# Budget Tracker Setup Guide

This guide walks you through setting up the Personal Budget Tracker module in your serverless application.

## 🎯 What You'll Build

A serverless budget tracking application that:
- Tracks income and expenses in DynamoDB
- Sends SNS email alerts when balance goes negative
- Provides REST API endpoints
- Integrates with existing UI

## 📋 Prerequisites

- ✅ AWS Account with appropriate permissions
- ✅ Terraform installed
- ✅ Python 3.9+ for Lambda functions
- ✅ Email address for SNS subscription

## 🚀 Step-by-Step Setup

### Step 1: Configure Variables

Edit `infrastructure/terraform.tfvars`:

```hcl
aws_region     = "us-east-1"
environment    = "dev"
project_name   = "budget-tracker"
alert_email    = "your-email@example.com"  # ⚠️ Change this!
```

### Step 2: Build Lambda Functions

```bash
cd budget-tracker/lambda-functions

# Build add-transaction
cd add-transaction
pip install -r requirements.txt -t .
zip -r function.zip .
cd ..

# Build get-balance
cd get-balance
pip install -r requirements.txt -t .
zip -r function.zip .
cd ..

# Build send-alert
cd send-alert
pip install -r requirements.txt -t .
zip -r function.zip .
cd ../..
```

### Step 3: Deploy Infrastructure

```bash
cd infrastructure
terraform init
terraform plan
terraform apply
```

### Step 4: Confirm SNS Subscription

1. Check your email inbox
2. Look for email from `aws-sns-no-reply@amazon.com`
3. Click "Confirm subscription"

### Step 5: Test the API

```bash
# Get API URL
terraform output

# Add a transaction
curl -X POST https://your-api-url/budget/transaction \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 100,
    "category": "income",
    "description": "Salary",
    "type": "income"
  }'

# Check balance
curl https://your-api-url/budget/balance
```

## 🧪 Testing Scenarios

### Scenario 1: Positive Balance

```bash
# Add income
curl -X POST .../budget/transaction \
  -d '{"amount": 1000, "type": "income", "category": "salary"}'

# Add expense
curl -X POST .../budget/transaction \
  -d '{"amount": 50, "type": "expense", "category": "groceries"}'
```

Result: Balance = $950, no alert

### Scenario 2: Negative Balance (Trigger Alert)

```bash
# Add large expense
curl -X POST .../budget/transaction \
  -d '{"amount": 2000, "type": "expense", "category": "rent"}'
```

Result: Balance = -$1000, **SNS alert sent** 📧

## 📊 Monitoring

### CloudWatch Logs

```bash
# View Lambda logs
aws logs tail /aws/lambda/budget-tracker-add-transaction --follow

aws logs tail /aws/lambda/budget-tracker-get-balance --follow
```

### DynamoDB Console

```bash
# View transactions
aws dynamodb scan \
  --table-name BudgetTracker \
  --region us-east-1
```

## 🐛 Troubleshooting

### SNS Alert Not Received

1. Check email spam folder
2. Verify SNS subscription confirmation
3. Check CloudWatch logs for errors
4. Verify Lambda permissions for SNS

### Balance Calculation Wrong

- Check transaction types ("income" vs "expense")
- Verify DynamoDB scan is working
- Check for any filtering logic

### API Gateway Errors

- Verify CORS configuration
- Check Lambda permissions
- Review API Gateway logs

## 📈 Next Steps

1. **Add More Categories** - Expand transaction categories
2. **Monthly Reports** - Generate monthly summaries
3. **Recurring Transactions** - Schedule automatic transactions
4. **Multi-Currency** - Support different currencies

## 🔗 Integration

### With Existing UI

Add budget tracker to sidebar:
- Use same CloudFront distribution
- Add tab navigation
- Share API Gateway

### With Knowledge Base

Both modules in one app:
- Unified dashboard
- Single authentication
- Shared resources

---

**Return to:** [Budget Tracker README](./README.md)

