# 🚀 Quick Start Guide

Get your Personal Knowledge Base API running in 10 minutes!

## Prerequisites Checklist

Install these tools if you don't have them:

- [ ] **AWS CLI** - `aws --version` or install from [aws.amazon.com/cli](https://aws.amazon.com/cli/)
- [ ] **Terraform** - `terraform --version` or install from [terraform.io](https://www.terraform.io/downloads)
- [ ] **Python 3.9+** - `python3 --version`
- [ ] **Docker** (optional) - `docker --version` or install from [docker.com](https://www.docker.com/)
- [ ] **kubectl** (optional) - `kubectl version` or install from [kubernetes.io](https://kubernetes.io/docs/tasks/tools/)

## 🎯 5-Minute Quick Start

### Step 1: Configure AWS (2 min)

```bash
# Configure your AWS credentials
aws configure
# Enter: Access Key, Secret Key, Region (e.g., us-east-1), Output format (json)

# Test the connection
aws sts get-caller-identity
```

### Step 2: Build Lambda Functions (1 min)

```bash
# Package Lambda functions
./scripts/build-lambda.sh
```

### Step 3: Deploy with Terraform (2 min)

```bash
cd infrastructure

# Initialize Terraform
terraform init

# Review what will be created
terraform plan

# Deploy everything
terraform apply
# Type 'yes' when prompted
```

### Step 4: Get Your API URL

```bash
# Get the API Gateway URL
terraform output api_gateway_url

# Copy the URL (it will look like: https://xxxxx.execute-api.us-east-1.amazonaws.com/prod/items)
```

### Step 5: Test Your API

```bash
# Test getting items (should return empty array initially)
curl https://your-api-url.amazonaws.com/prod/items

# Test creating an item
curl -X POST https://your-api-url.amazonaws.com/prod/items \
  -H "Content-Type: application/json" \
  -d '{"title":"My First Note","content":"This is working!","type":"note"}'

# Test getting items again
curl https://your-api-url.amazonaws.com/prod/items
```

## 📱 Using the Frontend

1. Open `frontend/index.html` in your browser
2. Paste your API Gateway URL in the configuration section
3. Click "Save URL"
4. Create and manage your items!

## 🐳 Local Testing with Docker (Optional)

```bash
cd docker
docker-compose up

# Test locally on http://localhost:9001 (get-items)
curl http://localhost:9001

# Test create-item on http://localhost:9002
curl -X POST http://localhost:9002
```

## ☸️ Testing with Kubernetes (Optional)

```bash
# Start minikube or kind
minikube start
# OR
kind create cluster

# Build and load Docker images
# (Modify kubernetes manifests to use local images first)

# Deploy to Kubernetes
kubectl apply -f kubernetes/

# Check status
kubectl get pods
kubectl get services
```

## 🔧 Common Commands

### View Your Resources

```bash
# View DynamoDB table
aws dynamodb list-tables

# List Lambda functions
aws lambda list-functions

# View API Gateway
aws apigateway get-rest-apis
```

### Update Lambda Code

```bash
# After making changes to Lambda functions
./scripts/build-lambda.sh

# Update individual function
cd lambda-functions/get-items
zip -r function.zip .
aws lambda update-function-code \
  --function-name pkb-api-get-items \
  --zip-file fileb://function.zip
```

### View Logs

```bash
# View Lambda logs
aws logs tail /aws/lambda/pkb-api-get-items --follow

# View CloudWatch metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Invocations \
  --dimensions Name=FunctionName,Value=pkb-api-get-items \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z \
  --period 3600 \
  --statistics Sum
```

### Clean Up

```bash
# Destroy all infrastructure
cd infrastructure
terraform destroy
# Type 'yes' to confirm

# This will delete:
# - API Gateway
# - Lambda functions
# - DynamoDB table
# - IAM roles
```

## 🚨 Troubleshooting

### "Access Denied" Error
- Check your AWS credentials: `aws sts get-caller-identity`
- Ensure your IAM user has necessary permissions

### "Function package not found"
- Run `./scripts/build-lambda.sh` first

### "Table already exists"
- Either delete the existing table or change the name in `main.tf`

### API Gateway "Internal Server Error"
- Check CloudWatch logs: `aws logs tail /aws/lambda/pkb-api-get-items`
- Verify DynamoDB table exists

## 📚 Next Steps

1. **Add Authentication** - Integrate AWS Cognito
2. **Add More Endpoints** - Update, search, filter
3. **Add Monitoring** - CloudWatch dashboards and alerts
4. **Add CI/CD** - GitHub Actions for automated deployment
5. **Add Infrastructure** - S3 for file storage, SNS for notifications

## 💡 Tips

- Use `terraform fmt` to format your Terraform files
- Use `terraform validate` to check for errors
- Keep your `.gitignore` updated to exclude sensitive files
- Tag your resources appropriately for cost tracking

## 🆘 Need Help?

- AWS Docs: https://docs.aws.amazon.com/
- Terraform Docs: https://www.terraform.io/docs
- Check the main README.md for more details

