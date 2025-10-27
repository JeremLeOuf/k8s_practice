# 500 Error Resolution Status

## What Was Fixed ✅

1. **CloudFront Updated** - Now pointing to correct API Gateway (`cryptjyoc1`)
2. **Lambda Permissions** - Updated to allow API Gateway `cryptjyoc1` to invoke Lambda
3. **API Gateway Deployment** - Created and deployed
4. **Wrong Resources Removed** - Deleted `/transactions` and `/balance` from PKB API
5. **KMS Permissions Added** - Added `kms:Decrypt` to Lambda IAM role

## Remaining Issue ❌

**Root Cause**: Lambda cannot decrypt environment variables

The Lambda functions are failing with:
```
KMSAccessDeniedException: User: arn:aws:sts::178457246282:assumed-role/pkb-lambda-execution-role/pkb-api-get-items 
is not authorized to perform: kms:Decrypt on resource: arn:aws:kms:us-east-1:178457246282:key/6150eeb4-6676-4e9f-b47a-ff5cb16ad053
```

## Solution Options

### Option 1: Contact AWS Support (Recommended)
The KMS key policy allows Lambda service access but something is blocking it. This may require AWS Support to investigate account-level settings.

### Option 2: Disable Encryption (Quick Fix)
Remove encryption from Lambda environment variables:
```bash
# No encryption on environment variables
aws lambda update-function-configuration \
  --function-name pkb-api-get-items \
  --environment Variables={TABLE_NAME=PersonalKnowledgeBase} \
  --kms-key-arn "" \
  --region us-east-1
```

### Option 3: Use AWS Managed Keys
Update Lambda to use an AWS managed key instead of customer-managed keys.

## Current Status

- ✅ CloudFront points to correct API (`cryptjyoc1`)
- ✅ Lambda integration configured
- ✅ Lambda permissions set
- ❌ Lambda execution blocked by KMS policy

## Test URLs

CloudFront URL (still returning 500):
- https://d7d0cbcnrfsn.cloudfront.net/items

Direct API Gateway (also 500):
- https://cryptjyoc1.execute-api.us-east-1.amazonaws.com/prod/items

## Next Steps

1. **Disable KMS encryption on Lambda environment variables** (Quickest)
2. **Wait for IAM changes to propagate** (May take several minutes)
3. **Contact AWS Support** if issue persists

