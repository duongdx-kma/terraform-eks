resource "kubernetes_service" "webserver_lb_service" {
  metadata {
    name = "webserver-lb-service"
  }
  spec {
    selector = {
      app = kubernetes_deployment.webserver.spec.0.selector.0.match_labels.app
    }
    # session_affinity = "ClientIP"
    port {
      name        = "http"
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}
