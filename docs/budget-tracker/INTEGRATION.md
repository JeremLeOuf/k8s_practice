# Integrating Budget Tracker into Main Project

This guide explains how to integrate the Budget Tracker module into your existing serverless application.

## 🎯 Integration Architecture

```
Current Project:
├── Personal Knowledge Base (existing)
│   ├── GET /items
│   ├── POST /items
│   └── DELETE /items/{id}
│
└── Budget Tracker (new)
    ├── POST /budget/transaction
    ├── GET /budget/balance
    └── SNS Alerts → Email
```

## 📋 Integration Steps

### Step 1: Update API Gateway

Add new resources to `infrastructure/main.tf`:

```hcl
# Budget Tracker API Resources
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

# Methods and integrations...
```

### Step 2: Update Frontend UI

Add tabs/sidebar navigation in `frontend/index.html`:

```html
<!-- Sidebar Navigation -->
<nav class="sidebar">
  <a href="#" class="nav-item active" data-tab="knowledge-base">
    📚 Knowledge Base
  </a>
  <a href="#" class="nav-item" data-tab="budget-tracker">
    💰 Budget Tracker
  </a>
</nav>

<!-- Tab Content -->
<div id="knowledge-base" class="tab-content active">
  <!-- Existing KB UI -->
</div>

<div id="budget-tracker" class="tab-content">
  <!-- Budget Tracker UI -->
  <h2>Budget Tracker</h2>
  <!-- Balance display, transaction form, etc. -->
</div>
```

### Step 3: Unified Deployment

Update deployment scripts to handle both modules:

```bash
#!/bin/bash
# scripts/deploy-all.sh

echo "🚀 Deploying all modules..."

# Deploy Knowledge Base
./scripts/build-lambda.sh
./scripts/deploy-frontend.sh

# Deploy Budget Tracker
cd budget-tracker
./scripts/build-lambda.sh
cd ..

# Apply infrastructure
cd infrastructure
terraform apply
```

## 🎨 UI Integration Patterns

### Pattern 1: Tabs (Simple)

```html
<div class="tabs">
  <button onclick="showTab('knowledge-base')">Knowledge Base</button>
  <button onclick="showTab('budget')">Budget</button>
</div>

<div id="knowledge-base" class="tab">...</div>
<div id="budget" class="tab">...</div>
```

### Pattern 2: Sidebar (Navigation)

```html
<aside class="sidebar">
  <ul>
    <li><a href="#knowledge-base">📚 Knowledge Base</a></li>
    <li><a href="#budget">💰 Budget Tracker</a></li>
  </ul>
</aside>

<main>
  <section id="knowledge-base">...</section>
  <section id="budget">...</section>
</main>
```

### Pattern 3: Single Page App (SPA)

```javascript
// app.js
const API_BASE = 'https://your-api-gateway-url';

class App {
  constructor() {
    this.currentModule = 'knowledge-base';
    this.init();
  }

  init() {
    this.renderNavigation();
    this.loadModule(this.currentModule);
  }

  loadModule(module) {
    if (module === 'knowledge-base') {
      this.loadKnowledgeBase();
    } else if (module === 'budget') {
      this.loadBudgetTracker();
    }
  }
}
```

## 🔧 Shared Resources

### Use Same API Gateway

Both modules use one API Gateway:

```
API Gateway Root
├── /items (Knowledge Base)
├── /items/{id}
└── /budget/* (Budget Tracker)
```

### Use Same CloudFront

Both modules served from same S3 bucket:

```
frontend/
├── index.html (Unified UI)
├── knowledge-base.js
└── budget-tracker.js
```

### Shared IAM Roles

Consolidate Lambda execution role:

```hcl
resource "aws_iam_role_policy" "unified_lambda" {
  # Combined permissions for both modules
}
```

## 📊 Database Design

### Knowledge Base (Existing)

```json
{
  "id": "item-123",
  "title": "Article title",
  "content": "Content...",
  "created_at": "2024-01-01T00:00:00Z"
}
```

### Budget Tracker (New)

```json
{
  "id": "trans-456",
  "amount": 50.00,
  "category": "groceries",
  "description": "Weekly shopping",
  "type": "expense",
  "timestamp": "2024-01-15T10:00:00Z"
}
```

## 🚀 Deployment Strategy

### Option A: Separate Stacks

- Deploy Knowledge Base first
- Deploy Budget Tracker separately
- Each has own Terraform state

### Option B: Unified Stack (Recommended)

- One Terraform state
- All resources in one apply
- Single S3 bucket for frontend
- Shared API Gateway

```bash
# Deploy everything
terraform apply
```

## 📝 API Endpoints Summary

### Knowledge Base
- `GET /items` - List all items
- `POST /items` - Create item
- `DELETE /items/{id}` - Delete item

### Budget Tracker
- `POST /budget/transaction` - Add transaction
- `GET /budget/balance` - Get balance
- `POST /budget/alert` - Send alert

## 🎯 Benefits of Integration

1. **Single Deployment** - Deploy once, get both modules
2. **Shared Infrastructure** - One API Gateway, one CloudFront
3. **Unified UI** - Single interface for all features
4. **Cost Effective** - Shared resources = lower costs
5. **Easy Maintenance** - One codebase, one workflow

## 🔄 Migration Path

### Phase 1: Setup Budget Tracker Module
- Create Lambda functions
- Add DynamoDB table
- Configure SNS alerts

### Phase 2: Update Infrastructure
- Add API Gateway resources
- Configure new endpoints
- Update IAM permissions

### Phase 3: Update Frontend
- Add navigation tabs
- Create budget UI
- Test integration

### Phase 4: Deploy
- Run terraform apply
- Deploy frontend
- Test end-to-end

## 🐛 Common Issues

### CORS Errors
- Add budget endpoints to CORS configuration
- Update API Gateway CORS settings

### Lambda Permissions
- Grant access to both DynamoDB tables
- Add SNS publish permissions

### Frontend Routing
- Implement client-side routing
- Handle hash/query parameters

## 📖 Next Steps

1. Review [Setup Guide](./BUDGET_TRACKER_SETUP.md)
2. Follow [Integration Steps](#integration-steps)
3. Test end-to-end
4. Deploy to production

---

**Return to:** [Budget Tracker README](./README.md)

