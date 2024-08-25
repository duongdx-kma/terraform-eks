resource "kubernetes_service_v1" "mysql_headless_service" {
  metadata {
    name = "mysql-headless-service"

    labels = {
      app = "mysql"
    }
  }
  spec {
    selector = {
      # app = kubernetes_stateful_set_v1.mysql.spec.0.selector.0.match_labels.app
      app = "mysql"
    }

    port {
      port        = var.db_port
      target_port = var.db_port
    }

    type       = "ClusterIP"
    cluster_ip = "None" # Headless service
  }
}

resource "kubernetes_service_v1" "mysql" {
  metadata {
    name = "mysql"

    labels = {
      app = "mysql"
    }
  }
  spec {
    selector = {
      # app = kubernetes_stateful_set_v1.mysql.spec.0.selector.0.match_labels.app
      app = "mysql"
    }

    port {
      port        = var.db_port
      target_port = var.db_port
    }

    type = "ClusterIP"
  }
}
