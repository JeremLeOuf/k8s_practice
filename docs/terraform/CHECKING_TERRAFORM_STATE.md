# Checking Your Terraform State

## Overview

When Terraform is deployed through GitHub Actions, the state management depends on your backend configuration. Currently, you're using **local state** which persists locally but is recreated during each GitHub Actions run.

## Your Current Setup

### Local State (What you have now)

- ✅ State file: `infrastructure/terraform.tfstate`
- ❌ Remote state (S3): Not configured (commented out)
- ⚠️ GitHub Actions: Creates fresh state on each run, imports existing resources

## How to Check Your Deployed Infrastructure

### Method 1: Local Terraform State (Recommended)

Since you have the state file locally, you can query it directly:

```bash
cd infrastructure

# List all resources in state
terraform state list

# Show detailed resource information
terraform state show aws_api_gateway_rest_api.api

# Get outputs (URLs, etc.)
terraform output

# Show everything in JSON format
terraform show -json | jq

# Get specific output
terraform output frontend_cdn_url
```

### Method 2: Check GitHub Actions Logs

View the latest deployment run to see what was deployed:

1. Go to your repository on GitHub
2. Click on "Actions" tab
3. Find the most recent workflow run
4. Expand the "Import Existing Resources" step (lines 153-228)
5. Look at the output - it shows all resources imported and state

The logs show:
```
📋 Resources in Terraform state:
aws_dynamodb_table.knowledge_base
aws_api_gateway_rest_api.api
aws_lambda_function.get_items
...
```

### Method 3: Use AWS CLI to Query Resources

Query AWS directly to see what's deployed:

```bash
# Check Lambda functions
aws lambda list-functions --query 'Functions[?contains(FunctionName, `pkb`) || contains(FunctionName, `budget`)].FunctionName' --output table

# Check API Gateway
aws apigateway get-rest-apis --query 'items[*].[name,id]' --output table

# Check DynamoDB tables
aws dynamodb list-tables --query 'TableNames[]' --output table

# Check S3 bucket
aws s3 ls | grep pkb

# Check CloudFront
aws cloudfront list-distributions --query 'DistributionList.Items[*].[Id,Comment,Enabled]' --output table
```

### Method 4: Use the Check Script

```bash
./scripts/check-aws-resources.sh
```

### Method 5: All AWS Resources (Comprehensive)

```bash
./scripts/list-all-aws-resources.sh
```

## Understanding the Differences

### Why You See Empty `terraform state list` Sometimes

**Scenario**: Running `terraform state list` in the wrong directory or after `git clean`

**Solution**: Always run Terraform commands from `infrastructure/` directory

```bash
cd infrastructure
terraform state list  # Should show your resources
```

### Your Current Resources (From Latest Check)

Based on your local state file, you have deployed:

**API Gateway:**
- API ID: `wh8ynl32ej`
- API URL: `https://wh8ynl32ej.execute-api.us-east-1.amazonaws.com/prod`
- Stage: `prod`

**Lambda Functions:**
- `pkb-api-get-items`
- `pkb-api-create-item`
- `pkb-api-delete-item`

**DynamoDB:**
- `PersonalKnowledgeBase` table

**S3:**
- `pkb-frontend-personal-knowledge-base` bucket

**CloudFront:**
- Distribution ID: `E3NS4RAXH9JQPX`
- Domain: `d3omyuipjafw6h.cloudfront.net`

## Setting Up Remote State (Optional)

If you want to manage state in S3 (recommended for team collaboration):

### 1. Uncomment Backend in `infrastructure/main.tf`:

```hcl
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "pkb-terraform-state"  # Create this bucket first
    key    = "serverless-app/terraform.tfstate"
    region = "us-east-1"
  }
}
```

### 2. Create the S3 Bucket:

```bash
aws s3api create-bucket --bucket pkb-terraform-state --region us-east-1
aws s3api put-bucket-versioning --bucket pkb-terraform-state --versioning-configuration Status=Enabled
```

### 3. Migrate Local State to S3:

```bash
cd infrastructure
terraform init -migrate-state
```

### 4. Benefits of Remote State:

- ✅ State persists across CI/CD runs
- ✅ Multiple team members can collaborate
- ✅ State is versioned and backed up
- ✅ GitHub Actions and local developers share the same state

## Quick Reference Commands

```bash
# Check state from anywhere in project
cd infrastructure && terraform state list

# See deployed resources
cd infrastructure && terraform output

# Show specific resource details
cd infrastructure && terraform state show aws_s3_bucket.frontend

# Count resources
cd infrastructure && terraform state list | wc -l

# Search for specific resources
cd infrastructure && terraform state list | grep api_gateway

# Get resource IDs
cd infrastructure && terraform state list | xargs -I {} terraform state show {} | grep "id ="
```

## Troubleshooting

### Issue: "terraform state list" shows nothing

**Possible causes:**
1. Running from wrong directory (not in `infrastructure/`)
2. State file doesn't exist (`terraform.tfstate`)
3. Not initialized (`terraform init` not run)

**Solution:**
```bash
cd infrastructure
ls -la terraform.tfstate  # Check if file exists
terraform init  # Initialize if needed
terraform state list
```

### Issue: Resources show in GitHub Actions but not locally

**Cause:** GitHub Actions has its own ephemeral state (lost after workflow completes)

**Solution:** Either:
1. Setup remote S3 backend (recommended)
2. Check GitHub Actions logs to see what was deployed
3. Query AWS directly using AWS CLI

### Issue: Want to sync GitHub Actions state with local state

**Solution:** GitHub Actions runs `terraform import` on each deployment (lines 153-228 in workflow), so local state might be missing some resources.

To sync:
```bash
cd infrastructure
git pull  # Get latest
./scripts/import-all-existing.sh  # Import what's in AWS
```

## Summary

Your Terraform state is currently **local** and managed in `infrastructure/terraform.tfstate`.

**To check your state:**
1. **Best option**: `cd infrastructure && terraform state list`
2. **For URLs**: `cd infrastructure && terraform output`
3. **For AWS resources**: Use `./scripts/check-aws-resources.sh`
4. **For GitHub Actions**: Check Actions tab in GitHub

The state file shows you have **24 resources** deployed successfully! ✅

