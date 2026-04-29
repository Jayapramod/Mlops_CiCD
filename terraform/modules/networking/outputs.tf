output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_az1_id" {
  description = "Public subnet AZ1 ID"
  value       = aws_subnet.public_az1.id
}

output "public_subnet_az2_id" {
  description = "Public subnet AZ2 ID"
  value       = aws_subnet.public_az2.id
}

output "private_subnet_id" {
  description = "Private subnet ID"
  value       = aws_subnet.private.id
}

output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = aws_security_group.alb.id
}

output "ecs_tasks_security_group_id" {
  description = "ECS tasks security group ID"
  value       = aws_security_group.ecs_tasks.id
}
