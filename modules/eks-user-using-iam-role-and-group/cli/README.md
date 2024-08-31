# EKS Admins with IAM Roles

## I. Structure

### 1. EKS admin
![alt text](images/eks-admin.png)

### 2. EKS Readonly

![alt text](images/eks-readonly.png)


## II. Demonstrate

### Step-01: Introduction
1. Create IAM Role with inline policy with EKS Full access.
2. Also Add Trust relationships policy in the same IAM Role
3. Create IAM Group with inline IAM Policy with `sts:AssumeRole`
4. Create IAM Group and associate the IAM Group policy
5. Create IAM User and associate to IAM Group
6. Test EKS Cluster access using credentials generated using `aws sts assume-role` and `kubectl`
7. Test EKS Cluster Dashboard access using `AWS Switch Role` concept via AWS Management Console


### Step-02: Pre-requisite: Create EKS Cluster
- We are going to create the the EKS Cluster as part of this Section

```powershell
# Terraform Initialize
terraform init

# List Terraform Resources (if already EKS Cluster created as part of previous section we can see those resources)
terraform state list

# Else Run below Terraform Commands
terraform validate
terraform plan
terraform apply -auto-approve

# Configure kubeconfig for kubectl
aws eks --region <region-code> update-kubeconfig --name <cluster_name>
aws eks --region ap-southeast-1 update-kubeconfig --name study-dev-eks-cluster

# Verify Kubernetes Worker Nodes using kubectl
kubectl get nodes
kubectl get nodes -o wide
```

### Step-03: Create IAM Role, IAM Trust Policy and IAM Policy
```powershell
# Verify User (Ensure you are using AWS Admin)
aws sts get-caller-identity

# Export AWS Account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
echo $ACCOUNT_ID

# IAM Trust Policy 
POLICY=$(echo -n '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"AWS":"arn:aws:iam::'; echo -n "$ACCOUNT_ID"; echo -n ':root"},"Action":"sts:AssumeRole","Condition":{}}]}')

# Verify both values
echo ACCOUNT_ID=$ACCOUNT_ID
echo POLICY=$POLICY

# Create IAM Role
aws iam create-role \
  --role-name eks-admin-role \
  --description "Kubernetes administrator role (for AWS IAM Authenticator for Kubernetes)." \
  --assume-role-policy-document "$POLICY" \
  --output text \
  --query 'Role.Arn'

# Create IAM Policy - EKS Full access
cd iam-files
aws iam put-role-policy --role-name eks-admin-role --policy-name eks-full-access-policy --policy-document file://eks-full-access-policy.json
```

### Step-04: Create IAM User Group named eksadmins
```powershell
# Create IAM User Groups
aws iam create-group --group-name eksadmins
```

### Step-05: Add Group Policy to eksadmins Group
- Let’s add a Policy on our group which will allow users from this group to assume our kubernetes admin Role:
```powershell
# Verify AWS ACCOUNT_ID is set
echo $ACCOUNT_ID

# IAM Group Policy
ADMIN_GROUP_POLICY=$(echo -n '{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowAssumeOrganizationAccountRole",
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": "arn:aws:iam::'; echo -n "$ACCOUNT_ID"; echo -n ':role/eks-admin-role"
    }
  ]
}')

# Verify Policy (if AWS Account Id replaced in policy)
echo $ADMIN_GROUP_POLICY

# Create Policy
aws iam put-group-policy \
--group-name eksadmins \
--policy-name eksadmins-group-policy \
--policy-document "$ADMIN_GROUP_POLICY"
```

### Step-06: Gives Access to our IAM Roles in EKS Cluster
```powershell
# Verify aws-auth configmap before making changes
kubectl -n kube-system get configmap aws-auth -o yaml

# Edit aws-auth configmap
kubectl -n kube-system edit configmap aws-auth

# ADD THIS in data -> mapRoles section of your aws-auth configmap
# Replace ACCOUNT_ID and EKS-ADMIN-ROLE
    - rolearn: arn:aws:iam::<ACCOUNT_ID>:role/<EKS-ADMIN-ROLE>
      username: eks-admin
      groups:
        - system:masters

# When replaced with Account ID and IAM Role Name
  mapRoles: |
    - rolearn: arn:aws:iam::180789647333:role/hr-dev-eks-nodegroup-role
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
    - rolearn: arn:aws:iam::180789647333:role/eks-admin-role
      username: eks-admin
      groups:
        - system:masters
 
# Verify aws-auth configmap after making changes
kubectl -n kube-system get configmap aws-auth -o yaml
```

