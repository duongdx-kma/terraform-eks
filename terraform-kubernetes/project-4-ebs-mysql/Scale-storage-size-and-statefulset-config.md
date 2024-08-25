
# Scaling Storage Size and edit `mysql-statefulset` configuration

### step 0: check configuration in `statefulset`
```yaml
persistentVolumeClaimRetentionPolicy:
    whenScaled: Retain
    whenDeleted: Retain
```

### step 1: check data `after` resize
```powershell
# Connect to mysql-0 MySQL Database
k exec -it mysql-0 -- /bin/bash -c 'mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -e "select * from webappdb.users"'

# Result:
# Defaulted container "mysql" out of: mysql, xtrabackup, init-script (init), init-mysql (init), clone-mysql (init)
# mysql: [Warning] Using a password on the command line interface can be insecure.
# +----+----------+--------------------+
# | id | name     | email              |
# +----+----------+--------------------+
# |  1 | duongdx  | duongdx@gmail.com  |
# |  2 | duongdx2 | duongdx2@gmail.com |
# +----+----------+--------------------+

# Connect to mysql-1 MySQL Database
k exec -it mysql-1 -- /bin/bash -c 'mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -e "select * from webappdb.users"'

# Result:
# Defaulted container "mysql" out of: mysql, xtrabackup, init-script (init), init-mysql (init), clone-mysql (init)
# mysql: [Warning] Using a password on the command line interface can be insecure.
# +----+----------+--------------------+
# | id | name     | email              |
# +----+----------+--------------------+
# |  1 | duongdx  | duongdx@gmail.com  |
# |  2 | duongdx2 | duongdx2@gmail.com |
# +----+----------+--------------------+

# PVC after resize
k get pvc

# NAME                 STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS            VOLUMEATTRIBUTESCLASS   AGE
# mysql-data-mysql-0   Bound    pvc-f81f12c3-0ec5-40b6-82f6-5f592c7a24a1   2Gi        RWO            ebs-gp3-storage-class   <unset>                 9m
# mysql-data-mysql-1   Bound    pvc-f8dda0df-80e7-4f44-85f7-aceabb030a69   2Gi        RWO            ebs-gp3-storage-class   <unset>                 9m
```

### step 2: Scale `old PVC - persistentVolumeClaim`
```powershell
# get all pvc with label
k get pvc -l app=mysql

# result:
# NAME                 STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS            VOLUMEATTRIBUTESCLASS   AGE
# mysql-data-mysql-0   Bound    pvc-231c3bd9-866d-4fca-8bf2-d28c1674807c   2Gi        RWO            ebs-gp3-storage-class   <unset>                 3m41s
# mysql-data-mysql-1   Bound    pvc-f39e9f55-4e54-4e78-818a-b48096a9cf35   2Gi        RWO            ebs-gp3-storage-class   <unset>                 3m41s

# update storage size
kubectl patch pvc mysql-data-mysql-0 --patch '{"spec":{"resources":{"requests":{"storage":"3Gi"}}}}'

kubectl patch pvc mysql-data-mysql-1 --patch '{"spec":{"resources":{"requests":{"storage":"3Gi"}}}}'
```

### step 3: check data `before` resize
```powershell

# Connect to mysql-0 MySQL Database
k exec -it mysql-0 -- /bin/bash -c 'mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -e "select * from webappdb.users"'

# Result:
# Defaulted container "mysql" out of: mysql, xtrabackup, init-script (init), init-mysql (init), clone-mysql (init)
# mysql: [Warning] Using a password on the command line interface can be insecure.
# +----+----------+--------------------+
# | id | name     | email              |
# +----+----------+--------------------+
# |  1 | duongdx  | duongdx@gmail.com  |
# |  2 | duongdx2 | duongdx2@gmail.com |
# +----+----------+--------------------+

# Connect to mysql-1 MySQL Database
k exec -it mysql-1 -- /bin/bash -c 'mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -e "select * from webappdb.users"'

# Result:
# Defaulted container "mysql" out of: mysql, xtrabackup, init-script (init), init-mysql (init), clone-mysql (init)
# mysql: [Warning] Using a password on the command line interface can be insecure.
# +----+----------+--------------------+
# | id | name     | email              |
# +----+----------+--------------------+
# |  1 | duongdx  | duongdx@gmail.com  |
# |  2 | duongdx2 | duongdx2@gmail.com |
# +----+----------+--------------------+


# PVC before resize
k get pvc

# NAME                 STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS            VOLUMEATTRIBUTESCLASS   AGE
# mysql-data-mysql-0   Bound    pvc-f81f12c3-0ec5-40b6-82f6-5f592c7a24a1   2Gi        RWO            ebs-gp3-storage-class   <unset>                 13m
# mysql-data-mysql-1   Bound    pvc-f8dda0df-80e7-4f44-85f7-aceabb030a69   2Gi        RWO            ebs-gp3-storage-class   <unset>                 13m
```

