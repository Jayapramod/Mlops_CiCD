terraform {
  required_version = "~> 1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Recommended: enable S3 backend for shared/team state management.
  # Steps:
  #   1. Create an S3 bucket and DynamoDB table for state locking.
  #   2. Uncomment the block below and fill in your values.
  #   3. Run `terraform init -migrate-state` to migrate local state.
  #
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "agrox/dev/terraform.tfstate"
  #   region         = "ap-south-1"
  #   dynamodb_table = "terraform-state-lock"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region
}

# ---------------------------------------------------------------------------
# NETWORKING MODULE
# ---------------------------------------------------------------------------
module "networking" {
  source = "../../modules/networking"

  environment            = var.environment
  project_name           = var.project_name
  aws_region             = var.aws_region
  vpc_cidr               = var.vpc_cidr
  public_subnet_az1_cidr = var.public_subnet_az1_cidr
  public_subnet_az2_cidr = var.public_subnet_az2_cidr
  private_subnet_cidr    = var.private_subnet_cidr
  az1                    = "${var.aws_region}a"
  az2                    = "${var.aws_region}b"
  container_port         = var.container_port
}

# ---------------------------------------------------------------------------
# ALB MODULE
# ---------------------------------------------------------------------------
module "alb" {
  source = "../../modules/alb"

  environment             = var.environment
  project_name            = var.project_name
  vpc_id                  = module.networking.vpc_id
  public_subnet_ids       = [module.networking.public_subnet_az1_id, module.networking.public_subnet_az2_id]
  alb_security_group_id   = module.networking.alb_security_group_id
  container_port          = var.container_port
}

# ---------------------------------------------------------------------------
# ECS MODULE
# ---------------------------------------------------------------------------
module "ecs" {
  source = "../../modules/ecs"

  environment                  = var.environment
  project_name                 = var.project_name
  aws_region                   = var.aws_region
  container_name               = var.container_name
  container_port               = var.container_port
  ecr_repository_uri           = var.ecr_repository_uri
  image_tag                    = var.image_tag
  task_cpu                     = var.task_cpu
  task_memory                  = var.task_memory
  desired_task_count           = var.desired_task_count
  max_tasks                    = var.max_tasks
  log_retention_days           = var.log_retention_days
  private_subnet_id            = module.networking.private_subnet_id
  ecs_tasks_security_group_id  = module.networking.ecs_tasks_security_group_id
  target_group_arn             = module.alb.target_group_arn
  alb_listener_arn             = module.alb.listener_arn
}

# ---------------------------------------------------------------------------
# ECR MODULE (Optional - Jenkins manages ECR)
# ---------------------------------------------------------------------------
module "ecr" {
  source = "../../modules/ecr"

  environment         = var.environment
  project_name        = var.project_name
  ecr_repository_uri  = var.ecr_repository_uri
}
