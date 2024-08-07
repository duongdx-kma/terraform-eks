# # Terraform Remote State Data source
# data "terraform_remote_state" "eks" {
#   backend = "local"
#   config = {
#     path = "../eks/terraform.tfstate"
#   }
# }

# Terraform Remote State Datasource - Remote Backend AWS S3
data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "duongdx-terraform-state"
    key    = "eks-cluster/dev/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

# Get EKS Cluster Name Using TFRSD
# data.terraform_remote_state.eks.output.cluster_id
