# Create the IAM Policy Document for the role's trust relationship
data "aws_iam_policy_document" "irsa_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]

    principals {
      type        = "Federated"
      identifiers = [var.aws_iam_openid_connect_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.aws_iam_openid_connect_provider_extract_from_arn}:sub"
      values = ["system:serviceaccount:${var.eks_namespace}:${var.eks_service_account_name}"]
    }
  }
}

resource "aws_iam_role" "this" {
  name = "${var.module_name}-role"
  assume_role_policy = data.aws_iam_policy_document.irsa_assume_role.json
}

output "irsa_iam_role_arn" {
  description = "IRSA Demo IAM Role ARN"
  value = aws_iam_role.this.arn
}
