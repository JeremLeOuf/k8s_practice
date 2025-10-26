# 🔧 Terraform & CI/CD Documentation

This folder contains documentation for Infrastructure as Code (Terraform) and CI/CD (GitHub Actions).

## 📄 Files

### 🚀 CI/CD Setup
- **[CI_CD_SETUP.md](./CI_CD_SETUP.md)** - GitHub Actions configuration
  - Pipeline setup
  - GitHub Secrets
  - Automation workflows

### 📚 Best Practices
- **[CI_CD_BEST_PRACTICES.md](./CI_CD_BEST_PRACTICES.md)** - Production patterns
  - Remote state management
  - Resource importing
  - Error handling

### 🐛 Fixes & Issues
- **[CI_CD_FIXES.md](./CI_CD_FIXES.md)** - Previous CI/CD fixes
- **[CI_CD_FIXES_SUMMARY.md](./CI_CD_FIXES_SUMMARY.md)** - Summary of all fixes

### 🗑️ Cleanup
- **[TERRAFORM_DESTROY_FIX.md](./TERRAFORM_DESTROY_FIX.md)** - S3 bucket emptying

### 💰 Cost Optimization
- **[AWS_FREE_TIER.md](./AWS_FREE_TIER.md)** - Stay within AWS Free Tier

## 🎯 Quick Start

### Setup CI/CD

1. **Configure GitHub Secrets**
   ```
   AWS_ACCESS_KEY_ID
   AWS_SECRET_ACCESS_KEY
   ```

2. **Push to main branch**
   ```bash
   git push origin main
   ```

3. **Monitor Actions**
   - View at: GitHub → Actions tab
   - Check deployment status

### Manual Deployment

```bash
cd infrastructure
terraform init
terraform plan
terraform apply
```

## 🏗️ Infrastructure

### Resources Managed
- **Lambda Functions** - Serverless compute
- **API Gateway** - REST API
- **DynamoDB** - NoSQL database
- **IAM Roles & Policies** - Access control
- **S3 Bucket** - Static website
- **CloudFront** - CDN distribution
- **Grafana IAM** - Monitoring access

### CI/CD Pipeline

```yaml
Jobs:
  1. Validate - Terraform plan and validation
  2. Deploy - Apply infrastructure (main branch only)
  3. Test - Lambda function testing
  4. Notify - Deployment status
```

## 🔧 Technology Stack

- **Terraform** - Infrastructure as Code
- **GitHub Actions** - CI/CD automation
- **AWS Provider** - Cloud resources
- **null Provider** - Local commands

## 📖 Learn More

- [CI/CD Setup](./CI_CD_SETUP.md)
- [Best Practices](./CI_CD_BEST_PRACTICES.md)
- [AWS Free Tier](./AWS_FREE_TIER.md)
- [Fix Summary](./CI_CD_FIXES_SUMMARY.md)

**Return to:** [Documentation Index](../README.md) | [Main README](../../README.md)

