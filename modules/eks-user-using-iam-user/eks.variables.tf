variable "eks_node_group_role_name" {
  description = "the EKS node group role"
  type        = string
}

variable "eks_cluster_endpoint" {
  description = "The EKS endpoint"
  type        = string
}

variable "eks_cluster_id" {
  description = "The EKS cluster ID"
  type        = string
}

variable "eks_certificate_authority_data" {
  description = "The EKS authority data"
  type        = string
}
