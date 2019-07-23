provider "aws" {
  region  = "eu-west-2"
  version = "~> 2.20"
}

module "vpn_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.14.1"
  namespace  = "madetech"
  stage      = "prod"
  name       = "vpn"
  attributes = ["public"]
  delimiter  = "-"

  additional_tag_map = {
    propagate_at_launch = "true"
  }
}

data "aws_ami" "foxpass_ami" {
  most_recent = true
  owners      = ["679593333241"] # foxpass

  filter {
    name   = "name"
    values = ["foxpass-ipsec-vpn*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "vpn_traffic" {
  name = module.vpn_label.id
  tags = module.vpn_label.tags

  description            = "Normal traffic to and from the vpn"
  vpc_id                 = aws_vpc.vpn.id
  revoke_rules_on_delete = true

  ingress {
    description = "Incoming vpn traffic"
    protocol    = "udp"
    from_port   = 500
    to_port     = 500
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Incoming vpn traffic"
    protocol    = "udp"
    from_port   = 4500
    to_port     = 4500
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH traffic"
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Outgoing vpn traffic"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "key" {
  public_key = var.ssh_public_key
}

locals {
  json_config = jsonencode(
    {
      psk             = var.shared_psk,
      dns_primary     = var.dns_primary,
      dns_secondary   = var.dns_secondary,
      local_cidr      = "10.11.12.0/24",
      foxpass_api_key = var.foxpass_api_key,
      //      require_groups = ["vpn"]
  })
}

resource "aws_launch_configuration" "foxpass_vpn" {
  name_prefix = "${module.vpn_label.id}-"

  associate_public_ip_address = true
  security_groups             = [aws_security_group.vpn_traffic.id]
  key_name                    = aws_key_pair.key.key_name

  image_id      = data.aws_ami.foxpass_ami.image_id
  instance_type = "t2.micro"

  user_data = <<EOF
#!/bin/bash
echo 'about to run user_data setup'

sudo locale-gen en_GB.UTF-8

echo '${local.json_config}' | sudo tee -a /root/vpn_config.json
sudo /opt/bin/config.py /root/vpn_config.json

echo 'finished user_data setup'
EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "foxpass_vpn" {
  name = module.vpn_label.name
  tags = module.vpn_label.tags_as_list_of_maps

  max_size = 2
  min_size = 1
  desired_capacity = 1

  health_check_grace_period = 150
  health_check_type = "EC2"

  vpc_zone_identifier = [aws_subnet.public.id]
  launch_configuration = aws_launch_configuration.foxpass_vpn.name
}

