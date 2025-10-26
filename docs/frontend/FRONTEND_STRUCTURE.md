# Frontend Structure - Multi-App Organization

## Overview

The frontend is now organized into separate application folders while maintaining a unified deployment pipeline. This structure allows for better organization, code reuse, and easier maintenance.

## Directory Structure

```
frontend/
├── index.html                 # 🏠 Home Hub - Main landing page
│
├── knowledge-base/            # 📚 Personal Knowledge Base App
│   ├── README.md
│   ├── app.html              # Main knowledge base application
│   └── grafana.html          # Grafana monitoring dashboard
│
├── budget-tracker/            # 💰 Budget Tracker App
│   ├── README.md
│   └── budget.html           # Budget tracking application
│
└── shared/                    # 🎨 Shared Assets (for future use)
    └── README.md
```

## Apps

### 1. Knowledge Base App (`knowledge-base/`)

**Purpose**: Personal knowledge management system

**Files**:
- `app.html` - CRUD operations for knowledge items
- `grafana.html` - Monitoring dashboard

**Features**:
- Create, read, delete knowledge items
- RESTful API integration
- Real-time updates

**API Endpoints**:
- GET `/items` - List all items
- POST `/items` - Create new item
- DELETE `/items/{id}` - Delete item

**Lambda Functions**:
- `pkb-api-get-items`
- `pkb-api-create-item`
- `pkb-api-delete-item`

### 2. Budget Tracker App (`budget-tracker/`)

**Purpose**: Financial tracking and budget management

**Files**:
- `budget.html` - Transaction management and balance tracking

**Features**:
- Add income/expense transactions
- Real-time balance calculation
- Transaction history
- SNS email alerts

**API Endpoints**:
- GET `/balance` - Get balance and transactions
- POST `/transactions` - Add new transaction

**Lambda Functions**:
- `budget-tracker-get-balance`
- `budget-tracker-add-transaction`

## Benefits of This Structure

### ✅ Separation of Concerns
- Each app has its own folder
- Clear boundaries between applications
- Independent development and deployment

### ✅ Shared Resources
- Common navigation structure
- Unified deployment pipeline
- Same S3 bucket and CloudFront distribution

### ✅ Code Reuse
- Shared API Gateway endpoints
- Common Lambda functions where applicable
- Unified infrastructure

### ✅ Maintainability
- Easier to locate app-specific code
- Clear README files for each app
- Better organization for future additions

## Deployment

### Single Command Deployment

All apps deploy together with one command:

```bash
./scripts/deploy-frontend.sh
```

### What Gets Deployed

1. **Home Hub** (`index.html`) - Main landing page
2. **Knowledge Base App** - All files in `knowledge-base/`
3. **Budget Tracker App** - All files in `budget-tracker/`
4. **Shared Assets** - All files in `shared/`

### Deployment Flow

```
Frontend Code
    ↓
./scripts/deploy-frontend.sh
    ↓
aws s3 sync frontend/ s3://bucket/
    ↓
S3 Bucket (Static Website)
    ↓
CloudFront (if enabled) or Direct S3 Access
```

## Navigation

Apps link to each other using relative paths:

**From Home Hub** (`index.html`):
```html
<a href="knowledge-base/app.html">Personal Knowledge Base</a>
<a href="budget-tracker/budget.html">Budget Tracker</a>
```

**From App Pages**:
```html
<!-- Go back to home -->
<a href="../index.html">🏠 Home</a>

<!-- Link to other apps -->
<a href="../knowledge-base/app.html">📚 Knowledge Base</a>
```

## Adding New Apps

To add a new app:

1. **Create app folder**:
   ```bash
   mkdir frontend/my-new-app
   ```

2. **Add app files**:
   ```bash
   # Add your HTML/CSS/JS files
   touch frontend/my-new-app/main.html
   ```

3. **Update navigation** in `index.html`:
   ```html
   <a href="my-new-app/main.html" class="app-card">
     <!-- App card content -->
   </a>
   ```

4. **Deploy**:
   ```bash
   ./scripts/deploy-frontend.sh
   ```

That's it! The unified deployment will include your new app automatically.

## Lambda Functions Architecture

### Shared Lambda Resources

Both apps share the same:
- ✅ API Gateway (single REST API)
- ✅ IAM roles and policies
- ✅ DynamoDB access permissions

### App-Specific Lambda Functions

**Knowledge Base**:
- Located: `lambda-functions/`
- Functions: get-items, create-item, delete-item
- Table: `PersonalKnowledgeBase`

**Budget Tracker**:
- Located: `budget-tracker/lambda-functions/`
- Functions: add-transaction, get-balance
- Table: `BudgetTracker`

## Build Pipeline Optimization

### Single Infrastructure

- One S3 bucket for all apps
- One CloudFront distribution (optional)
- One deployment script
- Shared infrastructure costs

### Parallel Deployment

Apps deploy simultaneously:
```
Deploy Knowledge Base ──┐
                        ├─→ S3 Sync → Deploy Complete
Deploy Budget Tracker ──┘
```

### Optimized Builds

- Lambda functions build separately
- Frontend apps deploy together
- No redundant infrastructure

## Access URLs

### S3 Website Endpoint (Fast Mode)
```
http://pkb-frontend-personal-knowledge-base.s3-website-us-east-1.amazonaws.com/
http://pkb-frontend-personal-knowledge-base.s3-website-us-east-1.amazonaws.com/knowledge-base/app.html
http://pkb-frontend-personal-knowledge-base.s3-website-us-east-1.amazonaws.com/budget-tracker/budget.html
```

### CloudFront (Production Mode)
```
https://d1234567890abc.cloudfront.net/
https://d1234567890abc.cloudfront.net/knowledge-base/app.html
https://d1234567890abc.cloudfront.net/budget-tracker/budget.html
```

## Future Enhancements

### Planned Features

- [ ] Shared CSS/styles in `shared/`
- [ ] Common JavaScript utilities
- [ ] Shared icons and images
- [ ] Common components library
- [ ] App-specific build optimizations

### Migration Path

Current apps maintain backward compatibility while supporting future enhancements.
