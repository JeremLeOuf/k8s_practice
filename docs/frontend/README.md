# 🌐 Frontend Documentation

This folder contains documentation for the static frontend (S3 + CloudFront).

## 📄 Files

### 📘 Main Documentation
- **[UI_README.md](./UI_README.md)** - Complete frontend guide
  - S3 bucket setup
  - CloudFront CDN configuration
  - UI deployment
  - CORS configuration

## 🎯 Quick Start

### Deploy Frontend

```bash
# Deploy to S3 and CloudFront
./scripts/deploy-frontend.sh

# Get CloudFront URL
cd infrastructure
terraform output frontend_cdn_url
```

### Access Frontend

Open the CloudFront URL in your browser:
```bash
terraform output -raw frontend_url
# Output: d2wgb3megns31b.cloudfront.net
```

Then visit: `https://d2wgb3megns31b.cloudfront.net`

## 🏗️ Architecture

```
┌──────────────────────────┐
│   CloudFront CDN         │
│   https://xxx.net        │
│   - Global distribution  │
│   - HTTPS termination    │
│   - Caching              │
└─────────────┬────────────┘
              │
              ↓
┌──────────────────────────┐
│   S3 Bucket              │
│   - Static website       │
│   - index.html           │
│   - Origin for CloudFront│
└──────────────────────────┘
```

## 📁 Frontend Files

```
frontend/
├── index.html          # Main HTML file
└── assets/            # CSS and JavaScript
```

### Features
- **Modern UI** - Clean, responsive design
- **API Integration** - Connects to backend API
- **CRUD Operations** - Create, read, delete items
- **Real-time Updates** - Live data from DynamoDB

## 🔧 Technology Stack

- **HTML/CSS/JavaScript** - Frontend code
- **S3** - Static website hosting
- **CloudFront** - CDN and caching
- **Terraform** - Infrastructure automation

## 📖 Learn More

- [Frontend Main Guide](./UI_README.md)
- [CDN Troubleshooting](./CDN_TROUBLESHOOTING.md) - Fix "Access Denied" errors

### Troubleshooting

**Getting "Access Denied" when accessing CDN?**

```bash
# Quick diagnosis
./scripts/check-cdn-status.sh

# Or manually deploy
./scripts/deploy-frontend.sh
```

See [CDN_TROUBLESHOOTING.md](./CDN_TROUBLESHOOTING.md) for detailed troubleshooting steps.

**Return to:** [Documentation Index](../README.md) | [Main README](../../README.md)

