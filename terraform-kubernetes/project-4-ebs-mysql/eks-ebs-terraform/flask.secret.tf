resource "kubernetes_secret" "flask_webapp_secret" {
  metadata {
    name = "mysql-secret"
  }

  data = {
    # writer env
    WRITE_DB_USER     = "ZHVvbmdkeA=="
    WRITE_DB_PASSWORD = "ZHVvbmdkeDE="

    # reader env
    READ_DB_USER     = "ZHVvbmdkeA=="
    READ_DB_PASSWORD = "ZHVvbmdkeDE="

    # database env
    DB_NAME = "d2ViYXBwZGI="
    DB_PORT = "MzMwNgo="
  }
}
