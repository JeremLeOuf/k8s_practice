#!/bin/bash

set -e

echo "🚀 Full Deployment Script"
echo "=========================="
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI not found. Please install it first.${NC}"
    exit 1
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}❌ Terraform not found. Please install it first.${NC}"
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}❌ AWS credentials not configured. Please run 'aws configure'${NC}"
    exit 1
fi

echo -e "${BLUE}📋 Deployment Checklist:${NC}"
echo "  ✅ AWS CLI configured"
echo "  ✅ Terraform installed"
echo ""
echo "What will be deployed:"
echo "  📚 Knowledge Base (Lambda functions, DynamoDB, API Gateway)"
echo "  💰 Budget Tracker (Lambda functions, DynamoDB, SNS)"
echo "  🌐 Frontend (S3 bucket with all apps)"
echo "  📊 Monitoring (Grafana access page)"
echo ""

read -p "Continue with deployment? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled."
    exit 0
fi

echo ""
echo "=========================================="
echo -e "${BLUE}STEP 1: Building Lambda Functions${NC}"
echo "=========================================="
echo ""

chmod +x scripts/build-lambda.sh
if ./scripts/build-lambda.sh; then
    echo -e "${GREEN}✅ Lambda functions built successfully${NC}"
else
    echo -e "${RED}❌ Lambda build failed${NC}"
    exit 1
fi

echo ""
echo "=========================================="
echo -e "${BLUE}STEP 2: Deploying Infrastructure${NC}"
echo "=========================================="
echo ""

cd infrastructure

# Initialize Terraform if needed
if [ ! -d ".terraform" ]; then
    echo -e "${YELLOW}⚠️  Initializing Terraform...${NC}"
    terraform init
fi

# Apply Terraform configuration
echo -e "${BLUE}Applying Terraform configuration...${NC}"
if terraform apply -auto-approve; then
    echo -e "${GREEN}✅ Infrastructure deployed successfully${NC}"
else
    echo -e "${RED}❌ Infrastructure deployment failed${NC}"
    exit 1
fi

# Get outputs
API_URL=$(terraform output -raw api_gateway_url 2>/dev/null || echo "")
BUCKET_NAME=$(terraform output -raw frontend_bucket_name 2>/dev/null || echo "")
FRONTEND_URL=$(terraform output -raw frontend_url 2>/dev/null || echo "")

cd ..

echo ""
echo "=========================================="
echo -e "${BLUE}STEP 3: Configuring Frontend${NC}"
echo "=========================================="
echo ""

if [ -n "$API_URL" ]; then
    echo -e "${BLUE}📝 Updating frontend with API Gateway URL: $API_URL${NC}"
    
    # Update Knowledge Base app
    if [ -f "frontend/knowledge-base/app.html" ]; then
        sed -i "s|const DEFAULT_API_URL = '[^']*'|const DEFAULT_API_URL = '$API_URL'|g" frontend/knowledge-base/app.html
        echo "  ✅ Updated knowledge-base/app.html"
    fi
    
    # Update Budget Tracker app
    if [ -f "frontend/budget-tracker/budget.html" ]; then
        sed -i "s|const API_BASE_URL = '[^']*'|const API_BASE_URL = '$API_URL'|g" frontend/budget-tracker/budget.html
        echo "  ✅ Updated budget-tracker/budget.html"
    fi
    
    echo -e "${GREEN}✅ Frontend configured${NC}"
else
    echo -e "${YELLOW}⚠️  Could not get API Gateway URL${NC}"
fi

echo ""
echo "=========================================="
echo -e "${BLUE}STEP 4: Deploying Frontend to S3${NC}"
echo "=========================================="
echo ""

if [ -n "$BUCKET_NAME" ]; then
    echo -e "${BLUE}📤 Uploading frontend files to S3 bucket: $BUCKET_NAME${NC}"
    echo ""
    echo "Files being deployed:"
    echo "  🏠 index.html (Home Hub)"
    echo "  📚 knowledge-base/app.html"
    echo "  📚 knowledge-base/grafana.html"
    echo "  💰 budget-tracker/budget.html"
    echo ""
    
    if aws s3 sync frontend/ "s3://$BUCKET_NAME/" --delete --region us-east-1; then
        echo -e "${GREEN}✅ Frontend deployed to S3${NC}"
    else
        echo -e "${RED}❌ Frontend deployment failed${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ Could not get S3 bucket name${NC}"
    exit 1
fi

echo ""
echo "=========================================="
echo -e "${GREEN}🎉 Deployment Complete!${NC}"
echo "=========================================="
echo ""

echo -e "${BLUE}📊 Deployment Summary:${NC}"
echo ""
echo -e "${GREEN}Backend APIs:${NC}"
echo "  API Gateway: $API_URL"
echo "  Knowledge Base API: $API_URL/items"
echo "  Budget Tracker API: $API_URL/transactions"
echo "  Budget Balance API: $API_URL/balance"
echo ""
echo -e "${GREEN}Frontend Access:${NC}"
if [ -n "$FRONTEND_URL" ]; then
    echo "  🌐 Website: http://$FRONTEND_URL"
    echo "  🏠 Home: http://$FRONTEND_URL/"
    echo "  📚 Knowledge Base: http://$FRONTEND_URL/knowledge-base/app.html"
    echo "  💰 Budget Tracker: http://$FRONTEND_URL/budget-tracker/budget.html"
    echo "  📊 Grafana: http://$FRONTEND_URL/knowledge-base/grafana.html"
fi
echo ""
echo -e "${GREEN}Databases:${NC}"
cd infrastructure
echo "  📚 Knowledge Base: $(terraform output -raw dynamodb_table_name)"
echo "  💰 Budget Tracker: $(terraform output -raw budget_tracker_table_name)"
cd ..
echo ""
echo -e "${YELLOW}💡 Tip: Test your deployment by visiting the frontend URLs above${NC}"
echo ""

