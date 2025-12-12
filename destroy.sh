#!/bin/bash

# Terraform Destroy Script for Python Flask ECS Infrastructure
# This script destroys all resources created by Terraform
# Usage: ./destroy.sh
# Usage: ./destroy.sh dev
# Usage: ./destroy.sh prod

set -e

# Parse arguments
ENVIRONMENT="${1:-both}"

# Validate environment argument
if [[ ! "$ENVIRONMENT" =~ ^(dev|prod|both)$ ]]; then
    echo "Invalid environment: $ENVIRONMENT"
    echo "Usage: $0 [dev|prod|both]"
    exit 1
fi

echo "================================================"
echo "Terraform Destroy - Python Flask ECS Infrastructure"
echo "================================================"
echo ""
echo "Environment: $ENVIRONMENT"
echo ""

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Confirm destruction
echo -e "${YELLOW}WARNING: This will delete all AWS resources!${NC}"
echo ""
echo "Resources to be deleted:"
echo "  - VPC and Subnets"
echo "  - Application Load Balancer"
echo "  - ECS Cluster and Services"
echo "  - CloudWatch Log Groups"
echo "  - IAM Roles and Policies"
echo "  - Security Groups"
echo "  - NAT Gateways and Elastic IPs"
echo ""
read -p "Are you sure you want to destroy $ENVIRONMENT environment(s)? (type 'yes' to confirm): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Destruction cancelled."
    exit 0
fi

# Destroy DEV
if [ "$ENVIRONMENT" = "dev" ] || [ "$ENVIRONMENT" = "both" ]; then
    echo ""
    echo -e "${YELLOW}Destroying DEV environment...${NC}"
    cd terraform/environments/dev
    terraform destroy -auto-approve
    cd ../../..
    echo -e "${GREEN}✓ DEV environment destroyed successfully!${NC}"
fi

# Destroy PROD
if [ "$ENVIRONMENT" = "prod" ] || [ "$ENVIRONMENT" = "both" ]; then
    echo ""
    echo -e "${YELLOW}Destroying PROD environment...${NC}"
    cd terraform/environments/prod
    terraform destroy -auto-approve
    cd ../../..
    echo -e "${GREEN}✓ PROD environment destroyed successfully!${NC}"
fi

echo ""
echo -e "${GREEN}✓ All requested resources have been successfully destroyed!${NC}"
echo ""
echo "Note: The ECR repository (python-flask) was NOT deleted because it was not created by Terraform."
echo "If you want to delete it manually, use:"
echo "  aws ecr delete-repository --repository-name python-flask --force"
