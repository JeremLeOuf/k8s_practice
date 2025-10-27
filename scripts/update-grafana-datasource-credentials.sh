#!/bin/bash

set -e

echo "🔧 Updating Grafana CloudWatch datasource credentials"
echo ""

# Check if credentials file exists
CREDENTIALS_FILE="grafana/.env.aws"

if [ ! -f "$CREDENTIALS_FILE" ]; then
  echo "❌ Credentials file not found: $CREDENTIALS_FILE"
  echo "💡 Run: ./scripts/setup-grafana-cloudwatch-datasource.sh first"
  exit 1
fi

# Source credentials
source "$CREDENTIALS_FILE"

# Check if credentials are set
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "❌ AWS credentials not found in $CREDENTIALS_FILE"
  exit 1
fi

echo "✅ Found credentials for: $AWS_ACCESS_KEY_ID"
echo ""

# Update datasource configuration
DATASOURCE_FILE="grafana/provisioning/datasources/cloudwatch.yml"

if [ ! -f "$DATASOURCE_FILE" ]; then
  echo "❌ Datasource file not found: $DATASOURCE_FILE"
  exit 1
fi

echo "📝 Updating datasource configuration..."
cat > "$DATASOURCE_FILE" <<EOF
apiVersion: 1

datasources:
  - name: CloudWatch
    type: cloudwatch
    access: proxy
    isDefault: true
    jsonData:
      authType: keys
      defaultRegion: us-east-1
    secureJsonData:
      accessKey: "${AWS_ACCESS_KEY_ID}"
      secretKey: "${AWS_SECRET_ACCESS_KEY}"
    editable: true
EOF

echo "✅ Datasource configuration updated"
echo ""
echo "🔄 You may need to restart Grafana for changes to take effect:"
echo "   docker-compose restart"

