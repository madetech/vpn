output "dns nameservers" {
  value = aws_route53_zone.vpn.name_servers
}

output "instance ip address" {
  value = aws_instance.foxpass_vpn.public_ip
}