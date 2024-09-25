data "aws_route53_zone" "patimapoochai" {
  name = "patimapoochai.net"
}

resource "aws_route53_record" "api_endpoint" {
  zone_id = data.aws_route53_zone.patimapoochai.zone_id
  name    = "resumeapi.${data.aws_route53_zone.patimapoochai.name}"
  type    = "A"

  alias {
    name                   = var.api_domain_name
    zone_id                = var.api_zone_id
    evaluate_target_health = true
  }
}

