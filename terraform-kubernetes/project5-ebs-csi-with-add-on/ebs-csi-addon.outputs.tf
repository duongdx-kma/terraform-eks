# EKS AddOn - EBS CSI Driver Outputs
output "ebs_csi_driver_addon_arn" {
  description = "EKS AddOn - EBS CSI Driver ARN"
  value = aws_eks_addon.ebs_csi_driver_addon.arn
}

output "ebs_csi_driver_addon_id" {
  description = "EKS AddOn - EBS CSI Driver ID"
  value = aws_eks_addon.ebs_csi_driver_addon.id
}