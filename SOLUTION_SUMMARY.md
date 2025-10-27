# Solution Summary: Grafana Credentials After Destroy/Deploy

## Problem
After running `terraform destroy` followed by `terraform apply`, the Grafana CloudWatch datasource becomes invalid because AWS credentials are deleted when the IAM user is destroyed.

## Solution Implemented

### 1. Automatic Credential Generation
**Script:** `scripts/setup-grafana-cloudwatch-datasource.sh`
- Checks if IAM user exists
- Deletes old access key if needed (AWS limit: 2 keys/user)
- Creates new access key
- Saves credentials to `grafana/.env.aws`

### 2. Datasource Configuration Update
**Script:** `scripts/update-grafana-datasource-credentials.sh`
- Reads credentials from `.env.aws`
- Updates Grafana datasource configuration
- Injects actual credentials into the YAML file

### 3. GitHub Actions Integration
**File:** `.github/workflows/deploy.yml`
- Added step to automatically run credential setup after infrastructure deployment
- Handles failures gracefully

### 4. Security
- Added `.env.aws` to `.gitignore`
- Credentials never committed to git
- Scripts make files readable only by owner (600)

## How To Use

After destroying and redeploying infrastructure:

```bash
# Step 1: Generate new credentials
./scripts/setup-grafana-cloudwatch-datasource.sh

# Step 2: Update Grafana datasource
./scripts/update-grafana-datasource-credentials.sh

# Step 3: Restart Grafana
cd grafana && docker-compose restart grafana
```

Or just update manually in Grafana UI:
1. Get credentials: `cat grafana/.env.aws`
2. Go to: http://localhost:3000/datasources
3. Edit CloudWatch datasource
4. Update credentials
5. Save & Test

## Documentation

- `docs/grafana/GRAFANA_CREDENTIALS_MANAGEMENT.md` - Full guide
- `docs/grafana/CREDENTIAL_AUTO_REGEN_SOLUTION.md` - Technical details
- `docs/grafana/README_CREDENTIAL_FIX.md` - Quick reference

## Summary

✅ Credentials now automatically regenerated after destroy/deploy  
✅ No manual intervention needed (if using GitHub Actions)  
✅ Secure credential storage (never committed)  
✅ Works locally and in CI/CD  

The datasource will remain valid after infrastructure changes! 🎉

