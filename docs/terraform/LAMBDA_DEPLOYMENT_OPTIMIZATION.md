# Lambda Deployment Optimization

## Problem
CI/CD pipeline was taking 2+ minutes per Lambda function to upload and update, leading to long deployment times.

## Root Causes
1. **Large deployment packages (15MB each)**: Installing unnecessary dependencies
2. **No cache strategy**: Re-building packages every time
3. **Sequential operations**: No parallelism in Terraform apply
4. **No timing visibility**: Can't identify which step is slow

## Solutions Implemented

### 1. Smart Lambda Packaging
**File**: `scripts/build-lambda.sh`

- Detects if only `boto3` is required (pre-installed in Lambda runtime)
- Creates minimal packages (<100KB instead of 15MB) for simple functions
- Uses `--no-cache-dir` for pip to speed up CI builds
- Removes unnecessary files (`.pyc`, `__pycache__`, documentation, etc.)
- Adds timing to each build step

**Expected Impact**: 80-90% size reduction for simple functions

### 2. CI/CD Optimizations
**File**: `.github/workflows/deploy.yml`

#### Caching Strategy
```yaml
- Cache Lambda packages by hash of Python files and requirements
- Skip rebuild if code hasn't changed
- Cache Terraform state and providers
```

#### Import Existing Resources
- Checks state before importing
- Handles budget tracker resources (`BudgetTracker`, `budget-tracker-lambda-role`)
- Prevents "already exists" errors

#### Performance Improvements
- **Parallelism**: `terraform apply -parallelism=10` (faster resource creation)
- **No refresh**: `-refresh=false` (skip AWS API calls to check current state)
- **Timing**: Added `time` command to measure actual deployment duration
- **Plan preview**: Shows what will change before applying

### 3. Expected Results

#### Before Optimization
- Build: ~30s per function × 3 = 90s
- Upload: ~120s per function × 3 = 360s  
- Apply: ~30s
- **Total: ~8 minutes**

#### After Optimization
- Build (cached): ~10s total (all 3 functions)
- Upload (minimal packages): ~20s per function × 3 = 60s
- Apply (parallel): ~30s
- **Total: ~2 minutes**

**Time Savings: ~6 minutes (75% reduction)**

## Usage

### Local Development
```bash
# Build optimized Lambda packages
./scripts/build-lambda.sh

# Check sizes
du -h lambda-functions/*/function.zip
```

### CI/CD Pipeline
The pipeline automatically:
1. Checks cache for Lambda packages
2. Builds only if code changed
3. Imports existing resources
4. Applies with high parallelism
5. Shows timing for each step

## Monitoring

Watch the CI/CD logs for:
- `📊 Package sizes:` - Shows total deployment package size
- `⏱️ Starting terraform apply at` - Start time
- `✅ Completed terraform apply at` - End time with duration

## Troubleshooting

### "Resource already exists" errors
```bash
./scripts/import-all-existing.sh
terraform apply
```

### Packages too large
Check `lambda-functions/*/requirements.txt`:
- If only `boto3`, that's fine (minimal package)
- If other deps, consider removing unused libraries

### Slow uploads
1. Check package sizes: `du -h lambda-functions/*/function.zip`
2. If >5MB, review dependencies in `requirements.txt`
3. Remove unnecessary imports from `lambda_function.py`

## Future Improvements

1. **S3-backed deployments**: Upload to S3 first, reference in Lambda (faster)
2. **Container images**: Use Lambda container images for better caching
3. **Layers**: Extract common dependencies to Lambda layers
4. **CLI deployments**: Use `aws lambda update-function-code` for faster updates

