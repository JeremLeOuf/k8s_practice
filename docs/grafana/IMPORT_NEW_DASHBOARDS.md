# 📊 Import New Grafana Dashboards

## Quick Start

You have **4 new Grafana dashboards** ready to use:

1. **🚀 Serverless Monitoring** - Basic real-time monitoring
2. **🎯 Advanced Serverless v2** - Advanced analytics (10 panels)
3. **📊 Lambda Monitoring** - Simple Lambda monitoring
4. **📈 Advanced Serverless Dashboard** - Legacy dashboard

## Method 1: Import via Grafana UI (Recommended)

### Step 1: Access Grafana

```bash
# Start port-forward
./scripts/access-grafana.sh

# Or manually:
kubectl port-forward -n grafana svc/grafana-service 3000:3000
```

Then open: http://localhost:3000
- Username: `admin`
- Password: `admin`

### Step 2: Import Dashboards

For each dashboard:

1. Click **"Dashboards"** in left sidebar
2. Click **"Import"** button (top right)
3. Click **"Upload JSON file"**
4. Select one of:
   - `grafana/dashboards/serverless-monitoring.json`
   - `grafana/dashboards/advanced-serverless-v2.json`
   - `grafana/dashboards/advanced-serverless-dashboard.json`
   - `grafana/dashboards/lambda-monitoring.json`
5. Select **"CloudWatch"** as data source
6. Click **"Import"**

### Step 3: View Dashboard

Dashboard appears in Dashboards menu. Click to view!

## Method 2: Manual Configuration

### Setup CloudWatch Data Source

1. Go to **Configuration** → **Data Sources**
2. Click **"Add data source"**
3. Search for **"CloudWatch"**
4. Enter:
   - **Name**: `CloudWatch`
   - **Default Region**: `us-east-1`
   - **Auth**: AWS Credentials
     - Access key: Your AWS access key
     - Secret key: Your AWS secret key
5. Click **"Save & Test"**

### Create Dashboard Manually

1. Go to **Dashboards** → **New**
2. Click **"Add"** → **"Visualization"**
3. Choose data source: **CloudWatch**
4. Configure query:
   - Namespace: `AWS/Lambda`
   - Metric: Choose (e.g., `Invocations`)
   - Dimension: `FunctionName`
   - Value: `pkb-api-get-items`
   - Statistic: `Sum`
5. Click **"Apply"**

## Method 3: Kubernetes ConfigMap (Advanced)

### Deploy via ConfigMap

The dashboards are already configured in Kubernetes:

```bash
# Apply the updated Grafana deployment
kubectl apply -f kubernetes/grafana-deployment.yaml -n grafana

# Apply the provisioning ConfigMap
kubectl apply -f kubernetes/grafana-provisioning.yaml -n grafana

# Apply the dashboard ConfigMaps
kubectl create configmap grafana-dashboards-serverless \
  --from-file=grafana/dashboards/serverless-monitoring.json \
  --dry-run=client -o yaml -n grafana | kubectl apply -f -

kubectl create configmap grafana-dashboards-advanced \
  --from-file=grafana/dashboards/advanced-serverless-v2.json \
  --dry-run=client -o yaml -n grafana | kubectl apply -f -

# Restart Grafana to load dashboards
kubectl rollout restart deployment/grafana -n grafana
```

## Dashboard Features

### 🚀 Serverless Monitoring (Basic)

**File**: `grafana/dashboards/serverless-monitoring.json`

**Panels**:
- Lambda Invocations (last hour)
- Lambda Errors (last hour)
- Duration Performance
- Throttles & Concurrency
- Total Invocations (3 gauges)
- Total Errors

**Refresh**: Every 30 seconds  
**Time Range**: Last 1 hour (default)

### 🎯 Advanced Serverless v2 (Advanced)

**File**: `grafana/dashboards/advanced-serverless-v2.json`

**Panels** (10 total):
1. 🔥 Request Rate - Stacked by endpoint (GET/POST/DELETE)
2. ⚠️ Error Rate - All functions
3. ⚡ Response Time - Avg vs Max
4. 📊 Performance Summary - Table
5. 💾 Memory Usage %
6. 🚦 Total Throttles
7. 📊 Request Distribution - Pie chart
8. ✅ Success Rate Gauge
9. 📈 24-Hour Summary - Table
10. 🔥 Concurrent Executions

**Refresh**: Every 5 seconds  
**Time Range**: Last 6 hours (default)

**Special Features**:
- ⭐ Links to AWS Console (CloudWatch, Lambda, API Gateway)
- 🔄 Real-time updates
- 📊 Multiple visualization types
- 🎨 Color-coded thresholds

## Troubleshooting

### Dashboard Shows "No Data"

**Cause**: CloudWatch data source not configured or no Lambda invocations

**Fix**:
```bash
# Invoke a Lambda function to generate data
aws lambda invoke \
  --function-name pkb-api-get-items \
  --payload '{}' \
  /tmp/response.json

# Wait 1-2 minutes for data to appear
```

### CloudWatch Data Source Missing

**Fix**:
1. Go to Configuration → Data Sources
2. Add CloudWatch data source
3. Enter AWS credentials

### Wrong Function Names

The dashboards expect these function names:
- `pkb-api-get-items`
- `pkb-api-create-item`
- `pkb-api-delete-item`

**To update**:
1. Open dashboard in edit mode
2. Update panel queries
3. Replace function names in dimensions

### Cannot Import JSON

**Fix**:
1. Check file size (must be < 100MB)
2. Validate JSON format
3. Ensure file is not corrupted

## Best Practices

### 1. Start with Basic Dashboard

Import `serverless-monitoring.json` first to verify setup.

### 2. Add Advanced Dashboard Later

Once basic dashboard works, import `advanced-serverless-v2.json`.

### 3. Customize for Your Use Case

- Update function names
- Adjust time ranges
- Change thresholds
- Add custom panels

### 4. Set Up Alerts

1. Click panel title → Edit
2. Click "Alert" tab
3. Configure threshold
4. Add notification channel

### 5. Organize Dashboards

Create folders:
- Production Dashboards
- Development Dashboards
- Legacy Dashboards

## Quick Commands

```bash
# Access Grafana
./scripts/access-grafana.sh

# Update dashboards
./scripts/update-grafana-dashboards.sh

# View all dashboards
ls -lh grafana/dashboards/

# Validate JSON
jq . grafana/dashboards/advanced-serverless-v2.json > /dev/null && echo "✅ Valid JSON"
```

## Next Steps

1. ✅ Import basic dashboard
2. ⭐ Set up CloudWatch data source
3. 📊 Customize thresholds
4. 🔔 Configure alerts
5. 📈 Monitor metrics

## Resources

- [Grafana Dashboard Guide](docs/grafana/DASHBOARD_GUIDE.md)
- [Grafana Setup](docs/grafana/SETUP_GRAFANA.md)
- [Access Grafana](docs/grafana/ACCESS_GRAFANA.md)

Enjoy your new monitoring dashboards! 📊

