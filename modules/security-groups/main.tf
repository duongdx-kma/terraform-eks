locals {
  tags = {
    GithubRepo = "terraform-eks"
    GithubUser = "duongdx-kma"
  }
}

module "bastion_host_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "bastion_host_sg"
  description = "Security group for bastion host with SSH ports open within VPC"
  vpc_id      = var.vpc_id

  # Ingress rule and CIDR
  ingress_cidr_blocks = ["0.0.0.0/0"]


  # resource tags
  tags = local.tags
}
