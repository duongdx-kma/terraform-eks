variable "eks_cluster_name" {
  description = "EKS cluster name or ID"
  type = string
}

# Output: AWS IAM Open ID Connect Provider ARN
variable "aws_iam_openid_connect_provider_arn" {
  description = "AWS IAM Open ID Connect Provider ARN"
  type = string
}

variable "aws_iam_openid_connect_provider_extract_from_arn" {
  description = "AWS IAM Open ID Connect Provider extract from ARN"
  type = string
}

variable eks_ebs_csi_namespace {
  description = "The EBS CSI (container storage interface) namespace"
  type = string
  default     = "kube-system"
}

variable eks_ebs_csi_service_account_name {
  description = "The EBS CSI (container storage interface) service account name"
  type = string
  default     = "ebs-csi-controller-sa"
}

