# 💰 Budget Tracker Implementation

## Overview

The Budget Tracker is now fully implemented as part of your serverless learning project!

## What's Been Added

### 1. ✅ Lambda Functions

**Location**: `budget-tracker/lambda-functions/`

- **`add-transaction/`** - Adds income or expense transactions
- **`get-balance/`** - Retrieves current balance and transaction history
- **`send-alert/`** - Sends SNS notifications for low balance

### 2. ✅ Terraform Infrastructure

**File**: `infrastructure/budget-tracker.tf`

**Resources**:
- DynamoDB table (`BudgetTracker`)
- SNS topic for alerts (`budget-alerts`)
- IAM roles and policies
- API Gateway endpoints
- Lambda functions with permissions

**API Endpoints**:
- `POST /transactions` - Add a new transaction
- `GET /balance` - Get balance and recent transactions
- CORS enabled for both endpoints

### 3. ✅ Frontend UI

**File**: `frontend/budget.html`

**Features**:
- 💵 Real-time balance display
- ➕ Add income/expense transactions
- 📋 View transaction history (last 20)
- 📊 Color-coded transactions (green/red)
- 🏷️ Category selection
- 💼 Description support

### 4. ✅ Integration

**Works with**:
- Lambda functions (serverless)
- DynamoDB (NoSQL database)
- SNS (alerts)
- API Gateway (REST API)
- Same frontend as Knowledge Base

## Deployment

### Build Lambda Functions

```bash
# The build script already includes budget tracker functions
./scripts/build-lambda.sh
```

### Deploy Infrastructure

```bash
cd infrastructure
terraform apply -auto-approve
```

### Update Frontend

```bash
# Frontend will be deployed automatically via CI/CD
# Or manually:
aws s3 sync frontend/ s3://pkb-frontend-personal-knowledge-base/ --delete
```

## API Endpoints

### Add Transaction

```bash
POST https://YOUR-API-GATEWAY/prod/transactions

{
  "amount": 50.00,
  "type": "expense",
  "category": "food",
  "description": "Grocery shopping"
}
```

### Get Balance

```bash
GET https://YOUR-API-GATEWAY/prod/balance

Response:
{
  "balance": 1250.50,
  "transactions": [...],
  "total_count": 25
}
```

## Usage

### Accessing the UI

1. **From Homepage** (`index.html`)
   - Click "Budget Tracker" card
   - Or navigate to `budget.html`

2. **Direct URL**
   ```
   https://YOUR-CDN/budget.html
   ```

### Adding a Transaction

1. Select type (Income/Expense)
2. Enter amount
3. Choose category
4. Add description (optional)
5. Click "Add Transaction"

### Viewing Balance

The balance automatically updates after each transaction.

- **Green** = Positive balance
- **Red** = Negative balance

### Recent Transactions

Shows last 20 transactions with:
- Type (Income/Expense)
- Category
- Description
- Amount
- Timestamp

## Features

### 1. Real-time Balance Calculation

Calculates balance from all transactions:
- Income adds to balance
- Expenses subtract from balance

### 2. Transaction Categories

**Expenses**:
- 🍽️ Food
- 🚗 Transport
- 🛍️ Shopping
- 📄 Bills
- 🎉 Entertainment
- 📦 Other

**Income**:
- 💼 Salary
- 💻 Freelance
- 📦 Other

### 3. SNS Alerts

Automatically sends email alerts when:
- Balance goes negative
- You exceed your budget threshold

**To set up alerts**:
1. Go to AWS SNS Console
2. Find `budget-alerts` topic
3. Confirm your email subscription
4. Start receiving alerts!

## Architecture

```
Frontend (budget.html)
    ↓ HTTPS
API Gateway
    ↓
Lambda Functions
    ↓
DynamoDB (BudgetTracker)
    ↓
SNS (Alerts) → Email
```

## Testing

### Test Add Transaction

```bash
curl -X POST https://YOUR-API/prod/transactions \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 100,
    "type": "income",
    "category": "salary",
    "description": "Paycheck"
  }'
```

### Test Get Balance

```bash
curl https://YOUR-API/prod/balance
```

## Troubleshooting

### No Transactions Showing

**Check**:
1. Lambda functions deployed?
2. DynamoDB table exists?
3. API Gateway endpoints configured?

**Verify**:
```bash
aws dynamodb scan --table-name BudgetTracker
```

### Balance Not Updating

**Check**:
1. Transaction added successfully?
2. Lambda function invoked?
3. API Gateway returning data?

### SNS Alerts Not Working

**Check**:
1. Email subscribed to topic?
2. CloudWatch logs for errors
3. IAM permissions for SNS

## Next Steps

### Enhancements

1. **Monthly Reports** - Add summary charts
2. **Budget Limits** - Set spending limits
3. **Export Data** - Download CSV
4. **Categories** - Add custom categories
5. **Recurring Transactions** - Auto-add bills

### Integration

1. **CloudWatch** - Add cost metrics
2. **Grafana** - Budget tracking dashboard
3. **Email Reports** - Weekly summaries
4. **Mobile App** - React Native version

## Resources

- [Budget Tracker Setup](BUDGET_TRACKER_SETUP.md)
- [Integration Guide](INTEGRATION.md)
- [Lambda Functions](../serverless/README.md)

Enjoy tracking your budget! 💰

