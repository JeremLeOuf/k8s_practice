#!/bin/bash

set -e

echo "📦 Building optimized Lambda function packages..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

cd lambda-functions

for func in get-items create-item delete-item; do
    START_TIME=$(date +%s)
    echo -e "${BLUE}Building $func...${NC}"
    cd $func
    
    # Clean previous build
    rm -rf function.zip package/
    
    # Get requirements
    if [ -f requirements.txt ]; then
        DEPS=$(grep -v '^#' requirements.txt | grep -v '^$' | tr '\n' ',' || true)
        # Count non-comment lines
        DEPS_COUNT=$(grep -v '^#' requirements.txt | grep -v '^$' | wc -l)
    else
        DEPS=""
        DEPS_COUNT=0
    fi
    
    # Check if dependencies include only boto3 (pre-installed in Lambda runtime)
    BOTO3_ONLY=false
    if [ ! -z "$DEPS" ] && [ "$DEPS_COUNT" -gt 0 ]; then
        # Check if boto3 is the only dependency (handle various formats like "boto3>=1.28.0")
        if echo "$DEPS" | grep -q "boto3" && [ "$DEPS_COUNT" -eq 1 ]; then
            BOTO3_ONLY=true
        fi
    fi
    
    if [ "$BOTO3_ONLY" = true ]; then
      echo "⚠️ Only boto3 in requirements (pre-installed in Lambda) - creating minimal package (<100KB)"
      mkdir -p package
      cp lambda_function.py package/
    else
      # Install dependencies
      echo "Installing dependencies: ${DEPS:-none}"
      mkdir -p package
      
      if [ -f requirements.txt ] && [ ! -z "$DEPS" ]; then
        pip install -q -r requirements.txt -t package/ --upgrade --no-cache-dir 2>/dev/null || echo "Install warning"
      fi
      
      # Copy Lambda function
      cp lambda_function.py package/
      
      # Clean up to minimize size
      find package -name "*.pyc" -delete 2>/dev/null || true
      find package -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
      find package -name "*.dist-info" -type d -exec rm -rf {} + 2>/dev/null || true
      find package -type d -name "pip" -exec rm -rf {} + 2>/dev/null || true
      find package -type d -name "setuptools" -exec rm -rf {} + 2>/dev/null || true
      find package -name "*.html" -delete 2>/dev/null || true
      find package -name "*.txt" -delete 2>/dev/null || true
    fi
    
    # Create zip
    echo "Creating ZIP..."
    cd package
    zip -rq ../function.zip . 2>/dev/null || zip -rq ../function.zip *
    cd ..
    
    # Get file size and build time
    SIZE=$(du -h function.zip | cut -f1)
    END_TIME=$(date +%s)
    ELAPSED=$((END_TIME - START_TIME))
    echo -e "${GREEN}✅ $func packaged (${SIZE}) in ${ELAPSED}s${NC}"
    cd ..
done

cd ..
echo -e "${GREEN}🎉 All Lambda functions packaged!${NC}"

# Show total package size
du -ch lambda-functions/*/function.zip | tail -1