#### Sample Output
```yaml
apiVersion: v1
data:
  mapRoles: |
    - groups:
      - system:bootstrappers
      - system:nodes
      rolearn: arn:aws:iam::180789647333:role/hr-dev-eks-nodegroup-role
      username: system:node:{{EC2PrivateDNSName}}
    - rolearn: arn:aws:iam::180789647333:role/eks-admin-role
      username: eks-admin
      groups:
        - system:masters
kind: ConfigMap
metadata:
  creationTimestamp: "2022-03-12T05:33:28Z"
  name: aws-auth
  namespace: kube-system
  resourceVersion: "1336"
  uid: f8174f23-554a-43e0-b47a-5eba338605ea
```


### Step-07: Create IAM User and Associate to IAM Group
```powershell   
# Create IAM User
aws iam create-user --user-name eksadmin1

# Associate IAM User to IAM Group  eksadmins
aws iam add-user-to-group --group-name <GROUP> --user-name <USER>
aws iam add-user-to-group --group-name eksadmins --user-name eksadmin1

# Set password for eksadmin1 user
aws iam create-login-profile --user-name eksadmin1 --password @EKSUser101 --no-password-reset-required

# Create Security Credentials for IAM User and make a note of them
aws iam create-access-key --user-name eksadmin1

# Sample Output
{
    "AccessKey": {
        "UserName": "eksadmin1",
        "AccessKeyId": "12345678",
        "Status": "Active",
        "SecretAccessKey": "12345678",
        "CreateDate": "2022-03-12T05:37:39+00:00"
    }
}
```

### Step-08: Configure eksadmin1 user AWS CLI Profile and Set it as Default Profile
```powershell
# To list all configuration data
aws configure list

# To list all your profile names
aws configure list-profiles

# Configure aws cli eksadmin1 Profile 
aws configure --profile eksadmin1
AWS Access Key ID: 12345678
AWS Secret Access Key: 12345678
Default region: us-east-1
Default output format: json

# Get current user configured in AWS CLI
aws sts get-caller-identity
Observation: Should see the user "kalyandev" (EKS_Cluster_Create_User) from default profile

# Set default profile
export AWS_DEFAULT_PROFILE=eksadmin1

# Get current user configured in AWS CLI
aws sts get-caller-identity
Observation: Should the user "eksadmin1" from eksadmin1 profile, refer below sample output

## Sample Output
aws sts get-caller-identity

#
# {
#     "UserId": "AIDASUF7HC7SQWWZGSGY7",
#     "Account": "180789647333",
#     "Arn": "arn:aws:iam::180789647333:user/eksadmin1"
# }

# Clean-Up kubeconfig
>$HOME/.kube/config
cat $HOME/.kube/config

# Configure kubeconfig for kubectl
aws eks --region <region-code> update-kubeconfig --name <cluster_name>
aws eks --region ap-southeast-1 update-kubeconfig --name study-dev-eks-cluster
Observation: Should fail
```


