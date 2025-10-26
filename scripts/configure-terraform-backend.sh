#!/bin/bash

set -e

echo "🔧 Setting up Terraform S3 backend for remote state"
echo ""

cd "$(dirname "$0")/.."

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

BUCKET_NAME="${1:-pkb-terraform-state}"

echo -e "${BLUE}This script will:${NC}"
echo "1. Create an S3 bucket for Terraform state: $BUCKET_NAME"
echo "2. Enable versioning on the bucket"
echo "3. Enable encryption"
echo "4. Configure Terraform backend in infrastructure/main.tf"
echo ""
read -p "Press enter to continue or Ctrl+C to abort..."
echo ""

# Check if bucket exists
if aws s3 ls "s3://$BUCKET_NAME" 2>&1 > /dev/null; then
    echo -e "${GREEN}✓ S3 bucket $BUCKET_NAME already exists${NC}"
else
    echo "Creating S3 bucket: $BUCKET_NAME"
    aws s3 mb "s3://$BUCKET_NAME" --region us-east-1
    
    # Enable versioning
    aws s3api put-bucket-versioning \
        --bucket "$BUCKET_NAME" \
        --versioning-configuration Status=Enabled
    
    # Enable encryption
    aws s3api put-bucket-encryption \
        --bucket "$BUCKET_NAME" \
        --server-side-encryption-configuration '{
            "Rules": [{
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }]
        }'
    
    # Block public access
    aws s3api put-public-access-block \
        --bucket "$BUCKET_NAME" \
        --public-access-block-configuration \
        "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
    
    echo -e "${GREEN}✓ S3 bucket created and configured${NC}"
fi

echo ""
echo "Now update infrastructure/main.tf to uncomment and configure the backend:"
echo ""
echo "backend \"s3\" {"
echo "  bucket = \"$BUCKET_NAME\""
echo "  key    = \"serverless-app/terraform.tfstate\""
echo "  region = \"us-east-1\""
echo "}"
echo ""
echo "Then run: terraform init -migrate-state"

