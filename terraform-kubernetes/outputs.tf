
# Project 3: EBS CSI: EBS container storage interface
/**
output "ebs_csi_helm_chart_release" {
  description = "The EBS CSI helm chart release"
  value       = module.eks_ebs_csi.ebs_csi_helm_chart_release
}

output "ebs_csi_iam_policy_arn" {
  description = "The EBS CSI iam policy arn"
  value       = module.eks_ebs_csi.ebs_csi_iam_policy_arn
}

output "ebs_csi_iam_role_arn" {
  description = "The EBS CSI iam role arn"
  value       = module.eks_ebs_csi.ebs_csi_iam_role_arn
}

output "eks_ebs_csi_image" {
  value = module.eks_ebs_csi.eks_ebs_csi_image
}
*/

# Project 5: EBS CSI AddOn
output "ebs_csi_iam_policy_arn" {
  description = "The EBS CSI iam policy arn"
  value       = module.eks_ebs_csi_addon.ebs_csi_iam_policy_arn
}

output "ebs_csi_iam_role_arn" {
  description = "The EBS CSI iam role arn"
  value       = module.eks_ebs_csi_addon.ebs_csi_iam_role_arn
}

# EKS AddOn - EBS CSI Driver Outputs
output "ebs_csi_driver_addon_arn" {
  description = "EKS AddOn - EBS CSI Driver ARN"
  value       = module.eks_ebs_csi_addon.ebs_csi_driver_addon_arn
}

output "ebs_csi_driver_addon_id" {
  description = "EKS AddOn - EBS CSI Driver ID"
  value       = module.eks_ebs_csi_addon.ebs_csi_driver_addon_id
}

output "flask_webapp_service" {
  value = module.mysql_stateful_app.flask_webapp_service
}
