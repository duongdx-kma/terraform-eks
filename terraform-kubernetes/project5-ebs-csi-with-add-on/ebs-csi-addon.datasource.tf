# Datasource: EBS CSI IAM Policy get from EBS GIT Repo (latest)
# This policy give necessary policies for create EBS resources
data "http" "ebs_csi_iam_policy_content" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-ebs-csi-driver/master/docs/example-iam-policy.json"

  # Optional request headers
  request_headers = {
    Accept = "application/json"
  }
}

data "aws_eks_addon_version" "this" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = var.eks_kubernetes_version
  most_recent        = true
}
