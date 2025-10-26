#!/bin/bash

set -e

echo "🔍 Checking for CloudFront distributions..."

# Find all CloudFront distributions with our tag
DISTRIBUTIONS=$(aws cloudfront list-distributions \
  --query "DistributionList.Items[?Comment=='Personal Knowledge Base Frontend'].Id" \
  --output text 2>/dev/null || echo "")

if [ -z "$DISTRIBUTIONS" ] || [ "$DISTRIBUTIONS" = "None" ]; then
  echo "✅ No CloudFront distributions found - Terraform will create new one"
  exit 0
fi

echo "📋 Found existing CloudFront distributions: $DISTRIBUTIONS"

# Process each distribution
for DIST_ID in $DISTRIBUTIONS; do
  echo ""
  echo "🔍 Checking distribution: $DIST_ID"
  
  # Get distribution status
  STATUS=$(aws cloudfront get-distribution \
    --id "$DIST_ID" \
    --query 'Distribution.Status' \
    --output text 2>/dev/null || echo "DELETED")
  
  echo "📊 Status: $STATUS"
  
  if [ "$STATUS" = "Deployed" ] || [ "$STATUS" = "InProgress" ]; then
    echo "✅ Distribution is active - keeping it!"
    echo "💡 Terraform will update this distribution instead of creating new one"
    continue
  fi
  
  if [ "$STATUS" = "Disabled" ]; then
    echo "⚠️ Distribution is disabled"
    echo "🔄 Removing disabled distribution (must be deleted before recreating)..."
    
    # Get current config
    aws cloudfront get-distribution-config --id "$DIST_ID" > /tmp/dist-config.json
    
    # Extract ETag and Config
    ETAG=$(jq -r '.ETag' /tmp/dist-config.json)
    CONFIG=$(jq -r '.DistributionConfig' /tmp/dist-config.json)
    
    # Disable the distribution
    echo "$CONFIG" | jq '.Enabled = false' > /tmp/new-config.json
    
    echo "⏳ Disabling distribution (this may take a moment)..."
    aws cloudfront update-distribution \
      --id "$DIST_ID" \
      --distribution-config "file:///tmp/new-config.json" \
      --if-match "$ETAG" > /dev/null 2>&1 || echo "⚠️ Failed to disable (may already be disabled)"
    
    # Wait for disabling to complete (max 5 minutes)
    echo "⏳ Waiting for distribution to be disabled..."
    TIMEOUT=300
    ELAPSED=0
    while [ $ELAPSED -lt $TIMEOUT ]; do
      STATUS=$(aws cloudfront get-distribution \
        --id "$DIST_ID" \
        --query 'Distribution.Status' \
        --output text 2>/dev/null || echo "DELETED")
      
      if [ "$STATUS" = "Deployed" ]; then
        echo "✅ Distribution disabled"
        break
      fi
      
      sleep 5
      ELAPSED=$((ELAPSED + 5))
      echo "⏱️ Still waiting... ($ELAPSED / $TIMEOUT seconds)"
    done
    
    # Delete the distribution
    echo "🗑️ Deleting distribution..."
    aws cloudfront delete-distribution \
      --id "$DIST_ID" \
      --if-match "$(aws cloudfront get-distribution-config --id "$DIST_ID" --query ETag --output text)" \
      > /dev/null 2>&1 || echo "⚠️ Failed to delete (may have already been deleted)"
    
    echo "✅ Distribution $DIST_ID scheduled for deletion"
  fi
done

echo ""
echo "✅ Cleanup complete!"
echo "💡 Active CloudFront distributions are preserved"
echo "💡 Only disabled distributions are removed"

