resource "kubernetes_stateful_set_v1" "mysql" {
  metadata {
    name = "mysql"

    labels = {
      app                      = "mysql"
      "app.kubernetes.io/name" = "mysql"
    }
  }

  depends_on = [
    kubernetes_config_map_v1.mysql,
    kubernetes_config_map_v1.container_init_config_map,
    kubernetes_config_map_v1.config_map,
    kubernetes_secret_v1.mysql_secret,
    kubernetes_service_v1.mysql,
    kubernetes_service_v1.mysql_headless_service,
    kubernetes_storage_class_v1.ebs_gp3_storage_class
  ]

  spec {
    pod_management_policy = "Parallel"
    replicas              = 2

    selector {
      match_labels = {
        "app"                    = "mysql"
        "app.kubernetes.io/name" = "mysql"
      }
    }

    # service name for mysql
    service_name = "mysql"

    template {
      metadata {
        labels = {
          "app"                    = "mysql"
          "app.kubernetes.io/name" = "mysql"
        }

        annotations = {}
      }

      spec {
        init_container {
          name  = "init-script"
          image = "busybox:1.35"
          command = [
            "sh",
            "-c",
            "cp /mnt/scripts/*.sh /mnt/writable-scripts/ && chmod +x /mnt/writable-scripts/*.sh"
          ]

          volume_mount {
            name       = "container-init-volume"
            mount_path = "/mnt/scripts"
          }

          volume_mount {
            name       = "writable-scripts"
            mount_path = "/mnt/writable-scripts"
          }
        }

        # Copies configuration from the Kubernetes-config-map to storage.
        init_container {
          name              = "init-mysql"
          image             = "mysql:5.7"
          image_pull_policy = "IfNotPresent"
          command = [
            "bash",
            "-c",
            "/mnt/writable-scripts/init-mysql.sh"
          ]

          # Volume mounting: mysql conf -> mount to "emptyDir"
          volume_mount {
            name       = "conf"
            mount_path = "/mnt/conf.d"
          }

          # Volume mounting: mysql config -> mount "mysql ConfigMap"
          volume_mount {
            name       = "config-map"
            mount_path = "/mnt/config-map"
          }

          volume_mount {
            name       = "writable-scripts"
            mount_path = "/mnt/writable-scripts"
          }
        }

        # Clones the MySQL database from mysql-(index-1) (Exclude mysql-0).
        init_container {
          name              = "clone-mysql"
          image             = "gcr.io/google-samples/xtrabackup:1.0"
          image_pull_policy = "IfNotPresent"

          command = [
            "bash",
            "-c",
            "/mnt/writable-scripts/clone-mysql.sh"
          ]

          # Volume mounting: mysql data -> mount to "PVC"
          volume_mount {
            name       = "mysql-data"
            mount_path = "/var/lib/mysql"
            sub_path   = "mysql"
          }

          # Volume mounting: mysql config -> mount "emptyDir"
          volume_mount {
            name       = "conf"
            mount_path = "/etc/mysql/conf.d"
          }

          volume_mount {
            name       = "writable-scripts"
            mount_path = "/mnt/writable-scripts"
          }
        }

        # Main container running MySQL.
        container {
          name              = "mysql"
          image             = "mysql:5.7"
          image_pull_policy = "IfNotPresent"
          # container ENV - from kubernetes secret
          env_from {
            secret_ref {
              name = kubernetes_secret_v1.mysql_secret.metadata.0.name
            }
          }

          # container port
          port {
            name           = "mysql"
            container_port = var.db_port
          }

          # container resource request
          resources {
            limits = {
              cpu    = "500m"
              memory = "1Gi"
            }

            requests = {
              cpu    = "250m"
              memory = "500Mi"
            }
          }

          # Volume mounting: mysql data -> mount to "PVC"
          volume_mount {
            name       = "mysql-data"
            mount_path = "/var/lib/mysql"
            sub_path   = "mysql"
          }

          # Volume mounting: mysql conf -> mount to "emptyDir"
          volume_mount {
            name       = "conf"
            mount_path = "/etc/mysql/conf.d"
          }

          # Volume mounting: mysql initdb -> mount to "user-management-db-script ConfigMap"
          volume_mount {
            name       = "user-management-db-volume"
            mount_path = "/docker-entrypoint-initdb.d"
          }

          # Liveness probes determine when to restart a container. For example, liveness probes could catch a deadlock, when an application is running, but unable to make progress.
          # If a container fails its liveness probe repeatedly, the kubelet restarts the container.
          # Liveness probes do not wait for readiness probes to succeed
          liveness_probe {
            exec {
              command = [
                "/bin/sh",
                "-c",
                "mysqladmin ping -u root -p$${MYSQL_ROOT_PASSWORD}"
              ]
            }

            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
          }

          # readiness probe
          readiness_probe {
            exec {
              command = [
                "/bin/sh",
                "-c",
                "mysql -h 127.0.0.1 -u root -p$${MYSQL_ROOT_PASSWORD} -e 'SELECT 1'"
              ]
            }

            initial_delay_seconds = 5
            period_seconds        = 2
            timeout_seconds       = 1
          }
        }

        # xtrabackup container:
        # 1. primary pod (mysql-0)
        # - xtrabackup extract database from mysql-0 => save data to local
        # 2. replica pod (mysql-1...n)
        # - extract data from database of mysql-(index-1) => save data to local
        # - compare diff and sync data with their database
        container {
          name              = "xtrabackup"
          image             = "gcr.io/google-samples/xtrabackup:1.0"
          image_pull_policy = "IfNotPresent"

          # container ENV - from kubernetes secret
          env_from {
            secret_ref {
              name = "mysql-secret"
            }
          }

          # container port
          port {
            name           = "xtrabackup"
            container_port = 3307
          }

          command = [
            "bash",
            "-c",
            "/mnt/writable-scripts/xtrabackup.sh"
          ]

          # container resource request
          resources {
            limits = {
              cpu    = "100m"
              memory = "100Mi"
            }

            requests = {
              cpu    = "100m"
              memory = "100Mi"
            }
          }

          # Volume mounting: mysql data -> mount to "PVC"
          volume_mount {
            name       = "mysql-data"
            mount_path = "/var/lib/mysql"
            sub_path   = "mysql"
          }

          # Volume mounting: mysql conf -> mount to "emptyDir"
          volume_mount {
            name       = "conf"
            mount_path = "/etc/mysql/conf.d"
          }

          # Volume mounting: mysql initdb -> mount to "user-management-db-script ConfigMap"
          volume_mount {
            name       = "user-management-db-volume"
            mount_path = "/docker-entrypoint-initdb.d"
          }

          volume_mount {
            name       = "writable-scripts"
            mount_path = "/mnt/writable-scripts"
          }
        }

        # Grace period to terminate a pod.
        # If the termination time exceeds this period, kube-api will send a force signal to kill the pod.
        termination_grace_period_seconds = 60

        volume {
          name = "conf"
          empty_dir {}
        }

        volume {
          name = "config-map"
          config_map {
            name = "mysql"
          }
        }

        volume {
          name = "user-management-db-volume"
          config_map {
            name = "user-management-db-script"
          }
        }

        # only for terraform:
        volume {
          name = "container-init-volume"

          config_map {
            name = "container-init-config-map"
          }
        }

        volume {
          name = "writable-scripts"
          empty_dir {}
        }
      }
    }

    # config update strategy
    update_strategy {
      type = "RollingUpdate"

      rolling_update {
        partition = 1
      }
    }

    volume_claim_template {
      metadata {
        name = "mysql-data"
        labels = {
          "app"                    = "mysql"
          "app.kubernetes.io/name" = "mysql"
        }
      }

      spec {
        storage_class_name = "ebs-gp3-storage-class"
        access_modes       = ["ReadWriteOnce"]

        resources {
          requests = {
            storage = "1Gi"
          }
        }
      }
    }

    persistent_volume_claim_retention_policy {
      when_deleted = "Retain"
      when_scaled  = "Retain"
    }
  }
}