### Step-09: Assume IAM Role and Configure kubectl
```powershell
# Export AWS Account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
echo $ACCOUNT_ID

# Assume IAM Role
aws sts assume-role --role-arn "arn:aws:iam::<REPLACE-YOUR-ACCOUNT-ID>:role/eks-admin-role" --role-session-name eksadminsession01
aws sts assume-role --role-arn "arn:aws:iam::$ACCOUNT_ID:role/eks-admin-role" --role-session-name eksadminsession101

# GET Values and replace here
export AWS_ACCESS_KEY_ID=RoleAccessKeyID
export AWS_SECRET_ACCESS_KEY=RoleSecretAccessKey
export AWS_SESSION_TOKEN=RoleSessionToken

# Verify current user configured in aws cli
aws sts get-caller-identity

# result
{
    "UserId": "AROASUF7HC7S7PCTLZCTE:eksadminsession101",
    "Account": "180789647333",
    "Arn": "arn:aws:sts::180789647333:assumed-role/eks-admin-role/eksadminsession101"
}

# Clean-Up kubeconfig
>$HOME/.kube/config
cat $HOME/.kube/config

# Configure kubeconfig for kubectl
aws eks --region <region-code> update-kubeconfig --name <cluster_name>
aws eks --region ap-southeast-1 update-kubeconfig --name study-dev-eks-cluster
# Describe Cluster
aws eks --region ap-southeast-1 update-kubeconfig --name study-dev-eks-cluster --query cluster.status

# List Kubernetes Nodes
kubectl get nodes
kubectl get pods -n kube-system

# To return to the IAM user, remove the environment variables:
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN

# Verify current user configured in aws cli
aws sts get-caller-identity
Observation: It should switch back to current AWS_DEFAULT_PROFILE eksadmin1

## Sample Output
{
    "UserId": "AIDASUF7HC7SQWWZGSGY7",
    "Account": "180789647333",
    "Arn": "arn:aws:iam::180789647333:user/eksadmin1"
}
```

### Step-10: Login as eksadmin1 user AWS Mgmt Console and Switch Roles
- Login to AWS Mgmt Console
  - Username: eksadmin1
  - Password: @EKSUser101
- Go to EKS Servie: https://console.aws.amazon.com/eks/home?region=us-east-1#
```powershell
# Error
Error loading clusters
User: arn:aws:iam::180789647333:user/eksadmin1 is not authorized to perform: eks:ListClusters on resource: arn:aws:eks:us-east-1:180789647333:cluster/*
```  
- Click on **Switch Role**
  - **Account:** <YOUR_AWS_ACCOUNT_ID> 
  - **Role:** eks-admin-role
  - **Display Name:** eksadmin-session101
  - **Select Color:** any color
- Access EKS Cluster -> study-dev-eks-cluster
  - Overview Tab
  - Workloads Tab
  - Configuration Tab  
- All should be accessible without any issues.

### Step-11: Clean-Up IAM Roles, users and Groups
```powershell
# Get current user configured in AWS CLI
aws sts get-caller-identity
Observation: Should the user "eksadmin1" from eksadmin1 profile

# Set default profile
export AWS_DEFAULT_PROFILE=default

# Get current user configured in AWS CLI
aws sts get-caller-identity
Observation: Should see the user "kalyandev" (EKS_Cluster_Create_User) from default profile

# Delete IAM Role Policy and IAM Role 
aws iam delete-role-policy --role-name eks-admin-role --policy-name eks-full-access-policy
aws iam delete-role --role-name eks-admin-role

# Remove IAM User from IAM Group
aws iam remove-user-from-group --user-name eksadmin1 --group-name eksadmins

# Delete IAM User Login profile
aws iam delete-login-profile --user-name eksadmin1

# Delete IAM Access Keys
aws iam list-access-keys --user-name eksadmin1
aws iam delete-access-key --access-key-id <REPLACE AccessKeyId> --user-name eksadmin1
aws iam delete-access-key --access-key-id 12345678 --user-name eksadmin1

# Delete IAM user
aws iam delete-user --user-name eksadmin1

# Delete IAM Group Policy
aws iam delete-group-policy --group-name eksadmins --policy-name eksadmins-group-policy

# Delete IAM Group
aws iam delete-group --group-name eksadmins
```

### Step-12: Cleanup - EKS Cluster
```powershell
# Get current user configured in AWS CLI
aws sts get-caller-identity
Observation: Should see the user "kalyandev" (EKS_Cluster_Create_User) from default profile

# Terraform Destroy
terraform apply -destroy -auto-approve
rm -rf .terraform*
```
 
## Step-14: Clean-up AWS CLI Profiles
```powershell
# Clean-up AWS Credentials File
vi /Users/kalyanreddy/.aws/credentials
Remove eksadmin1 creds

# Clean-Up AWS Config File
vi /Users/kalyanreddy/.aws/config 
Remove eksadmin1 profiles

# List Profiles - AWS CLI
aws configure list-profiles
```