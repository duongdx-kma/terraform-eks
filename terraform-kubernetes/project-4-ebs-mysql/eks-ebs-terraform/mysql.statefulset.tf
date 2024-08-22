resource "kubernetes_stateful_set_v1" "mysql" {
  metadata {
    name = "mysql"

    labels = {
      app                      = "mysql"
      "app.kubernetes.io/name" = "mysql"
    }
  }

  spec {
    pod_management_policy = "Parallel"
    replicas              = 3

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
        # Copies configuration from the Kubernetes-config-map to storage.
        init_container {
          name              = "init-mysql"
          image             = "mysql:5.7"
          image_pull_policy = "IfNotPresent"
          command = [
            "bash",
            "-c",
            <<EOT
              set -ex
              # Generate mysql server-id from pod ordinal index.
              [[ $HOSTNAME =~ -([0-9]+)$ ]] || exit 1
              ordinal=${BASH_REMATCH[1]}
              echo [mysqld] > /mnt/conf.d/server-id.cnf
              # Add an offset to avoid reserved server-id=0 value.
              echo server-id=$((100 + $ordinal)) >> /mnt/conf.d/server-id.cnf
              # Copy appropriate conf.d files from config-map to emptyDir.
              if [[ $ordinal -eq 0 ]]; then
                cp /mnt/config-map/primary.cnf /mnt/conf.d/
              else
                cp /mnt/config-map/replica.cnf /mnt/conf.d/
              fi"]
            EOT
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
        }

        # Clones the MySQL database from mysql-(index-1) (Exclude mysql-0).
        init_container {
          name              = "clone-mysql"
          image             = "gcr.io/google-samples/xtrabackup:1.0"
          image_pull_policy = "IfNotPresent"

          command = [
            "bash",
            "-c",
            <<EOT
              set -ex
              # Skip the clone if data already exists.
              [[ -d /var/lib/mysql/mysql ]] && exit 0
              # Skip the clone on primary (ordinal index 0).
              [[ `hostname` =~ -([0-9]+)$ ]] || exit 1
              ordinal=${BASH_REMATCH[1]}
              [[ $ordinal -eq 0 ]] && exit 0
              # Clone data from previous peer.

              echo mysql-$(($ordinal-1)).mysql

              ncat --recv-only mysql-$(($ordinal-1)).mysql 3307 | xbstream -x -C /var/lib/mysql
              # Prepare the backup.
              xtrabackup --prepare --target-dir=/var/lib/mysql
            EOT
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
        }

        # Main container running MySQL.
        container {
          name              = "mysql"
          image             = "mysql:5.7"
          image_pull_policy = "IfNotPresent"
          # container ENV - from kubernetes secret
          env_from {
            secret_ref {
              name = "mysql-secret"
            }
          }

          # container port
          port {
            name           = "mysql"
            container_port = 3306
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
              command = ["mysqladmin", "ping", "-u", "root", "-p${MYSQL_ROOT_PASSWORD}"]
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
                "mysql -h 127.0.0.1 -p${MYSQL_ROOT_PASSWORD} -e 'SELECT 1'"
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
            <<EOT
              set -ex
              cd /var/lib/mysql

              # Determine binlog position of cloned data, if any.
              if [[ -f xtrabackup_slave_info && "x$(<xtrabackup_slave_info)" != "x" ]]; then
                # XtraBackup already generated a partial "CHANGE MASTER TO" query
                # because we're cloning from an existing replica. (Need to remove the tailing semicolon!)
                cat xtrabackup_slave_info | sed -E 's/;$//g' > change_master_to.sql.in
                # Ignore xtrabackup_binlog_info in this case (it's useless).
                rm -f xtrabackup_slave_info xtrabackup_binlog_info
              elif [[ -f xtrabackup_binlog_info ]]; then
                # We're cloning directly from primary. Parse binlog position.
                [[ `cat xtrabackup_binlog_info` =~ ^(.*?)[[:space:]]+(.*?)$ ]] || exit 1
                rm -f xtrabackup_binlog_info xtrabackup_slave_info
                echo "CHANGE MASTER TO MASTER_LOG_FILE='${BASH_REMATCH[1]}',\
                      MASTER_LOG_POS=${BASH_REMATCH[2]}" > change_master_to.sql.in
              fi

              # Check if we need to complete a clone by starting replication.
              if [[ -f change_master_to.sql.in ]]; then
                echo "Waiting for mysqld to be ready (accepting connections)"
                until mysql -h 127.0.0.1 -u root -p"$MYSQL_ROOT_PASSWORD" -e "SELECT 1"; do sleep 1; done

                echo "Initializing replication from clone position"
                echo $MYSQL_ROOT_PASSWORD
                mysql -h 127.0.0.1 -u root -p"$MYSQL_ROOT_PASSWORD" \
                      -e "$(<change_master_to.sql.in), \
                              MASTER_HOST='mysql-0.mysql', \
                              MASTER_USER='root', \
                              MASTER_PASSWORD='$MYSQL_ROOT_PASSWORD', \
                              MASTER_CONNECT_RETRY=10; \
                            START SLAVE;" || exit 1
                # In case of container restart, attempt this at-most-once.
                mv change_master_to.sql.in change_master_to.sql.orig
              fi

              # Start a server to send backups when requested by peers.
              exec ncat --listen --keep-open --send-only --max-conns=1 3307 -c \
                "xtrabackup --backup --slave-info --stream=xbstream --host=127.0.0.1 --user=root --password=$MYSQL_ROOT_PASSWORD"
            EOT
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
        }

        # Grace period to terminate a pod.
        # If the termination time exceeds this period, kube-api will send a force signal to kill the pod.
        termination_grace_period_seconds = 300

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
      when_deleted = "Delete"
      when_scaled  = "Delete"
    }
  }
}
