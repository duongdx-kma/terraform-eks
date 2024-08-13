resource "helm_release" "ebs_csi_driver_chart" {
  name       = "ebs-csi-driver-chart"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  namespace  = var.eks_ebs_csi_namespace
  # version    = "2.33.0"  # If the version is left null, then Helm will use the latest version.

  # values = [
  #   "${file("values.yaml")}"
  # ]

  set {
    name  = "image.repository"
    value = "${var.eks_addons_container_registry_endpoint}/eks/aws-ebs-csi-driver"
    # Changes based on Region - This is for us-east-1 Additional Reference: https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html
  }

  set {
    name  = "controller.serviceAccount.create"
    value = "true"
  }

  set {
    name  = "controller.serviceAccount.name"
    value = var.eks_ebs_csi_service_account_name
  }

  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.ebs_csi_iam_role.arn
  }
}
