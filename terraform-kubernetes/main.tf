# module "project-1" {
#   source = "./project-1-webserver"
# }

# module "project-2" {
#   source                   = "./project-2-iam-role-for-service-account"
#   module_name              = "iam-role-for-sa"
#   eks_namespace            = "default"
#   eks_service_account_name = "s3-reader-sa"
#   aws_region               = var.aws_region

#   aws_iam_openid_connect_provider_arn              = data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_arn
#   aws_iam_openid_connect_provider_extract_from_arn = data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_extract_from_arn

#   tags = local.common_tags
# }

module "eks_ebs_csi" {
  source      = "./project-3-ebs-csi"
  aws_region  = var.aws_region
  module_name = "eks_ebs_csi"
  tags        = local.common_tags

  eks_ebs_csi_namespace                            = "kube-system"
  eks_ebs_csi_service_account_name                 = "ebs-csi-controller-sa"
  eks_addons_container_registry_endpoint           = var.aws_registry_for_eks_addons[var.aws_region]
  aws_iam_openid_connect_provider_arn              = data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_arn
  aws_iam_openid_connect_provider_extract_from_arn = data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_extract_from_arn
}
