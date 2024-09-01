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

variable eks_readonly_group_name {
  type = string
  description = "The EKS readonly group name (mine group)"
}

variable eks_develop_group_name {
  type = string
  description = "The EKS develop group name (mine group)"
}

variable develop_namespace {
  type = string
  description = "develop_namespace"
}
