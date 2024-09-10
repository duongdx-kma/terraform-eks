variable "ingress_class_name" {
  default = "the ingress class name"
  type = string
}

# Kubernetes Service Manifest (Type: Load Balancer)
resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name = "ingress-basics"
    labels = {
      "app" = "flask-webapp"
    }
    annotations = {
      # Load Balancer Name
      "alb.ingress.kubernetes.io/load-balancer-name" = "ingress-basics"
      # Ingress Core Settings
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      # Health Check Settings
      "alb.ingress.kubernetes.io/healthcheck-protocol" = "HTTP"
      "alb.ingress.kubernetes.io/target-type"          = "ip" # Using target type IP if target is CLUSTERIP service
      "alb.ingress.kubernetes.io/healthcheck-port"     = "traffic-port"

      #Important Note:  Need to add health check path annotations in service level if we are planning to use multiple targets in a load balancer
      "alb.ingress.kubernetes.io/healthcheck-path"             = "/"
      "alb.ingress.kubernetes.io/healthcheck-interval-seconds" = 15
      "alb.ingress.kubernetes.io/healthcheck-timeout-seconds"  = 5
      "alb.ingress.kubernetes.io/success-codes"                = 200
      "alb.ingress.kubernetes.io/healthy-threshold-count"      = 2
      "alb.ingress.kubernetes.io/unhealthy-threshold-count"    = 2
    }
  }

  spec {
    ingress_class_name = var.ingress_class_name # Ingress Class            
    default_backend {
      service {
        name = kubernetes_service_v1.webserver_03_service.metadata[0].name
        port {
          number = 80
        }
      }
    }

    rule {
      http {
        path {
          backend {
            service {
              name = kubernetes_service_v1.webserver_01_service.metadata[0].name
              port {
                number = 80
              }
            }
          }
          path = "/app1"
          path_type = "Prefix"
        }

        path {
          backend {
            service {
              name = kubernetes_service_v1.webserver_02_service.metadata[0].name
              port {
                number = 80
              }
            }
          }
          path = "/app2"
          path_type = "Prefix"
        }
      }
    }
  }
}
