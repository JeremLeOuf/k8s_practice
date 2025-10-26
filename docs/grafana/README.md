# 📊 Grafana Monitoring for Personal Knowledge Base API

This directory contains Grafana configuration for monitoring your Lambda functions in AWS CloudWatch.

## 🚀 Quick Start

### 1. Prerequisites

- Docker and Docker Compose installed
- AWS credentials configured
- AWS CLI configured

### 2. Setup Grafana

```bash
cd grafana
./setup-grafana.sh
```

This will:
- Start Grafana in Docker
- Create necessary configuration files
- Open Grafana on http://localhost:3000

### 3. Configure CloudWatch Data Source

```bash
./setup-cloudwatch-datasource.sh
```

This will:
- Connect Grafana to AWS CloudWatch
- Configure credentials
- Set up the data source

### 4. Import Dashboard

1. Open http://localhost:3000
2. Login with `admin` / `admin`
3. Go to Dashboards → Import
4. Upload `dashboards/lambda-monitoring.json`

Or manually create dashboards:
1. Go to Dashboards → New Dashboard
2. Add panels for Lambda metrics
3. Configure CloudWatch queries

## 📈 Available Metrics

### Lambda Functions
- **Invocations** - Number of function invocations
- **Duration** - Function execution time
- **Errors** - Error count
- **Throttles** - Concurrent execution limits
- **Dead Letter Queue** - Failed invocations

### Query Example

In Grafana, use CloudWatch queries like:
```
AWS/Lambda
Metric: Invocations
Dimensions: FunctionName = pkb-api-get-items
Statistic: Sum
```

## 🎨 Dashboard Panels

### 1. Invocation Rate
```yaml
- Title: Lambda Invocations
- Metric: Invocations
- Time Range: Last 1 hour
- Aggregation: Sum
```

### 2. Error Rate
```yaml
- Title: Lambda Errors  
- Metric: Errors
- Alert Threshold: > 0
```

### 3. Duration
```yaml
- Title: Execution Duration
- Metric: Duration
- Statistic: Average, Maximum
- Unit: Milliseconds
```

### 4. Cost Tracking
```yaml
- Title: Estimated Cost
- Calculated: (Invocations * Duration * $0.0000166667)
```

## 🔧 Configuration

### Environment Variables

Edit `.env` file:
```bash
GRAFANA_USER=admin
GRAFANA_PASSWORD=your_secure_password

# AWS Credentials
AWS_ACCESS_KEY_ID=your_key
AWS_SECRET_ACCESS_KEY=your_secret
AWS_DEFAULT_REGION=us-east-1
```

### Customization

Edit dashboards in `dashboards/` directory or create new ones through the UI.

## 🐛 Troubleshooting

### Grafana won't start
```bash
# Check Docker
docker ps

# View logs
docker-compose logs -f
```

### CloudWatch data source fails
- Verify AWS credentials
- Check IAM permissions
- Ensure region is correct (us-east-1)

### No data showing
- Verify Lambda functions have been invoked
- Check CloudWatch logs exist
- Try different time ranges
- Verify IAM permissions include CloudWatch read access

## 🔐 Security

### IAM Policy for CloudWatch Access

Create IAM user or role with this policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:GetMetricData",
        "cloudwatch:GetMetricStatistics",
        "cloudwatch:ListMetrics",
        "logs:DescribeLogGroups",
        "logs:GetLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
```

### Secure Your Grafana

Change default credentials in `.env`:
```bash
GRAFANA_USER=your_username
GRAFANA_PASSWORD=your_secure_password
```

Or via Grafana UI: Administration → Users → Change Password

## 📊 Dashboard Features

### Real-time Monitoring
- Live metrics from CloudWatch
- Auto-refresh every 30 seconds
- Historical data for trend analysis

### Alerts
Set up alerts for:
- High error rates (> 0 errors)
- Slow execution (Duration > 1s)
- Throttling events

### Cost Tracking
Monitor:
- Total invocations
- Compute time (GB-seconds)
- Estimated monthly cost

## 🎓 Next Steps

1. **Custom Dashboards** - Create dashboards for your specific needs
2. **Alerts** - Set up Slack/Email notifications
3. **Annotations** - Add deployment markers
4. **Variables** - Use template variables for multiple functions

## 📚 Resources

- [Grafana CloudWatch Docs](https://grafana.com/docs/grafana/latest/datasources/cloudwatch/)
- [Lambda Metrics Reference](https://docs.aws.amazon.com/lambda/latest/dg/monitoring-metrics.html)
- [Grafana Dashboard Examples](https://grafana.com/grafana/dashboards/)

## 🆘 Support

For issues:
1. Check logs: `docker-compose logs`
2. Verify AWS credentials
3. Review IAM permissions
4. Check CloudWatch console for data

