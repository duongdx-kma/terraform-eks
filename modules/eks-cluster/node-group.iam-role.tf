data "aws_iam_policy_document" "eks_node_group_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

// iam role
// iam role
resource "aws_iam_role" "eks_node_group_role" {
  name               = "${var.cluster_name}-eks-node-group-role"
  description        = "The role for EKS cluster"
  assume_role_policy = data.aws_iam_policy_document.eks_node_group_assume_role.json
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group_role.name
}

# AmazonEKSWorkerNodePolicy
# resource "aws_iam_policy" "AmazonEKSWorkerNodePolicy" {
#   name        = "AmazonEKSWorkerNodePolicy"
#   path        = "/"
#   description = "AmazonEKSWorkerNodePolicy"

#   policy = jsondecode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         "Sid" : "WorkerNodePermissions",
#         "Effect" : "Allow",
#         "Action" : [
#           "ec2:DescribeInstances",
#           "ec2:DescribeInstanceTypes",
#           "ec2:DescribeRouteTables",
#           "ec2:DescribeSecurityGroups",
#           "ec2:DescribeSubnets",
#           "ec2:DescribeVolumes",
#           "ec2:DescribeVolumesModifications",
#           "ec2:DescribeVpcs",
#           "eks:DescribeCluster",
#           "eks-auth:AssumeRoleForPodIdentity"
#         ],
#         "Resource" : "*"
#       }
#     ]
#   })
# }

# resource "aws_iam_policy" "AmazonEKS_CNI_Policy" {
#   name        = "AmazonEKS_CNI_Policy"
#   path        = "/"
#   description = "AmazonEKS_CNI_Policy"
#   policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         "Sid" : "AmazonEKSCNIPolicy",
#         "Effect" : "Allow",
#         "Action" : [
#           "ec2:AssignPrivateIpAddresses",
#           "ec2:AttachNetworkInterface",
#           "ec2:CreateNetworkInterface",
#           "ec2:DeleteNetworkInterface",
#           "ec2:DescribeInstances",
#           "ec2:DescribeTags",
#           "ec2:DescribeNetworkInterfaces",
#           "ec2:DescribeInstanceTypes",
#           "ec2:DescribeSubnets",
#           "ec2:DetachNetworkInterface",
#           "ec2:ModifyNetworkInterfaceAttribute",
#           "ec2:UnassignPrivateIpAddresses"
#         ],
#         "Resource" : "*"
#       },
#       {
#         "Sid" : "AmazonEKSCNIPolicyENITag",
#         "Effect" : "Allow",
#         "Action" : [
#           "ec2:CreateTags"
#         ],
#         "Resource" : [
#           "arn:aws:ec2:*:*:network-interface/*"
#         ]
#       }
#     ]
#   })
# }

# resource "aws_iam_policy" "AmazonEC2ContainerRegistryReadOnly" {
#   name        = "AmazonEC2ContainerRegistryReadOnly"
#   path        = "/"
#   description = "AmazonEC2ContainerRegistryReadOnly"
#   policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         "Effect" : "Allow",
#         "Action" : [
#           "ecr:GetAuthorizationToken",
#           "ecr:BatchCheckLayerAvailability",
#           "ecr:GetDownloadUrlForLayer",
#           "ecr:GetRepositoryPolicy",
#           "ecr:DescribeRepositories",
#           "ecr:ListImages",
#           "ecr:DescribeImages",
#           "ecr:BatchGetImage",
#           "ecr:GetLifecyclePolicy",
#           "ecr:GetLifecyclePolicyPreview",
#           "ecr:ListTagsForResource",
#           "ecr:DescribeImageScanFindings"
#         ],
#         "Resource" : "*"
#       }
#     ]
#   })
# }
