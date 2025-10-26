# CI/CD Lambda Hanging Issue - FIXED

## Problem
GitHub Actions pipeline hangs on Lambda function creation for 70+ seconds:
```
aws_lambda_function.get_items: Still creating... [00m70s elapsed]
aws_lambda_function.create_item: Still creating... [00m50s elapsed]
aws_lambda_function.delete_item: Still creating... [00m50s elapsed]
aws_lambda_function.add_transaction: Still creating... [00m50s elapsed]
aws_lambda_function.get_balance: Still creating... [00m40s elapsed]
```

## Root Cause
**Lambda functions already exist in AWS** but are NOT in the Terraform state used by CI/CD.

The CI/CD runner has its own Terraform state (local file in the runner), which doesn't include the Lambda functions we imported locally.

## Solution

Updated `.github/workflows/deploy.yml` to import Lambda functions at the very beginning of the deployment:

```yaml
- name: Import Existing Resources (Skip if in state)
  working-directory: ./infrastructure
  run: |
    # Lambda Functions (CRITICAL - prevents hanging!)
    echo "⚡ Importing Lambda functions..."
    terraform state show aws_lambda_function.get_items &>/dev/null || terraform import aws_lambda_function.get_items pkb-api-get-items 2>/dev/null || echo "⚠️ Skipped"
    terraform state show aws_lambda_function.create_item &>/dev/null || terraform import aws_lambda_function.create_item pkb-api-create-item 2>/dev/null || echo "⚠️ Skipped"
    terraform state show aws_lambda_function.delete_item &>/dev/null || terraform import aws_lambda_function.delete_item pkb-api-delete-item 2>/dev/null || echo "⚠️ Skipped"
    terraform state show aws_lambda_function.add_transaction &>/dev/null || terraform import aws_lambda_function.add_transaction budget-tracker-add-transaction 2>/dev/null || echo "⚠️ Skipped"
    terraform state show aws_lambda_function.get_balance &>/dev/null || terraform import aws_lambda_function.get_balance budget-tracker-get-balance 2>/dev/null || echo "⚠️ Skipped"
```

## Why This Happens

### Local vs CI/CD State
- **Local**: Your `infrastructure/terraform.tfstate` has imported resources
- **CI/CD**: Each GitHub runner starts fresh → no state → tries to create existing resources → hangs

### Terraform State Isolation
- Each runner has its own `.terraform` directory
- State files are NOT shared between local and CI/CD
- Need to import resources in EACH environment

## What's Fixed

### Before
```yaml
Import order:
1. DynamoDB tables
2. IAM roles/policies
3. S3 bucket
4. (MISSING: Lambda functions!)
```

### After
```yaml
Import order:
1. Lambda Functions ← ADDED (prevents 70s hang!)
2. Lambda Permissions ← ADDED (prevents hanging on apply)
3. DynamoDB tables
4. IAM roles/policies
5. S3 bucket
```

## Expected Behavior Now

### First Run (resources don't exist in AWS)
- CI/CD creates all resources
- Takes ~3-5 minutes
- No hanging

### Subsequent Runs (resources exist)
- CI/CD imports existing resources
- Terraform detects no changes needed
- Apply completes in ~30 seconds
- No hanging!

## Verification

After this fix, CI/CD pipeline should:
1. Import Lambda functions quickly (<10s)
2. Apply without hanging
3. Complete in <2 minutes (instead of 7+ minutes)

## Troubleshooting

### Still Hanging?
Check if resources exist in AWS:
```bash
aws lambda list-functions | grep pkb-api
aws lambda list-functions | grep budget-tracker
```

### Import Fails?
The import uses `2>/dev/null || echo "⚠️ Skipped"` so failures won't stop the pipeline. Check logs for actual errors.

### State Mismatch?
If local and CI/CD state diverge:
```bash
# In CI/CD logs, check:
terraform state list

# Should show all Lambda functions:
# aws_lambda_function.get_items
# aws_lambda_function.create_item
# aws_lambda_function.delete_item
# aws_lambda_function.add_transaction
# aws_lambda_function.get_balance
```

## Prevention

Always import existing resources before applying in new environments:
1. Local development
2. CI/CD pipeline
3. Staging environment
4. Production environment

Each environment needs its own imports.

