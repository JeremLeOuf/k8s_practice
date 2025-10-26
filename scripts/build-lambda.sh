#!/bin/bash

set -e

echo "📦 Building Lambda function packages..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

cd lambda-functions

for func in get-items create-item delete-item; do
    echo -e "${BLUE}Building $func...${NC}"
    cd $func
    
    # Create zip file
    if [ -f function.zip ]; then
        rm function.zip
    fi
    
    zip -r function.zip . -x "*.pyc" "__pycache__/*" "*.git/*"
    
    echo -e "${GREEN}✅ $func packaged successfully${NC}"
    cd ..
done

cd ..
echo -e "${GREEN}🎉 All Lambda functions packaged!${NC}"

