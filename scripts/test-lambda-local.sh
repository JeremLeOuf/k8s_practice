#!/bin/bash

echo "🧪 Testing Lambda functions locally..."
echo ""

# Test get-items
echo "📋 Testing get-items (GET /items)..."
curl -X POST http://localhost:9001 \
  -H "Content-Type: application/json" \
  -d '{
    "httpMethod": "GET",
    "path": "/items",
    "headers": {
      "Accept": "application/json"
    }
  }' | jq '.' 2>/dev/null || curl -X POST http://localhost:9001 \
  -H "Content-Type: application/json" \
  -d '{"httpMethod":"GET","path":"/items"}'
echo -e "\n"

# Test create-item  
echo "➕ Testing create-item (POST /items)..."
curl -X POST http://localhost:9002 \
  -H "Content-Type: application/json" \
  -d '{
    "httpMethod": "POST",
    "path": "/items",
    "headers": {
      "Content-Type": "application/json"
    },
    "body": "{\"title\":\"Test Item\",\"content\":\"Created locally\",\"type\":\"note\"}"
  }' | jq '.' 2>/dev/null || curl -X POST http://localhost:9002 \
  -H "Content-Type: application/json" \
  -d '{"httpMethod":"POST","path":"/items","body":"{\"title\":\"Test\",\"content\":\"Local test\",\"type\":\"note\"}"}'
echo -e "\n"

echo "✅ Tests complete!"
echo ""
echo "Note: To run Lambda containers, use:"
echo "  cd docker && docker-compose up"

