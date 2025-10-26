# 🚀 Grafana Dashboards - Quick Start

## ⚡ Quick Access

```bash
# 1. Port-forward to Grafana
./scripts/access-grafana.sh

# 2. Open Grafana
# URL: http://localhost:3000
# Login: admin / admin
```

## 📊 Available Dashboards

### 1. 🚀 Real-Time Monitoring
**Perfect for**: Live health checks, immediate alerts

**Features**:
- 📊 Request rate per function
- ⚠️ Error tracking in real-time
- ⚡ Performance metrics
- 🚦 Throttle indicators
- 📈 Gauge panels for quick status

**Use Cases**:
- During load testing
- Debugging issues
- Real-time health monitoring
- Quick status checks

### 2. 🎯 Advanced Serverless Dashboard
**Perfect for**: Deep analysis, trend spotting

**Features**:
- 🔥 Request patterns (bar chart)
- ⚡ Response time analysis (smooth curves)
- 💾 Resource utilization
- 📋 Function summary table
- ✅ Success rate tracking
- 🔥 Concurrency monitoring

**Use Cases**:
- Performance analysis
- Capacity planning
- Historical trending
- Root cause analysis

## 🔧 Setup (One-Time)

### Step 1: Configure CloudWatch Data Source
```
Grafana → Configuration (⚙️) → Data Sources → Add data source
→ Select: CloudWatch
→ Configure:
  - Access Key ID: (your AWS key)
  - Secret Access Key: (your AWS secret)
  - Default Region: us-east-1
→ Save & Test ✅
```

### Step 2: Import Dashboards
The dashboards are already in the ConfigMap! Just:

1. **Access Grafana**: `./scripts/access-grafana.sh`
2. **Go to Dashboards**: Click "Dashboards" in sidebar
3. **Browse**: Find your dashboards
4. **Open**: Click to view

### Step 3: Generate Some Traffic
```bash
# Make some API calls to generate metrics
curl https://your-api-url/items
curl -X POST https://your-api-url/items -d '{"title":"test","content":"data"}'
curl -X DELETE https://your-api-url/items/{id}
```

## 🎓 What You'll Learn

### Visualizations
- **Time Series**: Understanding trends over time
- **Bar Charts**: Comparing request volumes
- **Line Charts**: Tracking performance
- **Gauges**: Quick status indicators
- **Tables**: Detailed breakdowns

### Grafana Features
- **Refresh Intervals**: 10s, 30s, 1m
- **Time Ranges**: Auto, Last hour, Last 6h
- **Panel Editing**: Modify queries in real-time
- **Thresholds**: Green/Yellow/Red indicators
- **Annotations**: Mark important events

### AWS Integration
- **CloudWatch Metrics**: Lambda performance
- **Dimensions**: Function-specific filtering
- **Statistics**: Sum, Average, Min, Max
- **Periods**: 1m, 5m, 1h aggregation
- **Regions**: us-east-1

## 💡 Practice Exercises

### Exercise 1: Read the Dashboards
1. Look at Lambda Invocations panel
2. Identify which function gets most traffic
3. Check if any errors occurred
4. Note the response times

### Exercise 2: Modify Time Range
1. Change from "Last 1 Hour" to "Last 6 Hours"
2. Observe how patterns change
3. Compare peak vs off-peak traffic

### Exercise 3: Add a Panel
1. Click "+" in dashboard
2. Add query: `AWS/Lambda` → `Throttles`
3. Configure statistics: Sum
4. Save panel
5. Position it in the grid

### Exercise 4: Create an Alert
1. Edit any panel
2. Go to "Alert" tab
3. Create rule:
   - When errors > 0
   - Notify if it happens 3 times in 5 minutes
4. Save alert rule

## 📈 Understanding the Metrics

### Invocations
- What: Number of Lambda function calls
- Why: Track API usage
- Healthy: Consistent or predictable patterns

### Errors
- What: Failed Lambda executions
- Why: System health indicator
- Healthy: Zero errors (or expected failures handled)

### Duration
- What: Execution time in milliseconds
- Why: Performance indicator
- Healthy: < 500ms average

### Throttles
- What: Rejected requests due to concurrency limits
- Why: Capacity indicator
- Healthy: Zero throttles

### Memory Utilization
- What: RAM usage percentage
- Why: Optimization opportunity
- Healthy: 50-80% utilization

## 🎯 Pro Tips

1. **Use Refresh**: Auto-refresh keeps data current
2. **Adjust Time Ranges**: Different ranges reveal different insights
3. **Pin Favorite**: Star dashboards you use often
4. **Export**: Save your dashboards as JSON
5. **Share**: Generate shareable links
6. **Annotate**: Mark deployments and incidents

## 🚨 Common Issues

### No Data Showing
- **Check**: CloudWatch data source configured
- **Check**: Time range has data
- **Check**: Function names match

### Empty Panels
- **Wait**: Metrics need time to accumulate
- **Verify**: Make some API calls first
- **Refresh**: Click refresh icon

### Wrong Region
- **Fix**: Update data source region to `us-east-1`
- **Confirm**: Check AWS resources are in us-east-1

## 📚 Next Steps

1. Generate traffic with API calls
2. Watch dashboards populate
3. Experiment with different time ranges
4. Create your own custom panels
5. Set up alerts for errors
6. Build a custom dashboard for budget tracker

Happy monitoring! 🎉

