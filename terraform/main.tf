locals {
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_az1    = "10.0.1.0/24"
  public_subnet_az2    = "10.0.2.0/24"
  private_subnet_cidr  = "10.0.10.0/24"
  az1                  = "${var.aws_region}a"
  az2                  = "${var.aws_region}b"
}

# ---------------------------------------------------------------------------
# VPC
# ---------------------------------------------------------------------------
resource "aws_vpc" "agrox" {
  cidr_block           = local.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name      = "${var.cluster_name}-vpc"
    Project   = "agrox"
    ManagedBy = "terraform"
  }
}

# ---------------------------------------------------------------------------
# Internet Gateway
# ---------------------------------------------------------------------------
resource "aws_internet_gateway" "agrox" {
  vpc_id = aws_vpc.agrox.id

  tags = {
    Name      = "${var.cluster_name}-igw"
    Project   = "agrox"
    ManagedBy = "terraform"
  }
}

# ---------------------------------------------------------------------------
# Public Subnets (across 2 AZs for ALB requirement)
# ---------------------------------------------------------------------------
resource "aws_subnet" "public_az1" {
  vpc_id            = aws_vpc.agrox.id
  cidr_block        = local.public_subnet_az1
  availability_zone = local.az1

  map_public_ip_on_launch = true

  tags = {
    Name      = "${var.cluster_name}-public-subnet-az1"
    Project   = "agrox"
    ManagedBy = "terraform"
  }
}

resource "aws_subnet" "public_az2" {
  vpc_id            = aws_vpc.agrox.id
  cidr_block        = local.public_subnet_az2
  availability_zone = local.az2

  map_public_ip_on_launch = true

  tags = {
    Name      = "${var.cluster_name}-public-subnet-az2"
    Project   = "agrox"
    ManagedBy = "terraform"
  }
}

# ---------------------------------------------------------------------------
# Elastic IP for NAT Gateway
# ---------------------------------------------------------------------------
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name      = "${var.cluster_name}-eip"
    Project   = "agrox"
    ManagedBy = "terraform"
  }

  depends_on = [aws_internet_gateway.agrox]
}

# ---------------------------------------------------------------------------
# NAT Gateway (in public subnet AZ1 for private subnet outbound)
# ---------------------------------------------------------------------------
resource "aws_nat_gateway" "agrox" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_az1.id

  tags = {
    Name      = "${var.cluster_name}-nat"
    Project   = "agrox"
    ManagedBy = "terraform"
  }

  depends_on = [aws_internet_gateway.agrox]
}

# ---------------------------------------------------------------------------
# Private Subnet
# ---------------------------------------------------------------------------
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.agrox.id
  cidr_block        = local.private_subnet_cidr
  availability_zone = local.az1

  tags = {
    Name      = "${var.cluster_name}-private-subnet"
    Project   = "agrox"
    ManagedBy = "terraform"
  }
}

# ---------------------------------------------------------------------------
# Route Tables
# ---------------------------------------------------------------------------
# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.agrox.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.agrox.id
  }

  tags = {
    Name      = "${var.cluster_name}-public-rt"
    Project   = "agrox"
    ManagedBy = "terraform"
  }
}

resource "aws_route_table_association" "public_az1" {
  subnet_id      = aws_subnet.public_az1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_az2" {
  subnet_id      = aws_subnet.public_az2.id
  route_table_id = aws_route_table.public.id
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.agrox.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.agrox.id
  }

  tags = {
    Name      = "${var.cluster_name}-private-rt"
    Project   = "agrox"
    ManagedBy = "terraform"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# ---------------------------------------------------------------------------
# Security Groups
# ---------------------------------------------------------------------------
# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "${var.cluster_name}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.agrox.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.cluster_name}-alb-sg"
    Project   = "agrox"
    ManagedBy = "terraform"
  }
}

# ECS Tasks Security Group
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.cluster_name}-ecs-tasks-sg"
  description = "Security group for ECS tasks"
  vpc_id      = aws_vpc.agrox.id

  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.cluster_name}-ecs-tasks-sg"
    Project   = "agrox"
    ManagedBy = "terraform"
  }
}

