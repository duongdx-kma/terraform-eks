# Install `aws-ebs-csi-driver` using `HELM`

### Step 1. Add helm repository
```
helm repo add  aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
```
### Step 2. Check chart
```
helm search repo aws-ebs-csi-driver

# result:

NAME                                 	CHART VERSION	APP VERSION	DESCRIPTION
aws-ebs-csi-driver/aws-ebs-csi-driver	2.33.0       	1.33.0     	A Helm chart for AWS EBS CSI Driver
```

### Step 3. install `aws-ebs-csi-driver` on namespace `kube-system`
```
helm install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver --namespace kube-system --values project-3-ebs-csi/helm/values.yml
```

### Step 4. checking `aws-ebs-csi-driver`

```
# Describe EBS CSI Deployment
kubectl -n kube-system get deploy
kubectl -n kube-system describe deploy ebs-csi-controller
kubectl get pod -n kube-system

Observation: ebs-csi-controller Deployment 
1. ebs-csi-controller deployment creates a pod which is a multi-container pod
2. Rarely we get in Kubernetes to explore Multi-Container pod concept, so lets explore it here.
3. Each "ebs-csi-controller", contains following containers
  - ebs-plugin
  - csi-provisioner
  - csi-attacher
  - csi-resizer
  - liveness-probe
```

### Step 5. Verify Container Logs in EBS CSI Controller Pod

```
# Verify EBS CSI Controller Pod logs
kubectl -n kube-system get pods
kubectl -n kube-system logs -f ebs-csi-controller-56dfd4fccc-7fgbr

# Error we got when checking EBS CSI Controller pod logs
Kalyans-MacBook-Pro:02-ebs-terraform-manifests kdaida$ kubectl -n kube-system logs -f ebs-csi-controller-56dfd4fccc-7fgbr
error: a container name must be specified for pod ebs-csi-controller-56dfd4fccc-7fgbr, choose one of: [ebs-plugin csi-provisioner csi-attacher csi-resizer liveness-probe]
Kalyans-MacBook-Pro:02-ebs-terraform-manifests kdaida$ 

# Verify logs of liveness-probe container in EBS CSI Controller Pod
kubectl -n <NAMESPACE> logs -f <POD-NAME> <CONTAINER-NAME>
kubectl -n kube-system logs -f liveness-probe 

# Verify logs of ebs-plugin container in EBS CSI Controller Pod
kubectl -n <NAMESPACE> logs -f <POD-NAME> <CONTAINER-NAME>
kubectl -n kube-system logs -f ebs-csi-controller-56dfd4fccc-7fgbr ebs-plugin 

# Verify logs of csi-provisioner container in EBS CSI Controller Pod
kubectl -n <NAMESPACE> logs -f <POD-NAME> <CONTAINER-NAME>
kubectl -n kube-system logs -f ebs-csi-controller-56dfd4fccc-7fgbr csi-provisioner 

# Verify logs of csi-attacher container in EBS CSI Controller Pod
kubectl -n <NAMESPACE> logs -f <POD-NAME> <CONTAINER-NAME>
kubectl -n kube-system logs -f ebs-csi-controller-56dfd4fccc-7fgbr csi-attacher 

# Verify logs of csi-resizer container in EBS CSI Controller Pod
kubectl -n <NAMESPACE> logs -f <POD-NAME> <CONTAINER-NAME>
kubectl -n kube-system logs -f ebs-csi-controller-56dfd4fccc-7fgbr csi-resizer
```

### Step 6. Verify EBS CSI Node Daemonset and Pods
```
# Verify EBS CSI Node Daemonset
kubectl -n kube-system get daemonset
kubectl -n kube-system get ds
kubectl -n kube-system get pods 
Observation: 
1. We should know that, daemonset means it creates one pod per worker node in a worker node group
2. In our case, we have only 1 node in Worker Node group, it created only 1 pod named "ebs-csi-node-qp426"

# Descrine EBS CSI Node Daemonset (It also a multi-container pod)
kubectl -n kube-system describe ds ebs-csi-node
Observation:
1. We should the following containers listed in this daemonset
 - ebs-plugin 
 - node-driver-registrar 
 - liveness-probe

# Verify EBS CSI Node pods
kubectl -n kube-system get pods 
kubectl -n kube-system describe pod ebs-csi-node-qp426  
Observation:
1. Verify pod events, we can see multiple containers pulled and started in EBS CSI Node pod
```

### Step 7: Verify EBS CSI Kubernetes Service Accounts
```
# List EBS CSI  Kubernetes Service Accounts
kubectl -n kube-system get sa 
Observation:
1. We should find two service accounts related to EBS CSI
  - ebs-csi-controller-sa
  - ebs-csi-node-sa

# Describe EBS CSI Controller Service Account
kubectl -n kube-system describe sa ebs-csi-controller-sa
Observation:
1. Verify the "Annotations" field and you should find our IAM Role created for EBS CSI is associated with EKS Cluster EBS Service Account.
Annotations:         eks.amazonaws.com/role-arn: arn:aws:iam::180789647333:role/hr-dev-ebs-csi-iam-role
2. Also review the labels
Labels:              app.kubernetes.io/component=csi-driver
                     app.kubernetes.io/instance=hr-dev-aws-ebs-csi-driver
                     app.kubernetes.io/managed-by=Helm
                     app.kubernetes.io/name=aws-ebs-csi-driver
                     app.kubernetes.io/version=1.5.0
                     helm.sh/chart=aws-ebs-csi-driver-2.6.2


# Describe EBS CSI Node Service Account
kubectl -n kube-system describe sa ebs-csi-node-sa
Observation: 
1. Observe the labels
Labels:              app.kubernetes.io/component=csi-driver
                     app.kubernetes.io/instance=hr-dev-aws-ebs-csi-driver
                     app.kubernetes.io/managed-by=Helm
                     app.kubernetes.io/name=aws-ebs-csi-driver
                     app.kubernetes.io/version=1.5.0
                     helm.sh/chart=aws-ebs-csi-driver-2.6.2
```

### Step 8: Uninstall `aws-ebs-csi-driver`
```
helm uninstall ebs-csi-driver-chart -n kube-system
```