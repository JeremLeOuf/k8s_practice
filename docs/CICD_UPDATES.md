# CI/CD Pipeline Updates

## Overview

The GitHub Actions deployment pipeline has been updated to properly handle both CloudFront and S3-only deployments, automatically deploy on each commit, and support a fast development mode that skips resource imports.

## Changes Made

### 1. Fast Development Mode

Added `SKIP_IMPORT` environment variable to skip resource import steps:

```yaml
env:
  SKIP_IMPORT: true  # Fast mode - skips imports
```

**When enabled** (default):
- ⚡ Skipped: Resource imports (~30-60 seconds saved)
- ⚡ Skipped: CloudFront cleanup checks (~10 seconds saved)
- ⚡ Skipped: CloudFront enable checks (~5 seconds saved)
- **Total time saved: ~45-75 seconds per deployment**

**When disabled** (`SKIP_IMPORT: false`):
- All existing resources are checked and imported
- Slower but safer for first-time deployments or state sync issues

### 2. Automatic Build Triggers

The pipeline already triggers on each commit to `main` branch:

```yaml
on:
  push:
    branches: [ main ]
```

**No changes needed** - your pipeline already builds on every commit!

### 3. Frontend URL Detection

Added logic to detect whether CloudFront is enabled and use the appropriate frontend URL:

- **CloudFront enabled**: Uses `frontend_cdn_url` (HTTPS CloudFront URL)
- **CloudFront disabled**: Uses `frontend_s3_url` (HTTP S3 website endpoint)

### 4. Improved Frontend Verification

**Before**: Always waited for CloudFront (slow, especially for new deployments)

**After**: 
- S3 website endpoints are instantly available (no waiting)
- CloudFront deployments still get proper timeout checks
- Better feedback about which URL is being used

### 5. Enhanced Deployment Summary

The `notify` job now displays:
- Whether CloudFront or S3 is being used
- Complete URLs for all applications
- API Gateway URL
- Direct links to each app

## How It Works

1. **Commit to main** → Workflow triggers
2. **Build Lambda functions** → Packaged with dependencies
3. **Terraform apply** → Infrastructure provisioned/updated
4. **Frontend deployment** → Files synced to S3
5. **URL detection** → Checks CloudFront enable state
6. **Verification** → Tests frontend reachability
7. **Summary** → Shows all relevant URLs

## CloudFront vs S3-Only

### With CloudFront Enabled (`enable_cloudfront = true`)
- Frontend URL: `https://d1234567890.cloudfront.net`
- Deployment time: 15-20 minutes (first time)
- Update time: ~2 minutes
- Benefits: HTTPS, global CDN, better performance

### Without CloudFront (`enable_cloudfront = false`)
- Frontend URL: `http://pkb-frontend-xxx.s3-website-us-east-1.amazonaws.com`
- Deployment time: Instant (< 30 seconds)
- Update time: Instant
- Benefits: Fast development iteration, simple setup

## Usage

Simply push to the `main` branch:

```bash
git add .
git commit -m "Your changes"
git push origin main
```

The pipeline will automatically:
1. Build everything
2. Deploy to AWS
3. Show you the URLs in the GitHub Actions summary

## Manual Deployment

To manually trigger a deployment:

```bash
# Via GitHub Actions UI
Actions → CI/CD Pipeline → Run workflow → Deploy

# Or via deploy script locally
./deploy.sh
```

## Monitoring

Check deployment status in:
- **GitHub Actions**: `.github/workflows/deploy.yml` run logs
- **AWS Console**: 
  - S3: `pkb-frontend-xxx` bucket
  - CloudFront: Distribution (if enabled)
  - API Gateway: `pkb-api` endpoints

## Current Configuration

Based on `infrastructure/variables.tf` and `.github/workflows/deploy.yml`:
- `enable_cloudfront = false` (fast development mode)
- `SKIP_IMPORT = true` (fast development mode)
- Deploys to S3 website endpoint for instant availability
- Skips resource imports for faster iterations
- Frontend URL shown in pipeline summary

To enable CloudFront:
```hcl
# In terraform.tfvars or terraform apply
enable_cloudfront = true
```

To re-enable imports (for troubleshooting or first-time deployments):
```yaml
# In .github/workflows/deploy.yml
env:
  SKIP_IMPORT: false
```

