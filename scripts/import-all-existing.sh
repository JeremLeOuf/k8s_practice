#!/bin/bash

set -e

echo "🔍 Importing all existing AWS resources into Terraform state..."
echo ""

cd "$(dirname "$0")/../infrastructure"

# Get AWS Account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "AWS Account ID: $ACCOUNT_ID"
echo ""

# DynamoDB Tables
echo "📦 Importing DynamoDB tables..."
terraform import aws_dynamodb_table.knowledge_base PersonalKnowledgeBase || echo "⚠️ Already imported"
terraform import aws_dynamodb_table.budget_tracker BudgetTracker || echo "⚠️ Already imported"

# IAM Roles
echo "🔑 Importing IAM roles..."
terraform import aws_iam_role.lambda_role pkb-lambda-execution-role || echo "⚠️ Already imported"
terraform import aws_iam_role.budget_tracker_lambda budget-tracker-lambda-role || echo "⚠️ Already imported"

# IAM Policy
echo "📝 Importing IAM policies..."
terraform import aws_iam_policy.grafana_cloudwatch_access arn:aws:iam::$ACCOUNT_ID:policy/pkb-grafana-cloudwatch-access || echo "⚠️ Already imported"

# IAM User
echo "👤 Importing IAM users..."
terraform import aws_iam_user.grafana_cloudwatch pkb-grafana-cloudwatch || echo "⚠️ Already imported"

# S3 Bucket
echo "🪣 Importing S3 bucket..."
terraform import aws_s3_bucket.frontend pkb-frontend-personal-knowledge-base || echo "⚠️ Already imported"
terraform import aws_s3_bucket_versioning.frontend pkb-frontend-personal-knowledge-base || echo "⚠️ Already imported"
terraform import aws_s3_bucket_public_access_block.frontend pkb-frontend-personal-knowledge-base || echo "⚠️ Already imported"

echo ""
echo "✅ Import complete!"
echo ""
echo "Run: terraform apply"

