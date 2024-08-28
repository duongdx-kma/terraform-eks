resource "aws_iam_policy" "eks_ebs_csi_iam_policy" {
  name        = "eks_ebs_csi_policy"
  path        = "/"
  description = "EBS CSI IAM Policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = data.http.ebs_csi_iam_policy_content.response_body
}

output "ebs_csi_iam_policy_arn" {
  value = aws_iam_policy.eks_ebs_csi_iam_policy.arn
}
