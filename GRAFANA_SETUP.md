# 📊 Grafana Monitoring Setup Guide

Complete guide to setting up Grafana monitoring for your Personal Knowledge Base API.

## 🎯 Overview

This setup provides real-time monitoring of your Lambda functions using:
- **Grafana** - Visualization and alerting
- **CloudWatch** - AWS metrics data source
- **Docker** - Easy local deployment

## 🚀 Quick Start (5 minutes)

### Step 1: Start Grafana

```bash
cd grafana
./setup-grafana.sh
```

Wait for: "Grafana is starting!"

### Step 2: Configure CloudWatch

```bash
./setup-cloudwatch-datasource.sh
```

Enter your AWS credentials when prompted.

### Step 3: Open Grafana

1. Open http://localhost:3000
2. Login: `admin` / `admin`
3. Go to Dashboards → New Dashboard

### Step 4: Create Your First Panel

**Add Lambda Invocations Panel:**

1. Click "Add visualization"
2. Select "CloudWatch" data source
3. Configure:
   - Namespace: `AWS/Lambda`
   - Metric name: `Invocations`
   - Dimensions: `FunctionName` = `pkb-api-get-items`
   - Statistic: `Sum`
   - Period: `5 minutes`
4. Click "Apply"

**Add Lambda Errors Panel:**

1. Click "Add panel" → "Add visualization"
2. Configure:
   - Namespace: `AWS/Lambda`
   - Metric name: `Errors`
   - Dimensions: `FunctionName` = `pkb-api-get-items`
   - Statistic: `Sum`
3. Click "Apply"

### Step 5: Invoke Functions

```bash
curl https://f31rkf170i.execute-api.us-east-1.amazonaws.com/prod/items
```

Watch your metrics update in real-time!

## 🎨 Pre-built Dashboard

### Manual Setup

For all three Lambda functions:

**1. Get Items Monitoring**
```yaml
Panel 1: Invocations
  - Namespace: AWS/Lambda
  - Metric: Invocations
  - FunctionName: pkb-api-get-items
  - Statistic: Sum

Panel 2: Errors
  - Namespace: AWS/Lambda
  - Metric: Errors
  - FunctionName: pkb-api-get-items
  - Statistic: Sum

Panel 3: Duration
  - Namespace: AWS/Lambda
  - Metric: Duration
  - FunctionName: pkb-api-get-items
  - Statistic: Average, Maximum
```

**2. Create Item Monitoring**
```yaml
Same as above, but FunctionName: pkb-api-create-item
```

**3. Delete Item Monitoring**
```yaml
Same as above, but FunctionName: pkb-api-delete-item
```

## 🔐 AWS IAM Setup (One-time)

### Option 1: Use IAM User (Recommended for Local)

Create an IAM user with CloudWatch read access:

```bash
# Apply Terraform changes
cd infrastructure
terraform apply

# Generate access keys
aws iam create-access-key --user-name pkb-grafana-cloudwatch
```

Use the output credentials in `setup-cloudwatch-datasource.sh`

### Option 2: Use Existing AWS Credentials

If you already have AWS CLI configured:

```bash
# Your credentials will be used automatically
./setup-cloudwatch-datasource.sh
```

## 📊 Available Metrics

### Core Lambda Metrics

| Metric | Description | Ideal Value |
|--------|-------------|-------------|
| Invocations | Number of function calls | Monitor for usage |
| Errors | Failed executions | 0 (should be zero) |
| Duration | Execution time | < 1s |
| Throttles | Concurrent limit hits | 0 (should be zero) |

### Cost Metrics

| Metric | Calculation |
|--------|-------------|
| Requests | Total invocations |
| Compute | Duration × Memory |
| Monthly cost | ~$0.20 per million requests |

## 🚨 Setting Up Alerts

### Create Alert Rules

**1. Error Alert:**
```
Alert when: Errors > 0
Condition: Last 5 minutes
Notification: Email/Slack
```

**2. Performance Alert:**
```
Alert when: Duration > 1000ms
Condition: Average over 5 minutes
Notification: Email
```

**3. Throttle Alert:**
```
Alert when: Throttles > 0
Condition: Any in last 5 minutes
Notification: Email/Slack
```

## 🎓 Advanced Configuration

### Multi-Region Support

Edit `cloudwatch.yml`:
```yaml
jsonData:
  authType: aws
  defaultRegion: us-east-1
  customMetricsNamespaces: 'Lambda'
  assumeRoleArn: 'arn:aws:iam::ACCOUNT:role/grafana-cloudwatch'
```

### Custom Queries

**CloudWatch Insights Query:**
```
fields @timestamp, @message
| filter @message like /ERROR/
| sort @timestamp desc
| limit 100
```

**Metric Math:**
```
AVG([{
  "name": "pkb-api-get-items",
  "namespace": "AWS/Lambda",
  "metricName": "Duration"
}])
```

## 🔧 Troubleshooting

### No Data Appearing

**Check:**
1. AWS credentials are correct
2. IAM permissions include CloudWatch read access
3. Lambda functions have been invoked recently
4. Time range is set correctly in Grafana

**Test:**
```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Invocations \
  --dimensions Name=FunctionName,Value=pkb-api-get-items \
  --start-time 2025-10-26T00:00:00Z \
  --end-time 2025-10-26T23:59:59Z \
  --period 3600 \
  --statistics Sum
```

### Grafana Won't Start

```bash
# Check Docker
docker ps

# View logs
cd grafana
docker-compose logs -f

# Restart
docker-compose down
docker-compose up -d
```

### CloudWatch Data Source Fails

1. Verify credentials in IAM console
2. Check policy permissions
3. Ensure region is us-east-1
4. Try regenerating access keys

## 📈 Dashboard Examples

### 1. Overview Dashboard
- Total invocations (all functions)
- Error rate (should be 0)
- Average duration
- Cost estimate

### 2. Function-Specific Dashboard
- Per-function metrics
- Last 24 hours trend
- Top invocations
- Error breakdown

### 3. Cost Dashboard
- Daily invocations
- Compute time (GB-seconds)
- Monthly projection
- Free tier usage

## 🎯 Best Practices

1. **Use Templates** - Create variables for function names
2. **Set Refresh Rate** - 30s for real-time, 5m for historical
3. **Archive Dashboards** - Save important dashboards as JSON
4. **Configure Alerts** - Get notified of issues immediately
5. **Label Consistently** - Use consistent naming across dashboards

## 📚 Next Steps

1. **Explore Dashboards** - Browse Grafana dashboard library
2. **Set Up Alerts** - Configure email/Slack notifications
3. **Share Dashboards** - Export and share with team
4. **Customize** - Add more metrics and visualizations
5. **Production Setup** - Deploy to ECS/EKS for production

## 🎉 You're Done!

You now have:
- ✅ Grafana running locally
- ✅ CloudWatch data source configured
- ✅ Ability to monitor Lambda functions
- ✅ Real-time metrics and visualization

**Access Grafana:** http://localhost:3000  
**Next:** Create custom dashboards or import templates from [Grafana Dashboard Library](https://grafana.com/grafana/dashboards/)

## 📞 Support

For issues:
1. Check `grafana/README.md`
2. Review Docker logs: `docker-compose logs`
3. Verify AWS credentials and permissions
4. Test CloudWatch access via AWS CLI

