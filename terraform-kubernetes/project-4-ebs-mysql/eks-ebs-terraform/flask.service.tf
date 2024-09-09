locals {
  services = [
    {
      type        = "LoadBalancer"
      name        = "flask-webapp-alb-service"
      port        = var.flask_webapp_service_port
      target_port = var.app_port
      node_port   = null
      enabled     = var.flask_enable_alb
    },
    {
      type        = "NodePort"
      name        = "flask-webapp-node-port-service"
      port        = var.flask_webapp_service_port
      target_port = var.app_port
      node_port   = var.flask_webapp_public_node_port
      enabled     = var.flask_enable_node_port
    },
    {
      type        = "ClusterIP"
      name        = "flask-webapp-service"
      port        = var.flask_webapp_service_port
      target_port = var.app_port
      node_port   = null
      enabled     = true
    }
  ]

  services_to_create = [
    for s in local.services : s if s.enabled
  ]
}

resource "kubernetes_service_v1" "flask_webapp_service" {
  for_each = { for service in local.services_to_create : service.name => service }

  metadata {
    name = each.value.name
  }

  spec {
    selector = {
      app = kubernetes_deployment_v1.flask_webapp.spec.0.selector.0.match_labels.app
    }

    port {
      name        = "http"
      port        = var.flask_webapp_service_port
      target_port = var.app_port
      node_port   = each.value.node_port
    }

    type = each.value.type
  }
}

