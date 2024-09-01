
# --------------------------------
# Begin: EKS user using IAM Role and IAM Group
# --------------------------------

# Resource: AWS IAM User working as "EKS admin"
resource "aws_iam_user" "eks_admin_user" {
  name = "${var.module_name}-eks-admin-user"
  path = "/"
  force_destroy = true
  tags = var.tags
}

# Resource: EKS admin IAM Group Membership
resource "aws_iam_group_membership" "eks_admins_membership" {
  name = "${var.module_name}-eks-admins-group-membership"
  users = [
    aws_iam_user.eks_admin_user.name
  ]

  group = aws_iam_group.eks_admins_iam_group.name
}

# Resource: AWS IAM User working as "EKS ReadOnly"
resource "aws_iam_user" "eks_readonly_user" {
  name = "${var.module_name}-eks-readonly-user"
  path = "/"
  force_destroy = true
  tags = var.tags
}

# Resource: EKS Readonly IAM  Membership
resource "aws_iam_group_membership" "eks_readonly_membership" {
  name = "${var.module_name}-eks-readonly-group-membership"
  users = [
    aws_iam_user.eks_readonly_user.name
  ]

  group = aws_iam_group.eks_readonly_iam_group.name
}


# Resource: AWS IAM User working as "EKS Develop"
resource "aws_iam_user" "eks_develop_user" {
  name = "${var.module_name}-eks-develop-user"
  path = "/"
  force_destroy = true
  tags = var.tags
}

# Resource: EKS develop IAM  Membership
resource "aws_iam_group_membership" "eks_develop_membership" {
  name = "${var.module_name}-eks-develop-group-membership"
  users = [
    aws_iam_user.eks_develop_user.name
  ]

  group = aws_iam_group.eks_develop_iam_group.name
}
# --------------------------------
# End: EKS user using IAM Role and IAM Group
# --------------------------------
