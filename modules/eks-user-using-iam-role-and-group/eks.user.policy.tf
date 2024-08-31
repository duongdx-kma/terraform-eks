# IAM policy
resource aws_iam_policy "eks_admin_policy" {
  name = "${var.eks_cluster_name}-eks-admin-policy"
  description = "The policy allow admin user interact with ${var.eks_cluster_name} cluster"
  policy = jsonencode({
    "Version" : "2012-10-17",
     "Statement" : [
        {
          Effect: "Allow",
          Action: [
            "iam:ListRoles",
            "eks:*",
            "ssm:GetParameter"
          ]

          Resource : [
            var.eks_cluster_arn
          ]
        }
     ]
  })

  tags = {
    tag-key = "${var.module_name}-eks-admin-policy"
  }
}

# IAM role - policy attachment
resource "aws_iam_role_policy_attachment" "eks_admin_role_attachment" {
  policy_arn = aws_iam_policy.eks_admin_policy.arn
  role       = aws_iam_role.eks_admin_user_role.name
}
