terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  # Terraform backend as s3 for Remote State Storage
  backend "s3" {
    bucket = "duongdx-terraform-state"
    key    = "eks-cluster/dev/terraform.tfstate"
    region = "ap-southeast-1"

    # DynamoDB for state locking
    # dynamodb_table = "eks-cluster-dev"
  }
}

# Provider Block
provider "aws" {
  region  = var.aws_region
  profile = "default"
}
