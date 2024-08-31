data "aws_iam_policy_document" "eks_cluster_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

// iam role
resource "aws_iam_role" "eks_cluster_role" {
  name               = "${var.cluster_name}-eks-cluster-role"
  description        = "The role for EKS cluster"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role.json

  tags = var.tags
}

# Associate IAM Policy to IAM Role
resource "aws_iam_role_policy_attachment" "eks-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_role.name
}

# AmazonEKSClusterPolicy
# resource "aws_iam_policy" "AmazonEKSClusterPolicy" {
#   name        = "AmazonEKSClusterPolicy"
#   path        = "/"
#   description = "AmazonEKSClusterPolicy"

#   policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         "Effect" : "Allow",
#         "Action" : [
#           "autoscaling:DescribeAutoScalingGroups",
#           "autoscaling:UpdateAutoScalingGroup",
#           "ec2:AttachVolume",
#           "ec2:AuthorizeSecurityGroupIngress",
#           "ec2:CreateRoute",
#           "ec2:CreateSecurityGroup",
#           "ec2:CreateTags",
#           "ec2:CreateVolume",
#           "ec2:DeleteRoute",
#           "ec2:DeleteSecurityGroup",
#           "ec2:DeleteVolume",
#           "ec2:DescribeInstances",
#           "ec2:DescribeRouteTables",
#           "ec2:DescribeSecurityGroups",
#           "ec2:DescribeSubnets",
#           "ec2:DescribeVolumes",
#           "ec2:DescribeVolumesModifications",
#           "ec2:DescribeVpcs",
#           "ec2:DescribeDhcpOptions",
#           "ec2:DescribeNetworkInterfaces",
#           "ec2:DescribeAvailabilityZones",
#           "ec2:DetachVolume",
#           "ec2:ModifyInstanceAttribute",
#           "ec2:ModifyVolume",
#           "ec2:RevokeSecurityGroupIngress",
#           "ec2:DescribeAccountAttributes",
#           "ec2:DescribeAddresses",
#           "ec2:DescribeInternetGateways",
#           "elasticloadbalancing:AddTags",
#           "elasticloadbalancing:ApplySecurityGroupsToLoadBalancer",
#           "elasticloadbalancing:AttachLoadBalancerToSubnets",
#           "elasticloadbalancing:ConfigureHealthCheck",
#           "elasticloadbalancing:CreateListener",
#           "elasticloadbalancing:CreateLoadBalancer",
#           "elasticloadbalancing:CreateLoadBalancerListeners",
#           "elasticloadbalancing:CreateLoadBalancerPolicy",
#           "elasticloadbalancing:CreateTargetGroup",
#           "elasticloadbalancing:DeleteListener",
#           "elasticloadbalancing:DeleteLoadBalancer",
#           "elasticloadbalancing:DeleteLoadBalancerListeners",
#           "elasticloadbalancing:DeleteTargetGroup",
#           "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
#           "elasticloadbalancing:DeregisterTargets",
#           "elasticloadbalancing:DescribeListeners",
#           "elasticloadbalancing:DescribeLoadBalancerAttributes",
#           "elasticloadbalancing:DescribeLoadBalancerPolicies",
#           "elasticloadbalancing:DescribeLoadBalancers",
#           "elasticloadbalancing:DescribeTargetGroupAttributes",
#           "elasticloadbalancing:DescribeTargetGroups",
#           "elasticloadbalancing:DescribeTargetHealth",
#           "elasticloadbalancing:DetachLoadBalancerFromSubnets",
#           "elasticloadbalancing:ModifyListener",
#           "elasticloadbalancing:ModifyLoadBalancerAttributes",
#           "elasticloadbalancing:ModifyTargetGroup",
#           "elasticloadbalancing:ModifyTargetGroupAttributes",
#           "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
#           "elasticloadbalancing:RegisterTargets",
#           "elasticloadbalancing:SetLoadBalancerPoliciesForBackendServer",
#           "elasticloadbalancing:SetLoadBalancerPoliciesOfListener",
#           "kms:DescribeKey"
#         ],
#         "Resource" : "*"
#       },
#       {
#         "Effect" : "Allow",
#         "Action" : "iam:CreateServiceLinkedRole",
#         "Resource" : "*",
#         "Condition" : {
#           "StringEquals" : {
#             "iam:AWSServiceName" : "elasticloadbalancing.amazonaws.com"
#           }
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_policy" "AmazonEKSVPCResourceController" {
#   name        = "AmazonEKSVPCResourceController"
#   path        = "/"
#   description = "AmazonEKSVPCResourceController"
#   policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         "Effect" : "Allow",
#         "Action" : "ec2:CreateNetworkInterfacePermission",
#         "Resource" : "*",
#         "Condition" : {
#           "ForAnyValue:StringEquals" : {
#             "ec2:ResourceTag/eks:eni:owner" : "eks-vpc-resource-controller"
#           }
#         }
#       },
#       {
#         "Effect" : "Allow",
#         "Action" : [
#           "ec2:CreateNetworkInterface",
#           "ec2:DetachNetworkInterface",
#           "ec2:ModifyNetworkInterfaceAttribute",
#           "ec2:DeleteNetworkInterface",
#           "ec2:AttachNetworkInterface",
#           "ec2:UnassignPrivateIpAddresses",
#           "ec2:AssignPrivateIpAddresses"
#         ],
#         "Resource" : "*"
#       }
#     ]
#   })
# }
