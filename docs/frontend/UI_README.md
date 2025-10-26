# 🌐 Personal Knowledge Base - Frontend UI

A modern, responsive web interface for the Personal Knowledge Base API.

## Overview

This frontend is hosted on AWS S3 with CloudFront CDN for global distribution and fast loading times.

### Technology Stack
- **HTML5** - Structure
- **CSS3** - Styling (Inline)
- **JavaScript** - API interaction
- **AWS S3** - Static hosting
- **CloudFront** - CDN and caching

## Features

✅ **Create Items** - Add new knowledge items  
✅ **View Items** - List all items  
✅ **Delete Items** - Remove items  
✅ **Responsive Design** - Works on all devices  
✅ **Real-time Updates** - Instant feedback  
✅ **Modern UI** - Beautiful gradient design  

## Quick Start

### Option 1: Deploy to AWS

```bash
# Deploy infrastructure (includes frontend)
cd infrastructure
terraform apply

# Deploy frontend files
./scripts/deploy-frontend.sh
```

### Option 2: Test Locally

```bash
# Serve locally (requires Python)
cd frontend
python3 -m http.server 8000

# Open browser
# http://localhost:8000
```

### Option 3: Deploy Manually

```bash
# Get bucket name
cd infrastructure
BUCKET=$(terraform output -raw frontend_bucket_name)
cd ..

# Upload files
aws s3 sync frontend/ s3://${BUCKET}/

# Get CloudFront URL
cd infrastructure
terraform output frontend_url
```

## Configuration

### API Endpoint

The frontend is pre-configured with the default API endpoint:
```
https://vzilkz4t52.execute-api.us-east-1.amazonaws.com/prod
```

### Custom API Endpoint

Users can change the API endpoint in the UI:
1. Open the frontend
2. Enter new API URL in configuration section
3. Click "Save URL"

The URL is stored in browser's localStorage.

## Deployment

### Infrastructure Deployment

```bash
cd infrastructure
terraform apply
```

This creates:
- S3 bucket for static website hosting
- CloudFront distribution with CDN
- Origin Access Identity (OAI) for security
- Bucket policy for CloudFront access

### Content Deployment

```bash
# Deploy frontend files
./scripts/deploy-frontend.sh

# Or manually
aws s3 sync frontend/ s3://<bucket-name>/ --delete
```

## Architecture

```
Users
  ↓
CloudFront CDN (Global Distribution)
  ↓
S3 Bucket (Static Files)
  ↓
Frontend (index.html)
  ↓
API Gateway (REST API)
  ↓
Lambda Functions
  ↓
DynamoDB
```

## Files Structure

```
frontend/
├── index.html          # Main HTML file with inline CSS/JS
└── README.md           # This file
```

## Customization

### Change Colors

Edit the gradient in `index.html`:

```css
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
```

### Change API Endpoint

Update `DEFAULT_API_URL` in `index.html`:

```javascript
const DEFAULT_API_URL = 'https://your-api-url.amazonaws.com/prod';
```

### Add Features

The frontend uses vanilla JavaScript, making it easy to extend:
- Add search functionality
- Add filtering
- Add pagination
- Add item editing

## Troubleshooting

### CloudFront Not Updating

Clear CloudFront cache:
```bash
DIST_ID=$(aws cloudfront list-distributions --query "DistributionList.Items[?Origins.Items[0].DomainName=='<bucket>.s3.<region>.amazonaws.com'].Id" --output text)
aws cloudfront create-invalidation --distribution-id ${DIST_ID} --paths '/*'
```

### CORS Issues

Ensure API Gateway has CORS enabled. The frontend includes:
```javascript
headers: {
  'Content-Type': 'application/json',
  'Access-Control-Allow-Origin': '*'
}
```

### 404 Errors

Make sure:
1. S3 bucket has website hosting enabled
2. CloudFront default root object is set to `index.html`
3. Files are uploaded to S3

## Testing

### Local Testing

```bash
# Start local server
cd frontend
python3 -m http.server 8000

# Test in browser
open http://localhost:8000
```

### API Testing

Test the configured API endpoint:
```bash
curl https://vzilkz4t52.execute-api.us-east-1.amazonaws.com/prod/items
```

## Security

✅ **No public S3 access** - Only CloudFront can access files  
✅ **HTTPS only** - All traffic encrypted  
✅ **CORS enabled** - Controlled cross-origin requests  
✅ **No API keys** - Public API (can be secured later)  

## Cost

- **S3 Storage**: Free tier includes 5GB/month
- **CloudFront**: Free tier includes 1TB transfer/month
- **Estimated cost**: $0/month for typical usage

## Monitoring

### Check Deployment

```bash
# Get CloudFront URL
cd infrastructure
terraform output frontend_url

# Test in browser
open $(terraform output -raw frontend_url)
```

### View Logs

CloudFront access logs:
```bash
aws cloudfront list-distributions
aws logs tail /aws/cloudfront/your-distribution-id
```

## Next Steps

1. **Add Authentication** - AWS Cognito integration
2. **Add Search** - Full-text search for items
3. **Add Categories** - Organize items by type
4. **Add Image Upload** - S3 for file storage
5. **Add Markdown Support** - Rich text editing

## Resources

- [AWS S3 Static Website Hosting](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)
- [AWS CloudFront](https://docs.aws.amazon.com/cloudfront/)
- [CloudFront with S3](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/getting-started-simple-cloudfront-s3-custom-domain-overview.html)

