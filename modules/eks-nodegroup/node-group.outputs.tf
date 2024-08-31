# EKS Node Group Outputs - Public
output "node_group_public_id" {
  description = "Public Node Group ID"
  value       = aws_eks_node_group.eks_node_group_pubic.id
}

output "node_group_public_arn" {
  description = "Public Node Group ARN"
  value       = aws_eks_node_group.eks_node_group_pubic.arn
}

output "node_group_public_status" {
  description = "Public Node Group status"
  value       = aws_eks_node_group.eks_node_group_pubic.status
}

output "node_group_public_version" {
  description = "Public Node Group Kubernetes Version"
  value       = aws_eks_node_group.eks_node_group_pubic.version
}

# EKS Node Group Outputs - Private
# output "node_group_private_id" {
#   description = "Node Group 1 ID"
#   value       = aws_eks_node_group.eks_node_group_private.id
# }

# output "node_group_private_arn" {
#   description = "Private Node Group ARN"
#   value       = aws_eks_node_group.eks_node_group_private.arn
# }

# output "node_group_private_status" {
#   description = "Private Node Group status"
#   value       = aws_eks_node_group.eks_node_group_private.status
# }

# output "node_group_private_version" {
#   description = "Private Node Group Kubernetes Version"
#   value       = aws_eks_node_group.eks_node_group_private.version
# }
