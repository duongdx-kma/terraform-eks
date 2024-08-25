resource "kubernetes_secret_v1" "mysql_secret" {
  metadata {
    name = "mysql-secret"
  }

  data = {
    MYSQL_DATABASE      = var.mysql_database
    MYSQL_ROOT_PASSWORD = var.mysql_root_password
    MYSQL_PASSWORD      = var.mysql_password
    MYSQL_USER          = var.mysql_user
  }
}