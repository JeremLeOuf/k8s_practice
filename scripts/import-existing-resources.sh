#!/bin/bash

set -e

echo "🔧 Importing existing AWS resources into Terraform state..."
echo ""

cd "$(dirname "$0")/../infrastructure"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to import resource
import_resource() {
    local resource_type=$1
    local resource_name=$2
    local resource_id=$3
    
    echo -e "${YELLOW}Importing ${resource_type}.${resource_name}...${NC}"
    
    # Check if already in state
    if terraform state show "${resource_type}.${resource_name}" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Already in state, skipping${NC}"
    else
        terraform import "${resource_type}.${resource_name}" "${resource_id}" || echo -e "${YELLOW}⚠ Could not import (may not exist yet)${NC}"
    fi
    echo ""
}

echo "📋 This script will import existing AWS resources into Terraform state."
echo "⚠️  Make sure you've run 'terraform init' first!"
echo ""
read -p "Press enter to continue or Ctrl+C to abort..."
echo ""

# Import DynamoDB table
import_resource "aws_dynamodb_table" "knowledge_base" "PersonalKnowledgeBase"

# Import IAM role
import_resource "aws_iam_role" "lambda_role" "pkb-lambda-execution-role"

# Import IAM policy
import_resource "aws_iam_policy" "grafana_cloudwatch_access" "arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/pkb-grafana-cloudwatch-access"

# Import IAM user
import_resource "aws_iam_user" "grafana_cloudwatch" "pkb-grafana-cloudwatch"

# Import S3 bucket (if you know its name)
read -p "Enter S3 bucket name to import (or press enter to skip): " bucket_name
if [ ! -z "$bucket_name" ]; then
    import_resource "aws_s3_bucket" "frontend" "$bucket_name"
fi

echo ""
echo -e "${GREEN}✅ Import complete!${NC}"
echo ""
echo "Run 'terraform plan' to verify everything is working."

