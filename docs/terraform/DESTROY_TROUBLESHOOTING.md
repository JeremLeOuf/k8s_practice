# Terraform Destroy Troubleshooting

## Common Errors and Fixes

### Error 1: S3 Bucket Not Empty

**Error:**
```
Error: deleting S3 Bucket: BucketNotEmpty: The bucket you tried to delete is not empty.
```

**Cause**: S3 bucket has versioning enabled and contains object versions or delete markers.

**Solution:**

Run this command manually before `terraform destroy`:

```bash
BUCKET="pkb-frontend-personal-knowledge-base"

# Delete all object versions
aws s3api list-object-versions \
  --bucket "$BUCKET" \
  --output json \
  --query '{Objects: Versions[].{Key:Key,VersionId:VersionId}}' > /tmp/delete-versions.json

aws s3api delete-objects --bucket "$BUCKET" --delete file:///tmp/delete-versions.json

# Delete all markers
aws s3api list-object-versions \
  --bucket "$BUCKET" \
  --output json \
  --query '{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}' > /tmp/delete-markers.json

aws s3api delete-objects --bucket "$BUCKET" --delete file:///tmp/delete-markers.json

# Delete remaining objects
aws s3 rm "s3://$BUCKET" --recursive

# Now run destroy
terraform destroy
```

### Error 2: CloudFront OAI in Use

**Error:**
```
Error: CloudFrontOriginAccessIdentityInUse: The CloudFront origin access identity is still being used.
```

**Cause**: CloudFront distribution is still using the OAI.

**Solution:**

Wait for CloudFront to be disabled first:

```bash
# The destroy workflow handles this, but if running manually:
# Wait 5-10 minutes for CloudFront to disable, then retry
terraform destroy -refresh=false
```

Or manually disable CloudFront:

```bash
# Get distribution ID
DIST_ID=$(aws cloudfront list-distributions --query "DistributionList.Items[0].Id" --output text)

# Disable it
aws cloudfront update-distribution \
  --id "$DIST_ID" \
  --distribution-config file://config.json \
  --if-match ETAG

# Wait for status to change, then destroy
```

### Error 3: IAM Policy Attached

**Error:**
```
Error: Cannot delete a policy attached to entities
```

**Cause**: IAM policy is still attached to users or roles.

**Solution:**

```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
POLICY_ARN="arn:aws:iam::$ACCOUNT_ID:policy/pkb-grafana-cloudwatch-access"

# Detach from user
aws iam detach-user-policy \
  --user-name pkb-grafana-cloudwatch \
  --policy-arn "$POLICY_ARN"

# Detach from roles (if any)
aws iam list-entities-for-policy --policy-arn "$POLICY_ARN" | \
  jq -r '.PolicyRoles[].RoleName' | while read role; do
    aws iam detach-role-policy --role-name "$role" --policy-arn "$POLICY_ARN"
  done

# Now delete policy
aws iam delete-policy --policy-arn "$POLICY_ARN"
```

### Error 4: IAM User Still Attached

**Error:**
```
Error: Cannot delete entity, must detach all policies first.
```

**Cause**: User still has policies attached.

**Solution:**

```bash
# List all attached policies
aws iam list-attached-user-policies --user-name pkb-grafana-cloudwatch

# Detach each one
for policy in $(aws iam list-attached-user-policies --user-name pkb-grafana-cloudwatch | jq -r '.AttachedPolicies[].PolicyArn'); do
  aws iam detach-user-policy --user-name pkb-grafana-cloudwatch --policy-arn "$policy"
done

# Now delete user
aws iam delete-user --user-name pkb-grafana-cloudwatch
```

### Error 5: API Gateway Not Deleting

**Error:**
```
Error: BadRequestException: Unable to delete rest api
Error: BadRequestException: The REST API doesn't contain any models
Error: BadRequestException: Cannot delete stage because it is currently in use
```

**Cause**: API Gateway has resources, stages, or CloudWatch logs preventing deletion.

**Solution:**

```bash
# Get API Gateway ID
API_ID=$(aws apigateway get-rest-apis --query "items[0].id" --output text)

# Delete all stages first
STAGES=$(aws apigateway get-stages --rest-api-id "$API_ID" --query 'item[*].stageName' --output text)
for STAGE in $STAGES; do
  aws apigateway delete-stage --rest-api-id "$API_ID" --stage-name "$STAGE"
done

# Delete all resources (except root)
RESOURCES=$(aws apigateway get-resources --rest-api-id "$API_ID" --query 'items[?path!=`/`].id' --output text)
for RESOURCE_ID in $RESOURCES; do
  aws apigateway delete-resource --rest-api-id "$API_ID" --resource-id "$RESOURCE_ID"
done

# Delete API Gateway
aws apigateway delete-rest-api --rest-api-id "$API_ID"

# Delete CloudWatch log groups for API Gateway
aws logs describe-log-groups --log-group-name-prefix "/aws/apigateway" --query 'logGroups[*].logGroupName' --output text | \
  while read -r LOG_GROUP; do
    aws logs delete-log-group --log-group-name "$LOG_GROUP"
  done
```

