
# Resource: Cluster Role Binding
resource "kubernetes_role_binding_v1" "eks_readonly_role_binding" {
  metadata {
    name      = "${var.eks_cluster_name}-eks-readonly-role-binding"
    namespace = "default"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.eks_readonly_role.metadata.0.name
  }
  subject {
    kind      = "Group"
    name      = var.eks_readonly_group_name
    api_group = "rbac.authorization.k8s.io"
  }
}

# Resource: Cluster Role Binding: Develop Team
resource "kubernetes_role_binding_v1" "eks_develop_role_binding" {
  metadata {
    name      = "${var.eks_cluster_name}-eks-develop-role-binding"
    namespace = kubernetes_namespace_v1.k8s_dev.metadata.0.name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.eks_develop_role.metadata.0.name
  }
  subject {
    kind      = "Group"
    name      = var.eks_develop_group_name
    api_group = "rbac.authorization.k8s.io"
  }
}

