# 🎛️ Managing Infrastructure via GitHub Actions

## Overview

Your infrastructure is managed through **GitHub Actions**, providing automatic deployment, validation, and cleanup. Here's how to work with it.

## Quick Reference

| Action | Command/Link |
|--------|--------------|
| **Deploy** | Push to main branch OR use workflow dispatch |
| **Destroy** | Use workflow dispatch with "destroy" action |
| **Monitor** | View at: `https://github.com/YOUR_USERNAME/REPO/actions` |
| **Local Deploy** | `cd infrastructure && terraform apply` |

## Methods to Deploy/Destroy

### Method 1: GitHub Actions (Recommended) ⭐

#### Deploy Infrastructure

**Option A: Auto-deploy on commit**
```bash
git add .
git commit -m "Deploy infrastructure changes"
git push origin main
```

**Option B: Manual trigger**
1. Go to: `https://github.com/YOUR_USERNAME/REPO/actions`
2. Click **"CI/CD Pipeline"** workflow
3. Click **"Run workflow"** button
4. Select `action: deploy`
5. Click **"Run workflow"**

#### Destroy Infrastructure

**Via GitHub UI:**
1. Go to: `https://github.com/YOUR_USERNAME/REPO/actions`
2. Click **"CI/CD Pipeline"** workflow
3. Click **"Run workflow"** button
4. Select `action: destroy`
5. Click **"Run workflow"**

**Note:** Destroy takes ~5-10 minutes to complete cleanup.

### Method 2: Local Terraform (Alternative)

#### Deploy Locally
```bash
cd infrastructure
terraform init
terraform plan
terraform apply -auto-approve
```

#### Destroy Locally
```bash
cd infrastructure
terraform destroy -auto-approve
```

⚠️ **Warning:** Local deploy creates separate state from GitHub Actions!

## What Each Deployment Does

### Deploy Workflow Steps

1. **Validate Infrastructure** - Checks Terraform syntax
2. **Build Lambda Functions** - Creates optimized ZIP packages
3. **Cleanup Old CloudFront** - Removes previous distributions
4. **Terraform Init** - Initializes Terraform
5. **Import Existing Resources** - Imports existing AWS resources into state
6. **Terraform Apply** - Creates/updates infrastructure
7. **Configure Frontend** - Injects API Gateway URL
8. **Deploy to S3** - Uploads frontend files
9. **Invalidate CloudFront Cache** - Clears CDN cache
10. **Wait for CloudFront** - Verifies deployment

### Destroy Workflow Steps

1. **Import Existing Resources** - Imports everything into state
2. **Cleanup AWS Resources** - Empties S3, detaches IAM policies
3. **Terraform Destroy** - Removes all infrastructure
4. **Force Cleanup** - Removes any remaining resources

## Monitoring Deployments

### Viewing Workflow Runs

Visit: `https://github.com/YOUR_USERNAME/REPO/actions`

You'll see:
- ✅ **Green checkmark** - Successful deployment
- ❌ **Red X** - Failed deployment
- 🟡 **Yellow dot** - In progress

### Viewing Logs

1. Click on a workflow run
2. Click on the job (e.g., "Deploy Infrastructure")
3. Click on individual steps to see logs

### Common Deployment Times

| Resource | Time |
|----------|------|
| Lambda Functions | 10-30s each |
| DynamoDB Tables | 5-10s |
| API Gateway | 10-20s |
| S3 Bucket | 5s |
| CloudFront | 15-20 minutes |

**Total:** ~20-25 minutes (mostly CloudFront)

## Common Operations

### 1. Update Lambda Functions

```bash
# Edit lambda-function code
vim lambda-functions/get-items/lambda_function.py

# Commit and push
git add .
git commit -m "Update Lambda function"
git push origin main

# Auto-deploys via GitHub Actions
```

### 2. Update Frontend

```bash
# Edit frontend files
vim frontend/app.html

# Commit and push
git add .
git commit -m "Update frontend"
git push origin main

# Frontend auto-deploys to S3 and CloudFront
```

### 3. Add New Resources

