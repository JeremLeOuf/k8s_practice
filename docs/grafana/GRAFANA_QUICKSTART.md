# 🚀 Grafana Monitoring - Quick Start

## 1️⃣ Start Grafana (1 minute)

```bash
cd grafana
./setup-grafana.sh
```

Wait for "Grafana is starting!"

**Access:** http://localhost:3000  
**Login:** admin / admin

## 2️⃣ Configure CloudWatch (1 minute)

```bash
./setup-cloudwatch-datasource.sh
```

Enter your AWS credentials when prompted.

## 3️⃣ Create Your First Panel

### Invocations Panel:
1. Click "Add visualization"
2. Data source: CloudWatch
3. Configure:
   - Namespace: `AWS/Lambda`
   - Metric: `Invocations`
   - Dimensions: FunctionName = `pkb-api-get-items`
   - Statistic: `Sum`
4. Click "Apply"

### Errors Panel:
Same as above, but use metric: `Errors`

## 4️⃣ Generate Some Traffic

```bash
curl https://f31rkf170i.execute-api.us-east-1.amazonaws.com/prod/items
```

Watch metrics update in real-time! 📊

## 🎉 Done!

You now have:
- ✅ Real-time Lambda monitoring
- ✅ Error tracking
- ✅ Performance metrics
- ✅ Cost visibility

## 📚 More Info

- Full guide: `GRAFANA_SETUP.md`
- Grafana docs: `grafana/README.md`

## 🆘 Troubleshooting

**No data?**  
- Invoke Lambda functions to generate metrics
- Check AWS credentials
- Verify region is `us-east-1`

**Grafana won't start?**  
```bash
docker ps
docker-compose logs -f
```

**CloudWatch connection fails?**  
- Verify AWS credentials
- Check IAM permissions
- Run: `aws cloudwatch list-metrics`
