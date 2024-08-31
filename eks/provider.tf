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

  # required_providers {
  #   kubernetes = {
  #     source  = "hashicorp/kubernetes"
  #     version = ">= 2.31.0"
  #   }
  # }
}

# Provider Block
provider "aws" {
  region  = var.aws_region
  profile = "default"
}


# Datasource:
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

# Terraform Kubernetes Provider
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
