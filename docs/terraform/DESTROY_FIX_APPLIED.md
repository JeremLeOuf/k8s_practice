# Destroy Fix Applied - S3 and IAM Cleanup

## Problem

When running `terraform destroy` through GitHub Actions, the following errors occurred:

1. **S3 Bucket Not Empty**
   ```
   Error: deleting S3 Bucket (pkb-frontend-personal-knowledge-base): 
   BucketNotEmpty: The bucket you tried to delete is not empty. 
   You must delete all versions in the bucket.
   ```

2. **IAM User Has Policies Attached**
   ```
   Error: deleting IAM User (pkb-grafana-cloudwatch): 
   DeleteConflict: Cannot delete entity, must detach all policies first.
   ```

3. **IAM Policy Attached to Entities**
   ```
   Error: deleting IAM Policy: 
   DeleteConflict: Cannot delete a policy attached to entities.
   ```

## Solution Applied

### 1. Enhanced Cleanup Script (`scripts/cleanup-aws-resources.sh`)

The script now properly handles all dependencies:

**S3 Bucket Cleanup:**
- Checks if bucket exists before attempting cleanup
- Deletes all object versions
- Deletes all delete markers
- Deletes remaining objects (non-versioned)
- Handles versioned and non-versioned buckets

**IAM User Cleanup:**
- Deletes all access keys
- Detaches all attached policies (managed and inline)
- Detaches all user policies
- Prepares user for deletion

**IAM Policy Cleanup:**
- Detaches policy from all users
- Detaches policy from all roles
- Detaches policy from all groups
- Prepares policy for deletion

### 2. Updated Destroy Workflow (`.github/workflows/deploy.yml`)

**Order of Operations:**
1. Import existing resources (to know what to destroy)
2. **Cleanup AWS resources** (new step - empties S3, detaches IAM policies)
3. Run `terraform destroy`
4. Force cleanup if destroy fails (catches any remaining issues)

**Key Changes:**
- Added "Cleanup AWS Resources" step BEFORE terraform destroy
- Enhanced "Force Cleanup" step to handle all failure cases
- Added API Gateway import to destroy workflow
- Added proper error handling with `continue-on-error: true`

## How to Use

### Option 1: Via GitHub Actions (Recommended)

1. Go to your repository on GitHub
2. Click "Actions" tab
3. Click "Run workflow"
4. Select "destroy" as the action
5. Click "Run workflow"

The workflow will now:
1. Import existing resources
2. Cleanup S3 bucket and IAM resources
3. Run `terraform destroy`
4. Force cleanup if anything fails

### Option 2: Manual Cleanup Before Destroy

If you want to run cleanup manually before destroy:

```bash
# Make script executable
chmod +x scripts/cleanup-aws-resources.sh

# Run cleanup (will use default bucket name or provide one)
./scripts/cleanup-aws-resources.sh

# Or specify bucket
./scripts/cleanup-aws-resources.sh "pkb-frontend-personal-knowledge-base"

# Then run destroy
cd infrastructure
terraform destroy
```

### Option 3: Individual Resource Cleanup

If you encounter specific errors, you can manually clean up:

**S3 Bucket:**
```bash
BUCKET="pkb-frontend-personal-knowledge-base"

# Delete all versions
aws s3api list-object-versions --bucket "$BUCKET" --output json > /tmp/versions.json
VERSIONS=$(cat /tmp/versions.json | jq '{Objects: [.Versions[]? | {Key, VersionId}]}')
echo "$VERSIONS" > /tmp/delete-versions.json
aws s3api delete-objects --bucket "$BUCKET" --delete file:///tmp/delete-versions.json

# Delete all delete markers
MARKERS=$(cat /tmp/versions.json | jq '{Objects: [.DeleteMarkers[]? | {Key, VersionId}]}')
echo "$MARKERS" > /tmp/delete-markers.json
aws s3api delete-objects --bucket "$BUCKET" --delete file:///tmp/delete-markers.json

# Delete remaining objects
aws s3 rm "s3://$BUCKET" --recursive
```

**IAM User:**
```bash
USER="pkb-grafana-cloudwatch"

# Delete access keys
aws iam list-access-keys --user-name "$USER" --query 'AccessKeyMetadata[].AccessKeyId' --output text | \
  while read key_id; do
    aws iam delete-access-key --user-name "$USER" --access-key-id "$key_id"
  done

# Detach all policies
aws iam list-attached-user-policies --user-name "$USER" --query 'AttachedPolicies[].PolicyArn' --output text | \
  while read policy_arn; do
    aws iam detach-user-policy --user-name "$USER" --policy-arn "$policy_arn"
  done

# Delete user
aws iam delete-user --user-name "$USER"
```

**IAM Policy:**
```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
POLICY_ARN="arn:aws:iam::$ACCOUNT_ID:policy/pkb-grafana-cloudwatch-access"

# Detach from all users
aws iam list-entities-for-policy --policy-arn "$POLICY_ARN" --query 'PolicyUsers[].UserName' --output text | \
  while read user; do
    aws iam detach-user-policy --user-name "$user" --policy-arn "$POLICY_ARN"
  done

# Detach from all roles
aws iam list-entities-for-policy --policy-arn "$POLICY_ARN" --query 'PolicyRoles[].RoleName' --output text | \
  while read role; do
    aws iam detach-role-policy --role-name "$role" --policy-arn "$POLICY_ARN"
  done

# Delete policy
aws iam delete-policy --policy-arn "$POLICY_ARN"
```

## Testing

To verify the fix works:

1. Deploy infrastructure:
   ```bash
   # Via GitHub Actions: Run deploy workflow
   ```

2. Run destroy:
   ```bash
   # Via GitHub Actions: Run destroy workflow
   ```

3. Verify all resources are deleted:
   ```bash
   ./scripts/check-aws-resources.sh
   ```

You should see:
- ✅ No S3 buckets
- ✅ No IAM users
- ✅ No IAM policies
- ✅ No API Gateway
- ✅ No Lambda functions
- ✅ No DynamoDB tables

## What Was Fixed

| Issue | Root Cause | Fix Applied |
|-------|------------|-------------|
| S3 bucket not empty | Terraform tries to delete bucket with versions | Cleanup script deletes all versions first |
| IAM user has policies | User still has attached policies | Cleanup script detaches all policies |
| IAM policy attached | Policy attached to user/role/group | Cleanup script detaches from all entities |
| Access keys not deleted | IAM user has active access keys | Cleanup script deletes all access keys |

## Summary

The destroy process now:
1. ✅ Empties S3 bucket (all versions and delete markers)
2. ✅ Detaches IAM policies from users
3. ✅ Deletes access keys
4. ✅ Prepares resources for safe deletion
5. ✅ Handles failures gracefully

This ensures `terraform destroy` completes successfully without dependency errors.

## Related Files

- `scripts/cleanup-aws-resources.sh` - Enhanced cleanup script
- `.github/workflows/deploy.yml` - Updated destroy workflow
- `docs/terraform/DESTROY_TROUBLESHOOTING.md` - Troubleshooting guide
- `docs/terraform/API_GATEWAY_CLEANUP.md` - API Gateway specific cleanup

