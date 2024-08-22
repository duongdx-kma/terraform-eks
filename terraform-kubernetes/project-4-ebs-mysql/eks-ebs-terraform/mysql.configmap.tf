# Resource: Config Map
resource "kubernetes_config_map_v1" "config_map" {
  metadata {
    name = "user-management-db-script"
  }

  data = {
    "webappdb.sql" = "${file("${path.module}/webappdb.sql")}"
  }
}


resource "kubernetes_config_map" "mysql" {
  metadata {
    name = "mysql"
    labels = {
      "app"                    = "mysql"
      "app.kubernetes.io/name" = "mysql"
    }
  }

  data = {
    "primary.cnf" = <<-EOT
      # Apply this config only on the primary.
      [mysqld]
      log-bin
    EOT

    "replica.cnf" = <<-EOT
      # Apply this config only on replicas.
      [mysqld]
      super-read-only
    EOT
  }
}
