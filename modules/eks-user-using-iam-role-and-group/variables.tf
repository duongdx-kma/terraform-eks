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

variable "eks_cluster_arn" {
  type        = string
  description = "The EKS cluster name"
}
