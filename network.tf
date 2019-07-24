## Network
data "aws_availability_zones" "available" {}

resource "aws_vpc" "vpn" {
  cidr_block           = "172.17.0.0/16"
  enable_dns_hostnames = false
  enable_dns_support   = true

  tags = module.vpn_label.tags
}

resource "aws_subnet" "public" {
  cidr_block              = cidrsubnet(aws_vpc.vpn.cidr_block, 8, 0)
  availability_zone       = data.aws_availability_zones.available.names[0]
  vpc_id                  = aws_vpc.vpn.id
  map_public_ip_on_launch = true

  tags = module.vpn_label.tags
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpn.id

  tags = module.vpn_label.tags
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.vpn.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}
