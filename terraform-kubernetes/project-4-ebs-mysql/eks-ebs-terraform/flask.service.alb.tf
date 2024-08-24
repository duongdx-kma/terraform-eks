resource "kubernetes_service" "flask_webapp_node_port_service" {
  metadata {
    name = "webserver-node-port-service"
  }
  spec {
    selector = {
      app = kubernetes_deployment_v1.flask_webapp.spec.0.selector.0.match_labels.app
    }
    # session_affinity = "ClientIP"
    port {
      name        = "http"
      port        = 80
      target_port = 5000
      node_port   = 32100
    }

    type = "LoadBalancer"
  }
}
