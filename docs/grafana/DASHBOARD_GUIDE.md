# 📊 Grafana Dashboard Guide

## Overview

Your project now includes **3 professional Grafana dashboards** for monitoring your serverless applications:

1. **🚀 Serverless Monitoring** - Basic real-time monitoring
2. **🎯 Advanced Serverless v2** - Advanced analytics and insights
3. **📈 Budget Tracker** - Budget tracking monitoring

## Dashboard Features

### 🚀 Serverless Monitoring (Basic)

**Location:** `grafana/dashboards/serverless-monitoring.json`

**Panels:**
- 📊 Lambda Invocations - Request count over time
- ⚠️ Lambda Errors - Error tracking
- ⚡ Performance Table - Response time metrics
- 🚦 Throttles & Concurrency - Capacity monitoring
- 📈 Total Invocations (3 gauges - one per function)
- ⚠️ Total Errors - Error summary

**Refresh:** Every 30 seconds  
**Time Range:** Last 1 hour (default)

### 🎯 Advanced Serverless v2 (Advanced)

**Location:** `grafana/dashboards/advanced-serverless-v2.json`

**Panels:**
- 🔥 Request Rate - Stacked bar chart by endpoint (GET/POST/DELETE)
- ⚠️ Error Rate - All functions combined
- ⚡ Response Time - Average vs Maximum
- 📊 Performance Summary - Table with Avg & Max duration
- 💾 Memory Usage % - Memory utilization gauge
- 🚦 Total Throttles - Capacity issues
- 📊 Request Distribution - Pie chart (last hour)
- ✅ Success Rate Gauge - Overall health
- 📈 24-Hour Summary - Detailed table with error rates
- 🔥 Concurrent Executions - Peak usage

**Refresh:** Every 5 seconds  
**Time Range:** Last 6 hours (default)

**Special Features:**
- ⭐ **Links to AWS Console** - Direct navigation to CloudWatch, Lambda, API Gateway
- 🔄 **Real-time updates** - Auto-refresh every 5 seconds
- 📊 **Multiple visualization types** - Bars, lines, tables, gauges, pie charts
- 🎨 **Color-coded thresholds** - Green/yellow/red for easy status reading

### 📈 Budget Tracker (Future)

**Location:** To be created

**Planned Panels:**
- 💰 Current Balance
- 📊 Income vs Expenses
- 🎯 Budget Threshold Alerts
- 📈 Monthly Trends

## How to Import Dashboards

### Method 1: Via UI (Recommended)

1. **Access Grafana:**
   ```bash
   ./scripts/access-grafana.sh
   ```

2. **Import Dashboard:**
   - Click "+" → "Import"
   - Click "Upload JSON file"
   - Select `grafana/dashboards/advanced-serverless-v2.json`
   - Click "Import"

3. **Select Data Source:**
   - Choose "CloudWatch" data source
   - Click "Import"

### Method 2: Automatic (Via ConfigMap)

The Kubernetes ConfigMap auto-loads dashboards:

```bash
kubectl apply -f kubernetes/grafana-configmap-dashboards.yaml
```

## Understanding the Metrics

### Key Metrics to Watch

#### 1. **Invocations**
- **What:** Number of times functions are called
- **Good:** Consistent, growing trend
- **Bad:** Sudden spikes or drops

#### 2. **Duration**
- **What:** How long functions take to execute
- **Good:** < 500ms average
- **Bad:** > 1s average or > 3s max

#### 3. **Errors**
- **What:** Function failures
- **Good:** 0 errors
- **Bad:** Any non-zero value

#### 4. **Throttles**
- **What:** Functions being rate-limited
- **Good:** 0 throttles
- **Bad:** Any throttles (indicates scaling issues)

#### 5. **Concurrent Executions**
- **What:** How many functions running simultaneously
- **Good:** Stable, within limits
- **Bad:** Reaching concurrency limits

## Dashboard Customization

### Change Time Range

