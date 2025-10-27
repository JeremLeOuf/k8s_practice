# API Gateway Cleanup for Terraform Destroy

## Overview

When running `terraform destroy`, API Gateway resources can sometimes become orphaned or fail to delete. This document explains the solutions implemented to ensure clean deletion.

## Problem

API Gateway resources have complex dependency chains:

1. **Lambda permissions** must be deleted before API Gateway
2. **API Gateway stages** must be deleted before the REST API
3. **CloudWatch log groups** created for API Gateway execution are not managed by Terraform
4. **Deletion order** matters - resources must be deleted in reverse order of creation

## Solution Implemented

### 1. Lifecycle Management in Terraform

Added lifecycle blocks to ensure proper deletion order:

```terraform
# In infrastructure/main.tf and infrastructure/budget-tracker.tf

# API Gateway REST API - create before destroy to avoid conflicts
resource "aws_api_gateway_rest_api" "api" {
  lifecycle {
    create_before_destroy = true
  }
}

# Lambda Permissions - ensure they're deleted before API Gateway
resource "aws_lambda_permission" "api_gateway_*" {
  lifecycle {
    create_before_destroy = false
  }
}
```

### 2. Enhanced Cleanup Script

Updated `scripts/cleanup-orphaned-resources.sh` to:

- Delete API Gateway CloudWatch log groups
- Delete API Gateway stages
- Delete API Gateway models
- Delete API Gateway resources in correct order
- Handle all error cases gracefully

### 3. Updated Documentation

Added comprehensive troubleshooting steps in `docs/terraform/DESTROY_TROUBLESHOOTING.md`.

## How It Works

### Deletion Order

When `terraform destroy` runs with these changes:

1. **Lambda permissions** are removed first (`create_before_destroy = false`)
2. **Lambda functions** are deleted
3. **API Gateway deployment** is deleted
4. **API Gateway stage** is deleted
5. **API Gateway resources** (methods, integrations) are deleted
6. **API Gateway REST API** is deleted last (`create_before_destroy = true`)
7. **CloudWatch log groups** are cleaned up by the script

### If Terraform Destroy Fails

If you still encounter issues, run the cleanup script first:

```bash
cd scripts
./cleanup-orphaned-resources.sh
```

This will:
- Delete disabled CloudFront distributions
- Delete orphaned IAM policies
- Delete IAM users
- Delete CloudWatch log groups (including API Gateway logs)
- Delete API Gateway resources in the correct order

Then run:

```bash
cd infrastructure
terraform destroy
```

## Manual Cleanup

If you need to manually clean up API Gateway resources:

```bash
# Get API Gateway ID
API_ID=$(aws apigateway get-rest-apis --query "items[0].id" --output text)

# Delete all stages
STAGES=$(aws apigateway get-stages --rest-api-id "$API_ID" --query 'item[*].stageName' --output text)
for STAGE in $STAGES; do
  aws apigateway delete-stage --rest-api-id "$API_ID" --stage-name "$STAGE"
done

# Delete API Gateway
aws apigateway delete-rest-api --rest-api-id "$API_ID"

# Delete CloudWatch log groups
aws logs describe-log-groups --log-group-name-prefix "/aws/apigateway" --query 'logGroups[*].logGroupName' --output text | \
  while read -r LOG_GROUP; do
    aws logs delete-log-group --log-group-name "$LOG_GROUP"
  done
```

## Prevention

The lifecycle management changes ensure that:

- Resources are always deleted in the correct order
- No orphaned resources are left behind
- CloudWatch logs are properly cleaned up
- Lambda permissions don't block API Gateway deletion

## Testing

To verify the solution works:

1. Deploy infrastructure: `terraform apply`
2. Test the API to ensure it works
3. Destroy infrastructure: `terraform destroy`
4. Verify no orphaned resources: `./scripts/check-aws-resources.sh`

You should see no API Gateway resources remaining.

## Related Files

- `infrastructure/main.tf` - Added lifecycle management to API Gateway and Lambda permissions
- `infrastructure/budget-tracker.tf` - Added lifecycle management to Lambda permissions
- `scripts/cleanup-orphaned-resources.sh` - Enhanced with API Gateway cleanup
- `docs/terraform/DESTROY_TROUBLESHOOTING.md` - Added API Gateway troubleshooting steps

## Summary

These changes ensure that API Gateway resources are properly cleaned up on `terraform destroy`, preventing orphaned resources and reducing AWS costs.

