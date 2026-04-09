output "cluster_name" {
  description = "EKS cluster name — use in `aws eks update-kubeconfig --name <value>`."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API server endpoint."
  value       = module.eks.cluster_endpoint
}

output "ecr_repo_url" {
  description = "Full ECR repository URL — must match IMAGE in the Jenkinsfile."
  value       = aws_ecr_repository.agrox.repository_url
}

output "load_balancer_hostname" {
  description = "AWS ELB hostname for the agrox-service. May take ~2 min to populate after apply."
  value       = try(kubernetes_service.agrox.status[0].load_balancer[0].ingress[0].hostname, "pending")
}

output "vpc_id" {
  description = "VPC ID."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs used by EKS nodes."
  value       = module.vpc.public_subnets
}
