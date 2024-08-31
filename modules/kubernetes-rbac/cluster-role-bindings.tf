
# Resource: Cluster Role Binding
resource "kubernetes_cluster_role_binding_v1" "eks_readonly_cluster_role_binding" {
  metadata {
    name = "${var.eks_cluster_name}-eks-readonly-cluster-role-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.eks_readonly_cluster_role.metadata.0.name
  }
  subject {
    kind      = "Group"
    name      = var.eks_readonly_group_name
    api_group = "rbac.authorization.k8s.io"
  }
}