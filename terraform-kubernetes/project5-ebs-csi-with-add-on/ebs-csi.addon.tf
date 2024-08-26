resource "aws_eks_addon" "ebs_csi_driver_addon" {
  cluster_name             = var.eks_cluster_name
  addon_name               = "ebs-csi-driver-addon"
  service_account_role_arn = aws_iam_role.ebs_csi_iam_role.arn

  depends_on = [ aws_iam_role_policy_attachment.ebs_csi_iam_role_policy_attach ]

  configuration_values = jsonencode({
    replicaCount = 4
    resources = {
      limits = {
        cpu    = "100m"
        memory = "150Mi"
      }
      requests = {
        cpu    = "100m"
        memory = "150Mi"
      }
    }
  })
}
