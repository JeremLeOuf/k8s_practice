# 🔄 CI/CD Pipeline Setup

## Current Status
✅ GitHub Actions workflow created  
✅ Infrastructure files added to repository  
⏳ Requires AWS credentials to be configured  

## Setup Instructions

### 1. Add AWS Credentials to GitHub Secrets

Go to your GitHub repository:
1. Settings → Secrets and variables → Actions
2. Click "New repository secret"

Add these secrets:

**Secret 1: AWS_ACCESS_KEY_ID**
- Name: `AWS_ACCESS_KEY_ID`
- Value: Your AWS access key

**Secret 2: AWS_SECRET_ACCESS_KEY**
- Name: `AWS_SECRET_ACCESS_KEY`
- Value: Your AWS secret key

### 2. The CI/CD Will:
- ✅ Validate Terraform on every PR
- ✅ Auto-deploy infrastructure on merge to main
- ✅ Test Lambda functions
- ✅ Notify on success/failure

### 3. How It Works

```yaml
PR → Validate → Auto-deploy on merge → Test → Notify
```

### 4. What Gets Deployed

On push to `main`:
- Lambda functions
- API Gateway
- DynamoDB table
- S3 bucket + CloudFront
- CloudWatch monitoring

### 5. Monitoring CI/CD

View runs at:
https://github.com/YOUR_USERNAME/k8s_practice/actions

### 6. Skip CI/CD (Manual Deploy)

If you want to deploy manually:

```bash
cd infrastructure
terraform apply -auto-approve
```

---

## Current Workflow Files

`.github/workflows/deploy.yml` - Main CI/CD pipeline

## Future Enhancements

- [ ] Add Slack notifications
- [ ] Add email alerts
- [ ] Terraform state locking with S3 backend
- [ ] Preview environment for PRs
- [ ] Automated rollback on errors

---

## Next Steps (Recommended)

1. **Add AWS Secrets** to GitHub (as above)
2. **Create a test PR** to see CI/CD in action
3. **Merge to main** to trigger auto-deployment
4. **Monitor the pipeline** for success

---

## Resources

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Terraform Cloud](https://www.terraform.io/cloud)
- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)

