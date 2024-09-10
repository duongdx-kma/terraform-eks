resource "kubernetes_deployment_v1" "webserver_01" {
  metadata {
    name = "webserver-01"
    labels = {
      app = "webserver-01"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "webserver-01"
      }
    }

    template {
      metadata {
        labels = {
          app = "webserver-01"
        }
      }

      spec {
        container {
          image = "stacksimplify/kube-nginxapp1:1.0.0"
          name  = "webserver-01"

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
              path = "/app1/index.html"
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

resource "kubernetes_service_v1" "webserver_01_service" {
  metadata {
    name = "webserver-01-service"
    labels = {
      "app" = "webserver-01"
    }
    annotations = {
      "alb.ingress.kubernetes.io/healthcheck-path" = "/app1/index.html"
    }
  }
  spec {
    selector = {
      app = kubernetes_deployment_v1.webserver_01.spec.0.selector.0.match_labels.app
    }
    port {
      name        = "http"
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}
