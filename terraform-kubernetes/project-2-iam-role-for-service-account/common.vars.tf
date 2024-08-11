variable "eks_namespace" {
  type        = string
  description = "The eks namespace for service account"
}

variable "eks_service_account_name" {
  type        = string
  description = "The service account name"
}

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