# --------------------------------
# Start: EKS user using IAM User
# --------------------------------

# Resource: AWS IAM Basic User (No AWSConsole Access) working as "EKS Admin"
resource "aws_iam_user" "basic_user" {
  name = "${var.module_name}-basic-user"
  path = "/"
  force_destroy = true
  tags = var.tags
}

# Resource: AWS IAM User Policy - EKS Full Access
resource "aws_iam_user_policy" "basic_user_policy" {
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
  name = "${var.module_name}-admin-user"
  path = "/"
  force_destroy = true
  tags = var.tags
}

# Resource: Admin Access Policy - Attach it to admin user
resource "aws_iam_user_policy_attachment" "admin_user" {
  user       = aws_iam_user.admin_user.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Resource: AWS IAM Basic User (No AWSConsole Access) working as "EKS Readonly"
resource "aws_iam_user" "read_only_user" {
  name = "${var.module_name}-read-only-user"
  path = "/"
  force_destroy = true
  tags = var.tags
}

# Resource: AWS IAM User Policy - EKS Readonly Access
resource "aws_iam_user_policy" "read_only_user_policy" {
  name = "${var.module_name}-eks-read-only-policy"
  user = aws_iam_user.read_only_user.name

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "iam:ListRoles",
          "ssm:GetParameter",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:AccessKubernetesApi",
          "eks:ListUpdates",
          "eks:ListFargateProfiles",
          "eks:ListIdentityProviderConfigs",
          "eks:ListAddons",
          "eks:DescribeAddonVersions"
        ]
        Effect   = "Allow"
        Resource = "*"
        #Resource = "${aws_eks_cluster.eks_cluster.arn}"
      },
    ]
  })
}
# --------------------------------
# End: EKS user using IAM User
# --------------------------------
