terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Create ECR Repository
resource "aws_ecr_repository" "python_flask_repo" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = var.ecr_repository_name
    Environment = var.environment
    Project     = "python-flask"
  }
}

# Output the ECR repository details
output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.python_flask_repo.repository_url
}

output "ecr_repository_arn" {
  description = "The ARN of the ECR repository"
  value       = aws_ecr_repository.python_flask_repo.arn
}

output "ecr_registry_id" {
  description = "The registry ID (AWS Account ID)"
  value       = aws_ecr_repository.python_flask_repo.registry_id
}
