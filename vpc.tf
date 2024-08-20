locals {
  private_subnet_count = length(var.private_subnet_cidrs)
  public_subnet_count  = length(var.public_subnet_cidrs)
}

resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "eks-vpc"
  }
}

resource "aws_subnet" "public" {
  count                   = local.public_subnet_count
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  map_public_ip_on_launch = true # Public subnets should auto-assign public IPs
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "eks-public-subnet-${count.index + 1}"
  }
}

resource "aws_eip" "eks_nat" {
  vpc = true
}

resource "aws_nat_gateway" "eks_nat_gw" {
  allocation_id = aws_eip.eks_nat.id
  subnet_id     = aws_subnet.public[0].id # Use the first public subnet for NAT Gateway

  tags = {
    Name = "nat-gateway"
  }
}

resource "aws_subnet" "private" {
  count                   = local.private_subnet_count
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = element(var.private_subnet_cidrs, count.index)
  map_public_ip_on_launch = false # Private subnets should not auto-assign public IPs
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "eks-private-subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "eks-igw"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks_nat_gw.id
  }

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "public_rt_association" {
  count          = local.public_subnet_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_rt_association" {
  count          = local.private_subnet_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}
