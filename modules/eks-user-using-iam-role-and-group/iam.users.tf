# Resource: AWS IAM User - Basic User (No AWSConsole Access)
resource "aws_iam_user" "basic_user" {
  name = "${var.module_name}-eks-admin-2"
  path = "/"
  force_destroy = true
  tags = var.tags
}

# Resource: AWS IAM User Policy - EKS Full Access
resource "aws_iam_user_policy" "basic_user_eks_policy" {
  name = "${var.module_name}-eks-full-access-policy"
  user = aws_iam_user.basic_user.name

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "iam:ListRoles",
          "eks:*",
          "ssm:GetParameter"
        ]
        Effect   = "Allow"
        Resource = "*"
        #Resource = "${aws_eks_cluster.eks_cluster.arn}"
      },
    ]
  })
}

# --------------------------------

# Resource: AWS IAM User - Admin User (Has Full AWS Access)
resource "aws_iam_user" "admin_user" {
  name = "${var.module_name}-eks-admin"
  path = "/"
  force_destroy = true
  tags = var.tags
}

# Resource: Admin Access Policy - Attach it to admin user
resource "aws_iam_user_policy_attachment" "admin_user" {
  user       = aws_iam_user.admin_user.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# --------------------------------

# Resource: AWS IAM User - Basic User
resource "aws_iam_user" "eks_admin_user" {
  name = "${var.module_name}-eks-admin3"
  path = "/"
  force_destroy = true
  tags = var.tags
}

# Resource: AWS IAM Group Membership
resource "aws_iam_group_membership" "eks_admins" {
  name = "${var.module_name}-eks-admins-group-membership"
  users = [
    aws_iam_user.eks_admin_user.name
  ]

  group = aws_iam_group.eks_admins_iam_group.name
}
