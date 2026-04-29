output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "alb_dns_name" {
  description = "ALB DNS name (use this to access your application)"
  value       = module.alb.alb_dns_name
}

output "alb_arn" {
  description = "ALB ARN"
  value       = module.alb.alb_arn
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.ecs_cluster_name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = module.ecs.ecs_service_name
}

output "cloudwatch_log_group" {
  description = "CloudWatch log group"
  value       = module.ecs.cloudwatch_log_group
}

output "ecr_repository_uri" {
  description = "ECR repository URI"
  value       = module.ecr.ecr_repository_uri
}