```bash
# Edit Terraform
vim infrastructure/main.tf
# Add new resource...

# Commit and push
git add .
git commit -m "Add new Lambda function"
git push origin main

# GitHub Actions validates and deploys
```

### 4. View Current Infrastructure

```bash
# List what's deployed
./scripts/list-all-aws-resources.sh

# Check specific resources
./scripts/check-aws-resources.sh
```

### 5. Clean Up Orphaned Resources

```bash
# List all resources
./scripts/list-all-aws-resources.sh

# Clean up orphaned resources
./scripts/cleanup-orphaned-resources.sh
```

## Workflow Triggers

### Automatic Triggers

| Event | Action |
|-------|--------|
| Push to `main` | Deploys infrastructure |
| Pull Request to `main` | Validates only (no deploy) |
| Manual trigger (deploy) | Deploys infrastructure |
| Manual trigger (destroy) | Destroys infrastructure |

### Manual Trigger Parameters

When triggering manually via GitHub UI:

**Action Options:**
- `deploy` - Deploys infrastructure
- `destroy` - Destroys infrastructure

## Workflow States

### State Management

GitHub Actions uses **local Terraform state** in the runner. State is **NOT shared** across runs, but resources are imported before each run.

**This means:**
- ✅ Each run imports existing resources
- ✅ No state drift
- ✅ Can work from multiple machines
- ⚠️ State is ephemeral (lost after run)

### Viewing State Locally

If you want to see the state locally:

```bash
cd infrastructure
terraform init
terraform show
```

## Troubleshooting

### Deployment Failed

**Check:**
1. View workflow logs in GitHub Actions
2. Look for error messages in Terraform output
3. Common issues:
   - AWS credentials missing
   - Resource already exists
   - IAM permissions insufficient

**Fix:**
```bash
# Re-trigger workflow
# OR manually import resources:
cd infrastructure
terraform import aws_lambda_function.get_items pkb-api-get-items
terraform apply
```

### State Mismatch

If Terraform shows "resource not in state":

```bash
# Use the import script
./scripts/import-all-existing.sh
```

### CloudFront Stuck

CloudFront can take 20+ minutes:

```bash
# Check CloudFront status
aws cloudfront list-distributions --query "DistributionList.Items[*].[Id,Status]"

# Wait for "Deployed" status
```

## Best Practices

### 1. Always Validate Before Deploy

The workflow validates on every PR. Don't skip this step!

### 2. Use Workflow Dispatch for Testing

Test destroy with workflow dispatch before committing dangerous changes.

### 3. Monitor Costs

After deployment, check AWS Billing Dashboard:
```bash
# Check current costs
./scripts/check-aws-resources.sh
```

### 4. Use Terraform Plan

Before major changes, run `terraform plan` locally:
```bash
cd infrastructure
terraform init
terraform plan
```

### 5. Backup State (Optional)

If using remote state:
```bash
# Sync state to S3
terraform init -backend-config="bucket=your-terraform-state"
terraform apply
```

## Automation Tips

### Skip CI/CD (Optional)

If you need to skip CI/CD:
```bash
# Add to commit message
git commit -m "Skip CI [skip ci]"
```

### Force Re-run

To re-run a failed workflow:
1. Go to Actions tab
2. Click on failed workflow
3. Click "Re-run all jobs"

## Resources

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Terraform Docs](https://www.terraform.io/docs)
- [AWS Free Tier](https://aws.amazon.com/free/)
- Your workflow: `.github/workflows/deploy.yml`

## Quick Commands Cheat Sheet

```bash
# Deploy via GitHub
git push origin main

# Destroy via GitHub
# Go to Actions → Run workflow → destroy

# Deploy locally
cd infrastructure && terraform apply

# Destroy locally
cd infrastructure && terraform destroy

# View resources
./scripts/list-all-aws-resources.sh

# Check costs
./scripts/check-aws-resources.sh

# Import missing resources
./scripts/import-all-existing.sh

# Clean up orphaned resources
./scripts/cleanup-orphaned-resources.sh
```

