#!/bin/bash

set -e

echo "🚀 Deploying Personal Knowledge Base API..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Step 1: Package Lambda functions
echo -e "${BLUE}📦 Packaging Lambda functions...${NC}"
cd lambda-functions

for func in get-items create-item delete-item; do
    echo "Processing $func..."
    cd $func
    zip -r function.zip .
    cd ..
done

cd ..

# Step 2: Initialize Terraform
echo -e "${BLUE}🏗️  Initializing Terraform...${NC}"
cd infrastructure
terraform init

# Step 3: Plan Terraform changes
echo -e "${BLUE}📋 Planning Terraform changes...${NC}"
terraform plan

# Step 4: Apply Terraform
echo -e "${BLUE}🚀 Applying Terraform configuration...${NC}"
read -p "Do you want to proceed with deployment? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    terraform apply -auto-approve
    echo -e "${GREEN}✅ Deployment complete!${NC}"
else
    echo "Deployment cancelled."
    exit 1
fi

# Step 5: Get API URL
echo -e "${BLUE}🔗 Getting API Gateway URL...${NC}"
API_URL=$(terraform output -raw api_gateway_url)
echo -e "${GREEN}API URL: $API_URL${NC}"

cd ..
echo -e "${GREEN}🎉 Deployment finished!${NC}"

