#!/bin/bash

set -e

echo "🔍 Ensuring CloudFront distribution is enabled..."

# Get distribution ID
DIST_ID=$(aws cloudfront list-distributions \
  --query "DistributionList.Items[?Comment=='Personal Knowledge Base Frontend'].Id | [0]" \
  --output text 2>/dev/null || echo "")

if [ -z "$DIST_ID" ] || [ "$DIST_ID" = "null" ]; then
  echo "⚠️ No CloudFront distribution found"
  exit 0
fi

echo "📋 Distribution ID: $DIST_ID"

# Check if enabled
ENABLED=$(aws cloudfront get-distribution-config \
  --id "$DIST_ID" \
  --query 'DistributionConfig.Enabled' \
  --output text 2>/dev/null || echo "false")

echo "🔍 Current enabled status: $ENABLED"

if [ "$ENABLED" = "true" ]; then
  echo "✅ CloudFront is already enabled"
  exit 0
fi

echo "⚠️ CloudFront is disabled. Enabling..."

# Get current config
aws cloudfront get-distribution-config --id "$DIST_ID" > /tmp/cf-config.json
ETAG=$(jq -r '.ETag' /tmp/cf-config.json)

# Enable distribution
jq '.DistributionConfig.Enabled = true' /tmp/cf-config.json | \
  jq -r '.DistributionConfig' > /tmp/new-cf-config.json

# Update distribution
aws cloudfront update-distribution \
  --id "$DIST_ID" \
  --distribution-config file:///tmp/new-cf-config.json \
  --if-match "$ETAG" > /dev/null

echo "✅ CloudFront distribution enabled!"
echo "⏳ Waiting for deployment (may take 15-20 minutes)..."
echo "💡 The distribution will propagate to all edge locations"

