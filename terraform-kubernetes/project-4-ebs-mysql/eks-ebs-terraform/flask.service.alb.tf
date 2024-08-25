resource "kubernetes_service_v1" "flask_webapp_alb_service" {
  metadata {
    name = "flask-webapp-alb-service"
  }
  spec {
    selector = {
      app = kubernetes_deployment_v1.flask_webapp.spec.0.selector.0.match_labels.app
    }

    port {
      name        = "http"
      port        = var.flask_webapp_service_port
      target_port = var.app_port
    }

    type = "LoadBalancer"
  }
}
