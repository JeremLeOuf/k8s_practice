# Importing Advanced Grafana Dashboards

## Dashboards Created

I've created **2 amazing Grafana dashboards** for your serverless app:

### 1. 🚀 Real-Time Monitoring Dashboard
- **File**: `grafana/dashboards/serverless-monitoring.json`
- **Refresh**: 30 seconds
- **Time Range**: Last 1 hour

**Panels**:
- 📊 Lambda Invocations (time series)
- ⚠️ Lambda Errors (error tracking)
- ⚡ Duration Performance (table)
- 🚦 Throttles & Concurrency
- 📈 Individual function gauges
- ⚠️ Total error counter

### 2. 🎯 Advanced Serverless Dashboard
- **File**: `grafana/dashboards/advanced-serverless-dashboard.json`
- **Refresh**: 10 seconds
- **Time Range**: Last 6 hours

**Panels**:
- 🔥 Request Rate (bar chart)
- ⚡ Response Time (smooth line)
- ⚠️ Error Rate (tracked over time)
- 💾 Memory Utilization (bar gauge)
- ⏱️ Performance Metrics (current values)
- 🔥 Concurrent Executions
- 📋 Function Summary Table
- ✅ Success Rate Gauge

## How to Import

### Option 1: Via Grafana UI

1. **Access Grafana**:
   ```bash
   ./scripts/access-grafana.sh
   # Then visit http://localhost:3000
   ```

2. **Import Dashboard**:
   - Click `+` → `Import`
   - Click `Upload JSON file`
   - Select: `grafana/dashboards/serverless-monitoring.json`
   - Click `Import`

3. **Repeat for Advanced Dashboard**:
   - Import: `grafana/dashboards/advanced-serverless-dashboard.json`

### Option 2: Via kubectl (Automatic)

```bash
# Apply the ConfigMap
kubectl apply -f kubernetes/grafana-configmap-dashboards.yaml

# Restart Grafana to load dashboards
kubectl rollout restart deployment/grafana -n grafana

# Port-forward again
./scripts/access-grafana.sh
```

### Option 3: Import via API

```bash
# Get Grafana URL
kubectl port-forward -n grafana svc/grafana-service 3000:3000 &

# Import dashboard (replace <dashboard-id>)
curl -X POST http://localhost:3000/api/dashboards/db \
  -H "Content-Type: application/json" \
  -d @grafana/dashboards/serverless-monitoring.json
```

## Configure CloudWatch Data Source First!

Before the dashboards work, you **must** configure the CloudWatch data source:

### 1. Get AWS Credentials
```bash
# Create IAM access key for Grafana user
aws iam create-access-key --user-name pkb-grafana-cloudwatch
```

### 2. Add CloudWatch Data Source
1. Go to Grafana → **Configuration** (gear icon) → **Data Sources**
2. Click **Add data source**
3. Select **CloudWatch**
4. Configure:
   - **Name**: AWS CloudWatch
   - **Auth Provider**: Access & secret key
   - **Access Key ID**: `<from step 1>`
   - **Secret Access Key**: `<from step 1>`
   - **Default Region**: `us-east-1`
5. Click **Save & Test**

## Using the Dashboards

### Real-Time Monitoring Dashboard
Perfect for:
- Quick health checks
- Live monitoring during load tests
- Alert setup
- 1-hour view of activity

### Advanced Dashboard
Perfect for:
- Deep performance analysis
- Trend identification
- Capacity planning
- 6-hour historical view

## Features to Practice

### 1. Time Series Visualizations
- **Bar Charts**: See request patterns
- **Line Charts**: Track performance trends
- **Area Charts**: Visualize throughput

### 2. Gauge Panels
- **Individual Metrics**: Per-function stats
- **Total Counters**: Aggregate views
- **Success Rates**: Health indicators

### 3. Tables
- **Summary Views**: All functions at once
- **Sortable**: Click headers to sort
- **Formatted**: Human-readable values

### 4. Thresholds
- **Green**: Healthy (< 500ms duration)
- **Yellow**: Warning (500-1000ms)
- **Red**: Critical (> 1000ms)

### 5. Refresh Intervals
- **30s**: Standard monitoring
- **10s**: Real-time dashboards
- **1m**: Historical analysis

## Customizing the Dashboards

### Add More Metrics
```json
{
  "alias": "Your Custom Metric",
  "dimensions": {
    "FunctionName": "your-function-name"
  },
  "metricName": "MetricName",
  "namespace": "AWS/Lambda",
  "period": "1m",
  "refId": "X",
  "region": "us-east-1",
  "statistics": ["Sum", "Average"]
}
```

### Change Time Ranges
- Edit `"time": { "from": "now-1h" }` to different ranges:
  - `now-5m` (5 minutes)
  - `now-1h` (1 hour)
  - `now-6h` (6 hours)
  - `now-24h` (24 hours)
  - `now-7d` (7 days)

### Add Alerts
1. Click panel title → Edit
2. Go to **Alert** tab
3. Create rule:
   - When: `last()`
   - Of: `query`
   - Is: `above`, `1000`
4. Add notification channel

## Monitoring Best Practices

### Key Metrics to Watch
1. **Invocations**: Request volume
2. **Errors**: System health
3. **Duration**: Performance
4. **Throttles**: Resource limits
5. **Memory**: Utilization
6. **Concurrent Executions**: Load

### Alert Thresholds
- **Errors > 0**: Immediate attention
- **Duration > 1000ms**: Performance issue
- **Throttles > 10**: Scale up needed
- **Memory > 80%**: Optimization needed

## Next Steps

1. Import both dashboards
2. Configure CloudWatch data source
3. Let data flow for a few minutes
4. Experiment with different time ranges
5. Create custom dashboards
6. Set up alerts for critical metrics

## Troubleshooting

### "No data" in panels?
- Check CloudWatch data source is configured
- Verify AWS credentials
- Confirm Lambda functions are being invoked
- Check time range (data might be outside range)

### Dashboards not showing?
- Restart Grafana: `kubectl rollout restart deployment/grafana -n grafana`
- Check dashboard is imported: Go to Dashboards → Browse
- Verify ConfigMap was applied

### Can't import?
- Make sure you're logged in as admin
- Check file format (valid JSON)
- Use Import UI instead of API if needed

Enjoy your advanced monitoring setup! 🎉

