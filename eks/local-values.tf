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

  eks_cluster_name = "${var.business_division}-${var.environment}-${var.cluster_name}"
}
