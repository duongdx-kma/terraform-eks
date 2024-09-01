# Resource: Cluster Role ReadOnly
resource "kubernetes_role_v1" "eks_readonly_role" {
  metadata {
    name      = "eks-readonly-role"
    namespace = "default"
  }

  rule {
    api_groups = [""] # These come under core APIs
    resources  = ["pods"]
    verbs      = ["get", "watch", "list"]
  }
}


# Resource: Cluster Role - Develop Team
resource "kubernetes_role_v1" "eks_develop_role" {
  metadata {
    name      = "eks-develop-role"
    namespace = kubernetes_namespace_v1.k8s_dev.metadata.0.name
  }

  rule {
    api_groups     = ["", "extensions", "apps"]
    resources      = ["*"]
    verbs          = ["*"]
  }
  rule {
    api_groups = ["batch"]
    resources  = ["jobs", "cronjobs"]
    verbs      = ["*"]
  }
}
