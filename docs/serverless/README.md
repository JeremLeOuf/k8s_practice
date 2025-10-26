# 🚀 Serverless Backend Documentation

This folder contains all documentation related to the serverless backend (Lambda, API Gateway, DynamoDB).

## 📄 Files

### 📘 Main Documentation
- **[SERVERLESS_APP_README.md](./SERVERLESS_APP_README.md)** - Complete backend guide
  - Architecture overview
  - Lambda functions
  - API Gateway setup
  - DynamoDB configuration
  - Testing and deployment

### 🧪 Testing
- **[LOCAL_TESTING.md](./LOCAL_TESTING.md)** - Test Lambda functions locally
  - Docker containers
  - Local API testing
  - Debug techniques

### 📦 Dependencies
- **[UV_README.md](./UV_README.md)** - Fast Python package management
  - uv installation
  - Building with uv
  - Performance benefits

## 🎯 Quick Start

### Deploy Backend

```bash
# Build Lambda functions
./scripts/build-lambda.sh

# Deploy infrastructure
cd infrastructure
terraform apply

# Get API URL
terraform output api_gateway_url
```

### Test API

```bash
API_URL=$(terraform output -raw api_gateway_url)

# Get all items
curl "$API_URL/items"

# Create an item
curl -X POST "$API_URL/items" \
  -H "Content-Type: application/json" \
  -d '{"title": "Test", "content": "Hello World"}'

# Delete an item
curl -X DELETE "$API_URL/items/ITEM_ID"
```

## 🏗️ Architecture

```
┌─────────────────────┐
│   API Gateway       │
│   (REST API)        │
└──────────┬──────────┘
           │
           ↓
┌─────────────────────┐
│   Lambda Functions  │
│   - get-items       │
│   - create-item     │
│   - delete-item     │
└──────────┬──────────┘
           │
           ↓
┌─────────────────────┐
│   DynamoDB          │
│   (NoSQL Database)  │
└─────────────────────┘
```

## 📚 Lambda Functions

### Get Items (`get-items`)
- **Handler:** `lambda_function.handler`
- **Method:** GET
- **Endpoint:** `/items`
- **Description:** Retrieve all items from DynamoDB

### Create Item (`create-item`)
- **Handler:** `lambda_function.handler`
- **Method:** POST
- **Endpoint:** `/items`
- **Description:** Create a new item in DynamoDB

### Delete Item (`delete-item`)
- **Handler:** `lambda_function.handler`
- **Method:** DELETE
- **Endpoint:** `/items/{id}`
- **Description:** Delete an item from DynamoDB

## 🔧 Technology Stack

- **Python 3.9** - Lambda runtime
- **Boto3** - AWS SDK
- **DynamoDB** - Data storage
- **API Gateway** - REST API
- **Terraform** - Infrastructure

## 📖 Learn More

- [Backend Main Guide](./SERVERLESS_APP_README.md)
- [Local Testing](./LOCAL_TESTING.md)
- [uv Integration](./UV_README.md)

**Return to:** [Documentation Index](../README.md) | [Main README](../../README.md)

