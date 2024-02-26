resource "aws_route53_record" "frontend-alias-dns-record" {
  zone_id = var.zone_id
  name    = var.hosted_zone_name
  type    = "A"
  alias {
    name                   = var.resource_domain_name
    zone_id                = var.resource_hosted_zone
    evaluate_target_health = true
  }
}
