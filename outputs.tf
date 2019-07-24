output "dns_nameservers" {
  value = aws_route53_zone.vpn.name_servers
}

output "instance_ip_address" {
  value = aws_instance.foxpass_vpn.public_ip
}