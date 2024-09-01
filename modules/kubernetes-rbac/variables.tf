variable "module_name" {
  type        = string
  description = "The module name"
}

variable "tags" {
  type = map(any)
}

variable "aws_region" {
  type        = string
  description = "The AWS default region"
}

variable "eks_cluster_name" {
  type        = string
  description = "The EKS cluster name"
}

variable eks_readonly_group_name {
  type = string
  description = "The EKS readonly group name (mine group)"
}

variable eks_readonly_user_name {
  type = string
  description = "The EKS readonly user name (mine user)"
}
