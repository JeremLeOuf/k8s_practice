#!/bin/bash

set -e

echo "📊 Setting up Grafana dashboards..."

# Create namespace if it doesn't exist
kubectl create namespace grafana --dry-run=client -o yaml | kubectl apply -f -

# Create directories for dashboards
mkdir -p /tmp/grafana-dashboards

# Copy dashboard files
echo "📋 Copying dashboard files..."
cp grafana/dashboards/serverless-monitoring.json /tmp/grafana-dashboards/
cp grafana/dashboards/advanced-serverless-v2.json /tmp/grafana-dashboards/advanced-serverless-v2.json 2>/dev/null || echo "⚠️ advanced-serverless-v2.json not found, skipping"

# Create ConfigMap from directory
echo "🔧 Creating ConfigMap..."
kubectl create configmap grafana-dashboards \
  --from-file=/tmp/grafana-dashboards/ \
  --namespace=grafana \
  --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "✅ Dashboards configured!"
echo ""
echo "To import into Grafana:"
echo "1. Run: ./scripts/access-grafana.sh"
echo "2. Go to: Dashboards → Import"
echo "3. Select: 'Upload JSON file'"
echo "4. Choose: grafana/dashboards/advanced-serverless-v2.json"
echo ""
echo "Or wait for auto-provisioning (if configured)"

