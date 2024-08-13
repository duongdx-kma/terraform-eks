

# Project 3: EBS CSI: EBS container storage interface
output "ebs_csi_helm_chart_release" {
  description = "The EBS CSI helm chart release"
  value = module.eks_ebs_csi.ebs_csi_helm_chart_release
}

output "ebs_csi_iam_policy_arn" {
  description = "The EBS CSI iam policy arn"
  value = module.eks_ebs_csi.ebs_csi_iam_policy_arn
}

output "ebs_csi_iam_role_arn" {
  description = "The EBS CSI iam role arn"
  value = module.eks_ebs_csi.ebs_csi_iam_role_arn
}

output "eks_ebs_csi_image" {
  value = module.eks_ebs_csi.eks_ebs_csi_image
}