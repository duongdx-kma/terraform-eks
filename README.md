---
title: EKS Cluster and Node Groups using Terraform
description: Create AWS EKS Cluster and Node Groups using Terraform
---

## Step-1: Execute Terraform Commands
```t
# Terraform Initialize
terraform init

# Terraform Validate
terraform validate

# Terraform plan
terraform plan

# Terraform Apply
terraform apply -auto-approve

# Verify Outputs on the CLI or using below command
terraform output
```

## Step-2: Verify the following Services using AWS Management Console
1. Go to Services -> Elastic Kubernetes Service -> Clusters
2. Verify the following
   - Overview
   - Workloads
   - Configuration
     - Details
     - Compute
     - Networking
     - Add-Ons
     - Authentication
     - Logging
     - Update history
     - Tags


## Step-3: Install kubectl CLI
- [Install kubectl CLI](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html)

## Step-4: Configure kubeconfig for kubectl
```t
# Configure kubeconfig for kubectl
aws eks --region <region-code> update-kubeconfig --name <cluster_name>
aws eks --region us-east-1 update-kubeconfig --name hr-stag-eksdemo1

# List Worker Nodes
kubectl get nodes
kubectl get nodes -o wide

# Verify Services
kubectl get svc
```

## Step-5: Connect to EKS Worker Nodes using Bastion Host
```t
# Connect to Bastion EC2 Instance
ssh -i private-key/eks-terraform-key.pem ec2-user@<Bastion-EC2-Instance-Public-IP>
cd /tmp

# Connect to Kubernetes Worker Nodes - Public Node Group
ssh -i private-key/eks-terraform-key.pem ec2-user@<Public-NodeGroup-EC2Instance-PublicIP>
[or]
ec2-user@<Public-NodeGroup-EC2Instance-PrivateIP>

# Connect to Kubernetes Worker Nodes - Private Node Group from Bastion Host
ssh -i eks-terraform-key.pem ec2-user@<Private-NodeGroup-EC2Instance-PrivateIP>

##### REPEAT BELOW STEPS ON BOTH PUBLIC AND PRIVATE NODE GROUPS ####
# Verify if kubelet and kube-proxy running
ps -ef | grep kube

# Verify kubelet-config.json
cat /etc/kubernetes/kubelet/kubelet-config.json

# Verify kubelet kubeconfig
cat /var/lib/kubelet/kubeconfig

# Verify clusters.cluster.server value(EKS Cluster API Server Endpoint)  DNS resolution which is taken from kubeconfig
nslookup <EKS Cluster API Server Endpoint>
nslookup CF89341F3269FB40F03AAB19E695DBAD.gr7.us-east-1.eks.amazonaws.com
Very Important Note: Test this on Bastion Host, as EKS worker nodes doesnt have nslookup tool installed.
[or]
# Verify clusters.cluster.server value(EKS Cluster API Server Endpoint)   with wget
Try with wget on Node Group EC2 Instances (both public and private)
wget <Kubernetes API Server Endpoint>
wget https://0cbda14fd801e669f05c2444fb16d1b5.gr7.us-east-1.eks.amazonaws.com

## Sample Output
[ec2-user@ip-10-0-2-205 ~]$ wget https://0cbda14fd801e669f05c2444fb16d1b5.gr7.us-east-1.eks.amazonaws.com
--2021-12-30 08:40:50--  https://0cbda14fd801e669f05c2444fb16d1b5.gr7.us-east-1.eks.amazonaws.com/
Resolving 0cbda14fd801e669f05c2444fb16d1b5.gr7.us-east-1.eks.amazonaws.com (0cbda14fd801e669f05c2444fb16d1b5.gr7.us-east-1.eks.amazonaws.com)... 54.243.111.82, 34.197.138.103
Connecting to 0cbda14fd801e669f05c2444fb16d1b5.gr7.us-east-1.eks.amazonaws.com (0cbda14fd801e669f05c2444fb16d1b5.gr7.us-east-1.eks.amazonaws.com)|54.243.111.82|:443... connected.
ERROR: cannot verify 0cbda14fd801e669f05c2444fb16d1b5.gr7.us-east-1.eks.amazonaws.com's certificate, issued by ‘/CN=kubernetes’:
  Unable to locally verify the issuer's authority.
To connect to 0cbda14fd801e669f05c2444fb16d1b5.gr7.us-east-1.eks.amazonaws.com insecurely, use `--no-check-certificate'.
[ec2-user@ip-10-0-2-205 ~]$


# Verify Pod Infra Container for Kubelete
Example: --pod-infra-container-image=602401143452.dkr.ecr.us-east-1.amazonaws.com/eks/pause:3.1-eksbuild.1
Observation:
1. This Pod Infra container will be downloaded from AWS Elastic Container Registry ECR
2. All the EKS related system pods also will be downloaded from AWS ECR only
```

## Step-6: Verify Namespaces and Resources in Namespaces
```t
# Verify Namespaces
kubectl get namespaces
kubectl get ns
Observation: 4 namespaces will be listed by default
1. kube-node-lease
2. kube-public
3. default
4. kube-system

