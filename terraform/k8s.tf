# ---------------------------------------------------------------------------
# NOTE: Using ECS Fargate for container orchestration instead of Kubernetes
# ---------------------------------------------------------------------------
# This file is kept for reference. ECS is configured to:
#
# 1. Run AgroX application as containerized tasks on AWS Fargate
# 2. Pull Docker image automatically from ECR via Jenkins pipeline
# 3. Balance traffic through Application Load Balancer (ALB)
# 4. Provide auto-scaling based on CPU and memory utilization
#
# Infrastructure Components:
# - VPC: 10.0.0.0/16 (public + private subnets)
# - Public Subnet: 10.0.1.0/24 (ALB placement)
# - Private Subnet: 10.0.2.0/24 (ECS task placement)
# - NAT Gateway: Provides private subnet outbound internet access
# - ALB: Routes external traffic to ECS tasks
# - ECS Cluster: Manages Fargate tasks
# - CloudWatch: Captures application logs and metrics
#
# Deployment Workflow:
# 1. Jenkins triggers on code commit
# 2. Jenkins builds Docker image and pushes to ECR
# 3. Terraform applies ECS configuration
# 4. ECS pulls latest image from ECR
# 5. ALB routes traffic to running tasks
# 6. Auto-scaling adjusts task count based on CPU/memory
#
# Terraform Modules & Files:
# - main.tf: VPC, subnets, routing, security groups
# - alb.tf: Application Load Balancer, listener, target group
# - ecs.tf: ECS cluster, task definition, service, scaling policies
# - variables.tf: Configuration inputs
# - outputs.tf: Key resource identifiers
#
# To deploy:
#   cd terraform/
#   terraform init
#   terraform plan
#   terraform apply
#
# To view application:
#   Open browser to: <alb_dns_name> (from terraform output)
#
# To check logs:
#   aws logs tail /ecs/agrox-cluster --follow
#
# To scale tasks:
#   aws ecs update-service \
#     --cluster agrox-cluster \
#     --service agrox-service \
#     --desired-count 2
# ---------------------------------------------------------------------------


