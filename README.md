# Personal Knowledge Base API - Serverless Application

A serverless REST API built with AWS Lambda, API Gateway, Docker, Kubernetes, and Terraform.

## Project Overview

This application provides a REST API to manage personal knowledge items (notes, links, tasks) with a complete serverless architecture.

### Architecture
- **Frontend**: Simple HTML/JS frontend
- **API**: AWS API Gateway
- **Backend**: AWS Lambda functions (Python)
- **Database**: AWS DynamoDB (serverless NoSQL)
- **Containerization**: Docker
- **Orchestration**: Kubernetes (for local dev/testing)
- **IaC**: Terraform

## Project Structure

```
serverless_app/
├── README.md                      # This file
├── .gitignore                     # Git ignore rules
├── infrastructure/                # Terraform configuration
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars
├── lambda-functions/             # Lambda function code
│   ├── get-items/
│   ├── create-item/
│   └── delete-item/
├── docker/                       # Docker configurations
│   ├── Dockerfile.lambda
│   └── docker-compose.yml
├── kubernetes/                   # K8s manifests
│   ├── api-deployment.yaml
│   └── api-service.yaml
├── frontend/                     # Simple frontend
│   └── index.html
└── scripts/                      # Helper scripts
    └── deploy.sh

```

## Features
- ✅ Create, read, delete knowledge items
- ✅ RESTful API endpoints
- ✅ Serverless architecture (Lambda + API Gateway)
- ✅ Infrastructure as Code (Terraform)
- ✅ Docker containerization
- ✅ Kubernetes deployment manifests
- ✅ GitHub repository for version control

## Getting Started

### Prerequisites
- AWS Account with CLI configured
- Docker installed
- kubectl installed
- Terraform installed
- Python 3.9+

### Step-by-Step Guide

#### 1. Clone and Initialize Git (if starting fresh)
```bash
git init
git add .
git commit -m "Initial project setup"
git remote add origin <your-github-repo-url>
git push -u origin main
```

#### 2. Set Up AWS Credentials
```bash
aws configure
# Enter your Access Key, Secret Key, region (e.g., us-east-1), and output format (json)
```

#### 3. Initialize Terraform
```bash
cd infrastructure
terraform init
terraform plan
```

#### 4. Deploy Infrastructure
```bash
terraform apply
# This will create:
# - API Gateway
# - Lambda functions
# - DynamoDB table
# - IAM roles and policies
```

#### 5. Build Docker Images
```bash
cd docker
docker-compose build
```

#### 6. Test Locally with Kubernetes
```bash
# Deploy to local Kubernetes (minikube/kind)
kubectl apply -f ../kubernetes/

# Check deployment
kubectl get pods
kubectl get services
```

#### 7. Update Lambda Functions
```bash
# Deploy Lambda functions
cd lambda-functions/get-items
zip -r function.zip .
aws lambda update-function-code --function-name pkb-api-get-items --zip-file fileb://function.zip
```

## API Endpoints

Once deployed, you'll have these endpoints:
- `GET /api/items` - List all items
- `POST /api/items` - Create a new item
- `DELETE /api/items/{id}` - Delete an item

## Development Workflow

1. **Make changes** to Lambda functions in `lambda-functions/`
2. **Package and deploy** using AWS CLI or Terraform
3. **Update infrastructure** by editing Terraform files in `infrastructure/`
4. **Test locally** with Docker or Kubernetes
5. **Commit changes** to Git
6. **Deploy** using Terraform

## Cleanup
To destroy all infrastructure:
```bash
cd infrastructure
terraform destroy
```

## Next Steps

1. Customize the API endpoints
2. Add authentication (AWS Cognito)
3. Implement more Lambda functions
4. Set up CI/CD pipeline
5. Add monitoring (CloudWatch)
6. Implement auto-scaling for containers

## Resources

- [AWS Lambda Documentation](https://docs.aws.amazon.com/lambda/)
- [API Gateway Documentation](https://docs.aws.amazon.com/apigateway/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

