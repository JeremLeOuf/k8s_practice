# CI/CD Pipeline Fixes

## Issues Resolved

### 1. Missing Lambda ZIP Files
**Error**: `Error: reading ZIP file (./../lambda-functions/get-items/function.zip): open ./../lambda-functions/get-items/function.zip: no such file or directory`

**Root Cause**: The Lambda deployment packages need to be built before Terraform can deploy them.

**Solution**: 
- Updated `.github/workflows/deploy.yml` to build Lambda packages before Terraform runs
- Added `Build Lambda Functions` step in both `validate` and `deploy` jobs
- Added `source_code_hash` with `fileexists()` check and `lifecycle` block to handle missing files gracefully

### 2. S3 Bucket Already Exists
**Error**: `Error: creating S3 Bucket (pkb-frontend-personal-knowledge-base): BucketAlreadyExists`

**Root Cause**: The S3 bucket was created in a previous deployment and still exists.

**Solution**:
- Added `lifecycle` block to `aws_s3_bucket.frontend` to ignore bucket name changes
- This allows Terraform to manage existing buckets without trying to recreate them

## Changes Made

### `.github/workflows/deploy.yml`
- Added Lambda build step in `validate` job
- Added Lambda build step in `deploy` job  
- Added verification step to check Lambda packages
- Added error handling for deployment failures
- Removed `continue-on-error: true` from Terraform init/validate in deploy job

### `infrastructure/main.tf`
- Added `source_code_hash` to all three Lambda functions with conditional check
- Added `lifecycle` blocks to ignore `source_code_hash` changes

### `infrastructure/frontend.tf`
- Added `lifecycle` block to `aws_s3_bucket.frontend` to handle existing buckets

## Next Steps

1. **Monitor the GitHub Actions run** after this commit
2. **If the workflow still fails**, you may need to:
   - Import existing resources into Terraform state
   - Or manually delete conflicting resources

## Importing Existing Resources (if needed)

If you still get bucket conflicts, import the existing S3 bucket:

```bash
cd infrastructure
terraform import aws_s3_bucket.frontend pkb-frontend-personal-knowledge-base
terraform import aws_s3_bucket_versioning.frontend pkb-frontend-personal-knowledge-base
terraform import aws_s3_bucket_public_access_block.frontend pkb-frontend-personal-knowledge-base
terraform import aws_s3_bucket_website_configuration.frontend pkb-frontend-personal-knowledge-base
```

## Testing the Fix

The CI/CD pipeline should now:
1. ✅ Checkout code
2. ✅ Configure AWS credentials  
3. ✅ Setup Terraform
4. ✅ Build Lambda functions
5. ✅ Initialize Terraform
6. ✅ Format check (validate job only)
7. ✅ Validate configuration (validate job only)
8. ✅ Run Terraform plan (validate job only)
9. ✅ Apply infrastructure (deploy job only)

## Notes

- The `validate` job allows failures (`continue-on-error: true`) to not block PRs
- The `deploy` job only runs on pushes to `main` branch
- Lambda packages are now built automatically in CI/CD
- Existing S3 resources are handled gracefully

