#!/bin/bash

# Get CloudWatch metrics for Lambda functions

set -e

FUNCTION_NAME="${1:-get-items}"
REGION="${AWS_REGION:-us-east-1}"
DAYS="${2:-7}"  # Default to last 7 days

echo "📊 CloudWatch Metrics for: pkb-api-$FUNCTION_NAME"
echo "🌍 Region: $REGION"
echo "📅 Last $DAYS days"
echo ""

START_TIME=$(date -u -d "$DAYS days ago" +%Y-%m-%dT%H:%M:%SZ)
END_TIME=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "🕐 Time range: $START_TIME to $END_TIME"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📈 INVOCATIONS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
aws --region "$REGION" cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Invocations \
  --dimensions Name=FunctionName,Value=pkb-api-$FUNCTION_NAME \
  --start-time "$START_TIME" \
  --end-time "$END_TIME" \
  --period 3600 \
  --statistics Sum --query 'Datapoints[].Sum' --output table

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "❌ ERRORS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
aws --region "$REGION" cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Errors \
  --dimensions Name=FunctionName,Value=pkb-api-$FUNCTION_NAME \
  --start-time "$START_TIME" \
  --end-time "$END_TIME" \
  --period 3600 \
  --statistics Sum --query 'Datapoints[].Sum' --output table

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⏱️  DURATION (ms)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
aws --region "$REGION" cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Duration \
  --dimensions Name=FunctionName,Value=pkb-api-$FUNCTION_NAME \
  --start-time "$START_TIME" \
  --end-time "$END_TIME" \
  --period 3600 \
  --statistics Average Maximum --query 'Datapoints[].{Time:Timestamp,Avg:Average,Max:Maximum}' --output table

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💰 COST ESTIMATE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
TOTAL_INVOCATIONS=$(aws --region "$REGION" cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Invocations \
  --dimensions Name=FunctionName,Value=pkb-api-$FUNCTION_NAME \
  --start-time "$START_TIME" \
  --end-time "$END_TIME" \
  --period 86400 \
  --statistics Sum --query 'sum(Datapoints[].Sum)' --output text)

echo "Total Invocations: $TOTAL_INVOCATIONS"
echo "Free Tier: 1M requests/month (you're covered!)"
echo ""

echo "✅ Metrics retrieved successfully!"

