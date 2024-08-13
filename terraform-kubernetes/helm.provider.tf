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