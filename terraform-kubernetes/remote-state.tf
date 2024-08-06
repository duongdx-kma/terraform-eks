# Terraform Remote State Data source
data "terraform_remote_state" "eks" {
  backend = "local"
  config = {
    path = "../eks/terraform.tfstate"
  }
}

# Get EKS Cluster Name Using TFRSD
# data.terraform_remote_state.eks.output.cluster_id