# Verify Resources in kube-node-lease namespace
kubectl get all -n kube-node-lease

# Verify Resources in kube-public namespace
kubectl get all -n kube-public

# Verify Resources in default namespace
kubectl get all -n default
Observation:
1. Kubernetes Service: Cluster IP Service for Kubernetes Endpoint

# Verify Resources in kube-system namespace
kubectl get all -n kube-system
Observation:
1. Kubernetes Deployment: coredns
2. Kubernetes DaemonSet: aws-node, kube-proxy
3. Kubernetes Service: kube-dns
4. Kubernetes Pods: coredns, aws-node, kube-proxy
```

## Step-7: Verify pods in kube-system namespace
```t
# Verify System pods in kube-system namespace
kubectl get pods # Nothing in default namespace
kubectl get pods -n kube-system
kubectl get pods -n kube-system -o wide

# Verify Daemon Sets in kube-system namespace
kubectl get ds -n kube-system
Observation: The below two daemonsets will be running
1. aws-node
2. kube-proxy

# Describe aws-node Daemon Set
kubectl describe ds aws-node -n kube-system
Observation:
1. Reference "Image" value it will be the ECR Registry URL

# Describe kube-proxy Daemon Set
kubectl describe ds kube-proxy -n kube-system
1. Reference "Image" value it will be the ECR Registry URL

# Describe coredns Deployment
kubectl describe deploy coredns -n kube-system
```

## Step-8: EKS Network Interfaces
- Discuss about EKS Network Interfaces

## Step-9: EKS Security Groups
- EKS Cluster Security Group
- EKS Node Security Group

## Step-10: Comment EKS Private Node Group TF Configs
- Currently we have 3 EC2 Instances running but ideally we don't need all 3 for our next 3 section (Section-09, 10 and 11), so we will do some cost cutting now.
- Over the process we will learn how to deprovision resources using Terraform for EKS Cluster
- In all the upcoming few demos we don't need to run both Public and Private Node Groups.
- This is created during Basic EKS Cluster to let you know that we can create EKS Node Groups in our desired subnet (Example: Private Subnets) provided if we have outbound connectivity via NAT Gateway to connect to EKS Cluster Control Plane API Server Endpoint.
- This adds additional cost for us.
- We will run only Public Node Group with 1 EC2 Instance as Worker Node
- We will comment Private Node Group related code
- **Change-1:** Comment all code in `c5-08-eks-node-group-private.tf`
```t
# Create AWS EKS Node Group - Private
/*
resource "aws_eks_node_group" "eks_ng_private" {
  cluster_name    = aws_eks_cluster.eks_cluster.name

  node_group_name = "${local.name}-eks-ng-private"
  node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
  subnet_ids      = module.vpc.private_subnets
  #version = var.cluster_version #(Optional: Defaults to EKS Cluster Kubernetes version)

  ami_type = "AL2_x86_64"  
  capacity_type = "ON_DEMAND"
  disk_size = 20
  instance_types = ["t3.medium"]


  remote_access {
    ec2_ssh_key = "eks-terraform-key"
  }

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 2
  }

  # Desired max percentage of unavailable worker nodes during node group update.
  update_config {
    max_unavailable = 1
    #max_unavailable_percentage = 50    # ANY ONE TO USE
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly,
  ]  
  tags = {
    Name = "Private-Node-Group"
  }
}

*/
```
- **Change-2:** Comment private node group related Terraform Outputs in `c5-02-eks-outputs.tf`
```t
# EKS Node Group Outputs - Private
/*
output "node_group_private_id" {
  description = "Node Group 1 ID"
  value       = aws_eks_node_group.eks_ng_private.id
}

output "node_group_private_arn" {
  description = "Private Node Group ARN"
  value       = aws_eks_node_group.eks_ng_private.arn
}

output "node_group_private_status" {
  description = "Private Node Group status"
  value       = aws_eks_node_group.eks_ng_private.status
}

output "node_group_private_version" {
  description = "Private Node Group Kubernetes Version"
  value       = aws_eks_node_group.eks_ng_private.version
}

*/
```

## Step-11: Execute Terraform Commands & verify
```t
# Terraform Validate
terraform validate

# Terraform Plan
terraform plan

# Terraform Apply
terraform apply -auto-approve

# Verify Kubernetes Worker Nodes
kubectl get nodes -o wide
Observation:
1. Should see only 1 EKS Worker Node running
```

## Step-12: Stop Bastion Host EC2 Instance
- Stop the Bastion VM to save cost
- We will start this VM only when we are in need.
- It will be provisioned when we create EKS Cluster but we will put it in stopped state unless we need it.
- This will save one EC2 Instance cost for us.
- Totally next three sections we will use only EC2 Instance in Public Node Group to run our demos.
```t
# Stop EC2 Instance (Bastion Host)
1. Login to AWS Mgmt Console
2. Go to Services -> EC2 -> Instances -> hr-stag-BastionHost -> Instance State -> Stop
```