#!/bin/bash

set -e

echo "🚀 Setting up K8s and K9s environment for serverless app..."

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if minikube is installed
if ! command -v minikube &> /dev/null; then
    echo -e "${YELLOW}⚠️  Minikube not found. Installing...${NC}"
    echo "Download minikube from: https://minikube.sigs.k8s.io/docs/start/"
    exit 1
fi

# Check if k9s is installed
if ! command -v k9s &> /dev/null; then
    echo -e "${YELLOW}⚠️  k9s not found. Installing...${NC}"
    echo "Download k9s from: https://k9scli.io/topics/install/"
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${YELLOW}⚠️  kubectl not found. Please install kubectl first.${NC}"
    exit 1
fi

echo -e "${BLUE}✓ Checking minikube status...${NC}"
minikube status || minikube start

echo -e "${BLUE}✓ Setting up Docker environment...${NC}"
eval $(minikube docker-env)

echo -e "${BLUE}✓ Building Lambda Docker images...${NC}"
cd ../docker

# Build images
docker build -f Dockerfile.lambda -t pkb-get-items:latest ../lambda-functions/get-items/
docker build -f Dockerfile.lambda -t pkb-create-item:latest ../lambda-functions/create-item/
docker build -f Dockerfile.lambda -t pkb-delete-item:latest ../lambda-functions/delete-item/

echo -e "${GREEN}✓ Images built successfully!${NC}"

cd ..

echo -e "${BLUE}✓ Deploying to Kubernetes...${NC}"
kubectl apply -f kubernetes/

echo -e "${BLUE}✓ Waiting for pods to be ready...${NC}"
kubectl wait --for=condition=ready pod -l app=get-items --timeout=60s
kubectl wait --for=condition=ready pod -l app=create-item --timeout=60s
kubectl wait --for=condition=ready pod -l app=delete-item --timeout=60s

echo -e "${GREEN}✅ Setup complete!${NC}"
echo ""
echo -e "${BLUE}📊 Check your deployment:${NC}"
echo "  kubectl get pods"
echo "  kubectl get services"
echo ""
echo -e "${BLUE}🎯 Start k9s:${NC}"
echo "  k9s"
echo ""
echo -e "${BLUE}📖 Read K9S_LEARNING_GUIDE.md for more info${NC}"