1. Click the time selector (top-right)
2. Choose:
   - Last 5 minutes (for debugging)
   - Last 15 minutes (for detailed view)
   - Last 6 hours (for overview)
   - Last 7 days (for trends)

### Add Custom Panels

1. Click "Add panel" (top-right)
2. Select visualization type:
   - **Time series** - For trends over time
   - **Stat** - For single values
   - **Table** - For tabular data
   - **Gauge** - For progress/meters
   - **Pie chart** - For distribution

3. Configure query:
   - Datasource: CloudWatch
   - Namespace: AWS/Lambda
   - Metric: Choose (e.g., Invocations, Duration, Errors)
   - Function: Select your Lambda function
   - Statistic: Sum, Average, Maximum, etc.

### Set Up Alerts

1. Click "Alert" icon on a panel
2. Configure:
   - **Condition:** When metric exceeds threshold
   - **Notifications:** Email, Slack, PagerDuty
   - **Message:** Custom alert text

**Example Alert:**
```
IF Invocations == 0 for 5 minutes
THEN Send email: "API appears down"
```

## Troubleshooting

### No Data Showing

**Check:**
1. CloudWatch data source configured?
2. Lambda functions deployed?
3. Functions actually invoked?
4. Region matches? (should be `us-east-1`)

**Fix:**
```bash
# Invoke a function to generate data
aws lambda invoke \
  --function-name pkb-api-get-items \
  --payload '{}' \
  /tmp/response.json

# Wait 1-2 minutes, then refresh Grafana
```

### Wrong Function Names

**Check:** Dashboard JSON uses these function names:
- `pkb-api-get-items`
- `pkb-api-create-item`
- `pkb-api-delete-item`

**Fix:** Update the `dimensions.FunctionName` in each panel

### CloudWatch No Data

**Reasons:**
- No invocations yet
- Wrong region
- No permissions

**Debug:**
```bash
# Check if data exists
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Invocations \
  --dimensions Name=FunctionName,Value=pkb-api-get-items \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 60 \
  --statistics Sum

# Check permissions
aws iam get-user | jq '.User.UserName'
```

## Dashboard Best Practices

### 1. **Keep Refresh Reasonable**
- 5s for real-time dashboards
- 30s for overview dashboards
- 5m for trending dashboards

### 2. **Use Colors Effectively**
- 🟢 Green = Good (nominal)
- 🟡 Yellow = Warning (needs attention)
- 🔴 Red = Critical (action required)

### 3. **Organize by Theme**
- Top row: Key metrics (KPIs)
- Middle rows: Detailed breakdowns
- Bottom row: Summary tables

### 4. **Add Links**
- Link to AWS Console for drilling down
- Link to documentation for context
- Link to runbooks for incident response

### 5. **Set Meaningful Titles**
- Include emoji for quick scanning
- Be specific (e.g., "🔥 Request Rate" not just "Requests")
- Add units (ms, req/min, %)

## Next Steps

1. **Import Both Dashboards:**
   ```bash
   ./scripts/access-grafana.sh
   # Then import via UI
   ```

2. **Customize for Your Use Case:**
   - Add Budget Tracker metrics
   - Add API Gateway metrics
   - Add DynamoDB metrics

3. **Set Up Alerts:**
   - Error rate > 1%
   - Duration > 1s
   - Throttles > 0

4. **Share with Team:**
   - Export dashboards
   - Commit to Git
   - Deploy via ConfigMap

## Resources

- [Grafana CloudWatch Plugin Docs](https://grafana.com/grafana/plugins/grafana-cloudwatch-datasource/)
- [AWS Lambda Metrics Reference](https://docs.aws.amazon.com/lambda/latest/dg/monitoring-metrics.html)
- [Grafana Dashboard Best Practices](https://grafana.com/docs/grafana/latest/best-practices/)

## Questions?

Check out:
- `docs/grafana/ACCESS_GRAFANA.md` - How to access
- `docs/grafana/SETUP_GRAFANA.md` - Setup guide
- `docs/grafana/IMPORT_DASHBOARDS.md` - Import instructions

Enjoy monitoring! 📊

