# Resource: AWS IAM Group
resource "aws_iam_group" "eks_admins_iam_group" {
  name = "${var.module_name}-eks-admins"
  path = "/"
}
