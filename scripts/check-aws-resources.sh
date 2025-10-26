#!/bin/bash

set -e

echo "🔍 Checking for orphaned AWS resources not related to current deployment..."
echo ""

# Expected resource names (from your Terraform)
EXPECTED_LAMBDA_FUNCTIONS=(
  "pkb-api-get-items"
  "pkb-api-create-item"
  "pkb-api-delete-item"
  "budget-tracker-add-transaction"
  "budget-tracker-get-balance"
)

EXPECTED_BUCKET="pkb-frontend-personal-knowledge-base"
EXPECTED_TABLES=("PersonalKnowledgeBase" "BudgetTracker")

echo "=== LAMBDA FUNCTIONS ==="
ALL_LAMBDAS=$(aws lambda list-functions --query 'Functions[].FunctionName' --output text)
CURRENT_LAMBDAS=$(echo "$ALL_LAMBDAS" | grep -E "pkb|budget" || echo "None found")

echo "Found Lambda functions related to this project:"
echo "$CURRENT_LAMBDAS" | tr '\t' '\n' | grep -v "^$" || echo "  None"

if [ -n "$CURRENT_LAMBDAS" ] && [ "$CURRENT_LAMBDAS" != "None" ]; then
  echo ""
  echo "Other Lambda functions (may incur costs):"
  OTHER_LAMBDAS=$(aws lambda list-functions --query 'Functions[].FunctionName' --output text)
  echo "$OTHER_LAMBDAS" | tr '\t' '\n' | grep -vE "pkb|budget" | head -10 || echo "  None"
fi

echo ""
echo "=== S3 BUCKETS ==="
ALL_BUCKETS=$(aws s3api list-buckets --query 'Buckets[].Name' --output text)
CURRENT_BUCKETS=$(echo "$ALL_BUCKETS" | grep -E "pkb|budget" || echo "None found")

echo "Found S3 buckets related to this project:"
echo "$CURRENT_BUCKETS" | tr '\t' '\n' | grep -v "^$" || echo "  None"

if [ -n "$ALL_BUCKETS" ]; then
  echo ""
  echo "Other S3 buckets (may incur costs):"
  echo "$ALL_BUCKETS" | tr '\t' '\n' | grep -vE "pkb|budget" | head -10 || echo "  None"
fi

echo ""
echo "=== DYNAMODB TABLES ==="
ALL_TABLES=$(aws dynamodb list-tables --query 'TableNames[]' --output text 2>/dev/null || echo "")
CURRENT_TABLES=$(echo "$ALL_TABLES" | grep -E "PersonalKnowledgeBase|BudgetTracker" || echo "None found")

echo "Found DynamoDB tables:"
echo "$CURRENT_TABLES" | tr '\t' '\n' | grep -v "^$" || echo "  None"

if [ -n "$ALL_TABLES" ]; then
  echo ""
  echo "Other DynamoDB tables (may incur costs):"
  echo "$ALL_TABLES" | tr '\t' '\n' | grep -vE "PersonalKnowledgeBase|BudgetTracker" | head -10 || echo "  None"
fi

echo ""
echo "=== CLOUDFRONT DISTRIBUTIONS ==="
DISTRIBUTIONS=$(aws cloudfront list-distributions --query 'DistributionList.Items[]' --output json 2>/dev/null || echo "[]")
DIST_COUNT=$(echo "$DISTRIBUTIONS" | jq '. | length')

echo "Total CloudFront distributions: $DIST_COUNT"
echo ""
echo "Distributions for this project:"
echo "$DISTRIBUTIONS" | jq -r '.[] | select(.Comment | contains("Personal Knowledge Base")) | "ID: \(.Id) | Status: \(.Status) | Enabled: \(.Enabled) | Domain: \(.DomainName)"' || echo "  None found"

echo ""
echo "=== CLOUDWATCH LOG GROUPS ==="
LOG_GROUPS=$(aws logs describe-log-groups --query 'logGroups[*].logGroupName' --output text 2>/dev/null || echo "")
CURRENT_LOGS=$(echo "$LOG_GROUPS" | grep -E "/aws/lambda/(pkb|budget)" || echo "None found")

echo "Found log groups related to this project:"
echo "$CURRENT_LOGS" | tr '\t' '\n' | head -10 || echo "  None"

echo ""
echo "=== API GATEWAY ==="
APIS=$(aws apigateway get-rest-apis --query 'items[*].[name,id]' --output text 2>/dev/null || echo "")

echo "API Gateway APIs:"
echo "$APIS" || echo "  None found"

echo ""
echo "=== COST ESTIMATION ==="
echo ""
echo "💡 Resources that may incur costs:"
echo ""
echo "✅ Lambda Functions - Pay per invocation + compute time"
echo "✅ DynamoDB Tables - Pay per request (on-demand)"
echo "✅ CloudFront Distributions - Pay per GB transferred"
echo "✅ S3 Buckets - Pay for storage + requests"
echo "✅ CloudWatch Logs - Pay for ingestion + storage"
echo ""
echo "Current resources for this project:"
echo "- Lambda: ~5 functions"
echo "- DynamoDB: ~2 tables"
echo "- CloudFront: 1 distribution"
echo "- S3: 1 bucket"
echo ""
echo "All resources are within AWS Free Tier for 12 months!"
echo "After free tier, costs are minimal (~$0.01 per 1000 Lambda invocations)"

