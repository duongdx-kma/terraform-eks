# Resource: Config Map
resource "kubernetes_config_map_v1" "config_map" {
  metadata {
    name = "user-management-db-script"
  }

  data = {
    "webappdb.sql" = "${file("${path.module}/scripts/webappdb.sql")}"
  }
}

# Resource: Config Map
resource "kubernetes_config_map_v1" "container_init_config_map" {
  metadata {
    name = "container-init-config-map"
  }

  data = {
    "init-mysql.sh" = "${file("${path.module}/scripts/init-mysql.sh")}"
    "clone-mysql.sh" = "${file("${path.module}/scripts/clone-mysql.sh")}"
    "xtrabackup.sh" = "${file("${path.module}/scripts/xtrabackup.sh")}"
  }
}

resource "kubernetes_config_map_v1" "mysql" {
  metadata {
    name = "mysql"
    labels = {
      "app"                    = "mysql"
      "app.kubernetes.io/name" = "mysql"
    }
  }

  data = {
    "primary.cnf" = <<EOT
      # Apply this config only on the primary.
      [mysqld]
      log-bin
    EOT

    "replica.cnf" = <<EOT
      # Apply this config only on replicas.
      [mysqld]
      super-read-only
    EOT
  }
}
