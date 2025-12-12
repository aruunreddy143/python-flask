# Destroying Infrastructure

This guide explains how to safely destroy the Terraform-managed infrastructure.

## ⚠️ Warning

Destroying infrastructure will **permanently delete** all AWS resources including:
- VPC, Subnets, Internet Gateways
- Application Load Balancer (ALB)
- ECS Cluster, Services, and Task Definitions
- CloudWatch Log Groups
- IAM Roles and Policies
- Security Groups
- NAT Gateways and Elastic IPs
- Network Interfaces

**The ECR repository will NOT be automatically deleted** since it wasn't created by Terraform.

## Option 1: Using Destroy Scripts (Recommended)

### On Windows (PowerShell):
```powershell
cd terraform
.\destroy.ps1
```

### On Linux/Mac (Bash):
```bash
cd terraform
chmod +x destroy.sh
./destroy.sh
```

Both scripts will:
1. Show a confirmation prompt
2. Destroy DEV environment
3. Destroy PROD environment
4. Provide cleanup instructions

## Option 2: Manual Destruction

### Destroy DEV Environment:
```bash
cd terraform/environments/dev
terraform destroy
```

### Destroy PROD Environment:
```bash
cd terraform/environments/prod
terraform destroy
```

## Option 3: Selective Destruction

Destroy only specific resources (without destroying everything):

### Destroy only ECS Service (keeps infrastructure):
```bash
cd terraform/environments/dev
terraform destroy -target=module.ecs_service
```

### Destroy only ALB:
```bash
cd terraform/environments/dev
terraform destroy -target=module.alb
```

## Cleanup Checklist

After running destroy, verify cleanup:

```bash
# Check if resources are deleted
aws ec2 describe-vpcs --filter "Name=tag:Project,Values=python-flask"
aws ecs list-clusters --region us-east-1
aws elasticloadbalancing describe-load-balancers --region us-east-1

# Delete ECR repository (if desired)
aws ecr delete-repository --repository-name python-flask --force --region us-east-1

# Delete local Terraform state
rm -rf terraform/environments/dev/.terraform terraform/environments/dev/terraform.tfstate*
rm -rf terraform/environments/prod/.terraform terraform/environments/prod/terraform.tfstate*
```

## Cost Implications

After destruction, you will **no longer incur charges** for:
- ✓ EC2 instances (Fargate tasks)
- ✓ Load Balancer
- ✓ NAT Gateway
- ✓ Elastic IPs
- ✓ VPC endpoints

However, you **may still be charged** for:
- ⚠️ ECR repository storage (small cost)
- ⚠️ CloudWatch Logs (if log groups aren't deleted)

## Recovery

If you accidentally destroy resources:

1. **Terraform State is preserved** locally (in `.terraform` folders)
2. **Recreate resources** by running:
   ```bash
   cd terraform/environments/dev
   terraform apply
   ```

## Automation

To automatically destroy resources on a schedule, you can use AWS Lambda with this script:

```python
import boto3
import subprocess

def lambda_handler(event, context):
    # Run destroy script via CodeBuild or Systems Manager
    codebuild = boto3.client('codebuild')
    response = codebuild.start_build(projectName='python-flask-destroy')
    return response
```

## Security Considerations

- ✓ Ensure no production traffic is running before destroying
- ✓ Backup any important data from CloudWatch Logs
- ✓ Verify no dependent services are using these resources
- ✓ Review AWS CloudTrail for audit trail

---

**Need to keep some resources?** Use terraform targeting:
```bash
terraform destroy -target=module.vpc  # Only destroy VPC
terraform destroy -target=module.alb  # Only destroy ALB
```
