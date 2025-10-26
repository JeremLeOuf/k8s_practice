#!/bin/bash

set -e

BUCKET="${1:-pkb-frontend-personal-knowledge-base}"

echo "🗑️ Emptying S3 bucket: $BUCKET"

# Check if bucket exists
if ! aws s3 ls "s3://$BUCKET" 2>/dev/null; then
  echo "Bucket not found, skipping"
  exit 0
fi

echo "📦 Getting all object versions..."

# List all object versions and create deletion request
aws s3api list-object-versions --bucket "$BUCKET" > /tmp/versions.json 2>/dev/null || echo '{"Versions":[],"DeleteMarkers":[]}' > /tmp/versions.json

# Delete object versions
VERSIONS=$(jq -c '{Objects: [.Versions[]? | {Key,VersionId}] | select(length > 0)}' /tmp/versions.json)
if [ "$VERSIONS" != "{\"Objects\":[]}" ] && [ -n "$VERSIONS" ]; then
  echo "Deleting object versions..."
  echo "$VERSIONS" > /tmp/delete-versions.json
  aws s3api delete-objects --bucket "$BUCKET" --delete file:///tmp/delete-versions.json || echo "Failed to delete some versions"
fi

# Delete delete markers
MARKERS=$(jq -c '{Objects: [.DeleteMarkers[]? | {Key,VersionId}] | select(length > 0)}' /tmp/versions.json)
if [ "$MARKERS" != "{\"Objects\":[]}" ] && [ -n "$MARKERS" ]; then
  echo "Deleting delete markers..."
  echo "$MARKERS" > /tmp/delete-markers.json
  aws s3api delete-objects --bucket "$BUCKET" --delete file:///tmp/delete-markers.json || echo "Failed to delete some markers"
fi

# Delete remaining objects
echo "Deleting remaining objects..."
aws s3 rm "s3://$BUCKET" --recursive || echo "No objects to delete"

echo "✅ Bucket emptied successfully"

