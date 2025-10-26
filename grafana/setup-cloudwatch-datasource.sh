#!/bin/bash

set -e

echo "🔧 Setting up CloudWatch data source in Grafana"
echo ""

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Wait for Grafana to be ready
echo "Waiting for Grafana to be ready..."
while ! curl -s http://localhost:3000/api/health > /dev/null 2>&1; do
    sleep 2
    echo -n "."
done
echo ""
echo -e "${GREEN}✅ Grafana is ready!${NC}"
echo ""

# Get AWS credentials
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo -e "${YELLOW}⚠️  AWS credentials not set${NC}"
    echo ""
    echo "Please provide AWS credentials:"
    read -p "AWS Access Key ID: " AWS_ACCESS_KEY_ID
    read -sp "AWS Secret Access Key: " AWS_SECRET_ACCESS_KEY
    echo ""
fi

# Create data source configuration
echo "Creating CloudWatch data source..."

curl -X POST http://admin:admin@localhost:3000/api/datasources \
  -H "Content-Type: application/json" \
  -d '{
    "name": "CloudWatch",
    "type": "cloudwatch",
    "access": "proxy",
    "isDefault": true,
    "jsonData": {
      "authType": "keys",
      "defaultRegion": "us-east-1"
    },
    "secureJsonData": {
      "accessKeyId": "'"$AWS_ACCESS_KEY_ID"'",
      "secretAccessKey": "'"$AWS_SECRET_ACCESS_KEY"'"
    }
  }' 2>/dev/null | jq '.'

echo ""
echo -e "${GREEN}✅ CloudWatch data source configured!${NC}"
echo ""
echo "📊 Access Grafana: http://localhost:3000"
echo "🔍 Search for 'Lambda' to find the monitoring dashboard"
echo ""

