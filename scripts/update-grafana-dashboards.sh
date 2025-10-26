#!/bin/bash

set -e

echo "📊 Updating Grafana dashboards in Kubernetes..."

# Create or update namespace
kubectl create namespace grafana --dry-run=client -o yaml | kubectl apply -f -

# Deploy provisioning ConfigMap
echo "📝 Deploying Grafana provisioning..."
kubectl apply -f kubernetes/grafana-provisioning.yaml -n grafana

# Deploy or update dashboard ConfigMaps (one per dashboard)
echo "📊 Deploying Grafana dashboards..."

# Serverless Monitoring Dashboard
kubectl create configmap grafana-dashboards-serverless \
  --from-file=grafana/dashboards/serverless-monitoring.json \
  --dry-run=client -o yaml \
  --namespace=grafana | kubectl apply -f -

# Advanced Serverless v2 Dashboard
kubectl create configmap grafana-dashboards-advanced \
  --from-file=grafana/dashboards/advanced-serverless-v2.json \
  --dry-run=client -o yaml \
  --namespace=grafana | kubectl apply -f -

# Apply Grafana deployment (updated with volume mounts)
echo "🚀 Deploying updated Grafana configuration..."
kubectl apply -f kubernetes/grafana-deployment.yaml -n grafana

# Wait for deployment
echo "⏳ Waiting for Grafana to be ready..."
kubectl rollout status deployment/grafana -n grafana --timeout=120s

echo ""
echo "✅ Grafana dashboards deployed!"
echo ""
echo "📊 To access Grafana:"
echo "   1. Run: ./scripts/access-grafana.sh"
echo "   2. Or: kubectl port-forward -n grafana svc/grafana-service 3000:3000"
echo ""
echo "🌐 Available dashboards:"
echo "   - 🚀 Serverless Monitoring (Basic)"
echo "   - 🎯 Advanced Serverless v2 (Advanced - 10 panels)"
echo ""
echo "💡 Tip: Dashboards should auto-load in Grafana UI"

