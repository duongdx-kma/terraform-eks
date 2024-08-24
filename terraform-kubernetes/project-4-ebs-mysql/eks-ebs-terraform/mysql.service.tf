resource "kubernetes_service_v1" "mysql_headless_service" {
  metadata {
    name = "mysql-headless-service"

    labels = {
      app = "mysql"
    }
  }
  spec {
    selector = {
      app = kubernetes_stateful_set_v1.mysql.spec.0.selector.0.match_labels.app
    }

    port {
      port        = 3306
      target_port = 3306
    }
    type       = "ClientIP"
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
      app = kubernetes_stateful_set_v1.mysql.spec.0.selector.0.match_labels.app
    }

    port {
      port        = 3306
      target_port = 3306
    }

    type = "ClientIP"
  }
}
