#!/bin/bash

set -e

echo "🚀 Deploying frontend to S3 and CloudFront..."

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get the script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Get the bucket name from Terraform output
echo -e "${BLUE}📦 Getting S3 bucket name from Terraform...${NC}"
cd "$PROJECT_ROOT/infrastructure"

BUCKET_NAME=$(terraform output -raw frontend_bucket_name)
if [ -z "$BUCKET_NAME" ]; then
    echo "Error: Could not get bucket name from Terraform. Make sure frontend.tf is applied."
    exit 1
fi

cd "$PROJECT_ROOT"

echo -e "${BLUE}📤 Uploading frontend files to S3...${NC}"
aws s3 sync frontend/ s3://${BUCKET_NAME}/ --delete

echo -e "${GREEN}✅ Frontend deployed successfully!${NC}"
echo ""
echo -e "${BLUE}📊 CloudFront URL:${NC}"
cd "$PROJECT_ROOT/infrastructure"
terraform output -raw frontend_url
cd "$PROJECT_ROOT"

echo ""
echo "Note: CloudFront takes a few minutes to propagate changes."
echo "Clear CloudFront cache if needed: aws cloudfront create-invalidation --distribution-id <ID> --paths '/*'"

