# CDN Access Denied Troubleshooting

## Problem

When accessing the CloudFront CDN URL, you get an "Access Denied" error (403 or similar).

## Common Causes

### 1. Files Not Uploaded to S3
The most common issue is that the frontend files haven't been deployed to S3 yet.

**Solution:**
```bash
# Deploy frontend files to S3
./scripts/deploy-frontend.sh

# Wait a few minutes for CloudFront to update
```

### 2. CloudFront Still Deploying
CloudFront distributions take 15-20 minutes to fully deploy on first creation.

**Solution:**
Wait 15-20 minutes after Terraform apply, then try again.

### 3. S3 Bucket Policy Issues
The bucket might not have the correct policy for CloudFront access.

**Check:**
```bash
# Get bucket name
cd infrastructure
BUCKET_NAME=$(terraform output -raw frontend_bucket_name)

# Check bucket policy
aws s3api get-bucket-policy --bucket "$BUCKET_NAME"
```

### 4. CloudFront Cache
CloudFront might be caching the error.

**Solution:**
Invalidate CloudFront cache:
```bash
# Get distribution ID
DIST_ID=$(aws cloudfront list-distributions --query "DistributionList.Items[0].Id" --output text)

# Create invalidation
aws cloudfront create-invalidation --distribution-id "$DIST_ID" --paths "/*"
```

## Diagnosis

### Quick Check Script
```bash
./scripts/check-cdn-status.sh
```

This script will:
- ✅ Check if bucket exists and has files
- ✅ Check bucket policy
- ✅ Check CloudFront distribution status
- ✅ Test CDN URL
- ✅ Auto-deploy if files are missing

### Manual Checks

#### 1. Check S3 Bucket Contents
```bash
cd infrastructure
BUCKET=$(terraform output -raw frontend_bucket_name)
aws s3 ls "s3://$BUCKET"
```

Should show: `index.html` and other files

#### 2. Check CloudFront Distribution
```bash
aws cloudfront list-distributions --query "DistributionList.Items[].{Id:Id,DomainName:DomainName,Status:Status}" --output table
```

#### 3. Check Bucket Policy
```bash
BUCKET=$(terraform output -raw frontend_bucket_name)
aws s3api get-bucket-policy --bucket "$BUCKET" | jq -r .Policy | jq '.'
```

Should show a policy allowing CloudFront OAI to access.

#### 4. Test CDN Directly
```bash
URL=$(terraform output -raw frontend_url)
curl -I "https://$URL"
```

## Step-by-Step Fix

### Complete Fresh Deploy

```bash
# 1. Deploy infrastructure
cd infrastructure
terraform apply

# 2. Deploy frontend files
cd ..
./scripts/deploy-frontend.sh

# 3. Wait for CloudFront (15-20 minutes on first deploy)
echo "⏳ Waiting for CloudFront to deploy..."
watch -n 60 'aws cloudfront get-distribution --id $(aws cloudfront list-distributions --query "DistributionList.Items[0].Id" --output text) --query "Distribution.Status" --output text'

# 4. Invalidate cache
DIST_ID=$(aws cloudfront list-distributions --query "DistributionList.Items[0].Id" --output text)
aws cloudfront create-invalidation --distribution-id "$DIST_ID" --paths "/*"

# 5. Test
URL=$(terraform output -raw frontend_url)
echo "Visit: https://$URL"
```

## Verify Everything

```bash
# Run the diagnostic script
./scripts/check-cdn-status.sh
```

This will:
- Check all components
- Show current status
- Deploy if needed
- Test the CDN

## Expected Output

When working correctly, you should see:
```bash
✓ Files found in bucket
✓ CloudFront distribution is deployed
✓ CDN is reachable (Status: 200)
```

## Still Not Working?

### Check IAM Permissions
```bash
aws sts get-caller-identity
```

Your IAM user needs:
- `s3:PutObject`
- `s3:ListBucket`
- `cloudfront:GetDistribution`
- `cloudfront:CreateInvalidation`

### Check CloudFront Logs
```bash
# Enable logging in CloudFront
# Then check logs for errors
```

### Verify Correct Domain
```bash
# Make sure you're using the right URL
terraform output frontend_url
terraform output frontend_cdn_url
```

## Common Error Messages

| Error | Cause | Solution |
|-------|-------|----------|
| "Access Denied" (403) | Files not in bucket | Run `deploy-frontend.sh` |
| "Access Denied" (403) | Bucket policy issue | Check bucket policy |
| "Distribution Not Found" | Not deployed yet | Wait 15-20 minutes |
| "NoSuchBucket" | Bucket doesn't exist | Run `terraform apply` |
| "Access Denied" (403) | Cache issue | Invalidate CloudFront cache |

## Quick Reference

```bash
# Get all frontend information
cd infrastructure
terraform output | grep frontend

# Deploy frontend
./scripts/deploy-frontend.sh

# Check status
./scripts/check-cdn-status.sh

# Invalidate cache
aws cloudfront create-invalidation \
  --distribution-id $(aws cloudfront list-distributions --query "DistributionList.Items[0].Id" --output text) \
  --paths "/*"
```

## Resources

- [S3 Static Website Setup](./UI_README.md)
- [Deploy Frontend Script](../../scripts/deploy-frontend.sh)
- [Check CDN Status Script](../../scripts/check-cdn-status.sh)
- [AWS CloudFront Documentation](https://docs.aws.amazon.com/cloudfront/)

