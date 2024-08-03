module "bastion_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "5.1.2"
  name        = "bastion_sg"
  description = "Security group for bastion host with SSH ports open within VPC"
  vpc_id      = var.vpc_id

  # Ingress rule and CIDR
  ingress_with_cidr_blocks = var.bastion_host_ingress

  # Egress rules
  egress_rules = ["all-all"]

  # resource tags
  tags = var.tags
}

module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"
  name        = "alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP from Internet"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS from Internet"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_rules = ["all-all"]
  tags = var.tags
}

module "webserver_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"

  name        = "webserver-sg"
  description = "Security group for webserver"
  vpc_id      = var.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 8080
      to_port                  = 8080
      protocol                 = "tcp"
      description              = "Allow port 8080 from ALB"
      source_security_group_id = module.alb_sg.security_group_id
    },
    {
      from_port                = 8443
      to_port                  = 8443
      protocol                 = "tcp"
      description              = "Allow port 8443 from ALB"
      source_security_group_id = module.alb_sg.security_group_id
    },
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      description              = "Allow SSH from bastion host"
      source_security_group_id = module.bastion_sg.security_group_id
    }
  ]

  egress_rules = ["all-all"]
  tags = var.tags
}

module "database_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"

  name        = "database-sg"
  description = "Security group for database"
  vpc_id      = var.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      description              = "Allow MySQL from webserver"
      source_security_group_id = module.webserver_sg.security_group_id
    },
    {
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      description              = "Allow MySQL from bastion host"
      source_security_group_id = module.bastion_sg.security_group_id
    },
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      description              = "Allow SSH from bastion host"
      source_security_group_id = module.bastion_sg.security_group_id
    }
  ]

  egress_rules = ["all-all"]
  tags = var.tags
}
