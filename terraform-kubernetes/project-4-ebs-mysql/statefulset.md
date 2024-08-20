# Mysql Statefulset structure

![alt text](images/structure.png)


## I. Configure Explanation

### 1. Init container: `init-mysql`
```
- Copies configuration from the Kubernetes-config-map to storage.
```

### 2. Init container: `clone-mysql`
```
- Clones the MySQL database from mysql-(index-1) (Exclude mysql-0).
```

### 3. Container: `mysql`
```
- Main container running MySQL.
```

### 4. container: `xtrabackup` running as sidecar container
```
xtrabackup responsible for:

# 1. primary pod (mysql-0)

- xtrabackup extract database from mysql-0 => save data to local

# 2. replica pod (mysql-1...n)
- extract data from database of mysql-(index-1) => save data to local
- compare diff and sync data with their database
```

### 5. Notes:
```
- The primary pod handles both reading and writing operations.

=> To reduce the workload on mysql-0 (the primary database), we clone data from mysql-(index-1) instead of mysql-0.

=> "The purpose is to reduce the workload of mysql-0 (primary database).

=> I want the standby servers to be utilized as much as possible
```

## II. Testing Command:

### 0. Update `kube-config`
```powershell
aws eks --region ap-southeast-1 update-kubeconfig --name study-dev-eks-cluster
```

### 1. Apply manifest
```powershell
# command:
k apply -f .

# Result:
storageclass.storage.k8s.io/ebs-gp2-storage-class created
configmap/user-management-db-script created
configmap/mysql created
secret/mysql-secret created
service/mysql-headless-service created
service/mysql created
statefulset.apps/mysql created
```
### 2. Check kubernetes resources:
```powershell
# command:
k get sts,pod,svc,pv,pvc

# Result:
AME                     READY   AGE
statefulset.apps/mysql   3/3     113s

NAME          READY   STATUS    RESTARTS      AGE
pod/mysql-0   2/2     Running   1 (69s ago)   113s
pod/mysql-1   2/2     Running   0             63s
pod/mysql-2   2/2     Running   0             41s

NAME                             TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
service/kubernetes               ClusterIP   172.20.0.1     <none>        443/TCP    53m
service/mysql                    ClusterIP   172.20.7.213   <none>        3306/TCP   113s
service/mysql-headless-service   ClusterIP   None           <none>        3306/TCP   114s

NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                  STORAGECLASS            VOLUMEATTRIBUTESCLASS   REASON   AGE
persistentvolume/pvc-6467287e-2702-4dc2-a208-8b2e322a1f1e   1Gi        RWO            Delete           Bound    default/data-mysql-0   ebs-gp2-storage-class   <unset>                          111s
persistentvolume/pvc-f983e533-7080-4e43-8e5a-a72366be6de1   1Gi        RWO            Delete           Bound    default/data-mysql-1   ebs-gp2-storage-class   <unset>                          60s
persistentvolume/pvc-fbccf929-54fc-4af9-a3ed-d3ff10bb2281   1Gi        RWO            Delete           Bound    default/data-mysql-2   ebs-gp2-storage-class   <unset>                          39s

NAME                                 STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS            VOLUMEATTRIBUTESCLASS   AGE
persistentvolumeclaim/data-mysql-0   Bound    pvc-6467287e-2702-4dc2-a208-8b2e322a1f1e   1Gi        RWO            ebs-gp2-storage-class   <unset>                 113s
persistentvolumeclaim/data-mysql-1   Bound    pvc-f983e533-7080-4e43-8e5a-a72366be6de1   1Gi        RWO            ebs-gp2-storage-class   <unset>                 63s
persistentvolumeclaim/data-mysql-2   Bound    pvc-fbccf929-54fc-4af9-a3ed-d3ff10bb2281   1Gi        RWO            ebs-gp2-storage-class   <unset>                 41s
```

### 3. check AWS EBS:

![alt text](images/aws-ebs.png)

### 4. Insert data into the `mysql-0` (primary mysql) database

You can send test queries to the primary MySQL server (hostname mysql-0.mysql) by running a temporary container with the mysql:5.7 image and running the mysql client binary.

```powershell

# command:
kubectl run mysql-client --image=mysql:5.7 -i --rm --restart=Never -- bash -c '
  mysql -h mysql-0.mysql -u root -pduongdx1 -e "
    CREATE DATABASE test;
    USE test;
    CREATE TABLE messages (message VARCHAR(250));
    INSERT INTO messages VALUES (\"hello\");
  "'

# pod "mysql-client" deleted
```

**Cloning existing data**

```
Watch what will happen now.


when a new Pod joins the set as a replica, it must assume the primary MySQL server might already have data on it.
The second init container, named clone-mysql, performs a clone operation on a replica Pod the first time 
it starts up on an empty PersistentVolume. That means it copies all existing data from another running Pod, 
so its local state is consistent enough to begin replicating from the primary server.
MySQL itself does not provide a mechanism to do this, 
so the example uses a popular open-source tool called `Percona XtraBackup`. 
During the clone, the source MySQL server might suffer reduced performance. 
To minimize impact on the primary MySQL server, the script instructs each Pod to clone from the Pod whose ordinal index is one lower.
This works because the StatefulSet controller always ensures Pod N is Ready before starting Pod N+1.
```

**Starting replication**
```
After the init containers complete successfully, the regular containers run. 
The MySQL Pods consist of a mysql container that runs the actual mysqld server, 
and an `xtrabackup` container that acts as a sidecar.
The `xtrabackup` sidecar looks at the cloned data files and determines if it's necessary to initialize MySQL replication on the replica. 
If so, it waits for mysqld to be ready and then executes commands with replication parameters extracted from the `XtraBackup` clone files.
Replicas look for the primary server at its stable DNS name (mysql-0.mysql), 
they automatically find the primary server even if it gets a new Pod IP due to being rescheduled.
```

