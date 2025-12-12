output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.alb.alb_dns_name
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs_service.cluster_id
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = module.ecs_service.service_name
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = data.aws_ecr_repository.flask_app.repository_url
}

output "ecr_repository_arn" {
  description = "The ARN of the ECR repository"
  value       = data.aws_ecr_repository.flask_app.arn
}

output "ecr_registry_id" {
  description = "The registry ID (AWS Account ID)"
  value       = data.aws_ecr_repository.flask_app.registry_id
}

output "ecr_repository_name" {
  description = "The name of the ECR repository"
  value       = data.aws_ecr_repository.flask_app.name
}
