terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment the backend block once S3 bucket and DynamoDB table are created
  # backend "s3" {
  #   bucket         = "python-flask-terraform-state"
  #   key            = "prod/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = "python-flask"
    }
  }
}

# ECR Repository for Flask App
resource "aws_ecr_repository" "flask_app" {
  name                 = var.project_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.project_name}-ecr"
    Environment = var.environment
  }
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  vpc_name           = "${var.project_name}-vpc-${var.environment}"
  cidr_block         = "10.1.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]

  public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnet_cidrs = ["10.1.10.0/24", "10.1.11.0/24"]

  environment = var.environment
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# ALB Module
module "alb" {
  source = "../../modules/alb"

  alb_name           = "${var.project_name}-alb-${var.environment}"
  target_group_name  = "${var.project_name}-tg-${var.environment}"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.public_subnet_ids
  container_port     = var.container_port
  health_check_path  = "/"

  environment = var.environment
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# ECS Task Definition Module
module "ecs_task_definition" {
  source = "../../modules/ecs_task_definition"

  family              = "${var.project_name}-${var.environment}"
  container_name      = var.project_name
  ecr_repository_url  = aws_ecr_repository.flask_app.repository_url
  image_tag           = "latest"
  container_port      = var.container_port
  cpu                 = var.ecs_task_cpu
  memory              = var.ecs_task_memory
  log_group_name      = "/ecs/${var.project_name}-${var.environment}"
  log_group_region    = var.aws_region

  environment_variables = {
    FLASK_ENV = var.environment
  }

  environment = var.environment
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# ECS Service Module
module "ecs_service" {
  source = "../../modules/ecs_service"

  cluster_name           = "${var.project_name}-cluster-${var.environment}"
  service_name           = "${var.project_name}-service-${var.environment}"
  task_definition_arn    = module.ecs_task_definition.task_definition_arn
  desired_count          = var.ecs_desired_count
  container_name         = var.project_name
  container_port         = var.container_port
  vpc_id                 = module.vpc.vpc_id
  subnet_ids             = module.vpc.private_subnet_ids
  alb_target_group_arn   = module.alb.target_group_arn
  security_group_ids     = [module.alb.ecs_security_group_id]
  enable_autoscaling     = true
  min_capacity           = 2
  max_capacity           = 4

  environment = var.environment
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}
