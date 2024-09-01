# Resource: AWS IAM EKS Admin Policy
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
        "Resource" : aws_iam_role.eks_admin_user_role.arn
      }
    ]
  })

  tags = {
    tag-key = "${var.module_name}-assume-eks-admin-policy"
  }
}

# IAM EKS Admin groups - policy attachment
resource "aws_iam_policy_attachment" "eks_admin_group_policy_attachment" {
  name       = "${var.eks_cluster_name}-eks-admins-iam-group-policy-attachment"
  policy_arn = aws_iam_policy.eks_admins_iam_group_policy.arn
  groups     = [aws_iam_group.eks_admins_iam_group.name]
}

# Resource: AWS IAM EKS ReadOnly Policy
resource "aws_iam_policy" "eks_readonly_iam_group_policy" {
  name        = "${var.eks_cluster_name}-eks-readonly-iam-group-policy"
  description = "The policy allow roles, users and group assume role ${aws_iam_role.eks_readonly_user_role.name}"
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
        "Sid" : "AssumeEksReadonlyRole",
        "Effect" : "Allow",
        "Action" : [
          "sts:AssumeRole"
        ],
        "Resource" : aws_iam_role.eks_readonly_user_role.arn
      }
    ]
  })

  tags = {
    tag-key = "${var.module_name}-assume-eks-readonly-policy"
  }
}

# IAM EKS ReadOnly groups - policy attachment
resource "aws_iam_policy_attachment" "eks_readonly_group_policy_attachment" {
  name       = "${var.eks_cluster_name}-eks-readonly-iam-group-policy-attachment"
  policy_arn = aws_iam_policy.eks_readonly_iam_group_policy.arn
  groups     = [aws_iam_group.eks_readonly_iam_group.name]
}
