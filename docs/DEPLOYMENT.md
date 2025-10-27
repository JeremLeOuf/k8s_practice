# 🚀 Complete Deployment Guide

## Overview

Deploy your entire serverless application (Knowledge Base, Budget Tracker, Grafana, and Frontend) with a single command.

## Quick Start

```bash
# From the project root
./deploy.sh
```

That's it! The script will:
1. ✅ Build all Lambda functions
2. ✅ Deploy infrastructure (Terraform)
3. ✅ Configure frontend with API URLs
4. ✅ Deploy frontend to S3
5. ✅ Show you all the URLs

## What Gets Deployed

### Backend Services
- **Lambda Functions** (6 functions)
  - Knowledge Base: get-items, create-item, delete-item
  - Budget Tracker: add-transaction, get-balance, send-alert
- **API Gateway** - REST API endpoints
- **DynamoDB** - 2 tables (knowledge base, budget tracker)
- **SNS** - Budget alerts topic

### Frontend Apps
- **🏠 Home Hub** - Main landing page
- **📚 Knowledge Base** - Personal knowledge management
- **💰 Budget Tracker** - Financial tracking
- **📊 Grafana** - Monitoring dashboard access

## Prerequisites

Before running the deployment script:

1. **AWS CLI installed** and configured
   ```bash
   aws --version
   aws configure
   ```

2. **Terraform installed** (optional, script will check)
   ```bash
   terraform version
   ```

3. **AWS credentials** with permissions for:
   - Lambda
   - API Gateway
   - DynamoDB
   - S3
   - CloudFront
   - SNS
   - IAM

## Usage

### Basic Deployment

```bash
./deploy.sh
```

The script will:
1. Ask for confirmation
2. Build all Lambda functions
3. Deploy infrastructure with Terraform
4. Update frontend files with API Gateway URL
5. Deploy frontend to S3
6. Show deployment summary

### Step-by-Step Manual Deployment

If you prefer to deploy manually:

#### 1. Build Lambda Functions

```bash
./scripts/build-lambda.sh
```

#### 2. Deploy Infrastructure

```bash
cd infrastructure
terraform init
terraform apply
cd ..
```

#### 3. Deploy Frontend

```bash
./scripts/deploy-frontend.sh
```

## Deployment Output

After successful deployment, you'll see:

```
🎉 Deployment Complete!

📊 Deployment Summary:

Backend APIs:
  API Gateway: https://xxxxx.execute-api.us-east-1.amazonaws.com/prod
  Knowledge Base API: https://xxxxx.execute-api.us-east-1.amazonaws.com/prod/items
  Budget Tracker API: https://xxxxx.execute-api.us-eastاهدبته are transactions
  Budget Balance API: https://xxxxx.execute-api.us-east-1.amazonaws.com/prod/balance

Frontend Access:
  🌐 Website: http://pkb-frontend-personal-knowledge-base.s3-website-us-east-1.amazonaws.com
  🏠 Home: http://pkb-frontend-personal-knowledge-base.s3-website-us-east-1.amazonaws.com/
  📚 Knowledge Base: http://pkb-frontend-personal-knowledge-base.s3-website-us-east-1.amazonaws.com/knowledge-base/app.html
  💰 Budget Tracker: http://pkb-frontend-personal-knowledge-base.s3-website-us-east-1.amazonaws.com/budget-tracker/budget.html
  📊 Grafana: http://pkb-frontend-personal-knowledge-base.s3-website-us-east-1.amazonaws.com/knowledge-base/grafana.html

Databases:
  📚 Knowledge Base: PersonalKnowledgeBase
  💰 Budget Tracker: BudgetTracker
```

## Updating the Deployment

To update your deployment:

```bash
# Make your changes to code/files
git add .
git commit -m "Your changes"

# Redeploy
./deploy.sh
```

The script will:
- Rebuild changed Lambda functions
- Update Terraform infrastructure if changed
- Redeploy frontend with latest changes

## Troubleshooting

### AWS Credentials Not Found

```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Enter default region (us-east-1)
```

### Terraform State Lock

If Terraform is locked:
```bash
cd infrastructure
terraform force-unlock <LOCK_ID>
```

### Lambda Function Update Failed

The function code may be too large. Check:
```bash
du -h lambda-functions/**/*/function.zip
```

### Frontend Files Not Updating

Clear CloudFront cache:
```bash
cd infrastructure
aws cloudfront create-invalidation \
  --distribution-id <DIST_ID> \
  --paths "/*"
```

Or use S3 website endpoint directly (no CloudFront).

## Cost

This deployment uses AWS Free Tier:
- **Lambda**: 1M requests/month free
- **API Gateway**: 1M requests/month free
- **DynamoDB**: 25GB storage free
- **S3**: 5GB storage free
- **CloudFront**: 1TB transfer free (if enabled)

Total estimated cost: **$0/month** (within free tier limits)

## Deployment Time

- **First deployment**: ~3-5 minutes
- **Updates**: ~1-2 minutes
- **Fast mode** (no CloudFront): ~30 seconds

## Environment Variables

The script uses your current AWS environment. No additional configuration needed.

## Advanced Options

### Deploy Only Frontend

```bash
./scripts/deploy-frontend.sh
```

### Deploy Only Infrastructure

```bash
cd infrastructure
terraform apply
```

### Rebuild Only Lambda Functions

```bash
./scripts/build-lambda.sh
```

## CI/CD Integration

For automated deployments, see:
- [CI/CD Setup](./terraform/CI_CD_SETUP.md)
- GitHub Actions workflow: `.github/workflows/deploy.yml`

## Rollback

To rollback to a previous version:

```bash
cd infrastructure
terraform apply -var="enable_cloudfront=false"  # Disable CloudFront
# Or rollback via Terraform state
```

## Next Steps

1. ✅ **Test the deployment** - Visit the frontend URLs
2. ✅ **Configure Grafana** - Set up CloudWatch data source
3. ✅ **Add transactions** - Test budget tracker
4. ✅ **Monitor** - Check CloudWatch logs

## Support

For issues, check:
- [Terraform Troubleshooting](./terraform/DESTROY_TROUBLESHOOTING.md)
- [Frontend Issues](./frontend/CDN_TROUBLESHOOTING.md)
- [Budget Tracker Setup](./budget-tracker/BUDGET_TRACKER_SETUP.md)

