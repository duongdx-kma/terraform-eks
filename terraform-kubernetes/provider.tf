terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.31.0"
    }

    # required helm provider
    helm = {
      source = "hashicorp/helm"
      # version = "2.14.1"
      version = "~> 2.14"
    }


    # required http provider
    http = {
      source = "hashicorp/http"
      # version = "3.4.4"
      version = "~> 3.4"
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


# Helm Provider:

# Method 1:
# provider "helm" {
#   kubernetes {
#     config_path = "~/.kube/config"
#   }

#   # localhost registry with password protection
#   registry {
#     url = "oci://localhost:5000"
#     username = "username"
#     password = "password"
#   }

#   # private registry
#   registry {
#     url = "oci://private.registry"
#     username = "username"
#     password = "password"
#   }
# }

# Method 2:
# provider "helm" {
#   kubernetes {
#     host     = "https://cluster_endpoint:port"

#     client_certificate     = file("~/.kube/client-cert.pem")
#     client_key             = file("~/.kube/client-key.pem")
#     cluster_ca_certificate = file("~/.kube/cluster-ca-cert.pem")
#   }
# }

# Method 3:
provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.eks.outputs.cluster_id]
      command     = "aws"
    }
  }
}

provider "http" {
  # Configuration options
}
