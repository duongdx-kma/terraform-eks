resource "kubernetes_service" "flask_webapp_node_port_service" {
  metadata {
    name = "flask-webapp-node-port-service"
  }
  spec {
    selector = {
      app = kubernetes_deployment_v1.flask_webapp.spec.0.selector.0.match_labels.app
    }
    port {
      name        = "http"
      port        = var.flask_webapp_service_port
      target_port = var.app_port
      node_port   = var.flask_webapp_public_node_port
    }

    type = "NodePort"
  }
}
