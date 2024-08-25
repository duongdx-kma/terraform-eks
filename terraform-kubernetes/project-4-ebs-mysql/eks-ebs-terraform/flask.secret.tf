resource "kubernetes_secret_v1" "flask_webapp_secret" {
  metadata {
    name = "flask-webapp-secret"
  }

  data = {
    # writer env
    WRITE_DB_USER     = var.write_db_user
    WRITE_DB_PASSWORD = var.write_db_password

    # reader env
    READ_DB_USER     = var.read_db_user
    READ_DB_PASSWORD = var.read_db_password

    # database env
    DB_NAME = var.db_name
    DB_PORT = var.db_port
  }
}
