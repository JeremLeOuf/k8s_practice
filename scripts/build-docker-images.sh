#!/bin/bash

set -e

echo "🐳 Building Docker images for Lambda functions..."

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

cd docker

# Build get-items
echo -e "${BLUE}Building get-items...${NC}"
docker build -f Dockerfile.lambda -t pkb-get-items:latest ../lambda-functions/get-items/

# Build create-item
echo -e "${BLUE}Building create-item...${NC}"
docker build -f Dockerfile.lambda -t pkb-create-item:latest ../lambda-functions/create-item/

# Build delete-item
echo -e "${BLUE}Building delete-item...${NC}"
docker build -f Dockerfile.lambda -t pkb-delete-item:latest ../lambda-functions/delete-item/

echo -e "${GREEN}✅ All images built successfully!${NC}"
echo ""
echo "Images created:"
docker images | grep pkb

cd ..

