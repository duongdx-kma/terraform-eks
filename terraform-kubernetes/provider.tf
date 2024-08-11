terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.31.0"
    }
  }

  backend "s3" {
    bucket = "duongdx-terraform-state"
    key    = "eks-cluster/terraform-kubernetes/terraform.tfstate"
    region = "ap-southeast-1"

    # DynamoDB for state locking
    # dynamodb_table = "terraform-kubernetes"
  }
}
# Provider Block
provider "aws" {
  region  = var.aws_region
  profile = "default"
}

data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_id
}

# provider "kubernetes" {
#   config_path    = "~/.kube/config"
#   config_context = "my-context"
# }

provider "kubernetes" {
  host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
