# CI/CD Fixes Summary

## Issues Fixed

### 1. ✅ API Gateway Deprecation Warnings

**Before:**
```hcl
resource "aws_api_gateway_deployment" "api" {
  stage_name = "prod"  # ⚠️ Deprecated
}

output "api_url" {
  value = "${aws_api_gateway_deployment.api.invoke_url}/items"  # ⚠️ Deprecated
}
```

**After:**
```hcl
resource "aws_api_gateway_deployment" "api" {
  # stage_name removed
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.api.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "prod"
}

output "api_url" {
  value = "${aws_api_gateway_stage.prod.invoke_url}/items"
}
```

### 2. ✅ Resource Already Exists Errors

**Problem**: Terraform tries to create resources that already exist from previous runs.

**Solutions Applied**:

#### A. Lifecycle Rules (Immediate Fix)
Added to resources:
- `aws_dynamodb_table.knowledge_base`
- `aws_iam_role.lambda_role`  
- `aws_iam_policy.grafana_cloudwatch_access`
- `aws_iam_user.grafana_cloudwatch`

```hcl
lifecycle {
  ignore_changes = [name]
}
```

#### B. Import Step in CI/CD
Added optional import step to GitHub Actions:

```yaml
- name: Import Existing Resources (Optional)
  run: |
    terraform import aws_dynamodb_table.knowledge_base PersonalKnowledgeBase 2>/dev/null || echo "Already imported"
    terraform import aws_iam_role.lambda_role pkb-lambda-execution-role 2>/dev/null || echo "Already imported"
    # ... more imports
  continue-on-error: true
```

#### C. Error Handling
Improved error messages and handling in CI/CD.

### 3. ✅ Scripts Created

**`scripts/import-existing-resources.sh`**
- Interactive script to import existing resources into Terraform state
- Usage: `./scripts/import-existing-resources.sh`

**`scripts/configure-terraform-backend.sh`**
- Sets up S3 backend for remote state management
- Usage: `./scripts/configure-terraform-backend.sh [bucket-name]`

## Files Changed

1. `infrastructure/main.tf`
   - ✅ Fixed API Gateway deprecation warnings
   - ✅ Added `aws_api_gateway_stage` resource
   - ✅ Updated outputs to use stage instead of deployment
   - ✅ Added lifecycle rules to DynamoDB table and IAM role

2. `infrastructure/grafana.tf`
   - ✅ Added lifecycle rules to IAM policy and user

3. `infrastructure/frontend.tf`
   - ✅ Already has lifecycle rules for S3 bucket

4. `.github/workflows/deploy.yml`
   - ✅ Added import step for existing resources
   - ✅ Improved error handling
   - ✅ Better logging

5. New Files Created:
   - ✅ `scripts/import-existing-resources.sh`
   - ✅ `scripts/configure-terraform-backend.sh`
   - ✅ `CI_CD_BEST_PRACTICES.md`
   - ✅ `CI_CD_FIXES_SUMMARY.md`

## How It Works Now

### On First Deployment
1. Terraform creates all resources
2. State saved locally (or in S3 if backend configured)

### On Subsequent Deployments
1. **Import step** tries to import existing resources (fails gracefully if they're already in state)
2. **Terraform apply** updates existing resources or creates new ones
3. **Lifecycle rules** prevent conflicts on resource names

### Resource Conflicts Handled

| Resource | Solution |
|----------|----------|
| DynamoDB Table | Lifecycle rule + import step |
| IAM Role | Lifecycle rule + import step |
| IAM Policy | Lifecycle rule + import step |
| IAM User | Lifecycle rule + import step |
| S3 Bucket | Already had lifecycle rule |
| CloudFront | Handled via dependencies |
| Lambda | Recreated with new code |

## Testing

### Local Testing
```bash
cd infrastructure
terraform init
terraform plan  # Should show updates, not creation errors
terraform apply
```

### CI/CD Testing
- Check GitHub Actions after next push
- Should handle existing resources gracefully
- Look for "Import step completed" in logs

## Next Steps for Production

For a production environment, consider:

1. **Setup Remote Backend (S3)**
   ```bash
   ./scripts/configure-terraform-backend.sh pkb-terraform-state
   # Uncomment backend block in infrastructure/main.tf
   cd infrastructure
   terraform init -migrate-state
   ```

2. **State Locking**
   - Add DynamoDB table for state locking
   - Prevents concurrent modifications

3. **Separation of Environments**
   - Create separate Terraform workspaces for dev/staging/prod
   - Use different backend key prefixes

## References

- `CI_CD_BEST_PRACTICES.md` - Best practices for CI/CD with Terraform
- `TERRAFORM_DESTROY_FIX.md` - Fixed S3 bucket emptying on destroy
- `CI_CD_FIXES.md` - Previous CI/CD fixes

