output "eks_admin_user_role_arn" {
  description = "The ARN role for EKS admin user"
  value = aws_iam_role.eks_admin_user_role.arn
}