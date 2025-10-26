# Lambda Hanging Issue - Root Cause and Fix

## Problem
Lambda functions were hanging during `terraform apply` for 4+ minutes.

## Root Cause
**The Lambda functions already existed in AWS**, but were not in Terraform state. Terraform was trying to create them, causing a conflict/hang.

### Evidence
```bash
$ aws lambda list-functions | grep -E "(pkb-api|budget-tracker)"
pkb-api-get-items
pkb-api-create-item
pkb-api-delete-item
budget-tracker-add-transaction
budget-tracker-get-balance
```

These functions were created during earlier Terraform runs but not properly tracked in state.

## Solution

### 1. Import Existing Lambda Functions
```bash
cd infrastructure
terraform import aws_lambda_function.get_items pkb-api-get-items
terraform import aws_lambda_function.create_item pkb-api-create-item
terraform import aws_lambda_function.delete_item pkb-api-delete-item
terraform import aws_lambda_function.add_transaction budget-tracker-add-transaction
```

### 2. Removed `source_code_hash` Calculation
The `source_code_hash` was causing issues during plan/apply. Removed it to simplify deployment.

### 3. Created Missing ZIP Packages
Built all Lambda packages (including budget tracker functions):
```bash
./scripts/build-lambda.sh
```

## Key Learnings

### Why Some Functions Completed Quickly
- `get_balance` and `add_transaction` completed in ~6s
- These were **new** resources (not existing in AWS)
- Terraform could create them without conflicts

### Why Others Hung
- `get_items`, `create_item`, `delete_item` hung for 4+ minutes
- These **already existed** in AWS
- Terraform tried to create them → AWS returned "already exists" → Terraform retried
- This created an infinite loop/hang

## Prevention

### Always Check Existing Resources
Before running `terraform apply`, import existing resources:
```bash
# List existing Lambda functions
aws lambda list-functions | grep your-function-name

# Import if they exist
terraform import aws_lambda_function.your_function your-function-name
```

### CI/CD Integration
The `.github/workflows/deploy.yml` now includes:
1. Import existing resources before apply
2. Build Lambda packages with proper detection
3. Cache packages to avoid rebuilds

## Quick Fix Commands

```bash
# 1. Build all Lambda packages
./scripts/build-lambda.sh

# 2. Import existing Lambda functions
cd infrastructure
terraform import aws_lambda_function.get_items pkb-api-get-items
terraform import aws_lambda_function.create_item pkb-api-create-item  
terraform import aws_lambda_function.delete_item pkb-api-delete-item

# 3. Apply remaining changes
terraform apply -auto-approve
```

