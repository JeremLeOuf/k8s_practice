# AWS Free Tier Usage

This project is configured to stay within AWS Free Tier limits.

## Current Configuration

### ✅ Lambda (AWS Free Tier)
- **Memory**: 128 MB per function (minimum)
- **Timeout**: 3 seconds per function
- **Runtime**: Python 3.9
- **Free Tier Limits**:
  - 1 million requests per month
  - 400,000 GB-seconds of compute time per month
  - **Estimated cost**: $0/month for typical usage (< 1M requests)

### ✅ API Gateway (AWS Free Tier)
- **Type**: REST API
- **Deployment**: Regional endpoint
- **Free Tier Limits**:
  - 1 million API calls per month
  - **Estimated cost**: $0/month for typical usage (< 1M requests)

### ✅ DynamoDB (AWS Free Tier)
- **Billing Mode**: On-demand (PAY_PER_REQUEST)
- **Free Tier Limits**:
  - 25 GB storage free
  - 25 read capacity units (RCU) and 25 write capacity units (WCU) free per month
  - On-demand mode means you only pay for what you use beyond free tier
  - **Estimated cost**: $0/month for typical usage (< 25 GB, < 200M read/write requests)

## Free Tier Limits Summary

| Service | Free Tier Limit | Your Usage | Cost |
|---------|----------------|------------|------|
| Lambda | 1M requests/month | ~0-1000/month | **$0** |
| API Gateway | 1M requests/month | ~0-1000/month | **$0** |
| DynamoDB | 25GB storage + 25 RCU/WCU | < 1GB, minimal | **$0** |
| **TOTAL** | | | **$0/month** |

## Monitoring Free Tier Usage

### Check Lambda Usage
```bash
aws lambda get-account-settings
```

### Check API Gateway Metrics
```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApiGateway \
  --metric-name Count \
  --dimensions Name=ApiName,Value=pkb-api \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-02-01T00:00:00Z \
  --period 3600 \
  --statistics Sum
```

### Check DynamoDB Usage
```bash
aws dynamodb describe-table --table-name PersonalKnowledgeBase --query 'Table.{Size:TableSizeBytes}'
```

## Staying Within Free Tier

### Current Setup Ensures:
1. ✅ **Lambda functions**: 128MB memory, 3s timeout (minimal usage)
2. ✅ **DynamoDB**: On-demand billing (no provisioned capacity)
3. ✅ **API Gateway**: Standard REST API (not private)
4. ✅ **No CloudWatch alarms or custom metrics** (reduces costs)

### To Keep Costs at $0:
- Keep requests under 1M/month per service
- Store under 25GB in DynamoDB
- Use simple logging (CloudWatch basic monitoring)

### If You Need to Scale:
If you expect high usage, consider:
- Using provisioned capacity for DynamoDB (may incur costs)
- Increasing Lambda timeout for long-running processes
- Using provisioned concurrency (may incur costs)
- Adding CloudWatch metrics and alarms (minimal cost)

## Billing Alerts (Recommended)

Set up billing alerts to monitor costs:
1. Go to AWS Billing Dashboard
2. Create a budget with threshold alerts
3. Set alert at $1/month

```bash
# Create a billing budget (requires AWS CLI v2)
aws budgets create-budget \
  --account-id YOUR_ACCOUNT_ID \
  --budget file://budget.json \
  --notifications-with-subscribers file://notifications.json
```

## Cleanup

To completely remove all resources and stop all costs:
```bash
cd infrastructure
terraform destroy
```

This will delete all AWS resources created by this project.

## Resources

- [AWS Lambda Pricing](https://aws.amazon.com/lambda/pricing/)
- [API Gateway Pricing](https://aws.amazon.com/api-gateway/pricing/)
- [DynamoDB Pricing](https://aws.amazon.com/dynamodb/pricing/)
- [AWS Free Tier](https://aws.amazon.com/free/)

