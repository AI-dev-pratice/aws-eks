# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    { Name = "${var.project}_${var.environment}_vpc" },
    var.common_tags
  )
}

# Public Subnets
resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = element(data.aws_availability_zones.available_zone.names, count.index)
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    {
      Name                        = "${var.project}_${var.environment}_public_subnet_${count.index + 1}"
      "kubernetes.io/role/elb"    = "1"          # Important for EKS ALB
    },
    var.common_tags
  )
}

# Private Subnets
resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(data.aws_availability_zones.available_zone.names, count.index)

  tags = merge(
    {
      Name                              = "${var.project}_${var.environment}_private_subnet_${count.index + 1}"
      "kubernetes.io/role/internal-elb" = "1"    # Important for EKS internal ALB
    },
    var.common_tags
  )
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    { Name = "${var.project}_${var.environment}_igw" },
    var.common_tags
  )
}

# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    { Name = "${var.project}_${var.environment}_public_rt" },
    var.common_tags
  )
}

# Private Route Tables (one per AZ)
resource "aws_route_table" "private_rt" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway[count.index].id
  }

  tags = merge(
    { Name = "${var.project}_${var.environment}_private_rt_${count.index + 1}" },
    var.common_tags
  )
}

# Public Route Table Association
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# Elastic IPs for NAT
resource "aws_eip" "nat" {
  count  = length(var.public_subnet_cidrs)
  domain = "vpc"

  tags = merge(
    { Name = "${var.project}_${var.environment}_eip_${count.index + 1}" },
    var.common_tags
  )
}

# NAT Gateways
resource "aws_nat_gateway" "nat_gateway" {
  count         = length(var.public_subnet_cidrs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id

  depends_on = [aws_internet_gateway.igw]

  tags = merge(
    { Name = "${var.project}_${var.environment}_nat_${count.index + 1}" },
    var.common_tags
  )
}

# Private Route Table Associations
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rt[count.index].id
}