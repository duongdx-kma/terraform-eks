resource "kubernetes_deployment_v1" "flask_webapp" {
  metadata {
    name = "flask-webapp"
    labels = {
      app = "flask-webapp"
    }
  }

  spec {
    replicas = 3
    strategy {}

    selector {
      match_labels = {
        app = "flask-webapp"
      }
    }

    template {
      metadata {
        labels = {
          app = "flask-webapp"
        }
      }

      spec {
        init_container {
          image = "busybox"
          name  = "service-checker"
          command = [
            "sh",
            "-c",
            <<-EOT
              until nslookup mysql.$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace).svc.cluster.local; do
                echo "waiting for mysql to be up"
                sleep 2
              done
            EOT
          ]
        }

        container {
          name  = "flask-webapp"
          image = "duong1200798/python-webapp"

          # set container port
          port {
            container_port = 5000
          }

          # environment variables from k8s-secret
          env_from {
            secret_ref {
              name = "flask-webapp-secret"
            }
          }

          # environment variables from k8s-config-map
          env_from {
            config_map_ref {
              name = "flask-webapp-configmap"
            }
          }

          # environment variables from raw string
          env {
            name  = "READ_DB_HOST"
            value = "mysql"
          }

          # environment variables from raw string
          env {
            name  = "WRITE_DB_HOST"
            value = "mysql-0.mysql"
          }

          resources {
            requests = {
              memory = "64Mi"
              cpu    = "250m"
            }
            limits = {
              memory = "128Mi"
              cpu    = "500m"
            }
          }
        }
      }
    }
  }
}
