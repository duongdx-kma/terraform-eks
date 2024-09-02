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

# EKS cluster
variable eks_cluster_id {
  description = "The ID of the EKS Cluster"
  type = string
}

variable "eks_vpc_id" {
  description = "The ID of the VPC"
  type = string
}

variable "aws_iam_openid_connect_provider_arn" {
  description = "AWS IAM Open ID Connect Provider ARN"
  type = string
}

variable "aws_iam_openid_connect_provider_extract_from_arn" {
  description = "AWS IAM Open ID Connect Provider extract from ARN"
  type = string
}

variable eks_lbc_namespace {
  description = "The AWS Load Balancer Controller namespace"
  type = string
  default     = "kube-system"
}

variable eks_lbc_service_account_name {
  description = "The AWS Load Balancer Controller service account name"
  type = string
  default     = "aws-load-balancer-controller-sa"
}

variable eks_addons_container_registry_endpoint {
  description = "Amazon container image registry for Amazon EKS add-ons"
  type = string
}