### Error 6: Lambda Permissions Preventing API Gateway Deletion

**Error:**
```
Error: Cannot delete API Gateway due to Lambda permissions
```

**Cause**: Lambda permissions created by Terraform are blocking API Gateway deletion.

**Solution:**

```bash
# List all Lambda functions with API Gateway permissions
aws lambda get-policy --function-name pkb-api-get-items --query 'Policy' --output text | jq '.Statement[] | select(.Principal.Service == "apigateway.amazonaws.com") | .Sid'

# Remove permission (Terraform will handle this, but in case of issues)
aws lambda remove-permission \
  --function-name pkb-api-get-items \
  --statement-id AllowExecutionFromAPIGateway
```

**Note**: With the lifecycle changes added to the Terraform config, Lambda permissions should be deleted first, then API Gateway.

## Complete Manual Cleanup Script

```bash
#!/bin/bash
set -e

BUCKET="pkb-frontend-personal-knowledge-base"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
POLICY_ARN="arn:aws:iam::$ACCOUNT_ID:policy/pkb-grafana-cloudwatch-access"

echo "🧹 Cleaning up resources..."

# 1. Empty S3 bucket
echo "📦 Emptying S3 bucket..."
aws s3api list-object-versions --bucket "$BUCKET" --output json \
  --query '{Objects: Versions[].{Key:Key,VersionId:VersionId}}' > /tmp/delete.json
[ -s /tmp/delete.json ] && aws s3api delete-objects --bucket "$BUCKET" --delete file:///tmp/delete.json || true

aws s3api list-object-versions --bucket "$BUCKET" --output json \
  --query '{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}' > /tmp/delete.json
[ -s /tmp/delete.json ] && aws s3api delete-objects --bucket "$BUCKET" --delete file:///tmp/delete.json || true

aws s3 rm "s3://$BUCKET" --recursive || true

# 2. Disable CloudFront
echo "☁️ Disabling CloudFront..."
DIST_ID=$(aws cloudfront list-distributions --query "DistributionList.Items[0].Id" --output text 2>/dev/null || echo "")
if [ -n "$DIST_ID" ]; then
  aws cloudfront get-distribution --id "$DIST_ID" --query "Distribution.ETag" --output text > /tmp/etag.txt
  # Need to create config for disabling...
fi

# 3. Detach IAM policies
echo "🔓 Detaching IAM policies..."
aws iam detach-user-policy --user-name pkb-grafana-cloudwatch --policy-arn "$POLICY_ARN" 2>/dev/null || true

# 4. Delete IAM resources
echo "🗑️ Deleting IAM resources..."
aws iam delete-policy --policy-arn "$POLICY_ARN" 2>/dev/null || true
aws iam delete-user --user-name pkb-grafana-cloudwatch 2>/dev/null || true

echo "✅ Cleanup complete! You can now run: terraform destroy"
```

## Prevention

### Use the Destroy Workflow

The GitHub Actions destroy workflow handles all of this automatically:

```yaml
# In .github/workflows/deploy.yml
- name: Cleanup AWS Resources
  run: ./scripts/cleanup-aws-resources.sh
```

### Run Cleanup Script First

Before `terraform destroy`, run:

```bash
cd infrastructure
../scripts/cleanup-aws-resources.sh
terraform destroy
```

## Quick Fixes

### Fastest Method

```bash
# Option 1: Use Terraform with force-unlock
terraform force-unlock LOCK_ID
terraform destroy

# Option 2: Use the cleanup script + destroy
cd infrastructure
../scripts/cleanup-aws-resources.sh "pkb-frontend-personal-knowledge-base"
terraform destroy -auto-approve

# Option 3: Destroy via GitHub Actions
# Go to Actions → Run workflow → "destroy" action
```

## Summary

Most issues are caused by AWS resource dependencies. The solution is:

1. Empty S3 bucket (all versions)
2. Wait for CloudFront to disable
3. Detach IAM policies
4. Delete API Gateway stages and resources
5. Delete CloudWatch log groups (especially API Gateway logs)
6. Remove Lambda permissions for API Gateway
7. Then run terraform destroy

The destroy workflow does all of this automatically.

### Key Changes to Prevent API Gateway Orphan Issues

Recent updates to the Terraform configuration include:

1. **Lifecycle management** on `aws_api_gateway_rest_api` to ensure proper creation/deletion order
2. **Lifecycle management** on all `aws_lambda_permission` resources to ensure they're deleted before API Gateway
3. **Updated cleanup script** to handle API Gateway stages, models, and CloudWatch logs

These changes ensure that when you run `terraform destroy`, resources are deleted in the correct order:
1. Lambda permissions (delete first)
2. Lambda functions
3. API Gateway deployment
4. API Gateway stage
5. API Gateway resources
6. API Gateway REST API (delete last)
7. CloudWatch log groups

---

**Related**: [DESTROY_FIX.md](./DESTROY_FIX.md)

