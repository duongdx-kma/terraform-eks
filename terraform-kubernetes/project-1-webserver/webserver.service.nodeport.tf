resource "kubernetes_service" "webserver_node_port_service" {
  metadata {
    name = "webserver-node-port-service"
  }
  spec {
    selector = {
      app = kubernetes_deployment.webserver.spec.0.selector.0.match_labels.app
    }
    port {
      name        = "http"
      port        = 80
      target_port = 80
      node_port   = 32100
    }

    type = "NodePort"
  }
}
