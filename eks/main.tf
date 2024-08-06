module "vpc" {
  source                                 = "../modules/vpc"
  vpc_name                               = "terraform-eks-${var.environment}"
  aws_region                             = var.aws_region
  environment                            = var.environment
  vpc_create_database_subnet_group       = true
  vpc_create_database_subnet_route_table = true
  vpc_enable_nat_gateway                 = false # set false for testing
  vpc_single_nat_gateway                 = true
  public_subnet_tags = {
    Type                                              = "Public Subnets"
    "kubernetes.io/role/elb"                          = 1
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"
  }

  private_subnet_tags = {
    Type                                              = "Private Subnets"
    "kubernetes.io/role/internal-elb"                 = 1
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"
  }
  database_subnet_tags = {
    Type = "Private Database Subnets"
  }
}

module "security-groups" {
  source = "../modules/security-groups"
  vpc_id = module.vpc.vpc_id
  bastion_host_ingress = [{
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "The ingress for ssh protocol"
    cidr_blocks = "0.0.0.0/0"
  }]

  tags = local.common_tags
}

# module "bastion" {
#   source                        = "./modules/bastion-host"
#   module_name                   = "bastion-host"
#   instance_name                 = "bastion-instance"
#   instance_type                 = "t2.micro"
#   path_to_public_key            = "keys/bastion-key.pem.pub"
#   path_to_private_key           = "keys/bastion-key.pem"
#   path_to_public_node_group_key = "keys/node-group.pem"
#   vpc_security_group_ids        = [module.security-groups.bastion_sg_id]
#   subnet_id                     = module.vpc.public_subnets[0]

#   tags = local.common_tags
# }

module "eks" {
  source                            = "../modules/eks-cluster"
  cluster_version                   = "1.30"
  cluster_name                      = local.eks_cluster_name
  node_group_vpc_public_subnet_ids  = module.vpc.public_subnets
  node_group_vpc_private_subnet_ids = module.vpc.private_subnets
  vpc_subnet_ids                    = module.vpc.public_subnets
  node_group_path_to_public_key     = "keys/node-group.pem.pub"

  public_node_group_scaling_config = {
    desired_size = 1
    min_size     = 1
    max_size     = 1
  }

  # private_node_group_scaling_config = {
  #   desired_size = 1
  #   min_size     = 1
  #   max_size     = 1
  # }

  tags = local.common_tags
}
