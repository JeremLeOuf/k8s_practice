#!/bin/bash

# Quick start guide for k9s

echo "🎯 K9s Quick Start for Serverless App"
echo ""
echo "📋 Prerequisites:"
echo "  - k9s installed (run 'k9s version' to check)"
echo "  - minikube running (minikube start)"
echo "  - kubectl configured"
echo ""
echo "🚀 Starting k9s..."
echo ""
echo "In k9s:"
echo "  - Press 'p' to view pods"
echo "  - Press 's' to view services"
echo "  - Press 'd' to view deployments"
echo "  - Press '?' for help"
echo "  - Press 'q' to quit"
echo ""
echo "🤖 Opening k9s in 3 seconds..."
sleep 3

k9s

