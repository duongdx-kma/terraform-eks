resource "aws_iam_policy" "eks_lbc_iam_policy" {
  name        = "eks_lbc_policy"
  path        = "/"
  description = "EKS Load Balancer IAM Policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = data.http.lbc_iam_policy.response_body
}

output "lbc_iam_policy_arn" {
  value = aws_iam_policy.eks_lbc_iam_policy.arn
}
