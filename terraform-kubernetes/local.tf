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
