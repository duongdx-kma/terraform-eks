# Resource: Create External DNS IAM Policy 
resource "aws_iam_policy" "external_dns_iam_policy" {
  name        = "${var.eks_cluster_id}-AllowExternalDNSUpdates"
  path        = "/"
  description = "External DNS IAM Policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:ChangeResourceRecordSets"
        ],
        "Resource" : [
          "arn:aws:route53:::hostedzone/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets"
        ],
        "Resource" : [
          "*"
        ]
      }
    ]
  })
}

# Create the IAM Policy Document for the role's trust relationship
data "aws_iam_policy_document" "external_dns_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]

    principals {
      type        = "Federated"
      identifiers = [var.aws_iam_openid_connect_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.aws_iam_openid_connect_provider_extract_from_arn}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.aws_iam_openid_connect_provider_extract_from_arn}:sub"
      values = [
        "system:serviceaccount:${var.eks_external_dns_namespace}:${var.eks_external_dns_service_account_name}"
      ]
    }
  }
}

# Resource: Create IAM Role
resource "aws_iam_role" "external_dns_iam_role" {
  name = "${var.eks_cluster_id}-external-dns-iam-role"

  # Terraform's "jsonencode" function converts a Terraform expression result to valid JSON syntax.
  assume_role_policy = data.aws_iam_policy_document.external_dns_assume_role.json

  tags = merge(
    {
      tag-key = "AllowExternalDNSUpdates"
    },
    var.tags
  )
}

# Associate External DNS IAM Policy to IAM Role
resource "aws_iam_role_policy_attachment" "external_dns_iam_role_policy_attach" {
  policy_arn = aws_iam_policy.external_dns_iam_policy.arn
  role       = aws_iam_role.external_dns_iam_role.name
}
