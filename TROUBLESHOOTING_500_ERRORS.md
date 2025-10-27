# Troubleshooting 500 Errors on Knowledge Base API

## Issue
Getting 500 errors when accessing the Knowledge Base API through CloudFront:
- `GET https://d7d0cbcnrfsn.cloudfront.net/items` → 500
- `POST https://d7d0cbcnrfsn.cloudfront.net/items` → 500

## Root Cause Analysis

The issue is likely one or more of the following:

1. **CloudFront → API Gateway Path Routing**: CloudFront is configured as a custom origin for API Gateway, but the path routing might not be working correctly
2. **Lambda Event Structure**: When CloudFront proxies to API Gateway, the event structure might be different
3. **Caching Issues**: CloudFront might be caching error responses
4. **Lambda Function Errors**: The Lambda functions might be encountering runtime errors

## Fixes Applied

### 1. Enhanced Lambda Error Logging ✅
Updated all Lambda functions (`get-items`, `create-item`, `delete-item`) to:
- Add debug logging of event structure
- Add detailed error messages with stack traces
- Return error details in API responses for debugging

### 2. Updated Lambda Function Code ✅
- Rebuilt Lambda packages with enhanced error handling
- Deployed updated functions directly via AWS CLI
- Invalidated CloudFront cache

## Diagnostic Steps

### Check CloudWatch Logs
```bash
# Check Lambda logs for errors
aws logs tail /aws/lambda/pkb-api-get-items --since 30m --region us-east-1

# Check specific errors
aws logs filter-log-events \
  --log-group-name /aws/lambda/pkb-api-get-items \
  --filter-pattern "ERROR" \
  --max-items 10
```

### Test API Gateway Directly
```bash
# Get the API Gateway URL
cd infrastructure
API_URL=$(terraform output -raw api_gateway_url)

# Test direct (bypassing CloudFront)
curl $API_URL/items

# Check response
curl -v $API_URL/items
```

### Test Through CloudFront
After CloudFront cache invalidation completes:
```bash
# Wait for invalidation (check status)
aws cloudfront get-invalidation \
  --distribution-id E1M545EB9NN09U \
  --id I7E1S5XGP0YQPC9WV0ZJ3FIPSI

# Test through CloudFront
curl -v https://d7d0cbcnrfsn.cloudfront.net/items
```

## Potential Issues & Solutions

### Issue 1: CloudFront Cache Not Clearing
**Symptoms**: Still getting 500 errors after Lambda updates

**Solution**:
```bash
# Force invalidation again
aws cloudfront create-invalidation \
  --distribution-id E1M545EB9RN09U \
  --paths "/*" "/items*"
```

### Issue 2: API Gateway Deployment Not Updated
**Symptoms**: Changes to Lambda don't reflect in API

**Solution**:
```bash
cd infrastructure
terraform apply -auto-approve -refresh=false
```

This will trigger a new API Gateway deployment.

### Issue 3: Path Parameter Issues
**Symptoms**: DELETE requests failing, path parameters missing

**Solution**: Check that CloudFront is forwarding the correct headers. The configured headers should include:
- `Content-Type`
- `Accept`
- All request headers for API Gateway integration

### Issue 4: Lambda Permissions
**Symptoms**: Lambda can't access DynamoDB

**Check**:
```bash
# Verify Lambda role has DynamoDB permissions
aws iam get-role-policy \
  --role-name pkb-lambda-execution-role \
  --policy-name lambda-dynamodb-policy
```

## Current Configuration

- **CloudFront Distribution**: `E1M545EB9NN09U`
- **API Gateway**: REST API (`pkb-api`)
- **Lambda Functions**: 
  - `pkb-api-get-items`
  - `pkb-api-create-item`
  - `pkb-api-delete-item`
- **DynamoDB Table**: `PersonalKnowledgeBase`

## Testing the Fix

1. Wait 2-3 minutes for CloudFront invalidation to complete
2. Test the API:
   ```bash
   curl https://d7d0cbcnrfsn.cloudfront.net/items
   ```
3. Check for detailed error messages in the response
4. View CloudWatch logs for full stack traces

## Next Steps

If errors persist after 5 minutes:

1. Check CloudWatch logs for detailed error messages
2. Test API Gateway directly (bypassing CloudFront)
3. Verify DynamoDB table exists and is accessible
4. Check IAM permissions for Lambda → DynamoDB
5. Review the detailed error logs added to Lambda functions

## Monitoring

To monitor Lambda function performance:
```bash
# Watch logs in real-time
aws logs tail /aws/lambda/pkb-api-get-items --follow --region us-east-1

# Check metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Errors \
  --dimensions Name=FunctionName,Value=pkb-api-get-items \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Sum
```

## Expected Behavior After Fix

✅ GET /items returns 200 with list of items  
✅ POST /items returns 201 with created item  
✅ DELETE /items/{id} returns 200 with deleted item  
✅ All operations return detailed error messages if they fail

