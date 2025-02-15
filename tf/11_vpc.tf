locals {
  subnet_map = {
    public_1a = {
      availability_zone = "${var.region}a"
      cidr_block = var.cidr_block_map.public_1a
      category = "public-1a"
    }
    private_1a = {
      availability_zone = "${var.region}a"
      cidr_block = var.cidr_block_map.private_1a
      category = "private-1a"
    }
  }
  route_table_map = {
    public     = { 
      category = "public"
      gateway_id = aws_internet_gateway.main.id
    }
  }
  route_table_association_map = {
    public_1a  = { route_table_category = "public" }
  }
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project}-vpc-${var.env}"
  }
}

resource "aws_subnet" "main" {
  for_each = local.subnet_map
  vpc_id            = aws_vpc.main.id
  availability_zone = each.value["availability_zone"]
  cidr_block        = each.value["cidr_block"]
  tags = {
    Name = "${var.project}-subnet-${each.value.category}-${var.env}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project}-internet-gateway-${var.env}"
  }
}

resource "aws_eip" "ec2" {
  domain = "vpc"
  instance = aws_instance.vpn.id
  tags = {
    Name = "${var.project}-eip-ec2-${var.env}"
  }
}

resource "aws_route_table" "main" {
  for_each = local.route_table_map
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project}-route-table-${each.value.category}-${var.env}"
  }
}

resource "aws_route" "main" {
  for_each = local.route_table_map
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.main[each.key].id
  gateway_id             = each.value.gateway_id
}

resource "aws_route_table_association" "main" {
  for_each       = local.route_table_association_map
  subnet_id      = aws_subnet.main[each.key].id
  route_table_id = aws_route_table.main[each.value.route_table_category].id
}
