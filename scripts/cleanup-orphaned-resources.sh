#!/bin/bash

set -e

echo "🧹 Cleaning up orphaned AWS resources..."
echo ""
echo "⚠️  WARNING: This will delete CloudFront distributions that are disabled!"
echo "⚠️  Only run this if you're sure the infrastructure has been destroyed via Terraform."
echo ""
read -p "Are you sure you want to proceed? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
  echo "❌ Cleanup cancelled"
  exit 0
fi

echo ""
echo "=== CLEANING UP CLOUDFRONT DISTRIBUTIONS ==="
DISTRIBUTIONS=$(aws cloudfront list-distributions --query 'DistributionList.Items[?Enabled==`false`].Id' --output text)

if [ -z "$DISTRIBUTIONS" ] || [ "$DISTRIBUTIONS" = "None" ]; then
  echo "✅ No disabled CloudFront distributions to clean up"
else
  for DIST_ID in $DISTRIBUTIONS; do
    echo "🗑️  Deleting disabled distribution: $DIST_ID"
    ETAG=$(aws cloudfront get-distribution-config --id "$DIST_ID" --query 'ETag' --output text)
    aws cloudfront delete-distribution --id "$DIST_ID" --if-match "$ETAG" 2>/dev/null || echo "⚠️  Already deleted or cannot delete"
  done
fi

echo ""
echo "=== CLEANING UP IAM POLICIES ==="
POLICIES=$(aws iam list-policies --scope Local --query 'Policies[?contains(PolicyName, `pkb`) || contains(PolicyName, `grafana`)].Arn' --output text 2>/dev/null || echo "")

if [ -n "$POLICIES" ]; then
  for POLICY_ARN in $POLICIES; do
    POLICY_NAME=$(aws iam get-policy --policy-arn "$POLICY_ARN" --query 'Policy.PolicyName' --output text)
    echo "🔍 Checking policy: $POLICY_NAME"
    
    # Check if policy is attached
    ATTACHMENTS=$(aws iam list-entities-for-policy --policy-arn "$POLICY_ARN" --output json 2>/dev/null)
    HAS_ATTACHMENTS=$(echo "$ATTACHMENTS" | jq -e '.PolicyRoles | length > 0 or .PolicyUsers | length > 0 or .PolicyGroups | length > 0' 2>/dev/null || echo "false")
    
    if [ "$HAS_ATTACHMENTS" = "false" ]; then
      echo "🗑️  Deleting unattached policy: $POLICY_NAME"
      aws iam delete-policy --policy-arn "$POLICY_ARN" 2>/dev/null || echo "⚠️  Cannot delete policy"
    else
      echo "⚠️  Policy is attached, skipping: $POLICY_NAME"
    fi
  done
else
  echo "✅ No IAM policies to clean up"
fi

echo ""
echo "=== CLEANING UP IAM USERS ==="
USERS=$(aws iam list-users --query 'Users[?contains(UserName, `pkb`) || contains(UserName, `grafana`)].UserName' --output text 2>/dev/null || echo "")

if [ -n "$USERS" ]; then
  for USER in $USERS; do
    echo "🔍 Checking user: $USER"
    
    # Check for access keys
    KEYS=$(aws iam list-access-keys --user-name "$USER" --query 'AccessKeyMetadata[].AccessKeyId' --output text 2>/dev/null || echo "")
    if [ -n "$KEYS" ]; then
      for KEY_ID in $KEYS; do
        echo "🗑️  Deleting access key: $KEY_ID"
        aws iam delete-access-key --user-name "$USER" --access-key-id "$KEY_ID" 2>/dev/null || true
      done
    fi
    
    # Check for policies
    POLICIES=$(aws iam list-user-policies --user-name "$USER" --query 'PolicyNames[]' --output text 2>/dev/null || echo "")
    if [ -n "$POLICIES" ]; then
      for POLICY in $POLICIES; do
        echo "🗑️  Detaching policy: $POLICY"
        aws iam detach-user-policy --user-name "$USER" --policy-arn "arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/$POLICY" 2>/dev/null || true
      done
    fi
    
    # Delete user
    echo "🗑️  Deleting user: $USER"
    aws iam delete-user --user-name "$USER" 2>/dev/null || echo "⚠️  Cannot delete user (may have policies attached)"
  done
else
  echo "✅ No IAM users to clean up"
fi

echo ""
echo "=== CLEANING UP CLOUDWATCH LOG GROUPS ==="
LOG_GROUPS=$(aws logs describe-log-groups --query 'logGroups[?contains(logGroupName, `/aws/lambda/pkb`) || contains(logGroupName, `/aws/lambda/budget`) || contains(logGroupName, `/aws/apigateway`)].logGroupName' --output text 2>/dev/null || echo "")

if [ -n "$LOG_GROUPS" ]; then
  for LOG_GROUP in $LOG_GROUPS; do
    echo "🗑️  Deleting log group: $LOG_GROUP"
    aws logs delete-log-group --log-group-name "$LOG_GROUP" 2>/dev/null || echo "⚠️  Cannot delete log group"
  done
else
  echo "✅ No CloudWatch log groups to clean up"
fi

echo ""
echo "=== CLEANING UP API GATEWAY ==="
APIS=$(aws apigateway get-rest-apis --query 'items[*].[name,id]' --output text 2>/dev/null || echo "")

if [ -n "$APIS" ] && [ "$APIS" != "None" ]; then
  echo "$APIS" | while read -r NAME ID; do
    echo "🔍 Found API Gateway: $NAME ($ID)"
    
    # Delete all stages first
    echo "🗑️  Deleting stages..."
    STAGES=$(aws apigateway get-stages --rest-api-id "$ID" --query 'item[*].stageName' --output text 2>/dev/null || echo "")
    for STAGE in $STAGES; do
      echo "  Deleting stage: $STAGE"
      aws apigateway delete-stage --rest-api-id "$ID" --stage-name "$STAGE" 2>/dev/null || true
    done
    
    # Delete all models
    echo "🗑️  Deleting models..."
    aws apigateway get-models --rest-api-id "$ID" --query 'items[*].name' --output text 2>/dev/null | \
      while read -r MODEL; do
        aws apigateway delete-model --rest-api-id "$ID" --model-name "$MODEL" 2>/dev/null || true
      done
    
    # Finally delete the API Gateway
    echo "🗑️  Deleting API Gateway: $ID"
    aws apigateway delete-rest-api --rest-api-id "$ID" 2>/dev/null || echo "⚠️  Cannot delete API Gateway (may need to delete resources first)"
  done
else
  echo "✅ No API Gateway APIs to clean up"
fi

echo ""
echo "✅ Cleanup process completed!"
echo ""
echo "💡 You can now run terraform destroy if needed, or terraform apply to recreate infrastructure."
echo "💡 Remaining resources should be managed by Terraform."

