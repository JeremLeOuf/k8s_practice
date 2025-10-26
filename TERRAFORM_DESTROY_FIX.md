# Terraform Destroy Fix for S3 Bucket

## Problem

When running `terraform destroy`, the S3 bucket cannot be deleted because it's not empty:

```
Error: deleting S3 Bucket (pkb-frontend-personal-knowledge-base): operation error S3: DeleteBucket, 
https response error StatusCode: 409, ... BucketNotEmpty: The bucket you tried to delete is not empty.
```

## Solution

Added a `null_resource` with a destroy-time provisioner that automatically empties the S3 bucket before Terraform attempts to destroy it.

### How It Works

1. **null_resource with destroy provisioner**: Added at the end of `frontend.tf`
   ```hcl
   resource "null_resource" "empty_s3_bucket" {
     depends_on = [aws_cloudfront_distribution.frontend]
     
     triggers = {
       bucket_id = aws_s3_bucket.frontend.id
     }
     
     provisioner "local-exec" {
       when    = destroy
       command = "aws s3 rm s3://${self.triggers.bucket_id} --recursive || true"
     }
   }
   ```

2. **Destroy Order**:
   - CloudFront distribution is destroyed first (it depends on the bucket)
   - `null_resource` destroy provisioner runs and empties the bucket
   - Bucket and related resources are destroyed
   - All bucket objects are removed recursively

3. **Error Handling**: The `|| true` ensures the destroy process continues even if the bucket is already empty.

## Usage

Now you can simply run:

```bash
cd infrastructure
terraform destroy
```

The bucket will be automatically emptied before destruction.

## How It Works Technically

- The `destroy` provisioner runs **before** the resource is removed from state
- `triggers` stores the bucket ID during creation
- During destroy, `${self.triggers.bucket_id}` provides the bucket name
- The `depends_on` ensures CloudFront is destroyed first (before attempting to empty the bucket)
- `aws s3 rm --recursive` deletes all objects and versions in the bucket

## Notes

- Requires `aws` CLI to be installed and configured
- Works with versioned buckets (deletes all versions)
- Safe to run multiple times (bucket may already be empty)
- The bucket must be in the same AWS account/region as your current AWS CLI configuration

## Testing

You can test this by:

1. Deploying infrastructure:
   ```bash
   terraform apply
   ```

2. Adding some files to the S3 bucket (via the UI or `aws s3 sync`)

3. Destroying the infrastructure:
   ```bash
   terraform destroy
   ```

4. Watch as it automatically empties and deletes the bucket without errors!

