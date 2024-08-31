# Data IAM role: trusted relation policy
data "aws_iam_policy_document" "eks_admin_user_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalType"
      values   = ["User"]
    }
  }
}

# Resource: IAM Role - EKS Admin Access
resource "aws_iam_role" "eks_admin_user_role" {
  name               = "${var.eks_cluster_name}-eks-admin-user-role"
  description        = "The role for EKS admin user"
  assume_role_policy = data.aws_iam_policy_document.eks_admin_user_assume_role.json

  tags = merge(
    {
      role = "Admin"
      permission = "All"
    },
    var.tags
  )
}
