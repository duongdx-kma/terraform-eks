data "aws_route53_zone" "selected" {
  name = "${var.route53_domain}."
}

# Wait for Certificate Validation
resource "null_resource" "wait_for_create_alb" {
  depends_on = [kubernetes_ingress_v1.ingress]

  provisioner "local-exec" {
    command = "sleep 60" # Wait for ACM certificate validation
  }
}

data "aws_lb" "ingress_alb" {
  depends_on = [null_resource.wait_for_create_alb, kubernetes_ingress_v1.ingress]
  name       = kubernetes_ingress_v1.ingress.metadata.0.name # get ALB data
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.route53_sub_domain}.${data.aws_route53_zone.selected.name}"
  type    = "A"
  alias {
    name                   = "dualstack.${data.aws_lb.ingress_alb.dns_name}" # From the ALB which be created by ingress (aws load balancer controller)
    zone_id                = data.aws_lb.ingress_alb.zone_id  # From the ALB which be created by ingress (aws load balancer controller)
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.acm_cert.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      type    = dvo.resource_record_type
      value   = dvo.resource_record_value
      zone_id = data.aws_route53_zone.selected.zone_id
    }
  }

  zone_id = each.value.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.value]
  ttl     = 300
}
