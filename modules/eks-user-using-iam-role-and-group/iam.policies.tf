# Resource: AWS IAM Group Policy
resource "aws_iam_policy" "eks_admins_iam_group_policy" {
  name        = "${var.eks_cluster_name}-eks-admins-iam-group-policy"
  description = "The policy allow roles, users and group assume role ${aws_iam_role.eks_admin_user_role.name}"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "sts:GetSessionToken",
          "sts:DecodeAuthorizationMessage",
          "sts:GetAccessKeyInfo",
          "sts:GetCallerIdentity",
          "sts:GetServiceBearerToken"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AssumeEksAdminRole",
        "Effect" : "Allow",
        "Action" : "sts:*",
        "Resource" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.eks_admin_user_role.name}"
      }
    ]
  })

  tags = {
    tag-key = "${var.module_name}-assume-eks-admin-policy"
  }
}

# IAM groups - policy attachment
resource "aws_iam_policy_attachment" "eks_admin_group_policy_attachment" {
  name       = "${var.eks_cluster_name}-eks-admins-iam-group-policy-attachment"
  policy_arn = aws_iam_policy.eks_admins_iam_group_policy.arn
  groups     = [aws_iam_group.eks_admins_iam_group.name]
}
