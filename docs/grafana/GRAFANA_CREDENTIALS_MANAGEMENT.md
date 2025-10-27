# Grafana CloudWatch Credentials Management

## Problem

After a `terraform destroy` and `terraform apply` cycle, the Grafana CloudWatch datasource becomes invalid because:
1. The IAM user `pkb-grafana-cloudwatch` is recreated
2. New access keys need to be generated
3. The Grafana datasource still uses the old (deleted) credentials

## Solution

Automatically regenerate and update AWS credentials after each deployment cycle.

## How It Works

### 1. Automatically During Deployment

When you deploy via GitHub Actions:
```yaml
- name: Setup Grafana CloudWatch Credentials
  run: ./scripts/setup-grafana-cloudwatch-datasource.sh
```

This step:
- Checks if IAM user exists (must be created by Terraform first)
- Lists existing access keys
- Deletes old key if user already has one (AWS limit: 2 keys per user)
- Creates a new access key
- Saves credentials to `grafana/.env.aws`

### 2. Update Grafana Datasource

The datasource configuration is automatically updated with the new credentials by updating:
- `grafana/provisioning/datasources/cloudwatch.yml`

## Manual Setup

### If Deployment Succeeds But Grafana Still Shows Invalid Datasource

Run the credential setup manually:

```bash
# 1. Generate new credentials
./scripts/setup-grafana-cloudwatch-datasource.sh

# 2. Update Grafana datasource configuration
./scripts/update-grafana-datasource-credentials.sh

# 3. Restart Grafana (if using Docker)
cd grafana
docker-compose restart grafana
```

### If You Need to Manually Configure Credentials

1. **Get current credentials:**
   ```bash
   cat grafana/.env.aws
   ```

2. **Update Grafana datasource manually:**
   - Go to http://localhost:3000/datasources
   - Click on "CloudWatch"
   - Update:
     - Access Key ID: (from `.env.aws`)
     - Secret Access Key: (from `.env.aws`)
   - Click "Save & Test"

3. **Or update the provisioning file directly:**
   ```bash
   # Edit grafana/provisioning/datasources/cloudwatch.yml
   # Replace the secureJsonData section with new credentials
   # Then restart Grafana
   docker-compose restart grafana
   ```

## Troubleshooting

### Error: "IAM user not found"

**Cause:** Terraform hasn't created the IAM user yet.

**Solution:**
```bash
cd infrastructure
terraform apply
```

### Error: "Already has 2 access keys"

**Cause:** AWS limits to 2 active access keys per IAM user.

**Solution:**
```bash
# List existing keys
aws iam list-access-keys --user-name pkb-grafana-cloudwatch

# Delete an old key
aws iam delete-access-key --user-name pkb-grafana-cloudwatch --access-key-id KEY_ID

# Then run setup again
./scripts/setup-grafana-cloudwatch-datasource.sh
```

### Error: "Credentials file not found"

**Cause:** Script hasn't been run or file was deleted.

**Solution:**
```bash
# Run the setup script
./scripts/setup-grafana-cloudwatch-datasource.sh
```

### Datasource Still Invalid After Update

**Possible causes:**

1. **Grafana cached the old credentials:**
   ```bash
   # Restart Grafana
   docker-compose restart grafana
   # Or if using docker run
   docker restart grafana
   ```

2. **Credentials are correct but permissions missing:**
   - Check IAM policy is attached to user
   - Verify policy has CloudWatch read permissions

3. **Region mismatch:**
   - Ensure datasource uses `us-east-1`
   - Check IAM user policy allows all regions or specifically `us-east-1`

## Verification

### Test AWS Credentials

```bash
# Load credentials
source grafana/.env.aws

# Test CloudWatch access
aws cloudwatch list-metrics \
  --namespace AWS/Lambda \
  --region us-east-1

# Test logs access  
aws logs describe-log-groups \
  --region us-east-1
```

### Test Grafana Datasource

1. Open Grafana: http://localhost:3000
2. Go to Configuration → Data Sources
3. Click on "CloudWatch"
4. Click "Save & Test"
5. Should see: "✅ Successfully queried the CloudWatch API"

### Test Dashboard

1. Go to Dashboards
2. Open any dashboard
3. Should see CloudWatch metrics loading

## Security Notes

### Credentials Storage

Credentials are stored in:
- `grafana/.env.aws` - Never commit this file (should be in `.gitignore`)
- `grafana/provisioning/datasources/cloudwatch.yml` - Contains plain credentials (GitHub Actions only)

### Credentials in Git

⚠️ **Important:** The `.env.aws` file should never be committed to git.

Make sure `.gitignore` includes:
```
grafana/.env.aws
```

### Rotating Credentials

You can manually rotate credentials anytime:

```bash
# 1. Delete old key
aws iam list-access-keys --user-name pkb-grafana-cloudwatch
aws iam delete-access-key --user-name pkb-grafana-cloudwatch --access-key-id OLD_KEY

# 2. Create new key
./scripts/setup-grafana-cloudwatch-datasource.sh

# 3. Update Grafana
./scripts/update-grafana-datasource-credentials.sh

# 4. Restart Grafana
docker-compose restart grafana
```

## Best Practices

### 1. Automate in CI/CD

The GitHub Actions workflow automatically handles credentials, so you don't need to manually update them.

### 2. Use Terraform Output

After deployment, credentials are automatically:
- ✅ Generated
- ✅ Saved locally
- ✅ Available in CI/CD artifacts

### 3. Monitor Credential Expiration

AWS access keys don't expire, but you should rotate them periodically:
- Every 90 days for production
- After team member leaves
- If credentials are compromised

### 4. Separate Credentials Per Environment

For production, consider separate IAM users per environment:
- `pkb-grafana-cloudwatch-dev`
- `pkb-grafana-cloudwatch-staging`
- `pkb-grafana-cloudwatch-prod`

## Summary

The credential management system:
- ✅ Automatically generates new credentials after destroy/deploy
- ✅ Updates Grafana datasource configuration
- ✅ Handles AWS 2-key limit
- ✅ Saves credentials securely
- ✅ Works in CI/CD pipeline

You no longer need to manually update Grafana credentials after deployments! 🎉

## Quick Reference

```bash
# Setup credentials (run after terraform apply)
./scripts/setup-grafana-cloudwatch-datasource.sh

# Update datasource configuration
./scripts/update-grafana-datasource-credentials.sh

# Restart Grafana
cd grafana && docker-compose restart grafana

# Check credentials
cat grafana/.env.aws

# Test CloudWatch access
source grafana/.env.aws && aws cloudwatch list-metrics --namespace AWS/Lambda
```

