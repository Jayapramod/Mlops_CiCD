locals {
  azs = ["${var.aws_region}a", "${var.aws_region}b"]

  # Public subnet CIDRs — one per AZ
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
}

# ---------------------------------------------------------------------------
# VPC — public subnets only, no NAT gateway
# ---------------------------------------------------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = "10.0.0.0/16"

  azs            = local.azs
  public_subnets = local.public_subnets

  # No private subnets or NAT gateway
  enable_nat_gateway = false
  single_nat_gateway = false

  # Nodes and load balancers need public IPs
  map_public_ip_on_launch = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  # Tags required by the AWS LoadBalancer controller to discover public subnets
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  tags = {
    Project   = "agrox"
    ManagedBy = "terraform"
  }
}

# ---------------------------------------------------------------------------
# EKS Cluster
# ---------------------------------------------------------------------------
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  # Allow public access to the Kubernetes API server
  cluster_endpoint_public_access = true

  # Managed node group
  eks_managed_node_groups = {
    agrox-nodes = {
      instance_types = [var.node_instance_type]
      min_size       = var.node_min
      max_size       = var.node_max
      desired_size   = var.node_desired

      # Attach ECR read policy so pods can pull images without pull secrets
      iam_role_additional_policies = {
        ecr_read = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      }
    }
  }

  tags = {
    Project   = "agrox"
    ManagedBy = "terraform"
  }
}
