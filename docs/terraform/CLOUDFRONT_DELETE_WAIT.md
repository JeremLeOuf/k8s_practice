# CloudFront Distribution Delete - Expected Wait Times

## Normal Behavior
CloudFront distribution deletion takes **15-20 minutes**. This is expected AWS behavior, not a hang.

### Why So Long?
1. **Edge Location Propagation**: AWS must remove distribution from 200+ edge locations worldwide
2. **Cache Invalidation**: Wait for all caches to be cleared
3. **Traffic Draining**: Ensure no active connections remain
4. **DNS Propagation**: Remove distribution from global DNS

### Status During Delete
```bash
$ aws cloudfront get-distribution --id E2TCC1WJ238U13
{
  "Distribution": {
    "Status": "InProgress"  # Normal during deletion
  }
}
```

The status will show `InProgress` for 15-20 minutes, then change to `Deployed` briefly before deletion completes.

## Expected Terraform Output

```
aws_cloudfront_distribution.frontend: Destroying... [id=E2TCC1WJ238U13]
aws_cloudfront_distribution.frontend: Still destroying... [00m10s elapsed]
aws_cloudfront_distribution.frontend: Still destroying... [00m20s elapsed]
# ... continues for ~15-20 minutes ...
aws_cloudfront_distribution.frontend: Destruction complete after 18m32s
```

## Can This Be Avoided?

### Option 1: Don't Wait (Not Recommended)
```hcl
resource "aws_cloudfront_distribution" "frontend" {
  # ...
  lifecycle {
    create_before_destroy = true
  }
}
```
**Problem**: This won't help - deletion is inherently slow

### Option 2: Skip CloudFront in CI/CD
For temporary test environments, use S3 static website hosting directly:
```hcl
resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  # ...
}
```
**Trade-off**: No CDN benefits, but faster delete

### Option 3: Use Lambda@Edge for Minimal CDN
Use a smaller CloudFront setup or accept the wait time.

## Best Practices

### For Development
1. **Use S3 directly** (no CloudFront) for faster iteration
2. **Only use CloudFront for staging/production**

### For CI/CD Destroy
```yaml
- name: Terraform Destroy
  run: |
    timeout 1800 terraform destroy -auto-approve
  # 30-minute timeout for CloudFront deletion
```

### For Production
**Don't destroy** unless absolutely necessary:
1. CloudFront deletion takes 20 minutes
2. Can't be undone or cancelled
3. Breaking changes require new distribution ID
4. Cache rebuilding takes additional time

## Quick Check Commands

```bash
# Check CloudFront status
aws cloudfront get-distribution --id <distribution-id>

# List all distributions
aws cloudfront list-distributions | grep -E "Id|DomainName"

# Skip CloudFront (faster cleanup)
terraform destroy -target=aws_s3_bucket.frontend
terraform destroy -target=aws_iam_role.lambda_role
# etc. (everything except CloudFront)
```

## Summary

**15-20 minute wait is NORMAL** for CloudFront deletion. This is not a bug or hang - it's how AWS CloudFront CDN works.

**If you need faster iteration:**
- Use S3 static website hosting for development
- Save CloudFront for production deployments
- Consider skipping CloudFront in temporary environments

