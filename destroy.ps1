# Terraform Destroy Script for Python Flask ECS Infrastructure
# This script destroys all resources created by Terraform
# Usage: .\destroy.ps1
# Usage: .\destroy.ps1 -Environment dev
# Usage: .\destroy.ps1 -Environment prod

param(
    [ValidateSet("both", "dev", "prod")]
    [string]$Environment = "both"
)

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Terraform Destroy - Python Flask ECS Infrastructure" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Environment: $Environment" -ForegroundColor Magenta
Write-Host ""

Write-Host "WARNING: This will delete all AWS resources!" -ForegroundColor Yellow
Write-Host ""
Write-Host "Resources to be deleted:"
Write-Host "  - VPC and Subnets"
Write-Host "  - Application Load Balancer"
Write-Host "  - ECS Cluster and Services"
Write-Host "  - CloudWatch Log Groups"
Write-Host "  - IAM Roles and Policies"
Write-Host "  - Security Groups"
Write-Host "  - NAT Gateways and Elastic IPs"
Write-Host ""

$confirmation = Read-Host "Are you sure you want to destroy $Environment environment(s)? (type 'yes' to confirm)"

if ($confirmation -ne "yes") {
    Write-Host "Destruction cancelled."
    exit 0
}

if ($Environment -eq "dev" -or $Environment -eq "both") {
    Write-Host ""
    Write-Host "Destroying DEV environment..." -ForegroundColor Yellow

    Push-Location terraform/environments/dev
    terraform destroy -auto-approve
    Pop-Location
    
    Write-Host "✓ DEV environment destroyed successfully!" -ForegroundColor Green
}

if ($Environment -eq "prod" -or $Environment -eq "both") {
    Write-Host ""
    Write-Host "Destroying PROD environment..." -ForegroundColor Yellow

    Push-Location terraform/environments/prod
    terraform destroy -auto-approve
    Pop-Location
    
    Write-Host "✓ PROD environment destroyed successfully!" -ForegroundColor Green
}

Write-Host ""
Write-Host "✓ All requested resources have been successfully destroyed!" -ForegroundColor Green
Write-Host ""
Write-Host "Note: The ECR repository (python-flask) was NOT deleted because it was not created by Terraform."
Write-Host "If you want to delete it manually, use:"
Write-Host "  aws ecr delete-repository --repository-name python-flask --force"
