output "cluster_id" {
  description = "The name/id of the EKS cluster"
  value       = module.eks.cluster_id
}

output "cluster_arn" {
  description = "The arn of the EKS cluster"
  value       = module.eks.cluster_arn
}

output "cluster_certificate_authority_data" {
  description = "Nested attribute containing certificate-authority-data for your cluster. This is the base64 encoded certificate data required to communicate with your cluster."
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API."
  value       = module.eks.cluster_endpoint
}

output "cluster_version" {
  description = "The Kubernetes server version for the EKS cluster."
  value       = module.eks.cluster_version
}

output "cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster."
  value       = module.aws_iam.eks_cluster_iam_role_name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster."
  value       = module.aws_iam.eks_cluster_iam_role_arn
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = module.eks.cluster_oidc_issuer_url
}

output "cluster_primary_security_group_id" {
  description = "The cluster primary security group ID created by the EKS cluster on 1.14 or later. Referred to as 'Cluster security group' in the EKS console."
  value       = module.eks.cluster_primary_security_group_id
}

# EKS Node Group Outputs - Public
output "node_group_public_id" {
  description = "Public Node Group ID"
  value       = module.eks_nodegroup.node_group_public_id
}

output "node_group_public_arn" {
  description = "Public Node Group ARN"
  value       = module.eks_nodegroup.node_group_public_arn
}

output "node_group_public_status" {
  description = "Public Node Group status"
  value       = module.eks_nodegroup.node_group_public_status
}

output "node_group_public_version" {
  description = "Public Node Group Kubernetes Version"
  value       = module.eks_nodegroup.node_group_public_version
}

# EKS Node Group Outputs - Private
# output "node_group_private_id" {
#   description = "Node Group 1 ID"
#   value       = module.eks_nodegroup.node_group_private_id
# }

# output "node_group_private_arn" {
#   description = "Private Node Group ARN"
#   value       = module.eks_nodegroup.node_group_private_arn
# }

# output "node_group_private_status" {
#   description = "Private Node Group status"
#   value       = module.eks_nodegroup.node_group_private_status
# }

# output "node_group_private_version" {
#   description = "Private Node Group Kubernetes Version"
#   value       = module.eks_nodegroup.node_group_private_version
# }


output "aws_iam_openid_connect_provider_arn" {
  value = module.eks.aws_iam_openid_connect_provider_arn
}

# Output: AWS IAM Open ID Connect Provider
output "aws_iam_openid_connect_provider_extract_from_arn" {
  description = "AWS IAM Open ID Connect Provider extract from ARN"
  value       = module.eks.aws_iam_openid_connect_provider_extract_from_arn
}


# EKS admin user role:
output "eks_admin_user_role_arn" {
  description = "The ARN role for EKS admin user"
  value       = module.eks_multiple_user.eks_admin_user_role_arn
}

# EKS readonly user role:
output "eks_readonly_user_role_arn" {
  description = "The ARN role for EKS readonly user"
  value       = module.eks_multiple_user.eks_readonly_user_role_arn
}

# EKS develop user role:
output "eks_develop_user_role_arn" {
  description = "The ARN role for EKS develop user"
  value       = module.eks_multiple_user.eks_develop_user_role_arn
}

