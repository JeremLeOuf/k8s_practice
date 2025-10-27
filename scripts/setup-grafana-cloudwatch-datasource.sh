#!/bin/bash

set -e

echo "🔧 Setting up Grafana CloudWatch Data Source"
echo ""

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &>/dev/null; then
  echo "❌ AWS CLI not configured. Please run: aws configure"
  exit 1
fi

USER_NAME="pkb-grafana-cloudwatch"

echo "📋 Checking if IAM user exists..."
if ! aws iam get-user --user-name "$USER_NAME" &>/dev/null; then
  echo "❌ IAM user $USER_NAME not found."
  echo "💡 This user should be created by Terraform. Please run terraform apply first."
  exit 1
fi

echo "✅ IAM user exists: $USER_NAME"
echo ""

# Check for existing access keys
echo "🔑 Checking for existing access keys..."
KEYS=$(aws iam list-access-keys --user-name "$USER_NAME" --query 'AccessKeyMetadata[]' --output json 2>/dev/null || echo "[]")
KEY_COUNT=$(echo "$KEYS" | jq '. | length')

if [ "$KEY_COUNT" -ge 2 ]; then
  echo "⚠️  User already has 2 access keys (AWS limit)"
  echo "📋 Existing keys:"
  echo "$KEYS" | jq -r '.[] | "ID: \(.AccessKeyId), Created: \(.CreateDate)"'
  echo ""
  echo "Please delete an old key first:"
  echo "  aws iam delete-access-key --user-name $USER_NAME --access-key-id KEY_ID"
  echo ""
  echo "Or use existing keys if they're still valid."
  exit 1
fi

if [ "$KEY_COUNT" -eq 1 ]; then
  EXISTING_KEY=$(echo "$KEYS" | jq -r '.[0].AccessKeyId')
  echo "⚠️  Found existing access key: $EXISTING_KEY"
  read -p "Delete and create new key? (y/N): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🗑️  Deleting old key..."
    aws iam delete-access-key --user-name "$USER_NAME" --access-key-id "$EXISTING_KEY"
  else
    echo "✅ Keeping existing key"
    exit 0
  fi
fi

# Create new access key
echo "🔑 Creating new access key..."
CREDENTIALS=$(aws iam create-access-key --user-name "$USER_NAME" --output json)

ACCESS_KEY=$(echo "$CREDENTIALS" | jq -r '.AccessKey.AccessKeyId')
SECRET_KEY=$(echo "$CREDENTIALS" | jq -r '.AccessKey.SecretAccessKey')

if [ -z "$ACCESS_KEY" ] || [ "$ACCESS_KEY" == "null" ]; then
  echo "❌ Failed to create access key"
  exit 1
fi

echo "✅ Access key created successfully!"
echo ""

# Save credentials to file
CREDENTIALS_FILE="grafana/.env.aws"
echo "💾 Saving credentials to $CREDENTIALS_FILE..."

cat > "$CREDENTIALS_FILE" <<EOF
AWS_ACCESS_KEY_ID=$ACCESS_KEY
AWS_SECRET_ACCESS_KEY=$SECRET_KEY
AWS_DEFAULT_REGION=us-east-1
EOF

chmod 600 "$CREDENTIALS_FILE"
echo "✅ Credentials saved to $CREDENTIALS_FILE"

echo ""
echo "📋 Next steps:"
echo ""
echo "1. Update Grafana datasource configuration:"
echo "   ./scripts/update-grafana-datasource-credentials.sh"
echo ""
echo "2. Or update manually at:"
echo "   http://localhost:3000/datasources"
echo ""
echo "3. Credentials:"
echo "   Access Key ID: $ACCESS_KEY"
echo "   Secret Access Key: $SECRET_KEY"
echo ""
echo "⚠️  Save these credentials securely - they won't be shown again!"

