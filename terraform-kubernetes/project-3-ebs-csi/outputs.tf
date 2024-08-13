output "ebs_csi_helm_chart_release" {
  description = "The EBS CSI helm chart release"
  value = helm_release.ebs_csi_driver_chart.metadata
}

output "eks_ebs_csi_image" {
  description = "Amazon container image registry for Amazon EKS add-ons"
  value = "${var.eks_addons_container_registry_endpoint}/eks/aws-ebs-csi-driver"
}