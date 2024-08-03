# Input Variables
# AWS Region
variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type        = string
}

# Environment Variable
variable "environment" {
  description = "Environment Variable used as a prefix"
  type        = string
  default     = "dev"
}

variable "vpc_name" {
  description = "The VPC name"
  type        = string
}

variable "vpc_create_database_subnet_group" {
  type    = bool
  default = true
}

variable "vpc_create_database_subnet_route_table" {
  type    = bool
  default = true
}

variable "vpc_enable_nat_gateway" {
  type    = bool
  default = true
}

variable "vpc_single_nat_gateway" {
  type    = bool
  default = true
}


variable "public_subnet_tags" {
  type = map(any)
  default = {
    Type = "Public Subnets"
  }
}

variable "private_subnet_tags" {
  type = map(any)
  default = {
    Type = "Private Subnets"
  }
}
variable "database_subnet_tags" {
  type = map(any)
  default = {
    Type = "Private Database Subnets"
  }
}
