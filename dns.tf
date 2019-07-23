resource "aws_route53_zone" "vpn" {
  name = var.public_dns_name
}

resource "aws_route53_record" "vpn" {
  zone_id = aws_route53_zone.vpn.id
  name    = aws_route53_zone.vpn.name
  type    = "A"
  ttl     = 60

  records = [
    aws_instance.foxpass_vpn.public_ip
  ]
}