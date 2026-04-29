# Development Environment Variables
aws_region               = "ap-south-1"
environment              = "dev"
project_name             = "agrox"
vpc_cidr                 = "10.0.0.0/16"
public_subnet_az1_cidr   = "10.0.1.0/24"
public_subnet_az2_cidr   = "10.0.2.0/24"
private_subnet_cidr      = "10.0.10.0/24"
container_name           = "agrox-app"
container_port           = 8000
ecr_repository_uri       = "687222805896.dkr.ecr.ap-south-1.amazonaws.com/agrox"
image_tag                = "latest"
task_cpu                 = "256"
task_memory              = "512"
desired_task_count       = 1
max_tasks                = 2
log_retention_days       = 7
