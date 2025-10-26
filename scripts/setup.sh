#!/bin/bash

set -e

echo "🔧 Setting up Personal Knowledge Base API..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed. Please install it first."
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "⚠️  Docker is not installed (optional for local testing)"
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "⚠️  kubectl is not installed (optional for K8s deployment)"
fi

# Initialize Git repository if not already done
if [ ! -d .git ]; then
    echo -e "${BLUE}📦 Initializing Git repository...${NC}"
    git init
    git add .
    git commit -m "Initial project setup"
    echo -e "${GREEN}✅ Git repository initialized${NC}"
fi

# Create Python virtual environment for testing
if [ ! -d venv ]; then
    echo -e "${BLUE}🐍 Creating Python virtual environment...${NC}"
    python3 -m venv venv
    source venv/bin/activate
    pip install boto3
    echo -e "${GREEN}✅ Virtual environment created${NC}"
fi

echo -e "${GREEN}✅ Setup complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Configure AWS credentials: aws configure"
echo "2. Review infrastructure/main.tf configuration"
echo "3. Run './scripts/deploy.sh' to deploy to AWS"
echo "4. Or run 'docker-compose up' in docker/ directory for local testing"

