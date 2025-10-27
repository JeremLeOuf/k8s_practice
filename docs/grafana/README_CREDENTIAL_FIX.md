# Grafana Credential Fix - Quick Reference

## TL;DR

After `terraform destroy` and `terraform apply`, run:

```bash
./scripts/setup-grafana-cloudwatch-datasource.sh
./scripts/update-grafana-datasource-credentials.sh
cd grafana && docker-compose restart grafana
```

## What Was The Problem?

After destroying and recreating infrastructure:
- The IAM user `pkb-grafana-cloudwatch` gets deleted and recreated
- All access keys are deleted
- Grafana still tries to use the old (deleted) credentials
- Datasource becomes invalid ❌

## What's The Solution?

Two scripts that automatically:
1. ✅ Generate new AWS credentials
2. ✅ Save them securely 
3. ✅ Update Grafana configuration

## Usage

### Option 1: After Manual Deploy

```bash
# After terraform apply
./scripts/setup-grafana-cloudwatch-datasource.sh
./scripts/update-grafana-datasource-credentials.sh

# Restart Grafana
cd grafana
docker-compose restart grafana

# Verify in Grafana UI
# Go to: http://localhost:3000/datasources → CloudWatch → Save & Test
```

### Option 2: Automated (GitHub Actions)

The deploy workflow now automatically runs the credential setup step, so credentials are generated for you.

### Option 3: Just Update Credentials Manually

1. Get credentials: `cat grafana/.env.aws`
2. Go to Grafana: http://localhost:3000/datasources
3. Click "CloudWatch"
4. Update Access Key ID and Secret Access Key
5. Click "Save & Test"

## Files Created

- `scripts/setup-grafana-cloudwatch-datasource.sh` - Generate credentials
- `scripts/update-grafana-datasource-credentials.sh` - Update datasource
- `docs/grafana/GRAFANA_CREDENTIALS_MANAGEMENT.md` - Full documentation
- `docs/grafana/CREDENTIAL_AUTO_REGEN_SOLUTION.md` - Technical details

## That's It!

Credentials are now automatically regenerated after destroy/deploy cycles. No more invalid datasource errors! 🎉

