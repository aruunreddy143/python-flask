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

  default_tags {
    tags = {
      Project     = "python-flask"
      ManagedBy   = "Terraform"
    }
  }
}

module "ecr" {
  source = "../../modules/ecr"

  repository_name = var.ecr_repository_name
  environment     = var.environment
  scan_on_push    = var.scan_on_push

  tags = var.common_tags
}
