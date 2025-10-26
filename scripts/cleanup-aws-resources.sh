#!/bin/bash

set -e

echo "🧹 Cleaning up AWS resources for destroy..."

BUCKET="${1:-pkb-frontend-personal-knowledge-base}"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "📦 Emptying S3 bucket: $BUCKET"

# Empty S3 bucket with all versions
aws s3api delete-bucket --bucket "$BUCKET" --force 2>/dev/null || {
  # If that fails, manually delete all objects and versions
  echo "Deleting all object versions..."
  
  # Get all versions
  aws s3api list-object-versions --bucket "$BUCKET" --output json > /tmp/versions.json || echo '{"Versions":[],"DeleteMarkers":[]}' > /tmp/versions.json
  
  # Delete versions in batches (max 1000)
  cat /tmp/versions.json | jq -c 'reduce .Versions as $v ([]; . + [$v | {Key,VersionId}])' > /tmp/versions-to-delete.json
  cat /tmp/versions.json | jq -c 'reduce .DeleteMarkers as $d ([]; . + [$d | {Key,VersionId}])' >> /tmp/versions-to-delete.json
  
  # Delete in batches
  while read -r batch; do
    if [ -n "$batch" ]; then
      echo "$batch" | jq -s '{Objects: .}' | aws s3api delete-objects --bucket "$BUCKET" --delete file:///dev/stdin 2>/dev/null || true
    fi
  done < <(cat /tmp/versions-to-delete.json | jq -c '.')
  
  # Delete remaining objects
  aws s3 rm "s3://$BUCKET" --recursive || true
}

echo "🔓 Detaching IAM policies..."

# Detach policy from user
aws iam list-attached-user-policies --user-name pkb-grafana-cloudwatch 2>/dev/null | \
  jq -r '.AttachedPolicies[].PolicyArn' | while read -r policy_arn; do
    echo "Detaching policy: $policy_arn"
    aws iam detach-user-policy --user-name pkb-grafana-cloudwatch --policy-arn "$policy_arn" 2>/dev/null || true
  done

# Get all entities attached to the policy
POLICY_ARN="arn:aws:iam::$ACCOUNT_ID:policy/pkb-grafana-cloudwatch-access"
aws iam list-entities-for-policy --policy-arn "$POLICY_ARN" 2>/dev/null | \
  jq -r '.PolicyUsers[].UserName' | while read -r user; do
    echo "Detaching from user: $user"
    aws iam detach-user-policy --user-name "$user" --policy-arn "$POLICY_ARN" 2>/dev/null || true
  done

aws iam list-entities-for-policy --policy-arn "$POLICY_ARN" 2>/dev/null | \
  jq -r '.PolicyRoles[].RoleName' | while read -r role; do
    echo "Detaching from role: $role"
    aws iam detach-role-policy --role-name "$role" --policy-arn "$POLICY_ARN" 2>/dev/null || true
  done

echo "✅ Cleanup completed"

