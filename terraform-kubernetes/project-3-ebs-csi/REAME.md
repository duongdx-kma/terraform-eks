# Install `aws-ebs-csi-driver` using `Terraform helm provider`

### Step 1. Provision infrastructure:
```powershell
# Terraform Init
terraform init

# Terraform Validate
terraform validate

# Terraform Plan
terraform plan

# Terraform Apply (Ignore this if already EKS Cluster created in previous demo)
terraform apply -auto-approve

# List Terraform Resources 
terraform state list
```

### Step 2. checking `aws-ebs-csi-driver`

```powershell
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

### Step 3. Verify Container Logs in EBS CSI Controller Pod

```powershell
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

### Step 4. Verify EBS CSI Node Daemonset and Pods
```powershell
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

### Step 5: Verify EBS CSI Kubernetes Service Accounts
```powershell
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
