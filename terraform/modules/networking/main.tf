# ---------------------------------------------------------------------------
# VPC
# ---------------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name      = "${var.environment}-vpc"
    Project   = var.project_name
    Environment = var.environment
    ManagedBy = "terraform"
  }
}

# ---------------------------------------------------------------------------
# Internet Gateway
# ---------------------------------------------------------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name      = "${var.environment}-igw"
    Project   = var.project_name
    Environment = var.environment
    ManagedBy = "terraform"
  }
}

# ---------------------------------------------------------------------------
# Public Subnets (across 2 AZs for ALB requirement)
# ---------------------------------------------------------------------------
resource "aws_subnet" "public_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_az1_cidr
  availability_zone = var.az1

  map_public_ip_on_launch = true

  tags = {
    Name      = "${var.environment}-public-subnet-az1"
    Project   = var.project_name
    Environment = var.environment
    ManagedBy = "terraform"
  }
}

resource "aws_subnet" "public_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_az2_cidr
  availability_zone = var.az2

  map_public_ip_on_launch = true

  tags = {
    Name      = "${var.environment}-public-subnet-az2"
    Project   = var.project_name
    Environment = var.environment
    ManagedBy = "terraform"
  }
}

# ---------------------------------------------------------------------------
# Elastic IP for NAT Gateway
# ---------------------------------------------------------------------------
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name      = "${var.environment}-eip"
    Project   = var.project_name
    Environment = var.environment
    ManagedBy = "terraform"
  }

  depends_on = [aws_internet_gateway.main]
}

# ---------------------------------------------------------------------------
# NAT Gateway (in public subnet AZ1 for private subnet outbound)
# ---------------------------------------------------------------------------
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_az1.id

  tags = {
    Name      = "${var.environment}-nat"
    Project   = var.project_name
    Environment = var.environment
    ManagedBy = "terraform"
  }

  depends_on = [aws_internet_gateway.main]
}

# ---------------------------------------------------------------------------
# Private Subnet
# ---------------------------------------------------------------------------
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.az1

  tags = {
    Name      = "${var.environment}-private-subnet"
    Project   = var.project_name
    Environment = var.environment
    ManagedBy = "terraform"
  }
}

# ---------------------------------------------------------------------------
# Route Tables
# ---------------------------------------------------------------------------
# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name      = "${var.environment}-public-rt"
    Project   = var.project_name
    Environment = var.environment
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
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name      = "${var.environment}-private-rt"
    Project   = var.project_name
    Environment = var.environment
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
  name        = "${var.environment}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.main.id

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
    Name      = "${var.environment}-alb-sg"
    Project   = var.project_name
    Environment = var.environment
    ManagedBy = "terraform"
  }
}

# ECS Tasks Security Group
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.environment}-ecs-tasks-sg"
  description = "Security group for ECS tasks"
  vpc_id      = aws_vpc.main.id

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
    Name      = "${var.environment}-ecs-tasks-sg"
    Project   = var.project_name
    Environment = var.environment
    ManagedBy = "terraform"
  }
}
