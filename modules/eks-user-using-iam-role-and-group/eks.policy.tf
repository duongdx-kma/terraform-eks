# ADMIN Access: IAM policy
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

  tags = merge(
    {
      permission = "All"
      namespace = "All"
      tag-key = "${var.module_name}-eks-admin-policy"
    },
    var.tags
  )
}

# ADMIN Access: IAM role - policy attachment
resource "aws_iam_role_policy_attachment" "eks_admin_role_attachment" {
  policy_arn = aws_iam_policy.eks_admin_policy.arn
  role       = aws_iam_role.eks_admin_user_role.name
}


# REadOnly Access: IAM policy
resource aws_iam_policy "eks_readonly_policy" {
  name = "${var.eks_cluster_name}-eks-readonly-policy"
  description = "The policy allow readonly user interact with ${var.eks_cluster_name} cluster"
  policy = jsonencode({
    "Version" : "2012-10-17",
     "Statement" : [
        {
          Effect: "Allow",
          Action: [
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

          Resource : [
            var.eks_cluster_arn
          ]
        }
     ]
  })

  tags = merge(
    {
      permission = "Read"
      namespace = "All"
      tag-key = "${var.module_name}-eks-readonly-policy"
    },
    var.tags
  )
}

# REadOnly Access: IAM role - policy attachment
resource "aws_iam_role_policy_attachment" "eks_readonly_role_attachment" {
  policy_arn = aws_iam_policy.eks_readonly_policy.arn
  role       = aws_iam_role.eks_readonly_user_role.name
}

# develop Access: IAM policy
resource aws_iam_policy "eks_develop_policy" {
  name = "${var.eks_cluster_name}-eks-develop-policy"
  description = "The policy allow develop user interact with ${var.eks_cluster_name} cluster"
  policy = jsonencode({
    "Version" : "2012-10-17",
     "Statement" : [
        {
          Effect: "Allow",
          Action: [
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

          Resource : [
            var.eks_cluster_arn
          ]
        }
     ]
  })

  tags = merge(
    {
      permission = "All"
      namespace = var.develop_namespace
      tag-key = "${var.module_name}-eks-develop-policy"
    },
    var.tags
  )
}

# develop Access: IAM role - policy attachment
resource "aws_iam_role_policy_attachment" "eks_develop_role_attachment" {
  policy_arn = aws_iam_policy.eks_develop_policy.arn
  role       = aws_iam_role.eks_develop_user_role.name
}
