# Frontend Structure

## Overview
The CDN frontend now serves as a multi-app hub with navigation between different learning modules.

## File Structure

```
frontend/
├── index.html          # 🏠 Homepage - Welcome and app selection
├── app.html            # 📚 Personal Knowledge Base App
├── grafana.html        # 📊 Grafana Dashboard Access
└── budget.html         # 💰 Budget Tracker App (to be created)
```

## Pages

### 1. Homepage (`index.html`)
**Purpose**: Landing page and app selector

**Features**:
- Welcome message for CI/CD & SysOps learning environment
- Grid of app cards for easy navigation
- Tech stack overview
- GitHub link

**Navigation**:
- Personal Knowledge Base → `app.html`
- Budget Tracker → `budget.html`
- Grafana Dashboard → `grafana.html`

### 2. Personal Knowledge Base (`app.html`)
**Purpose**: Main application for creating/managing knowledge items

**Features**:
- Create, view, and delete knowledge items
- RESTful API integration with Lambda functions
- Modern, responsive UI

**API Endpoints**:
- GET `/items` - List all items
- POST `/items` - Create new item
- DELETE `/items/{id}` - Delete an item

### 3. Grafana Dashboard (`grafana.html`)
**Purpose**: Embedded Grafana monitoring interface

**Features**:
- Full-screen Grafana dashboard
- Auto-detection of Grafana availability
- Helpful error messages with setup instructions
- Port-forward helper instructions

**Usage**:
Requires running: `kubectl port-forward -n grafana svc/grafana-service 3000:3000`

### 4. Budget Tracker (`budget.html`) - TODO
**Purpose**: Financial tracking and budget management

**Features** (to be implemented):
- Add transactions
- View balance
- Set spending alerts
- Transaction history

## Deployment

### Manual Deployment
```bash
aws s3 sync frontend/ s3://pkb-frontend-personal-knowledge-base/
aws cloudfront create-invalidation --distribution-id <dist-id> --paths "/*"
```

### CI/CD Deployment
Automatic via GitHub Actions after Terraform apply.

## CDN URLs

- Homepage: `https://d3fkfd08m7hmoz.cloudfront.net/`
- Knowledge Base: `https://d3fkfd08m7hmoz.cloudfront.net/app.html`
- Grafana: `https://d3fkfd08m7hmoz.cloudfront.net/grafana.html`
- Budget Tracker: `https://d3fkfd08m7hmoz.cloudfront.net/budget.html`

## Navigation Flow

```
index.html (Homepage)
  ├── → app.html (Knowledge Base)
  ├── → budget.html (Budget Tracker)
  └── → grafana.html (Monitoring)

Each page has back button to return to homepage
```

## Styling

All pages share:
- Consistent color scheme (gradient purple)
- Responsive design (mobile-friendly)
- Modern UI with cards and hover effects
- Easy navigation between apps

## Future Enhancements

1. **Budget Tracker UI** - Full implementation
2. **Dark mode** - Toggle for light/dark themes
3. **User authentication** - IAM/Cognito integration
4. **Dashboard hub** - Overview page with links
5. **Documentation** - In-app guides
6. **API testing** - Interactive API explorer

## Troubleshooting

### "Access Denied" on CDN
1. Wait for CloudFront deployment (15-20 min)
2. Check S3 bucket has files:
   ```bash
   aws s3 ls s3://pkb-frontend-personal-knowledge-base/
   ```
3. Invalidate cache manually:
   ```bash
   aws cloudfront create-invalidation --distribution-id <id> --paths "/*"
   ```

### App doesn't load
1. Check browser console for errors
2. Verify API Gateway URL in app
3. Check CORS settings in API Gateway

### Grafana shows "Not Accessible"
1. Run port-forward command
2. Ensure Grafana pod is running
3. Check kubectl access to cluster

