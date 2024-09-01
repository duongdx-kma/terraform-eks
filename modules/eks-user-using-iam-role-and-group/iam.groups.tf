# Resource: AWS IAM Group work as "EKS Admin"
resource "aws_iam_group" "eks_admins_iam_group" {
  name = "${var.module_name}-eks-admins"
  path = "/"
}

# Resource: AWS IAM Group work as "EKS Readonly"
resource "aws_iam_group" "eks_readonly_iam_group" {
  name = "${var.module_name}-eks-readonly"
  path = "/"
}

# Resource: AWS IAM Group work as "EKS Develop"
resource "aws_iam_group" "eks_develop_iam_group" {
  name = "${var.module_name}-eks-develop"
  path = "/"
}
