# Admin Access: Data IAM role: trusted relation policy
data "aws_iam_policy_document" "eks_admin_user_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalType"
      values   = ["User"]
    }
  }
}

# Admin Access: Resource: IAM Role - EKS Admin Access
resource "aws_iam_role" "eks_admin_user_role" {
  name               = "${var.eks_cluster_name}-eks-admin-user-role"
  description        = "The role for EKS admin user"
  assume_role_policy = data.aws_iam_policy_document.eks_admin_user_assume_role.json

  tags = merge(
    {
      role = "Admin"
      permission = "All"
      namespace = "All"
    },
    var.tags
  )
}

# ---

# ReadOnly Access: Data IAM role: trusted relation policy
data "aws_iam_policy_document" "eks_readonly_user_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalType"
      values   = ["User"]
    }
  }
}

# ReadOnly Access: Resource: IAM Role - EKS ReadOnly Access
resource "aws_iam_role" "eks_readonly_user_role" {
  name               = "${var.eks_cluster_name}-eks-readonly-user-role"
  description        = "The role for EKS ReadOnly user"
  assume_role_policy = data.aws_iam_policy_document.eks_readonly_user_assume_role.json

  tags = merge(
    {
      role = "ReadOnly"
      permission = "Read"
      namespace = "All"
    },
    var.tags
  )
}


# ---

# Developer Access: Data IAM role: trusted relation policy
data "aws_iam_policy_document" "eks_develop_user_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalType"
      values   = ["User"]
    }
  }
}

# Developer Access: Resource: IAM Role - EKS Develop Access
resource "aws_iam_role" "eks_develop_user_role" {
  name               = "${var.eks_cluster_name}-eks-develop-user-role"
  description        = "The role for EKS Develop user"
  assume_role_policy = data.aws_iam_policy_document.eks_develop_user_assume_role.json

  tags = merge(
    {
      role = "Developer"
      permission = "All"
      namespace = var.develop_namespace
    },
    var.tags
  )
}
