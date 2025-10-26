# 🧹 CloudFront Cleanup Strategy

## Overview

To prevent accumulation of old CloudFront distributions during repeated deployments, this project now includes an automated cleanup strategy that removes old distributions before creating new ones.

## How It Works

### 1. **Pre-Deployment Cleanup** 

Before each `terraform apply`, a cleanup script runs that:

1. **Identifies old distributions** - Finds CloudFront distributions matching your project tag
2. **Disables them** - Marks distributions as disabled (required before deletion)
3. **Deletes them** - Schedules distributions for deletion

### 2. **Lifecycle Management**

The CloudFront resource in `infrastructure/frontend.tf` includes:

```hcl
lifecycle {
  create_before_destroy = true
}
```

This ensures new distributions are created before old ones are deleted, preventing downtime.

### 3. **Project Tags**

CloudFront distributions are tagged with:
- `Name`: "Personal Knowledge Base Frontend"
- `Environment`: variable value
- `Project`: variable value

This allows the cleanup script to identify distributions belonging to this repo.

## What the Script Does

`scripts/cleanup-old-cloudfront.sh`:

1. Finds distributions with matching `Comment` field
2. Checks if they're already disabled
3. Disables active distributions (if needed)
4. Waits for disabling to complete
5. Deletes distributions

## CI/CD Integration

The cleanup runs automatically in the GitHub Actions pipeline:

```yaml
- name: Cleanup Old CloudFront Distributions
  run: |
    echo "🧹 Cleaning up old CloudFront distributions..."
    chmod +x scripts/cleanup-old-cloudfront.sh
    ./scripts/cleanup-old-cloudfront.sh || echo "⚠️ Cleanup failed, continuing..."
  continue-on-error: true
```

**Note:** `continue-on-error: true` ensures deployments proceed even if cleanup fails (e.g., due to network issues).

## CloudFront Deletion Timeline

CloudFront distributions take **15-20 minutes** to fully delete. The cleanup script:

1. Starts the deletion process
2. Returns immediately (doesn't wait)
3. Terraform creates a new distribution
4. Old distribution completes deletion in background

## Manual Cleanup

If you need to manually cleanup old distributions:

```bash
./scripts/cleanup-old-cloudfront.sh
```

Or delete specific distributions:

```bash
# List distributions
aws cloudfront list-distributions --query "DistributionList.Items[*].[Id,Comment,Status]"

# Disable a distribution
aws cloudfront get-distribution-config --id DIST_ID > config.json
# Edit config.json to set "Enabled": false
aws cloudfront update-distribution --id DIST_ID --distribution-config file://config.json --if-match ETAG

# Delete distribution (after it's disabled)
aws cloudfront delete-distribution --id DIST_ID --if-match ETAG
```

## Troubleshooting

### Error: "Distribution not found"
- Distribution may have already been deleted
- Check AWS Console for active distributions

### Error: "Cannot delete distribution, it's not disabled"
- Script will automatically disable it first
- Wait up to 15 minutes for disabling to complete

### Script takes too long
- CloudFront operations can take 15-20 minutes
- Script times out after 5 minutes of waiting
- Distribution deletion continues in background

### Multiple distributions still exist
- Cleanup runs before each deployment
- Old distributions are marked for deletion
- Terraform `create_before_destroy` creates new one immediately
- Old distributions delete in background (no impact)

## Best Practices

1. **Always tag distributions** - Makes cleanup reliable
2. **Run cleanup before apply** - Ensures clean state
3. **Use `create_before_destroy`** - Prevents downtime
4. **Ignore transient failures** - Continue deployment even if cleanup fails

## Cost Impact

**Good news**: CloudFront distributions don't cost anything when they're disabled or being deleted. Only active distributions with traffic incur costs.

This cleanup strategy ensures you don't accumulate orphaned distributions over time, keeping your AWS account clean.

## Limitations

- Cleanup script looks for specific `Comment` field: "Personal Knowledge Base Frontend"
- Only works for distributions created by this repo
- Doesn't delete manually created distributions
- Requires AWS CLI and `jq` to be installed

## Future Enhancements

Possible improvements:
- [ ] Use Terraform `aws_cloudfront_distribution` data source to find old distributions
- [ ] Add support for multiple projects/environments
- [ ] Implement distributed locking to prevent race conditions
- [ ] Add notification for successful cleanup

