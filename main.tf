module "vpc" {
  source = "./modules/vpc"
  vpc_name = "terraform-eks-${var.environment}"
  aws_region = var.aws_region
  environment = var.environment
  vpc_create_database_subnet_group = true
  vpc_create_database_subnet_route_table = true
  vpc_enable_nat_gateway = false # set false for testing
  vpc_single_nat_gateway = true
}
