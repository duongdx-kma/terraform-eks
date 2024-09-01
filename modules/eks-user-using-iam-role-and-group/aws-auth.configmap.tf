variable "eks_node_group_role_name" {
  description = "the EKS node group role"
  type        = string
}

# Sample Role Format: arn:aws:iam::180789647333:role/hr-dev-eks-nodegroup-role
# Locals Block
locals {
  configmap_roles = [
    # role for eks node instance
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.eks_node_group_role_name}"
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    },

    # "IAM EKS full access role" as "EKS admin"
    {
      rolearn  = aws_iam_role.eks_admin_user_role.arn # IAM Role ARN
      username = "iam-role-as-eks-admin"
      groups   = ["system:masters"] # kubernetes groups
    },

    # "IAM EKS Readonly access role" as "EKS readonly GROUP"
    {
      rolearn  = aws_iam_role.eks_readonly_user_role.arn # IAM Role ARN
      username = "iam-role-as-eks-readonly"
      groups   = [var.eks_readonly_group_name] # kubernetes groups
    },

    # "IAM EKS Develop access role" as "EKS Develop GROUP"
    {
      rolearn  = aws_iam_role.eks_develop_user_role.arn # IAM Role ARN
      username = "iam-role-as-eks-develop"
      groups   = [var.eks_develop_group_name] # kubernetes groups
    }
  ]

  configmap_users = [

    # "IAM Basic user" as "EKS Admin"
    {
      userarn  = "${aws_iam_user.basic_user.arn}"
      username = "${aws_iam_user.basic_user.name}"
      groups   = ["system:masters"]
    },
    # "IAM Admin user" as "EKS Admin"
    {
      userarn  = "${aws_iam_user.admin_user.arn}"
      username = "${aws_iam_user.admin_user.name}"
      groups   = ["system:masters"]
    },

    # "IAM readonly user" as "EKS readonly user"
    {
      userarn  = "${aws_iam_user.iam_read_only_user.arn}"
      username = "iam-user-as-eks-readonly"
      groups   = [var.eks_readonly_group_name]
    },
  ]
}

# Resource: Kubernetes Config Map
resource "kubernetes_config_map_v1" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
  data = {
    mapRoles = yamlencode(local.configmap_roles)
    mapUsers = yamlencode(local.configmap_users)
  }
}