### 5.  Query database using the exposed service for read-only 

```powershell
# command:
kubectl run mysql-client --image=mysql:5.7 -i -t --rm --restart=Never -- bash -c 'mysql -h mysql.default.svc.cluster.local -u root -pduongdx1 -e "
    SELECT * FROM test.messages
"'

# -h mysql: name of mysql service
# +---------+
# | message |
# +---------+
# | hello   |
# +---------+
# pod "mysql-client" deleted
```

To demonstrate that the mysql-read Service distributes connections across servers, you can run SELECT @@server_id in a loop:

```powershell

# command:
kubectl run mysql-client --image=mysql:5.7 -i -t --rm --restart=Never -- bash -c "
  while sleep 1; do mysql -h mysql.default.svc.cluster.local -u root -pduongdx1 -e 'SELECT @@server_id,NOW()'; done"
  
#   If you don't see a command prompt, try pressing enter.
# #   +-------------+---------------------+
# #   | @@server_id | NOW()               |
# #   +-------------+---------------------+
# #   |         102 | 2022-12-21 14:34:09 |
# #   +-------------+---------------------+
# #   +-------------+---------------------+
# #   | @@server_id | NOW()               |
# #   +-------------+---------------------+
# #   |         100 | 2022-12-21 14:34:10 |
# #   +-------------+---------------------+
# #   +-------------+---------------------+
# #   | @@server_id | NOW()               |
# #   +-------------+---------------------+
# #   |         101 | 2022-12-21 14:34:11 |
# #   +-------------+---------------------+
```

### 6. Scaling the number of replicas

When you use MySQL replication, you can scale your read query capacity by adding replicas. 
For a StatefulSet, you can achieve this with a single command:

```powershell

# command:
kubectl scale statefulset mysql --replicas=5

# statefulset.apps/mysql scaled

kubectl get pods -l app=mysql --watch
# NAME      READY   STATUS    RESTARTS   AGE
# mysql-0   2/2     Running   0          3h32m
# mysql-1   2/2     Running   0          3h31m
# mysql-2   2/2     Running   0          8m37s
# mysql-3   0/2     Pending   0          1s
# mysql-3   0/2     Pending   0          3s
# mysql-3   0/2     Init:0/2   0          3s
# mysql-3   0/2     Init:1/2   0          15s
# mysql-3   0/2     Init:1/2   0          16s
# mysql-3   0/2     PodInitializing   0          24s
# mysql-3   1/2     Running           0          25s
# mysql-3   2/2     Running           0          31s
# mysql-4   0/2     Pending           0          0s
# mysql-4   0/2     Pending           0          3s
# mysql-4   0/2     Init:0/2          0          3s
# mysql-4   0/2     Init:1/2          0          16s
# mysql-4   0/2     Init:1/2          0          17s
# mysql-4   0/2     PodInitializing   0          24s
# mysql-4   1/2     Running           0          25s
# mysql-4   2/2     Running           0          30s
```

### 7. Verify database is replicated into the new replicas

Verify that these new servers have the data you added before they existed:

```powershell
# command:
kubectl run mysql-client --image=mysql:5.7 -i -t --rm --restart=Never -- bash -c "
    mysql -h mysql-3.mysql.default.svc.cluster.local -u root -pduongdx1 -e 'SELECT * FROM test.messages'
"
# mysql: [Warning] Using a password on the command line interface can be insecure.
# +---------+
# | message |
# +---------+
# | hello   |
# +---------+
# pod "mysql-client" deleted
```

### 8. Scaling back down the StatefulSet
```powershell
# command:
kubectl scale statefulset mysql --replicas=3
```

Although scaling up creates new PersistentVolumeClaims automatically, scaling down does not automatically delete these PVCs.
This gives you the choice to keep those initialized PVCs around to make scaling back up quicker, or to extract data before deleting them.

```powershell
# command:
kubectl get pvc -l app=mysql

# result:
NAME           STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS            VOLUMEATTRIBUTESCLASS   AGE
data-mysql-0   Bound    pvc-6467287e-2702-4dc2-a208-8b2e322a1f1e   1Gi        RWO            ebs-gp2-storage-class   <unset>                 44m
data-mysql-1   Bound    pvc-f983e533-7080-4e43-8e5a-a72366be6de1   1Gi        RWO            ebs-gp2-storage-class   <unset>                 43m
data-mysql-2   Bound    pvc-fbccf929-54fc-4af9-a3ed-d3ff10bb2281   1Gi        RWO            ebs-gp2-storage-class   <unset>                 43m
data-mysql-3   Bound    pvc-59b1558d-4325-4ad8-b2a6-ac6d1af78f60   1Gi        RWO            ebs-gp2-storage-class   <unset>  
```


### 9. deleting the unneeded PVs

```powershell
# command:
kubectl delete pvc data-mysql-3

# command:
kubectl get pvc -l app=mysql

# result:
NAME           STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS            VOLUMEATTRIBUTESCLASS   AGE
data-mysql-0   Bound    pvc-6467287e-2702-4dc2-a208-8b2e322a1f1e   1Gi        RWO            ebs-gp2-storage-class   <unset>                 46m
data-mysql-1   Bound    pvc-f983e533-7080-4e43-8e5a-a72366be6de1   1Gi        RWO            ebs-gp2-storage-class   <unset>                 45m
data-mysql-2   Bound    pvc-fbccf929-54fc-4af9-a3ed-d3ff10bb2281   1Gi        RWO            ebs-gp2-storage-class   <unset> 
```