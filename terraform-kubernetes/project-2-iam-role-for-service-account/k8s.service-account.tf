resource "kubernetes_service_account_v1" "s3_read_only_sa" {
  depends_on = [aws_iam_role_policy_attachment.this]

  metadata {
    name      = var.eks_service_account_name
    namespace = var.eks_namespace

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.this.arn
    }
  }
}

resource "kubernetes_secret_v1" "sa_token" {
  metadata {
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account_v1.s3_read_only_sa.metadata.0.name
    }

    generate_name = "s3-read-only-sa-token-"
  }

  type                           = "kubernetes.io/service-account-token"
  wait_for_service_account_token = true
}
