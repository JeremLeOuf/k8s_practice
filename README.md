# 📚 Personal Knowledge Base - Serverless Learning Project

A comprehensive serverless application project designed for learning AWS, Terraform, Kubernetes (k9s), and Grafana monitoring.

## 🎯 Learning Paths

This project is organized by learning topic. Choose your path:

### 🚀 [Serverless Backend](./docs/serverless/)
- **AWS Lambda** - Serverless functions
- **API Gateway** - REST API
- **DynamoDB** - NoSQL database
- **Terraform IaC** - Infrastructure as Code

**Start Here:** [`docs/serverless/SERVERLESS_APP_README.md`](./docs/serverless/SERVERLESS_APP_README.md)

### 🌐 [Static Frontend](./docs/frontend/)
- **S3** - Static website hosting
- **CloudFront** - CDN and caching
- **Modern UI** - HTML/CSS/JavaScript

**Start Here:** [`docs/frontend/UI_README.md`](./docs/frontend/UI_README.md)

### ☸️ [Kubernetes & k9s](./docs/kubernetes/)
- **Minikube** - Local Kubernetes cluster
- **k9s** - Terminal UI for Kubernetes
- **Container Orchestration** - Deploy and manage

**Start Here:** [`docs/kubernetes/START_HERE.md`](./docs/kubernetes/START_HERE.md)

### 📊 [Grafana Monitoring](./docs/grafana/)
- **Grafana** - Visualization platform
- **CloudWatch** - AWS metrics
- **Dashboards** - Monitor Lambda functions

**Start Here:** [`docs/grafana/GRAFANA_QUICKSTART.md`](./docs/grafana/GRAFANA_QUICKSTART.md)

### 🔧 [Terraform & CI/CD](./docs/terraform/)
- **Infrastructure as Code** - Manage AWS resources
- **GitHub Actions** - Automated deployments
- **Best Practices** - Production-ready patterns

**Start Here:** [`docs/terraform/CI_CD_SETUP.md`](./docs/terraform/CI_CD_SETUP.md)

## 📁 Project Structure

```
serverless_app/
├── README.md                       # This file - navigation hub
│
├── 📂 Code & Infrastructure
│   ├── infrastructure/            # Terraform configuration
│   ├── lambda-functions/          # Lambda function code
│   ├── frontend/                  # Static website files
│   ├── docker/                    # Docker configurations
│   └── kubernetes/                # K8s manifests
│
├── 📂 Scripts
│   └── scripts/                   # Automation scripts
│
└── 📂 Documentation
    └── docs/
        ├── serverless/            # Backend/API docs
        ├── frontend/              # Frontend docs
        ├── kubernetes/            # k9s learning docs
        ├── grafana/               # Monitoring docs
        ├── terraform/             # IaC & CI/CD docs
        └── aws/                   # AWS-specific docs
```

## 🚀 Quick Start

### Deploy Everything (One Command)

```bash
# Deploy entire application
./deploy.sh
```

This deploys: Backend (Lambda, API Gateway, DynamoDB) + Frontend (S3) + Budget Tracker + Grafana

### Manual Deployment (Step by Step)

#### 1. Deploy Backend (API)

```bash
# Build Lambda functions
./scripts/build-lambda.sh

# Deploy infrastructure
cd infrastructure
terraform apply
```

**Learn More:** [`docs/serverless/SERVERLESS_APP_README.md`](./docs/serverless/SERVERLESS_APP_README.md)

### 2. Deploy Frontend (UI)

```bash
# Fast deployment (S3 only, ~1 minute) - Default
./scripts/deploy-frontend.sh

# Or enable CloudFront for production (takes 10-15 minutes)
cd infrastructure
terraform apply -var="enable_cloudfront=true"

# Get the URL
terraform output frontend_url
```

**⚡ Tip:** For faster development, CloudFront is disabled by default. Enable it only for production.

**Learn More:** 
- [`docs/frontend/UI_README.md`](./docs/frontend/UI_README.md)
- [`docs/terraform/FAST_DEPLOYMENT.md`](./docs/terraform/FAST_DEPLOYMENT.md)