### step 4: update `statefulset` for future pod
```powershell
# check available statefulset
k get statefulset

# NAME    READY   AGE
# mysql   2/2     71m

# get old config
k get statefulset mysql -o yaml > new_mysql_statefulset.yml

# get old statefulset manifest file and change storage size: new_mysql_statefulset.yml
file: new_mysql_statefulset.yml ➜➜➜➜➜➜➜➜➜➜➜➜➜ storage: 2Gi -> storage: 3Gi
```

### step 5: ➜➜➜➜➜➜➜➜➜➜➜➜➜DELETE←←←←←←←←←←←←←←←←←← `old statefulset configuration`
```powershell

# delete old statefulset
kubectl delete statefulset mysql --cascade=orphan

# ➜➜➜➜➜➜➜➜➜➜➜➜➜➜➜➜➜➜➜➜➜➜➜➜MAGIC HERE: it don't delete the pod←←←←←←←←←←←←←←←←←←←←←←←←←←←
➜   k get statefulset
# No resources found in default namespace.

➜  k get pod
# NAME                           READY   STATUS    RESTARTS   AGE
# flask-webapp-75986db95-9hl8k   1/1     Running   0          135m
# mysql-0                        2/2     Running   0          49m
# mysql-1                        2/2     Running   0          15m
```

