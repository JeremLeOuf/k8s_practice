# Fast Deployment Guide

## Problem

CloudFront distributions take **10-15 minutes** to deploy and destroy, making development iterations slow and CI/CD pipelines time-consuming.

## Solution: Conditional CloudFront

CloudFront is now **optional** and disabled by default. You can deploy in two modes:

### 1. Fast Mode (Default) - S3 Website Hosting Only

No CloudFront distribution is created. Perfect for development and learning.

```bash
# Deploy (takes ~1 minute instead of 10-15 minutes)
cd infrastructure
terraform apply

# Destroy (takes ~30 seconds instead of 2+ minutes)
terraform destroy
```

**Access your app:**
```
http://pkb-frontend-personal-knowledge-base.s3-website-us-east-1.amazonaws.com
```

**Pros:**
- ✅ **Instant deployment** (< 1 minute)
- ✅ **Fast destroy** (< 30 seconds)
- ✅ No CloudFront costs
- ✅ Perfect for dev/test environments

**Cons:**
- ❌ HTTP only (no HTTPS)
- ❌ No CDN (slower globally)
- ❌ No custom domain

### 2. Production Mode - CloudFront Enabled

Enables CloudFront for production use with CDN, HTTPS, and global edge locations.

```bash
# Deploy with CloudFront (takes ~5-15 minutes first time)
cd infrastructure
terraform apply -var="enable_cloudfront=true"

# Destroy with CloudFront (takes 2+ minutes due to CloudFront propagation)
terraform destroy -var="enable_cloudfront=true"
```

**Access your app:**
```
https://d1234567890abc.cloudfront.net
```

**Pros:**
- ✅ HTTPS support
- ✅ Global CDN (faster worldwide)
- ✅ Professional production setup
- ✅ Custom domain support

**Cons:**
- ❌ **Slow deployment** (10-15 minutes first time)
- ❌ **Slow destroy** (2+ minutes)
- ❌ Higher cost

## Quick Start

### Development / Testing (Recommended for Speed)

```bash
cd infrastructure
terraform init
terraform apply              # CloudFront disabled by default
terraform output             # Get S3 website URL
```

### Production Deployment

```bash
cd infrastructure
terraform apply -var="enable_cloudfront=true"
terraform output             # Get CloudFront URL
```

## Switching Between Modes

### From Fast Mode to Production Mode

```bash
# This will create CloudFront (takes ~15 minutes)
terraform apply -var="enable_cloudfront=true"
```

**Note:** You'll need to upload frontend files again:
```bash
aws s3 sync frontend/ s3://pkb-frontend-personal-knowledge-base/
```

### From Production Mode to Fast Mode

```bash
# This will destroy CloudFront (takes 2+ minutes)
terraform apply -var="enable_cloudfront=false"
# Or simply don't specify the variable (default is false)
terraform apply
```

## Terraform Variables

Add to `terraform.tfvars`:

```hcl
# For development (default)
enable_cloudfront = false

# For production
# enable_cloudfront = true
```

## Deployment Time Comparison

| Mode | Create Time | Destroy Time | Use Case |
|------|-------------|--------------|----------|
| Fast (S3 only) | ~1 minute | ~30 seconds | Development, testing, CI/CD |
| Production (CloudFront) | ~10-15 minutes | ~2-5 minutes | Production, demo |

## CI/CD Integration

For faster CI/CD pipelines, use fast mode:

```yaml
# .github/workflows/deploy.yml
- name: Deploy Infrastructure
  run: |
    cd infrastructure
    terraform apply -auto-approve  # Uses fast mode by default
```

For production deployments:

```yaml
- name: Deploy Production
  run: |
    cd infrastructure
    terraform apply -var="enable_cloudfront=true" -auto-approve
```

## Troubleshooting

### Issue: CloudFront still taking long to destroy

**Solution:** If you're destroying with CloudFront enabled, wait for it to complete. It can take 2-5 minutes. If it's stuck, manually disable the distribution in AWS Console first.

### Issue: S3 website returning 403

**Solution:** 
```bash
# Check if bucket policy exists
terraform state list | grep bucket_policy

# If CloudFront was previously enabled, you may need to:
terraform apply -var="enable_cloudfront=false"
terraform apply  # Re-run to fix public access
```

### Issue: Want to switch modes mid-deployment

**Solution:** Always complete current deployment, then switch:
```bash
# If stuck destroying CloudFront
# Wait for it to complete, then:
terraform apply -var="enable_cloudfront=false"
```

## Recommendations

1. **Local Development:** Always use fast mode
2. **CI/CD Testing:** Use fast mode for speed
3. **Production:** Enable CloudFront for features and performance
4. **Learning/Demos:** Fast mode is perfectly fine

## Additional Notes

- Default configuration: `enable_cloudfront = false`
- No breaking changes to existing resources
- S3 bucket remains the same regardless of mode
- Can switch between modes anytime
- S3 website endpoint URL never changes