### 3. Learn Kubernetes (k9s)

```bash
# Setup minikube and k9s
./scripts/setup-k9s.sh

# Launch k9s
./scripts/k9s-quickstart.sh
```

**Learn More:** [`docs/kubernetes/START_HERE.md`](./docs/kubernetes/START_HERE.md)

### 4. Monitor with Grafana

```bash
# Setup Grafana
cd grafana
./setup-grafana.sh
```

**Learn More:** [`docs/grafana/GRAFANA_QUICKSTART.md`](./docs/grafana/GRAFANA_QUICKSTART.md)

## 🏗️ Architecture

```
┌─────────────────────────┐
│   Frontend UI           │
│   (CloudFront CDN)      │
└───────────┬─────────────┘
            │ HTTPS
            ↓
┌─────────────────────────┐
│   API Gateway           │
│   (REST API)            │
└───────────┬─────────────┘
            │
            ↓
┌─────────────────────────┐
│   Lambda Functions      │
│   (Python 3.9)          │
│   - get-items           │
│   - create-item         │
│   - delete-item         │
└───────────┬─────────────┘
            │
            ↓
┌─────────────────────────┐
│   DynamoDB              │
│   (NoSQL Database)      │
└─────────────────────────┘
```

## 🛠️ Technologies

### Cloud Services
- **AWS Lambda** - Serverless computing
- **API Gateway** - REST API management
- **DynamoDB** - Managed NoSQL database
- **S3** - Object storage
- **CloudFront** - Content delivery network
- **CloudWatch** - Monitoring and logging

### Infrastructure & DevOps
- **Terraform** - Infrastructure as Code
- **GitHub Actions** - CI/CD pipeline
- **Docker** - Containerization
- **Kubernetes** - Container orchestration

### Tools
- **k9s** - Kubernetes terminal UI
- **Minikube** - Local Kubernetes
- **Grafana** - Observability platform
- **uv** - Fast Python package manager

## 💰 Cost

**Estimated: $0/month** (AWS Free Tier)
- Lambda: 1M requests/month
- API Gateway: 1M requests/month
- DynamoDB: 25GB storage
- S3: 5GB storage
- CloudFront: 1TB transfer

**Learn More:** [`docs/terraform/AWS_FREE_TIER.md`](./docs/terraform/AWS_FREE_TIER.md)

## 📚 Learning Resources

### 📖 Documentation by Topic

#### Serverless Backend
- [Main Guide](./docs/serverless/SERVERLESS_APP_README.md) - Complete backend documentation
- [Local Testing](./docs/serverless/LOCAL_TESTING.md) - Test Lambda locally
- [uv Integration](./docs/serverless/UV_README.md) - Fast dependency management

#### Frontend
- [UI Guide](./docs/frontend/UI_README.md) - S3 + CloudFront deployment

#### Kubernetes
- [Start Here](./docs/kubernetes/START_HERE.md) - k9s learning path
- [k9s Tutorial](./docs/kubernetes/K9S_LEARNING_GUIDE.md) - Comprehensive guide
- [Quick Start](./docs/kubernetes/K9S_QUICKSTART.md) - Get started quickly

#### Grafana
- [Quick Start](./docs/grafana/GRAFANA_QUICKSTART.md) - Setup Grafana
- [Setup Guide](./docs/grafana/GRAFANA_SETUP.md) - Detailed instructions
- [Troubleshooting](./docs/grafana/TROUBLESHOOT.md) - Common issues

#### Terraform & CI/CD
- [CI/CD Setup](./docs/terraform/CI_CD_SETUP.md) - GitHub Actions
- [Best Practices](./docs/terraform/CI_CD_BEST_PRACTICES.md) - Production patterns
- [Fast Deployment](./docs/terraform/FAST_DEPLOYMENT.md) - Skip CloudFront for speed
- [Hosting Options](./docs/terraform/HOSTING_OPTIONS.md) - GitHub Pages, Netlify, CloudFront
- [Destroy Fix](./docs/terraform/TERRAFORM_DESTROY_FIX.md) - S3 bucket cleanup

