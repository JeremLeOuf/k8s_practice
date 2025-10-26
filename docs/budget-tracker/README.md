# 💰 Budget Tracker - Personal Finance Module

Learn to build a serverless budget tracking application with DynamoDB and SNS alerts.

## 📋 Features

- ✅ **Add Transactions** - Track income and expenses
- ✅ **View Balance** - Real-time balance calculation
- ✅ **SNS Alerts** - Email notifications when balance is low
- ✅ **DynamoDB** - Persistent storage for transactions
- ✅ **REST API** - HTTP endpoints for all operations

## 🏗️ Architecture

```
Frontend → API Gateway → Lambda Functions
                              ↓
                       DynamoDB (Transactions)
                              ↓
                       SNS (Alerts) → Email
```

## 📁 Structure

```
budget-tracker/
├── lambda-functions/
│   ├── add-transaction/     # Add income/expense
│   ├── get-balance/         # Get balance and transactions
│   └── send-alert/          # Send SNS alerts
└── infrastructure/
    └── budget-tracker.tf    # Terraform configuration
```

## 🚀 Quick Start

### 1. Deploy Infrastructure

```bash
# Build Lambda functions
cd budget-tracker/lambda-functions
for func in add-transaction get-balance; do
  cd $func
  pip install -r requirements.txt -t .
  zip -r function.zip .
  cd ..
done

# Deploy with Terraform
cd infrastructure
terraform apply
```

### 2. Configure SNS Subscription

After deployment, check your email for SNS subscription confirmation.

### 3. Use the Budget Tracker

Access via the UI sidebar or API endpoints directly.

## 📡 API Endpoints

### Add Transaction
```bash
POST /budget/transaction
Content-Type: application/json

{
  "amount": 50.00,
  "category": "groceries",
  "description": "Weekly groceries",
  "type": "expense"  # or "income"
}
```

### Get Balance
```bash
GET /budget/balance

Response:
{
  "balance": 1250.50,
  "transactions": [...],
  "total_count": 42
}
```

## 🎯 Learning Objectives

- **DynamoDB**: NoSQL database operations
- **SNS**: Email notifications and alerts
- **Lambda Triggers**: Automate alert sending
- **Budget Logic**: Income vs expense tracking

## 💡 Use Cases

1. **Personal Budgeting** - Track spending
2. **Subscription Monitoring** - Alert on low funds
3. **Expense Categorization** - Organize by category
4. **Balance Notifications** - Get alerts automatically

## 🔧 Technology Stack

- **DynamoDB** - Transaction storage
- **SNS** - Email alerts
- **Lambda** - Serverless compute
- **API Gateway** - REST API
- **Python** - Lambda runtime

## 📖 Documentation

- [Setup Guide](./BUDGET_TRACKER_SETUP.md)
- [API Documentation](./API.md)
- [Integration Guide](./INTEGRATION.md)

## 🎓 Learning Path

1. **Week 1**: Understand DynamoDB table design
2. **Week 2**: Implement transaction logic
3. **Week 3**: Set up SNS alerts
4. **Week 4**: Integrate with frontend

---

**Return to:** [Documentation Index](../README.md) | [Main README](../../README.md)

