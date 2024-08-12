# Create the IAM Policy Document for the role's trust relationship
data "aws_iam_policy_document" "ebs_csi_assume_role" {
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
      values   = ["system:serviceaccount:${var.eks_ebs_csi_namespace}:${var.ebs_csi_service_account_name}"]
    }
  }
}

resource "aws_iam_role" "ebs_csi_role" {
  name               = "${var.module_name}-role"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume_role.json

  tags = merge(
    {
      tag-key = "${var.module_name}-ebs-csi-iam-role"
    },
    var.tags
  )
}

resource "aws_iam_role_policy_attachment" "ebs_csi_role_policy_attach" {
  role       = aws_iam_role.ebs_csi_role.name
  policy_arn = aws_iam_policy.eks_ebs_csi_policy.arn
}
