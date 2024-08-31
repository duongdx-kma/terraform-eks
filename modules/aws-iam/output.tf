# EKS Cluster IAM Role
output "eks_cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster."
  value       = aws_iam_role.eks_cluster_role.name
}

output "eks_cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster."
  value       = aws_iam_role.eks_cluster_role.arn
}

# EKS NodeGroup IAM Role
output "eks_node_group_role_arn" {
  description = "The ARN of eks node group"
  value       = aws_iam_role.eks_node_group_role.arn
}

output "eks_node_group_role_name" {
  description = "The Name of eks node group"
  value       = aws_iam_role.eks_node_group_role.name
}
