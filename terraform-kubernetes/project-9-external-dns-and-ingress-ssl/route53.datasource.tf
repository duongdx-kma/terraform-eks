data "aws_route53_zone" "selected" {
  name = "${var.route53_domain}."
}


