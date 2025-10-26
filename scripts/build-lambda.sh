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
    echo -e "${BLUE}Building $func...${NC}"
    cd $func
    
    # Clean previous build
    rm -rf function.zip package/
    
    # Check if dependencies include only boto3 (pre-installed in Lambda runtime)
    if [ -f requirements.txt ] && grep -q "^boto3" requirements.txt && ! grep -q "^[^#]*[^boto3]" requirements.txt; then
      echo "⚠️ Only boto3 in requirements - boto3 is pre-installed in Lambda runtime"
      echo "Creating minimal package..."
      
      # Create package with just the Lambda function
      mkdir -p package
      cp lambda_function.py package/
    else
      # Install dependencies to a package directory
      echo "Installing dependencies..."
      mkdir -p package
      pip install -q -r requirements.txt -t package/ --upgrade 2>/dev/null || echo "Install failed, continuing..."
      
      # Copy Lambda function
      cp lambda_function.py package/
      
      # Remove unnecessary files to reduce size
      find package -name "*.pyc" -delete
      find package -type d -name "__pycache__" -exec rm -r {} + 2>/dev/null || true
      find package -name "*.dist-info" -exec rm -r {} + 2>/dev/null || true
      find package -type d -name "pip" -exec rm -r {} + 2>/dev/null || true
      find package -type d -name "setuptools" -exec rm -r {} + 2>/dev/null || true
      find package -name "*.html" -delete 2>/dev/null || true
      find package -name "*.txt" -delete 2>/dev/null || true
    fi
    
    # Create zip
    echo "Creating ZIP..."
    cd package
    zip -rq ../function.zip .
    cd ..
    
    # Get file size
    SIZE=$(du -h function.zip | cut -f1)
    echo -e "${GREEN}✅ $func packaged (${SIZE})${NC}"
    cd ..
done

cd ..
echo -e "${GREEN}🎉 All Lambda functions packaged!${NC}"

# Show total package size
du -ch lambda-functions/*/function.zip | tail -1

