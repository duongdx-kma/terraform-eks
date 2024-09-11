locals {
  owners      = var.owner
  environment = var.environment

  name = "${var.business_division}-${var.environment}"
  common_tags = {
    owner       = local.owners
    environment = local.environment
    GithubRepo  = "terraform-eks"
    GithubUser  = "duongdx-kma"
  }
}

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

# module "eks_ebs_csi" {
#   source      = "./project-3-ebs-csi"
#   aws_region  = var.aws_region
#   module_name = "eks-ebs-csi"
#   tags        = local.common_tags

#   eks_ebs_csi_namespace                            = "kube-system"
#   eks_ebs_csi_service_account_name                 = "ebs-csi-controller-sa"
#   eks_addons_container_registry_endpoint           = var.aws_registry_for_eks_addons[var.aws_region]
#   aws_iam_openid_connect_provider_arn              = data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_arn
#   aws_iam_openid_connect_provider_extract_from_arn = data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_extract_from_arn
# }

module "eks_ebs_csi_addon" {
  source      = "./project-5-ebs-csi-with-add-on"
  aws_region  = var.aws_region
  module_name = "eks-ebs-csi-addon"
  tags        = local.common_tags

  eks_kubernetes_version                           = data.aws_eks_cluster.cluster.version
  eks_cluster_name                                 = data.aws_eks_cluster.cluster.name
  eks_ebs_csi_namespace                            = "kube-system"
  eks_ebs_csi_service_account_name                 = "ebs-csi-controller-sa"
  aws_iam_openid_connect_provider_arn              = data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_arn
  aws_iam_openid_connect_provider_extract_from_arn = data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_extract_from_arn
}

# module "mysql_stateful_app" {
#   source = "./project-4-ebs-mysql/eks-ebs-terraform"
#   # Mysql variable
#   mysql_database      = "webappdb"
#   mysql_root_password = "duongdx1"
#   mysql_password      = "duongdx1"
#   mysql_user          = "duongdx"

#   # Python variable to Mysql
#   write_db_user     = "duongdx"
#   write_db_password = "duongdx1"
#   read_db_user      = "duongdx"
#   read_db_password  = "duongdx1"

#   # Python variable
#   db_name                       = "webappdb"
#   db_port                       = 3306
#   app_port                      = 5000
#   app_env                       = var.environment
#   flask_enable_alb              = false
#   flask_enable_node_port        = false
#   flask_webapp_service_port     = 80
#   flask_webapp_public_node_port = 32100
# }

# module "ingress_for_application" {
#   source               = "./project-6-basic-ingress"
#   ingress_class_name   = "aws-load-balancer-ingress-class"
#   default_service_port = module.mysql_stateful_app.flask_webapp_service[0].service_port
#   default_service_name = module.mysql_stateful_app.flask_webapp_service[0].service_name
# }

# module "ingress_context_path_based_routing" {
#   source               = "./project-7-ingress-path-based-routing"
#   ingress_class_name   = "aws-load-balancer-ingress-class"
# }

# module "ingress_ssl_tls" {
#   source             = "./project-8-ingress-ssl-tls"
#   ingress_class_name = "aws-load-balancer-ingress-class"
#   route53_domain     = "duongdx.com"
#   route53_sub_domain = "web" # web.duongdx.com

#   tags = local.common_tags
# }

# Start: Project 9
# module "external_dns_and_ingress_ssl" {
#   source             = "./project-9-external-dns-and-ingress-ssl"
#   ingress_class_name = "aws-load-balancer-ingress-class"
#   route53_domain     = "duongdx.com"
#   ingress_domains = "web.duongdx.com, webapp.duongdx.com"

#   tags = local.common_tags
# }

# Outputs: external_dns_and_ingress_ssl
# output "acm_certificate_id" {
#   value = module.ingress_ssl_tls_and_external_dns.acm_certificate_id
# }

# output "acm_certificate_arn" {
#   value = module.ingress_ssl_tls_and_external_dns.acm_certificate_arn
# }

# output "acm_certificate_status" {
#   value = module.ingress_ssl_tls_and_external_dns.acm_certificate_status
# }
# End: Project 9


module "external_dns_and_k8s_service" {
  source             = "./project-10-external-dns-and-k8s-services-ssl"
  route53_domain     = "duongdx.com"

  tags = local.common_tags
}