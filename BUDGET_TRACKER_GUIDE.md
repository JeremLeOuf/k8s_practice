# 💰 Budget Tracker - Implementation Guide

## 📦 What's Been Added

### New Files & Folders

```
serverless_app/
├── budget-tracker/                    # NEW MODULE
│   ├── lambda-functions/
│   │   ├── add-transaction/
│   │   │   ├── lambda_function.py
│   │   │   └── requirements.txt
│   │   ├── get-balance/
│   │   │   ├── lambda_function.py
│   │   │   └── requirements.txt
│   │   └── send-alert/
│   │       ├── lambda_function.py
│   │       └── requirements.txt
│
├── infrastructure/
│   └── budget-tracker.tf              # NEW TERRAFORM
│
└── docs/
    └── budget-tracker/                # NEW DOCS
        ├── README.md
        ├── BUDGET_TRACKER_SETUP.md
        └── INTEGRATION.md
```

## 🚀 Quick Start

### Step 1: Build Lambda Functions

```bash
cd budget-tracker/lambda-functions

# Install dependencies and package
for func in add-transaction get-balance send-alert; do
  cd $func
  pip install -r requirements.txt -t .
  zip -r function.zip .
  cd ..
done
```

### Step 2: Update Terraform Variables

Edit `infrastructure/terraform.tfvars`:

```hcl
aws_region   = "us-east-1"
environment  = "dev"
project_name = "personal-knowledge-base"
alert_email  = "your-email@example.com"  # ⚠️ CHANGE THIS
```

### Step 3: Deploy

```bash
cd infrastructure
terraform apply
```

### Step 4: Confirm SNS Subscription

Check your email for AWS SNS confirmation link.

## 🎨 UI Integration Options

### Option A: Simple Tabs (Recommended)

Add this to your `frontend/index.html`:

```html
<!-- Add before main content -->
<div class="app-tabs">
  <button class="tab-btn active" data-tab="knowledge-base">📚 Knowledge Base</button>
  <button class="tab-btn" data-tab="budget">💰 Budget Tracker</button>
</div>

<!-- Knowledge Base (existing) -->
<div id="knowledge-base" class="tab-content active">
  <!-- Your existing KB UI -->
</div>

<!-- Budget Tracker (new) -->
<div id="budget" class="tab-content">
  <h2>Budget Tracker</h2>
  <div id="balance">Loading...</div>
  <form id="add-transaction">
    <input type="number" name="amount" placeholder="Amount">
    <input type="text" name="category" placeholder="Category">
    <select name="type">
      <option value="expense">Expense</option>
      <option value="income">Income</option>
    </select>
    <button type="submit">Add Transaction</button>
  </form>
  <div id="transactions">Loading...</div>
</div>

<script>
// Tab switching
document.querySelectorAll('.tab-btn').forEach(btn => {
  btn.addEventListener('click', () => {
    document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
    document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
    btn.classList.add('active');
    document.getElementById(btn.dataset.tab).classList.add('active');
  });
});

// Budget tracker API calls
const API_URL = 'YOUR-API-GATEWAY-URL';

// Load balance
fetch(`${API_URL}/budget/balance`)
  .then(res => res.json())
  .then(data => {
    document.getElementById('balance').textContent = `Balance: $${data.balance}`;
  });

// Add transaction
document.getElementById('add-transaction').addEventListener('submit', (e) => {
  e.preventDefault();
  const formData = new FormData(e.target);
  fetch(`${API_URL}/budget/transaction`, {
    method: 'POST',
    body: JSON.stringify({
      amount: parseFloat(formData.get('amount')),
      category: formData.get('category'),
      type: formData.get('type')
    })
  }).then(() => location.reload());
});
</script>
```

### Option B: Sidebar Navigation

```html
<style>
.sidebar {
  width: 200px;
  float: left;
  border-right: 1px solid #ccc;
}

.content {
  margin-left: 200px;
}
</style>

<div class="sidebar">
  <nav>
    <a href="#" onclick="loadModule('kb')">📚 Knowledge Base</a>
    <a href="#" onclick="loadModule('budget')">💰 Budget</a>
  </nav>
</div>

<div class="content" id="app-content">
  <!-- Dynamic content loads here -->
</div>
```

## 📡 API Endpoints to Add

You'll need to add these to API Gateway in `infrastructure/budget-tracker.tf` or `main.tf`:

```hcl
# Add to infrastructure/main.tf or create separate file

resource "aws_api_gateway_resource" "budget" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "budget"
}

resource "aws_api_gateway_resource" "transaction" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.budget.id
  path_part   = "transaction"
}

# Add GET method for balance
# Add POST method for transaction
# Add integrations with Lambda functions
```

## 🎯 Learning Outcomes

By implementing this, you'll learn:

1. **SNS Alerts** - Email notifications in cloud
2. **Multi-Module Architecture** - Extending existing app
3. **DynamoDB Design** - Transaction modeling
4. **API Gateway Extensions** - Adding new endpoints
5. **UI Integration** - Tab/navigation patterns
6. **State Management** - Balance calculations

## 📊 Architecture Comparison

### Before (Single Module)
```
Frontend → API Gateway → Lambda → DynamoDB (KB only)
```

### After (Multi-Module)
```
Frontend → API Gateway → Lambda (Multi) → DynamoDB (KB + Budget)
                              ↓
                         SNS → Email Alerts
```

## 🔧 Implementation Checklist

- [ ] Build Lambda functions
- [ ] Deploy Terraform configuration
- [ ] Confirm SNS subscription
- [ ] Add API Gateway endpoints
- [ ] Update frontend with tabs
- [ ] Test add transaction
- [ ] Test get balance
- [ ] Test alerts (spend over budget)
- [ ] Update CI/CD pipeline
- [ ] Document in README

## 📖 Next Steps

1. Follow [Setup Guide](./docs/budget-tracker/BUDGET_TRACKER_SETUP.md)
2. Complete [Integration Guide](./docs/budget-tracker/INTEGRATION.md)
3. Test locally
4. Deploy to AWS
5. Update UI with tabs

## 💡 Enhancement Ideas

Once working, you could add:
- 📊 **Charts** - Visualize spending trends
- 📅 **Calendar View** - Daily/weekly/monthly views
- 🏷️ **Recurring Transactions** - Auto-add monthly bills
- 📈 **Reports** - Export CSV/PDF reports
- 🔔 **Smart Alerts** - Category-based thresholds

---

**Need help?** Check [Budget Tracker Setup](./docs/budget-tracker/BUDGET_TRACKER_SETUP.md)

