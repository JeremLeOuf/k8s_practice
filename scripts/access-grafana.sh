#!/bin/bash

set -e

echo "🔍 Checking Grafana deployment..."
kubectl get deployment -n grafana grafana 2>/dev/null || {
  echo "❌ Grafana not found. Deploying..."
  kubectl apply -f kubernetes/grafana-deployment.yaml
  kubectl apply -f kubernetes/grafana-service.yaml
  
  echo "⏳ Waiting for Grafana to be ready..."
  kubectl rollout status deployment/grafana -n grafana --timeout=120s
}

echo ""
echo "🚀 Starting port-forward for Grafana..."
echo "📊 Access Grafana at: http://localhost:3000"
echo "👤 Username: admin"
echo "🔑 Password: admin"
echo ""
echo "⚠️  Note: 'broken pipe' errors are normal and can be ignored"
echo "Press Ctrl+C to stop"
echo ""

# Suppress error messages from broken pipes (common with web page reloads)
kubectl port-forward -n grafana svc/grafana-service 3000:3000 2>&1 | grep -v "Unhandled Error" | grep -v "error copying"

