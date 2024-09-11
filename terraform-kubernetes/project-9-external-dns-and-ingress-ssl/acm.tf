# Resource: ACM Certificate
resource "aws_acm_certificate" "acm_cert" {
  domain_name       = "*.${data.aws_route53_zone.selected.name}"
  validation_method = "DNS"

  tags = var.tags

  lifecycle {
    create_before_destroy = true
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

# ACM Certificate Validation Resource
resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.acm_cert.arn

  validation_record_fqdns = [for record in aws_route53_record.acm_validation : record.fqdn]
}

# Outputs
output "acm_certificate_id" {
  value = aws_acm_certificate.acm_cert.id 
}

output "acm_certificate_arn" {
  value = aws_acm_certificate.acm_cert.arn
}

output "acm_certificate_status" {
  value = aws_acm_certificate.acm_cert.status
}
