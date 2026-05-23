# Query for Route 53 Hosted zone ID
data "aws_route53_zone" "dns_hosted_zone_name" {
  name         = "${var.domain_name}"
  private_zone = false
}

# add ALB DNS name as alias in Route 53
resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.dns_hosted_zone_name.zone_id
  name    = "student.${data.aws_route53_zone.dns_hosted_zone_name.name}"
  type    = "A"
  
  alias {
    name = var.alb_dns_name
    zone_id = "${var.alb_zone_id}"
    evaluate_target_health = true
  }
}

#Query for certificate stored in ACM
data "aws_acm_certificate" "issued_cert" {
  domain   = "${var.domain_name}"
  statuses = ["ISSUED"]
}