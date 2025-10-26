#!/bin/bash

set -e

echo "⚡ Building Lambda functions with uv..."

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Ensure uv is in PATH
export PATH="$HOME/.cargo/bin:$PATH"

cd lambda-functions

for func in get-items create-item delete-item; do
    echo -e "${BLUE}Building $func with uv...${NC}"
    cd $func
    
    # Use uv to install dependencies
    if command -v uv &> /dev/null; then
        echo "Using uv to install dependencies..."
        uv pip install --target . -r requirements.txt
        
        # Create zip file
        if [ -f function.zip ]; then
            rm function.zip
        fi
        zip -r function.zip . -x "*.pyc" "__pycache__/*" "*.git/*" "*.dist-info/*" "*/__pycache__/*"
    else
        echo "uv not found, falling back to pip..."
        pip install -r requirements.txt -t .
        zip -r function.zip . -x "*.pyc" "__pycache__/*"
    fi
    
    echo -e "${GREEN}✅ $func packaged successfully${NC}"
    cd ..
done

cd ..
echo -e "${GREEN}🎉 All Lambda functions packaged with uv!${NC}"

