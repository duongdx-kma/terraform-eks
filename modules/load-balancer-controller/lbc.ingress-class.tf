variable ingress_class_name {
  description = "The ingress class name"
  type = string
}

variable "is_default_ingress_class" {
  description = "The variable indicate the ingressClass is default or not"
  type = bool
  default = false
}

locals {
  ingress_annotations =  {
    "ingressclass.kubernetes.io/is-default-class" = var.is_default_ingress_class ? "true" : ""
    "addition-annotation" = "hello-duongdx"
  }
}

# Resource: Kubernetes Ingress Class
resource "kubernetes_ingress_class_v1" "ingress_class_default" {
  depends_on = [helm_release.load_balancer_controller]
  metadata {
    name = var.ingress_class_name
    annotations = local.ingress_annotations
  }
  spec {
    controller = "ingress.k8s.aws/alb"
  }
}
