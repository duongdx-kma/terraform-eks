resource "kubernetes_deployment_v1" "webserver_06" {
  metadata {
    name = "webserver-06"
    labels = {
      app = "webserver-06"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "webserver-06"
      }
    }

    template {
      metadata {
        labels = {
          app = "webserver-06"
        }
      }

      spec {
        container {
          image = "stacksimplify/kube-nginxapp1:1.0.0"
          name  = "webserver-06"

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

resource "kubernetes_service_v1" "webserver_06_service" {
  metadata {
    name = "webserver-06-service"
    labels = {
      "app" = "webserver-06"
    }
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type" = "external"
      "alb.ingress.kubernetes.io/healthcheck-path"        = "/app1/index.html"
      "external-dns.alpha.kubernetes.io/hostname"         = "external-dns-k8s-webserver-06.duongdx.com"
      "alb.ingress.kubernetes.io/listen-ports"            = jsonencode([{ "HTTPS" = 443 }, { "HTTP" = 80 }])
      # Hostname to be used by external DNS
      # SSL redirection settings
      "alb.ingress.kubernetes.io/ssl-redirect" = "443"
      # Note that the backend talks over HTTP.
      "service.beta.kubernetes.io/aws-load-balancer-backend-protocol" = "http"
      # TODO: Fill in with the ARN of your certificate.
      "service.beta.kubernetes.io/aws-load-balancer-ssl-cert" = aws_acm_certificate.acm_cert.arn
      # Only run SSL on the port named "https" below.
      "service.beta.kubernetes.io/aws-load-balancer-ssl-ports" = "https"
    }
  }
  spec {
    selector = {
      app = kubernetes_deployment_v1.webserver_06.spec.0.selector.0.match_labels.app
    }
    port {
      name        = "http"
      port        = 80
      target_port = 80
    }

    port {
      name        = "https"
      port        = 443
      target_port = 80
    }

    type = "LoadBalancer"
  }

  depends_on = [aws_acm_certificate_validation.cert_validation]
}
