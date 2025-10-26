#!/bin/bash

set -e

echo "🔍 Checking CDN and S3 status..."
echo ""

cd "$(dirname "$0")/.."

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get outputs from Terraform
echo "📋 Getting Terraform outputs..."
cd infrastructure
BUCKET_NAME=$(terraform output -raw frontend_bucket_name 2>/dev/null || echo "")
CDN_URL=$(terraform output -raw frontend_url 2>/dev/null || echo "")

if [ -z "$BUCKET_NAME" ]; then
    echo -e "${RED}❌ Could not get bucket name from Terraform${NC}"
    echo "Run: cd infrastructure && terraform apply"
    exit 1
fi

echo -e "${GREEN}✓ Bucket: $BUCKET_NAME${NC}"
echo -e "${GREEN}✓ CDN URL: $CDN_URL${NC}"
echo ""

# Check if bucket exists and has files
echo "📦 Checking S3 bucket contents..."
if aws s3 ls "s3://$BUCKET_NAME" 2>/dev/null | grep -q "index.html"; then
    echo -e "${GREEN}✓ Files found in bucket${NC}"
    aws s3 ls "s3://$BUCKET_NAME"
else
    echo -e "${RED}❌ No files in bucket${NC}"
    echo ""
    echo "💡 Deploying frontend files..."
    cd ..
    ./scripts/deploy-frontend.sh
fi

echo ""
echo "🌐 Checking CloudFront distribution..."
DISTRIBUTION_ID=$(aws cloudfront list-distributions --query "DistributionList.Items[?contains(Origins.Items[*].DomainName, \`$BUCKET_NAME\`)].Id" --output text 2>/dev/null || echo "")

if [ -z "$DISTRIBUTION_ID" ]; then
    echo -e "${RED}❌ Could not find CloudFront distribution${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Distribution ID: $DISTRIBUTION_ID${NC}"

# Check distribution status
echo ""
echo "📊 CloudFront status:"
aws cloudfront get-distribution --id "$DISTRIBUTION_ID" --query "Distribution.Status" --output text

# Test CDN URL
echo ""
echo "🧪 Testing CDN URL..."
if [ ! -z "$CDN_URL" ]; then
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://$CDN_URL" || echo "000")
    if [ "$STATUS" = "200" ] || [ "$STATUS" = "403" ]; then
        echo -e "${GREEN}✓ CDN is reachable (Status: $STATUS)${NC}"
        echo ""
        echo "🌐 Open in browser:"
        echo -e "${YELLOW}https://$CDN_URL${NC}"
    else
        echo -e "${RED}❌ CDN returned status: $STATUS${NC}"
        
        if [ "$STATUS" = "000" ]; then
            echo ""
            echo "💡 Distribution might still be deploying..."
            echo "   Wait a few minutes and try again"
        fi
    fi
fi

echo ""
echo "📝 S3 Bucket Policy:"
aws s3api get-bucket-policy --bucket "$BUCKET_NAME" 2>/dev/null | jq -r .Policy | jq '.' || echo "No bucket policy found"

