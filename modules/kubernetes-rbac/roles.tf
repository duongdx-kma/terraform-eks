# Resource: Cluster Role
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
