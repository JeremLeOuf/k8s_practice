#!/bin/bash

set -e

echo "🔍 Checking Grafana deployment..."

# Check if we can access the current context
if ! kubectl cluster-info &>/dev/null; then
  echo "❌ Error: Cannot connect to Kubernetes cluster"
  echo "💡 Please check your kubectl configuration:"
  echo "   kubectl config get-contexts"
  echo "   kubectl config use-context <context-name>"
  exit 1
fi

# Try to get the deployment, suppress errors for "not found"
kubectl get deployment -n grafana grafana 2>/dev/null || {
  echo "❌ Grafana not found. Deploying..."
  
  # Ensure namespace exists
  kubectl create namespace grafana 2>/dev/null || true
  
  # Apply all Grafana resources
  kubectl apply -f kubernetes/grafana-configmap-dashboards.yaml || true
  kubectl apply -f kubernetes/grafana-provisioning.yaml || true
  kubectl apply -f kubernetes/grafana-deployment.yaml
  kubectl apply -f kubernetes/grafana-service.yaml
  
  echo "⏳ Waiting for Grafana to be ready..."
  kubectl rollout status deployment/grafana -n grafana --timeout=AbortError || true
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