### step 6: Update new apply
```powershell
# command:
k apply -f new_mysql_statefulset.yml

# result:
# statefulset.apps/mysql created

# command:
k get statefulset

# # result:
# NAME    READY   AGE
# mysql   2/2     5s

k describe statefulset mysql
# Name:               mysql
# Namespace:          default
# CreationTimestamp:  Sun, 25 Aug 2024 14:37:10 +0700
# Selector:           app=mysql,app.kubernetes.io/name=mysql
# Labels:             app=mysql
#                     app.kubernetes.io/name=mysql
# Annotations:        <none>
# Replicas:           2 desired | 2 total
# Update Strategy:    RollingUpdate
#   Partition:        1
# Pods Status:        2 Running / 0 Waiting / 0 Succeeded / 0 Failed
# Pod Template:
#   Labels:       app=mysql
#                 app.kubernetes.io/name=mysql
#   Annotations:  kubectl.kubernetes.io/restartedAt: 2024-08-25T14:19:00+07:00
#   Init Containers:
#    init-script:
#     Image:      busybox:1.35
#     Port:       <none>
#     Host Port:  <none>
#     Command:
#       sh
#       -c
#       cp /mnt/scripts/*.sh /mnt/writable-scripts/ && chmod +x /mnt/writable-scripts/*.sh
#     Environment:  <none>
#     Mounts:
#       /mnt/scripts from container-init-volume (rw)
#       /mnt/writable-scripts from writable-scripts (rw)
#    init-mysql:
#     Image:      mysql:5.7
#     Port:       <none>
#     Host Port:  <none>
#     Command:
#       bash
#       -c
#       /mnt/writable-scripts/init-mysql.sh
#     Environment:  <none>
#     Mounts:
#       /mnt/conf.d from conf (rw)
#       /mnt/config-map from config-map (rw)
#       /mnt/writable-scripts from writable-scripts (rw)
#    clone-mysql:
#     Image:      gcr.io/google-samples/xtrabackup:1.0
#     Port:       <none>
#     Host Port:  <none>
#     Command:
#       bash
#       -c
#       /mnt/writable-scripts/clone-mysql.sh
#     Environment:  <none>
#     Mounts:
#       /etc/mysql/conf.d from conf (rw)
#       /mnt/writable-scripts from writable-scripts (rw)
#       /var/lib/mysql from mysql-data (rw,path="mysql")
#   Containers:
#    mysql:
#     Image:      mysql:5.7
#     Port:       3306/TCP
#     Host Port:  0/TCP
#     Limits:
#       cpu:     500m
#       memory:  1Gi
#     Requests:
#       cpu:      250m
#       memory:   500Mi
#     Liveness:   exec [/bin/sh -c mysqladmin ping -u root -p${MYSQL_ROOT_PASSWORD}] delay=30s timeout=5s period=10s #success=1 #failure=3
#     Readiness:  exec [/bin/sh -c mysql -h 127.0.0.1 -u root -p${MYSQL_ROOT_PASSWORD} -e 'SELECT 1'] delay=5s timeout=1s period=2s #success=1 #failure=3
#     Environment Variables from:
#       mysql-secret  Secret  Optional: false
#     Environment:    <none>
#     Mounts:
#       /docker-entrypoint-initdb.d from user-management-db-volume (rw)
#       /etc/mysql/conf.d from conf (rw)
#       /var/lib/mysql from mysql-data (rw,path="mysql")
#    xtrabackup:
#     Image:      gcr.io/google-samples/xtrabackup:1.0
#     Port:       3307/TCP
#     Host Port:  0/TCP
#     Command:
#       bash
#       -c
#       /mnt/writable-scripts/xtrabackup.sh
#     Limits:
#       cpu:     100m
#       memory:  100Mi
#     Requests:
#       cpu:     100m
#       memory:  100Mi
#     Environment Variables from:
#       mysql-secret  Secret  Optional: false
#     Environment:    <none>
#     Mounts:
#       /docker-entrypoint-initdb.d from user-management-db-volume (rw)
#       /etc/mysql/conf.d from conf (rw)
#       /mnt/writable-scripts from writable-scripts (rw)
#       /var/lib/mysql from mysql-data (rw,path="mysql")
#   Volumes:
#    conf:
#     Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
#     Medium:
#     SizeLimit:  <unset>
#    config-map:
#     Type:      ConfigMap (a volume populated by a ConfigMap)
#     Name:      mysql
#     Optional:  false
#    user-management-db-volume:
#     Type:      ConfigMap (a volume populated by a ConfigMap)
#     Name:      user-management-db-script
#     Optional:  false
#    container-init-volume:
#     Type:      ConfigMap (a volume populated by a ConfigMap)
#     Name:      container-init-config-map
#     Optional:  false
#    writable-scripts:
#     Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
#     Medium:     
#     SizeLimit:  <unset>
# Volume Claims:
#   Name:          mysql-data
#   StorageClass:  ebs-gp3-storage-class
#   Labels:        <none>
#   Annotations:   <none>
#   Capacity:      3Gi
#   Access Modes:  [ReadWriteOnce]
# Events:          <none>

```

### step 7: check scale out `mysql-statefulset`:
```powershell

# Scaling-out command:
k scale --replicas=3 statefulset/mysql


# check data of new pod
k exec -it mysql-2 -- /bin/bash -c 'mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -e "select * from webappdb.users"'

# Defaulted container "mysql" out of: mysql, xtrabackup, init-script (init), init-mysql (init), clone-mysql (init)
# mysql: [Warning] Using a password on the command line interface can be insecure.
# +----+-----------------+-----------------+
# | id | name            | email           |
# +----+-----------------+-----------------+
# |  1 | duong@gmail.com | duong@gmail.com |
# |  2 | 1               | duong@gmail.com |
# |  3 | 2               | duong@gmail.com |
# +----+-----------------+-----------------+

# check PVC
k get pvc

# mysql-data-mysql-0   Bound    pvc-231c3bd9-866d-4fca-8bf2-d28c1674807c   3Gi        RWO            ebs-gp3-storage-class   <unset>                 59m
# mysql-data-mysql-1   Bound    pvc-f39e9f55-4e54-4e78-818a-b48096a9cf35   3Gi        RWO            ebs-gp3-storage-class   <unset>                 59m
# mysql-data-mysql-2   Bound    pvc-a80d4021-088f-4e7e-86e0-c41cb6a6cb0f   3Gi        RWO            ebs-gp3-storage-class   <unset>                 12s
```
