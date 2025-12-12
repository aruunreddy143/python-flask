param([ValidateSet("both", "dev", "prod")] [string]$Environment)

# Use parameter, environment variable, or prompt for input
if ([string]::IsNullOrEmpty($Environment)) {
    if ($env:TERRAFORM_ENVIRONMENT) {
        $Environment = $env:TERRAFORM_ENVIRONMENT
        Write-Host "Using TERRAFORM_ENVIRONMENT variable: $Environment" -ForegroundColor Cyan
    } else {
        Write-Host "Available options: dev, prod, both" -ForegroundColor Cyan
        $Environment = Read-Host "Enter environment to destroy"
        if ($Environment -notin @("dev", "prod", "both")) {
            Write-Host "Invalid environment. Use: dev, prod, or both" -ForegroundColor Red
            exit 1
        }
    }
}

Write-Host "=======================" -ForegroundColor Cyan
Write-Host "Terraform Destroy Script" -ForegroundColor Cyan
Write-Host "=======================" -ForegroundColor Cyan
Write-Host "Environment(s): $Environment" -ForegroundColor Magenta
Write-Host ""
Write-Host "WARNING: This will DELETE all resources in the selected environment(s)!" -ForegroundColor Red
Write-Host "This action CANNOT be undone." -ForegroundColor Red
Write-Host ""
$confirmation = Read-Host "Type 'yes' to confirm destruction"
if ($confirmation -ne "yes") {
    Write-Host "Destruction cancelled." -ForegroundColor Green
    exit 0
}

if ($Environment -eq "dev" -or $Environment -eq "both") {
    Write-Host ""
    Write-Host "Destroying DEV environment..." -ForegroundColor Yellow
    Write-Host "================================" -ForegroundColor Yellow
    Push-Location environments/dev
    terraform destroy -auto-approve
    Pop-Location
    Write-Host "DEV environment destroyed." -ForegroundColor Green
}

if ($Environment -eq "prod" -or $Environment -eq "both") {
    Write-Host ""
    Write-Host "Destroying PROD environment..." -ForegroundColor Yellow
    Write-Host "================================" -ForegroundColor Yellow
    Push-Location environments/prod
    terraform destroy -auto-approve
    Pop-Location
    Write-Host "PROD environment destroyed." -ForegroundColor Green
}

Write-Host ""
Write-Host "All selected environments have been destroyed." -ForegroundColor Green
