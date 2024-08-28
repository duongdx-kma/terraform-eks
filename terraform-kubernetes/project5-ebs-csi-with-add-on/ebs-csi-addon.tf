# https://www.reddit.com/r/Terraform/comments/znomk4/ebs_csi_driver_entirely_from_terraform_on_aws_eks/
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon#example-add-on-usage-with-custom-configuration_values
resource "aws_eks_addon" "ebs_csi_driver_addon" {
  cluster_name = var.eks_cluster_name
  addon_name   = "aws-ebs-csi-driver"

  addon_version               = data.aws_eks_addon_version.this.version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  service_account_role_arn    = aws_iam_role.ebs_csi_iam_role.arn

  depends_on = [aws_iam_role_policy_attachment.ebs_csi_iam_role_policy_attach]
}
