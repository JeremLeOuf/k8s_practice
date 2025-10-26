# 📚 Personal Knowledge Base - Serverless Application

A complete serverless application with **backend API** (Lambda + API Gateway + DynamoDB) and **frontend UI** (S3 + CloudFront).

## 📖 Documentation

### Backend / Serverless Infrastructure
- **[SERVERLESS_APP_README.md](./SERVERLESS_APP_README.md)** - API, Lambda, Infrastructure docs
- [QUICKSTART.md](./QUICKSTART.md) - Quick deployment guide
- [AWS_FREE_TIER.md](./AWS_FREE_TIER.md) - Free tier optimization

### Frontend / UI
- **[UI_README.md](./UI_README.md)** - S3 + CloudFront deployment guide
- Static HTML/CSS/JS interface
- Pre-configured with API endpoint

### Kubernetes / K9s Learning
- **[START_HERE.md](./START_HERE.md)** - K9s learning path
- **[K9S_LEARNING_GUIDE.md](./K9S_LEARNING_GUIDE.md)** - Comprehensive k9s tutorial
- **[K9S_QUICKSTART.md](./K9S_QUICKSTART.md)** - Quick start with k9s

### Project Documentation
- **[PROJECT_SUMMARY.md](./PROJECT_SUMMARY.md)** - Architecture overview
- [AWS_FREE_TIER.md](./AWS_FREE_TIER.md) - Cost optimization guide

## 🚀 Quick Start

### Deploy Backend (API)

```bash
# Build and deploy Lambda functions
./scripts/build-lambda.sh
cd infrastructure
terraform apply
```

### Deploy Frontend (UI)

```bash
# Deploy to S3 + CloudFront
./scripts/deploy-frontend.sh

# Get CloudFront URL
cd infrastructure
terraform output frontend_url
```

## 🏗️ Architecture

```
┌─────────────────────┐
│   Frontend UI       │
│   (CloudFront CDN)  │
│   https://xxx.net  │
└──────────┬──────────┘
           │ HTTPS
           ↓
┌─────────────────────┐
│   API Gateway       │
│   (REST API)        │
└──────────┬──────────┘
           │
           ↓
┌─────────────────────┐
│   Lambda Functions  │
│   (Python 3.9)      │
│   - get-items       │
│   - create-item     │
│   - delete-item     │
└──────────┬──────────┘
           │
           ↓
┌─────────────────────┐
│   DynamoDB          │
│   (NoSQL Database)  │
└─────────────────────┘
```

## 📁 Project Structure

```
serverless_app/
├── README.md                    # This file
│
├── BACKEND / API
│   ├── SERVERLESS_APP_README.md # Backend documentation
│   ├── infrastructure/          # Terraform config
│   └── lambda-functions/        # Lambda code
│       ├── get-items/
│       ├── create-item/
│       └── delete-item/
│
├── FRONTEND / UI
│   ├── UI_README.md             # Frontend documentation
│   ├── frontend/                # Static HTML files
│   └── scripts/deploy-frontend.sh
│
├── KUBERNETES / K9S
│   ├── START_HERE.md            # K9s starter
│   ├── K9S_LEARNING_GUIDE.md   # K9s tutorial
│   ├── K9S_QUICKSTART.md       # Quick start
│   ├── kubernetes/              # K8s manifests
│   └── scripts/setup-k9s.sh
│
└── DOCUMENTATION
    ├── QUICKSTART.md
    ├── PROJECT_SUMMARY.md
    ├── AWS_FREE_TIER.md
    └── *.md files
```

## 🎯 What You Can Do

### Backend
- ✅ Deploy serverless API to AWS
- ✅ Manage Lambda functions with Terraform
- ✅ Use DynamoDB for data storage
- ✅ Learn Infrastructure as Code

### Frontend
- ✅ Deploy static website to S3
- ✅ Use CloudFront CDN
- ✅ Interact with API from browser
- ✅ Modern, responsive UI

### Kubernetes
- ✅ Learn k9s (terminal UI for K8s)
- ✅ Deploy with Minikube
- ✅ Practice container orchestration
- ✅ Monitor with k9s

## 🛠️ Technologies

### AWS Services
- **Lambda** - Serverless functions
- **API Gateway** - REST API
- **DynamoDB** - NoSQL database
- **S3** - Static website hosting
- **CloudFront** - CDN and caching

### Infrastructure
- **Terraform** - IaC
- **Docker** - Containerization
- **Kubernetes** - Orchestration

### Tools
- **k9s** - K8s terminal UI
- **Minikube** - Local K8s cluster
- **Git** - Version control

## 📝 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/items` | List all items |
| POST | `/items` | Create new item |
| DELETE | `/items/{id}` | Delete item |

## 💰 Cost

**Estimated: $0/month** (AWS Free Tier)
- Lambda: 1M requests/month
- API Gateway: 1M requests/month
- DynamoDB: 25GB storage
- S3: 5GB storage
- CloudFront: 1TB transfer

## 🚀 Quick Deploy

### Option 1: Full Stack

```bash
# Backend
./scripts/build-lambda.sh
cd infrastructure && terraform apply

# Frontend
./scripts/deploy-frontend.sh

# Get URLs
terraform output
```

### Option 2: Backend Only

```bash
cd infrastructure
terraform apply
terraform output api_gateway_url
```

### Option 3: Frontend Only

```bash
./scripts/deploy-frontend.sh
```

## 📚 Learning Path

### Week 1: Backend
1. Read `SERVERLESS_APP_README.md`
2. Deploy Lambda functions
3. Test API endpoints
4. Learn Terraform basics

### Week 2: Frontend
1. Read `UI_README.md`
2. Deploy to S3 + CloudFront
3. Test UI in browser
4. Customize interface

### Week 3: Kubernetes
1. Read `START_HERE.md`
2. Install minikube and k9s
3. Deploy to K8s
4. Practice with k9s

## 🆘 Need Help?

### Backend Issues
- See `SERVERLESS_APP_README.md`
- Check `infrastructure/` for Terraform config
- Review CloudWatch logs

### Frontend Issues
- See `UI_README.md`
- Check `frontend/` for HTML files
- Verify CloudFront distribution

### K9s Issues
- See `K9S_LEARNING_GUIDE.md`
- Check `kubernetes/` manifests
- Review minikube status

## 🎉 Features

- ✅ **Serverless Backend** - Lambda + API Gateway + DynamoDB
- ✅ **Static Frontend** - S3 + CloudFront
- ✅ **Infrastructure as Code** - Terraform
- ✅ **Container Support** - Docker + Kubernetes
- ✅ **Free Tier** - AWS cost optimization
- ✅ **Complete Docs** - Separate backend/frontend guides

## 📖 Next Steps

1. **Read Documentation**
   - `SERVERLESS_APP_README.md` for backend
   - `UI_README.md` for frontend

2. **Deploy Application**
   ```bash
   ./scripts/build-lambda.sh
   cd infrastructure && terraform apply
   ./scripts/deploy-frontend.sh
   ```

3. **Learn K9s**
   - Read `START_HERE.md`
   - Install minikube and k9s
   - Deploy and practice

## 🔗 Links

- [Backend Documentation](./SERVERLESS_APP_README.md)
- [Frontend Documentation](./UI_README.md)
- [K9s Learning Guide](./K9S_LEARNING_GUIDE.md)
- [Quick Start Guide](./QUICKSTART.md)

---

**Ready to start?** Pick a path:
- 🎯 **Backend**: Read `SERVERLESS_APP_README.md`
- 🌐 **Frontend**: Read `UI_README.md`
- 🎓 **K9s**: Read `START_HERE.md`
