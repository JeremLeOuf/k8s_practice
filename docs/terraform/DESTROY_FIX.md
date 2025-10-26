# Destroy Workflow Fixes

## Problems Fixed

### 1. IAM Policy Attachment Errors
**Error**: `Cannot delete a policy attached to entities`

**Cause**: IAM policies were still attached to users/roles when Terraform tried to delete them.

**Solution**: Added a cleanup step that detaches policies before destroy.

### 2. S3 Bucket Not Empty
**Error**: `BucketNotEmpty: The bucket you tried to delete is not empty`

**Cause**: S3 bucket versioning created delete markers and old versions.

**Solution**: Added comprehensive bucket emptying that deletes all versions and delete markers.

### 3. IAM User Policy Attachments
**Error**: `Cannot delete entity, must detach all policies first`

**Cause**: Policies were still attached to the user when Terraform tried to delete.

**Solution**: Detach all policies from the user before attempting deletion.

## New Cleanup Script

Created `scripts/cleanup-aws-resources.sh` that:
- Empties S3 bucket including all versions
- Detaches IAM policy attachments
- Cleans up IAM user policies
- Handles errors gracefully

## Updated Destroy Workflow

The workflow now:
1. Imports existing resources
2. Calls cleanup script to handle dependencies
3. Runs terraform destroy
4. Force cleans remaining resources if needed

## Usage

### Via GitHub Actions

1. Go to GitHub → Actions
2. Click "CI/CD Pipeline"
3. Click "Run workflow"
4. Select "destroy" action
5. Click "Run workflow"

### Via Local Command

```bash
cd infrastructure

# Import if needed
terraform import aws_s3_bucket.frontend pkb-frontend-personal-knowledge-base
terraform import aws_iam_user.grafana_cloudwatch pkb-grafana-cloudwatch

# Clean up
../scripts/cleanup-aws-resources.sh

# Destroy
terraform destroy -auto-approve
```

## Cleanup Script Details

The cleanup script:
- Handles S3 bucket versioning
- Removes all object versions
- Removes delete markers
- Detaches IAM policy attachments
- Handles multiple user/role attachments
- Continues on errors

## Manual Cleanup (if script fails)

```bash
# Empty S3 bucket
BUCKET="pkb-frontend-personal-knowledge-base"
aws s3api delete-objects --bucket "$BUCKET" --delete "$(aws s3api list-object-versions --bucket "$BUCKET" --query '{Objects: Versions[].{Key:Key,VersionId:VersionId}}')"

# Detach IAM policy
POLICY_ARN="arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/pkb-grafana-cloudwatch-access"
aws iam detach-user-policy --user-name pkb-grafana-cloudwatch --policy-arn "$POLICY_ARN"

# Delete policy
aws iam delete-policy --policy-arn "$POLICY_ARN"

# Delete user
aws iam delete-user --user-name pkb-grafana-cloudwatch
```

## Testing the Destroy Workflow

1. **Deploy something first**:
   ```bash
   cd infrastructure
   terraform apply
   ```

2. **Run destroy**:
   - Via GitHub Actions: Select "destroy" workflow
   - Via local: `terraform destroy`

3. **Verify cleanup**:
   - Check S3 bucket is deleted
   - Check IAM policies are deleted
   - Check IAM users are deleted
   - Check CloudWatch logs are gone

## Troubleshooting

### Still Getting Errors?

Run cleanup script manually:
```bash
./scripts/cleanup-aws-resources.sh
```

### S3 Bucket Still Exists?

Force delete:
```bash
aws s3 rb s3://pkb-frontend-personal-knowledge-base --force
```

### IAM Resources Still Exist?

Manual cleanup:
```bash
# List policies
aws iam list-user-policies --user-name pkb-grafana-cloudwatch

# Detach each
aws iam detach-user-policy --user-name pkb-grafana-cloudwatch --policy-arn "POLICY_ARN"

# Delete user
aws iam delete-user --user-name pkb-grafana-cloudwatch
```

## Summary

The destroy workflow now:
- ✅ Properly empties S3 buckets with versioning
- ✅ Detaches IAM policy attachments
- ✅ Cleans up IAM resources in correct order
- ✅ Handles errors gracefully
- ✅ Provides fallback cleanup

---

**Related**: [TERRAFORM_DESTROY_FIX.md](./TERRAFORM_DESTROY_FIX.md)

