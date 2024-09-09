output "flask_webapp_service" {
  value = [
    for service in kubernetes_service_v1.flask_webapp_service :
    {
      service_name = service.metadata[0].name
      service_port = service.spec[0].port[0].port
    }
  ]
}
