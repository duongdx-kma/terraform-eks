resource "kubernetes_service" "webserver_nlb_service" {
  metadata {
    name = "webserver-nlb-service"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"    # To create Network Load Balancer  
    }
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
