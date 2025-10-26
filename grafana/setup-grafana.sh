#!/bin/bash

set -e

echo "🎯 Setting up Grafana monitoring for Personal Knowledge Base API"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if AWS credentials are configured
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  AWS credentials not found. Please configure AWS credentials.${NC}"
    echo ""
    echo "Run:"
    echo "  export AWS_ACCESS_KEY_ID=your_key"
    echo "  export AWS_SECRET_ACCESS_KEY=your_secret"
    exit 1
fi

echo -e "${GREEN}✅ AWS credentials found${NC}"
echo ""

# Check if docker-compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW}⚠️  docker-compose not found. Installing...${NC}"
    # Try to install docker-compose or suggest installation
    echo "Please install docker-compose:"
    echo "  sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose"
    echo "  sudo chmod +x /usr/local/bin/docker-compose"
    exit 1
fi

echo -e "${GREEN}✅ docker-compose found${NC}"
echo ""

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "Creating .env file..."
    cat > .env << EOF
# Grafana Configuration
GRAFANA_USER=admin
GRAFANA_PASSWORD=admin

# AWS Configuration for CloudWatch
AWS_ACCESS_KEY_ID=\${AWS_ACCESS_KEY_ID}
AWS_SECRET_ACCESS_KEY=\${AWS_SECRET_ACCESS_KEY}
AWS_DEFAULT_REGION=us-east-1
EOF
    echo -e "${GREEN}✅ Created .env file${NC}"
else
    echo -e "${BLUE}ℹ️  .env file already exists${NC}"
fi

echo ""
echo -e "${BLUE}Starting Grafana...${NC}"
echo ""

# Start Grafana
docker-compose up -d

echo ""
echo -e "${GREEN}✅ Grafana is starting!${NC}"
echo ""
echo -e "${BLUE}📊 Access Grafana at: http://localhost:3000${NC}"
echo -e "${BLUE}👤 Username: admin${NC}"
echo -e "${BLUE}🔑 Password: admin${NC}"
echo ""
echo "⏱️  Wait ~30 seconds for Grafana to initialize..."
echo ""
echo "Then run:"
echo "  ./setup-cloudwatch-datasource.sh"
echo ""

