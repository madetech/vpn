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
  private_ip = "172.17.0.81"
}

resource "aws_instance" "foxpass_vpn" {
  tags = module.vpn_label.tags

  private_ip = local.private_ip

  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.vpn_traffic.id]
  subnet_id                   = aws_subnet.public.id
  key_name                    = aws_key_pair.key.key_name

  ami           = data.aws_ami.foxpass_ami.image_id
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

resource "aws_eip" "static_ip" {
  vpc = true

  instance = aws_instance.foxpass_vpn.id
  depends_on = ["aws_internet_gateway.gw"]
  associate_with_private_ip = local.private_ip
}
