# 🚀 Serverless Personal Knowledge Base - Backend

A complete serverless REST API using AWS Lambda, API Gateway, and DynamoDB.

## What This Is

This is the **backend/infrastructure** documentation for the Personal Knowledge Base project.  
For frontend/UI documentation, see [UI_README.md](./UI_README.md)

## Architecture

```
API Gateway (REST API)
    ↓
Lambda Functions
    ↓
DynamoDB (NoSQL Database)
```

### Components
- **3 Lambda Functions** - Get, Create, Delete items
- **DynamoDB** - Serverless NoSQL database
- **API Gateway** - REST API endpoints
- **Terraform** - Infrastructure as Code
- **IAM** - Security and permissions

## Quick Start

### Prerequisites

- AWS Account
- AWS CLI configured
- Terraform installed

### Deploy

```bash
# Initialize Terraform
cd infrastructure
terraform init

# Build Lambda functions
cd ..
./scripts/build-lambda.sh

# Deploy to AWS
cd infrastructure
terraform apply
```

### API Endpoints

Once deployed, you get:
- `GET /items` - List all items
- `POST /items` - Create a new item
- `DELETE /items/{id}` - Delete an item

## Project Structure

```
serverless_app/
├── infrastructure/          # Terraform configuration
├── lambda-functions/       # Lambda function code
│   ├── get-items/
│   ├── create-item/
│   └── delete-item/
├── kubernetes/             # K8s manifests (for k9s learning)
├── docker/                 # Docker configurations
└── scripts/                # Helper scripts
```

## Documentation

- [README.md](./README.md) - Full project overview
- [QUICKSTART.md](./QUICKSTART.md) - Deployment guide
- [PROJECT_SUMMARY.md](./PROJECT_SUMMARY.md) - Architecture details
- [AWS_FREE_TIER.md](./AWS_FREE_TIER.md) - Free tier optimization
- [K9S_LEARNING_GUIDE.md](./K9S_LEARNING_GUIDE.md) - K9s tutorial
- [START_HERE.md](./START_HERE.md) - K9s starter guide

## API Reference

### Get All Items

```bash
curl https://your-api-url.amazonaws.com/prod/items
```

Response:
```json
{
  "items": [
    {
      "id": "uuid",
      "title": "Item Title",
      "content": "Item content...",
      "type": "note",
      "created_at": "2024-01-01T00:00:00",
      "updated_at": "2024-01-01T00:00:00"
    }
  ],
  "count": 1
}
```

### Create Item

```bash
curl -X POST https://your-api-url.amazonaws.com/prod/items \
  -H "Content-Type: application/json" \
  -d '{"title":"New Item","content":"Content here","type":"note"}'
```

### Delete Item

```bash
curl -X DELETE https://your-api-url.amazonaws.com/prod/items/{id}
```

## Infrastructure

### Terraform Resources

- `main.tf` - Main infrastructure
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `frontend.tf` - S3 + CloudFront

### Deployment

```bash
terraform init
terraform plan
terraform apply
```

## Lambda Functions

### get-items
- Reads all items from DynamoDB
- Returns JSON array with count

### create-item
- Creates new item in DynamoDB
- Generates unique ID
- Returns created item

### delete-item
- Deletes item by ID
- Returns deleted item

## DynamoDB Schema

```javascript
{
  id: string (hash key),
  title: string,
  content: string,
  type: string,
  created_at: ISO8601,
  updated_at: ISO8601
}
```

## Security

- ✅ **IAM Roles** - Least privilege access
- ✅ **VPC** - Network isolation (optional)
- ✅ **Encryption** - At-rest and in-transit
- ✅ **CORS** - Cross-origin controls

## Monitoring

### CloudWatch Logs

```bash
aws logs tail /aws/lambda/pkb-api-get-items --follow
```

### Metrics

```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Invocations \
  --dimensions Name=FunctionName,Value=pkb-api-get-items \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z \
  --period 3600 \
  --statistics Sum
```

## Cost Optimization

All resources configured for **AWS Free Tier**:
- Lambda: 1M requests/month free
- API Gateway: 1M requests/month free
- DynamoDB: 25GB storage + 25 RCU/WCU free

See [AWS_FREE_TIER.md](./AWS_FREE_TIER.md) for details.

## Cleanup

```bash
cd infrastructure
terraform destroy
```

This removes all AWS resources.

## Next Steps

1. **Add Authentication** - AWS Cognito
2. **Add Search** - CloudSearch or Algolia
3. **Add Caching** - ElastiCache
4. **Add Monitoring** - CloudWatch dashboards
5. **Add CI/CD** - GitHub Actions

## Resources

- [AWS Lambda Docs](https://docs.aws.amazon.com/lambda/)
- [API Gateway Docs](https://docs.aws.amazon.com/apigateway/)
- [DynamoDB Docs](https://docs.aws.amazon.com/dynamodb/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/)

