resource "kubernetes_deployment" "webserver" {
  metadata {
    name = "webserver"
    labels = {
      app = "webserver"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "webserver"
      }
    }

    template {
      metadata {
        labels = {
          app = "webserver"
        }
      }

      spec {
        container {
          image = "nginx:alpine"
          name  = "nginx"

          resources {
            limits = {
              cpu    = "250m"
              memory = "128Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
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