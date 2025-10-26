# 🧪 Local Testing Guide

## Testing Lambda Functions Locally

The Lambda containers use AWS Lambda Runtime Interface Emulator (RIE) which expects AWS Lambda event format, not simple HTTP requests.

## Quick Start

### Option 1: Test with AWS Lambda Format

```bash
# Start containers
cd docker
docker-compose up -d

# Test get-items
curl -X POST http://localhost:9001/2015-03-31/functions/function/invocations \
  -H "Content-Type: application/json" \
  -d '{
    "httpMethod": "GET",
    "path": "/items",
    "headers": {}
  }'

# Test create-item
curl -X POST http://localhost:9002/2015-03-31/functions/function/invocations \
  -H "Content-Type: application/json" \
  -d '{
    "httpMethod": "POST",
    "path": "/items",
    "headers": {"Content-Type": "application/json"},
    "body": "{\"title\":\"Test\",\"content\":\"From local\",\"type\":\"note\"}"
  }'
```

### Option 2: Use SAM Local (Recommended)

Install AWS SAM CLI:
```bash
pip install aws-sam-cli
```

Run Lambda locally:
```bash
sam local start-api --template template.yaml
```

Then test with:
```bash
curl http://localhost:3000/items
curl -X POST http://localhost:3000/items -d '{"title":"Test","content":"Content"}'
```

### Option 3: Test the Deployed API (Easiest)

```bash
# Get API URL
cd infrastructure
terraform output api_gateway_url

# Test deployed API
curl https://vzilkz4t52.execute-api.us-east-1.amazonaws.com/prod/items
```

## Frontend Local Testing

```bash
# Serve frontend locally
cd frontend
python3 -m http.server 8000

# Open browser
# http://localhost:8000
```

The frontend is configured to connect to your deployed API.

## Why Regular HTTP Doesn't Work

Lambda containers expect:
- AWS Lambda event format
- Port 9000 (Runtime API) or RIE endpoint
- POST requests to `/2015-03-31/functions/function/invocations`

They DON'T support:
- Simple HTTP GET/POST
- REST endpoints
- Regular web server requests

## Alternative: Use AWS Directly

The easiest way to test is to use your deployed API:

```bash
curl https://vzilkz4t52.execute-api.us-east-1.amazonaws.com/prod/items
```

Or use the frontend with the pre-configured API URL!

