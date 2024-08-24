
resource "kubernetes_config_map" "flask_webapp_config" {
  metadata {
    name = "flask-webapp-configmap"
    labels = {
      "app" = "flask-webapp"
    }
  }

  data = {
    # app env
    APP_PORT = "5000"
    APP_ENV  = "dev"
  }
}
