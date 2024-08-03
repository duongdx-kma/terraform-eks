# VPC Variables
vpc_name                               = "myvpc"
vpc_create_database_subnet_group       = true
vpc_create_database_subnet_route_table = true
vpc_enable_nat_gateway                 = true
vpc_single_nat_gateway                 = true

public_subnet_tags = {
  Type = "Public Subnets"
}

private_subnet_tags = {
  Type = "Private Subnets"
}

database_subnet_tags = {
  Type = "Private Database Subnets"
}
