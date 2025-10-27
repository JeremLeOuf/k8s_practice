#!/bin/bash

set -e

echo "🧹 Cleaning up AWS resources for destroy..."

BUCKET="${1:-pkb-frontend-personal-knowledge-base}"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "📦 Emptying S3 bucket: $BUCKET"

# Check if bucket exists
if aws s3api head-bucket --bucket "$BUCKET" 2>/dev/null; then
  echo "Found bucket $BUCKET, emptying..."
  
  # Delete all object versions
  echo "Deleting all object versions and delete markers..."
  aws s3api list-object-versions --bucket "$BUCKET" --output json > /tmp/versions.json 2>/dev/null || echo '{"Versions":[],"DeleteMarkers":[]}' > /tmp/versions.json
  
  # Delete all versions
  VERSIONS=$(cat /tmp/versions.json | jq -c '{Objects: [.Versions[]? | {Key, VersionId}]}' 2>/dev/null)
  if [ "$VERSIONS" != '{"Objects":[]}' ] && [ -n "$VERSIONS" ]; then
    echo "$VERSIONS" | jq -e '.Objects | length > 0' > /dev/null 2>&1 && {
      echo "$VERSIONS" > /tmp/delete-versions.json
      aws s3api delete-objects --bucket "$BUCKET" --delete file:///tmp/delete-versions.json 2>/dev/null || true
    }
  fi
  
  # Delete all delete markers
  MARKERS=$(cat /tmp/versions.json | jq -c '{Objects: [.DeleteMarkers[]? | {Key, VersionId}]}' 2>/dev/null)
  if [ "$MARKERS" != '{"Objects":[]}' ] && [ -n "$MARKERS" ]; then
    echo "$MARKERS" | jq -e '.Objects | length > 0' > /dev/null 2>&1 && {
      echo "$MARKERS" > /tmp/delete-markers.json
      aws s3api delete-objects --bucket "$BUCKET" --delete file:///tmp/delete-markers.json 2>/dev/null || true
    }
  fi
  
  # Delete remaining objects (non-versioned)
  aws s3 rm "s3://$BUCKET" --recursive 2>/dev/null || true
  
  echo "✅ S3 bucket emptied"
else
  echo "⚠️  Bucket $BUCKET not found or already deleted"
fi

echo ""
echo "🔓 Cleaning up IAM resources..."

# Clean up IAM User
USER_NAME="pkb-grafana-cloudwatch"
if aws iam get-user --user-name "$USER_NAME" 2>/dev/null | grep -q "$USER_NAME"; then
  echo "Found IAM user: $USER_NAME"
  
  # Delete access keys
  echo "Deleting access keys..."
  aws iam list-access-keys --user-name "$USER_NAME" --query 'AccessKeyMetadata[].AccessKeyId' --output text 2>/dev/null | \
    while read -r key_id; do
      if [ -n "$key_id" ]; then
        echo "  Deleting access key: $key_id"
        aws iam delete-access-key --user-name "$USER_NAME" --access-key-id "$key_id" 2>/dev/null || true
      fi
    done
  
  # Detach all policies from user
  echo "Detaching policies from user..."
  aws iam list-attached-user-policies --user-name "$USER_NAME" --query 'AttachedPolicies[].PolicyArn' --output text 2>/dev/null | \
    while read -r policy_arn; do
      if [ -n "$policy_arn" ]; then
        echo "  Detaching policy: $policy_arn"
        aws iam detach-user-policy --user-name "$USER_NAME" --policy-arn "$policy_arn" 2>/dev/null || true
      fi
    done
  
  # Detach inline policies
  aws iam list-user-policies --user-name "$USER_NAME" --query 'PolicyNames[]' --output text 2>/dev/null | \
    while read -r policy_name; do
      if [ -n "$policy_name" ]; then
        echo "  Deleting inline policy: $policy_name"
        aws iam delete-user-policy --user-name "$USER_NAME" --policy-name "$policy_name" 2>/dev/null || true
      fi
    done
  
  echo "✅ IAM user cleaned up"
else
  echo "⚠️  IAM user $USER_NAME not found"
fi

# Clean up IAM Policy
POLICY_ARN="arn:aws:iam::$ACCOUNT_ID:policy/pkb-grafana-cloudwatch-access"
echo "Checking policy: $POLICY_ARN"

# Get all entities attached to the policy
if aws iam list-entities-for-policy --policy-arn "$POLICY_ARN" 2>/dev/null | jq -e '. | .PolicyUsers + .PolicyRoles + .PolicyGroups | map(select(. != null)) | flatten | length > 0' > /dev/null 2>&1; then
  echo "Policy is attached, detaching from entities..."
  
  # Detach from users
  aws iam list-entities-for-policy --policy-arn "$POLICY_ARN" --query 'PolicyUsers[].UserName' --output text 2>/dev/null | \
    while read -r user; do
      if [ -n "$user" ]; then
        echo "  Detaching from user: $user"
        aws iam detach-user-policy --user-name "$user" --policy-arn "$POLICY_ARN" 2>/dev/null || true
      fi
    done
  
  # Detach from roles
  aws iam list-entities-for-policy --policy-arn "$POLICY_ARN" --query 'PolicyRoles[].RoleName' --output text 2>/dev/null | \
    while read -r role; do
      if [ -n "$role" ]; then
        echo "  Detaching from role: $role"
        aws iam detach-role-policy --role-name "$role" --policy-arn "$POLICY_ARN" 2>/dev/null || true
      fi
    done
  
  # Detach from groups
  aws iam list-entities-for-policy --policy-arn "$POLICY_ARN" --query 'PolicyGroups[].GroupName' --output text 2>/dev/null | \
    while read -r group; do
      if [ -n "$group" ]; then
        echo "  Detaching from group: $group"
        aws iam detach-group-policy --group-name "$group" --policy-arn "$POLICY_ARN" 2>/dev/null || true
      fi
    done
  
  echo "✅ Policy detached from all entities"
else
  echo "⚠️  Policy not attached or not found"
fi

echo ""
echo "✅ Cleanup completed"

