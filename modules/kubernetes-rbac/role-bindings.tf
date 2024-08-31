
# Resource: Cluster Role Binding
resource "kubernetes_role_binding_v1" "eks_readonly_role_binding" {
  metadata {
    name      = "${var.eks_cluster_name}-eks-readonly-role-binding"
    namespace = "default"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_role_v1.eks_readonly_role.metadata.0.name
  }
  subject {
    kind      = "User"
    name      = var.eks_readonly_user_name
    api_group = "rbac.authorization.k8s.io"
  }
}
