output "eks_admin_user_role_arn" {
  description = "The ARN role for EKS admin user"
  value = aws_iam_role.eks_admin_user_role.arn
}

output "eks_readonly_user_role_arn" {
  description = "The ARN role for EKS readonly user"
  value = aws_iam_role.eks_readonly_user_role.arn
}

output "aws_iam_readonly_user_name" {
  description = "The name of the AWS IAM user - which match RoleBinding user_name"
  value = aws_iam_user.iam_read_only_user.name
}

output "eks_develop_user_role_arn" {
  description = "The ARN role for EKS develop user"
  value = aws_iam_role.eks_develop_user_role.arn
}
