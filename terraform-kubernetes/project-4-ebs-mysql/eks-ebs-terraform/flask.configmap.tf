
resource "kubernetes_config_map_v1" "flask_webapp_config" {
  metadata {
    name = "flask-webapp-configmap"
    labels = {
      "app" = "flask-webapp"
    }
  }

  data = {
    # app env
    APP_PORT = var.app_port
    APP_ENV  = var.app_env
  }
}
