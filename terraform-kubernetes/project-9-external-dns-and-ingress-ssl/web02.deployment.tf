resource "kubernetes_deployment_v1" "webserver_02" {
  metadata {
    name = "webserver-02"
    labels = {
      app = "webserver-02"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "webserver-02"
      }
    }

    template {
      metadata {
        labels = {
          app = "webserver-02"
        }
      }

      spec {
        container {
          image = "stacksimplify/kube-nginxapp2:1.0.0"
          name  = "webserver-02"

          resources {
            limits = {
              cpu    = "200m"
              memory = "128Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "64Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/app2/index.html"
              port = 80

              http_header {
                name  = "X-Custom-Header"
                value = "Awesome"
              }
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "webserver_02_service" {
  metadata {
    name = "webserver-02-service"
    labels = {
      "app" = "webserver-02"
    }
    annotations = {
      "alb.ingress.kubernetes.io/healthcheck-path" = "/app2/index.html"
    }
  }
  spec {
    selector = {
      app = kubernetes_deployment_v1.webserver_02.spec.0.selector.0.match_labels.app
    }
    port {
      name        = "http"
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}
