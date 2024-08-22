resource "kubernetes_secret" "mysql_secret" {
  metadata {
    name = "mysql-secret"
  }

  data = {
    MYSQL_DATABASE      = "d2ViYXBwZGI="
    MYSQL_ROOT_PASSWORD = "ZHVvbmdkeDE="
    MYSQL_PASSWORD      = "ZHVvbmdkeDE="
    MYSQL_USER          = "ZHVvbmdkeA=="
  }
}