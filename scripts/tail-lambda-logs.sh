#!/bin/bash

# Tail CloudWatch logs for Lambda functions

set -e

FUNCTION_NAME="${1:-get-items}"
REGION="${AWS_REGION:-us-east-1}"

echo "📋 Tailing logs for: $FUNCTION_NAME"
echo "🌍 Region: $REGION"
echo ""

# Full log group name
LOG_GROUP="/aws/lambda/pkb-api-$FUNCTION_NAME"

echo "📊 Log group: $LOG_GROUP"
echo ""
echo "Press Ctrl+C to stop..."
echo ""

aws --region "$REGION" logs tail "$LOG_GROUP" --follow

