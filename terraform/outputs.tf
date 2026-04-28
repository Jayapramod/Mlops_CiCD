output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.agrox.name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.agrox.name
}

output "alb_dns_name" {
  description = "DNS name of the load balancer (use this to access your application)"
  value       = aws_lb.agrox.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.agrox.arn
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.agrox.id
}

output "public_subnet_az1_id" {
  description = "Public subnet AZ1 ID (ALB deployed here)"
  value       = aws_subnet.public_az1.id
}

output "public_subnet_az2_id" {
  description = "Public subnet AZ2 ID (ALB deployed here)"
  value       = aws_subnet.public_az2.id
}

output "private_subnet_id" {
  description = "Private subnet ID (ECS tasks deployed here)"
  value       = aws_subnet.private.id
}

output "cloudwatch_log_group" {
  description = "CloudWatch log group for ECS task logs"
  value       = aws_cloudwatch_log_group.agrox.name
}