### 📋 General Documentation
- [Quick Start](./docs/QUICKSTART.md) - Overall quick start
- [Project Summary](./docs/PROJECT_SUMMARY.md) - Architecture overview
- [Deployment Summary](./docs/DEPLOYMENT_SUMMARY.md) - Deployment details
- [SysOps Roadmap](./docs/SYSOP_ROADMAP.md) - Career path

## 🎯 What You'll Learn

### Cloud Services
- ✅ Deploy serverless applications with AWS
- ✅ Design REST APIs with API Gateway
- ✅ Use DynamoDB for data persistence
- ✅ Serve static websites with S3 + CloudFront
- ✅ Monitor with CloudWatch and Grafana

### Infrastructure as Code
- ✅ Write Terraform configurations
- ✅ Manage infrastructure lifecycles
- ✅ Handle existing resources gracefully
- ✅ Set up CI/CD pipelines

### Container Orchestration
- ✅ Use Kubernetes (k9s) for management
- ✅ Deploy with Minikube locally
- ✅ Containerize applications with Docker
- ✅ Practice production operations

### DevOps Practices
- ✅ Automate deployments with GitHub Actions
- ✅ Manage dependencies efficiently
- ✅ Monitor applications in production
- ✅ Follow best practices

## 🚦 Getting Started

### For AWS/Serverless Learning
1. Read [`docs/serverless/SERVERLESS_APP_README.md`](./docs/serverless/SERVERLESS_APP_README.md)
2. Deploy backend infrastructure
3. Test Lambda functions
4. Move to frontend deployment

### For Kubernetes Learning
1. Read [`docs/kubernetes/START_HERE.md`](./docs/kubernetes/START_HERE.md)
2. Setup minikube and k9s
3. Deploy to Kubernetes
4. Practice with k9s

### For Monitoring
1. Read [`docs/grafana/GRAFANA_QUICKSTART.md`](./docs/grafana/GRAFANA_QUICKSTART.md)
2. Setup Grafana
3. Configure CloudWatch datasource
4. Create dashboards

### For DevOps/CI/CD
1. Read [`docs/terraform/CI_CD_SETUP.md`](./docs/terraform/CI_CD_SETUP.md)
2. Configure GitHub Actions
3. Set up AWS credentials
4. Trigger automated deployments

## 📝 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/items` | List all knowledge base items |
| POST | `/items` | Create a new item |
| DELETE | `/items/{id}` | Delete an item by ID |

**Base URL:** Get from `terraform output api_gateway_url`

## 🆘 Troubleshooting

- **Backend Issues** → [`docs/serverless/SERVERLESS_APP_README.md`](./docs/serverless/SERVERLESS_APP_README.md)
- **Frontend Issues** → [`docs/frontend/UI_README.md`](./docs/frontend/UI_README.md)
- **k9s Issues** → [`docs/kubernetes/K9S_LEARNING_GUIDE.md`](./docs/kubernetes/K9S_LEARNING_GUIDE.md)
- **Grafana Issues** → [`docs/grafana/TROUBLESHOOT.md`](./docs/grafana/TROUBLESHOOT.md)
- **Terraform Issues** → [`docs/terraform/CI_CD_BEST_PRACTICES.md`](./docs/terraform/CI_CD_BEST_PRACTICES.md)

## 🎉 Features

- ✅ **Complete Serverless Stack** - Lambda + API Gateway + DynamoDB
- ✅ **Static Frontend** - S3 + CloudFront CDN
- ✅ **Infrastructure as Code** - Fully automated with Terraform
- ✅ **CI/CD Pipeline** - GitHub Actions integration
- ✅ **Container Support** - Docker + Kubernetes
- ✅ **Monitoring** - Grafana + CloudWatch
- ✅ **Free Tier** - AWS cost optimization
- ✅ **Well Documented** - Organized learning paths

## 📖 Next Steps

1. **Choose your learning path** from the sections above
2. **Read the relevant documentation** in the `docs/` folder
3. **Deploy and practice** with the provided scripts
4. **Explore advanced topics** as you progress

---

**Ready to start?** Pick a learning path above and dive in! 🚀

