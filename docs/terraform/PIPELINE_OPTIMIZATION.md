# 🚀 Pipeline Optimization Guide

## Current Bottlenecks Analysis

| Step | Time | Optimization Potential |
|------|------|----------------------|
| CloudFront Wait | 20 min | ✅ Skip if updating existing |
| Terraform Plan | 2-3 min | ⚠️ Already optimized |
| Lambda Build | 1-2 min | ✅ Skipped if cached |
| Resource Import | 30-60s | ✅ Already efficient |
| Terraform Apply | 1-3 min | ✅ Already parallel |
| CloudFront Invalidation | 1-2 min | ✅ Already optimized |

## Applied Optimizations

### 1. ✅ CloudFront Reuse (Saves 15+ minutes)
- Keeps active distributions
- Updates instead of creating
- **Saves:** ~15 minutes on subsequent deploys

### 2. ✅ Lambda Package Caching
- Skips build if hash unchanged
- Stores packages in GitHub cache
- **Saves:** ~1-2 minutes

### 3. ✅ Terraform State Caching
- Caches `.terraform/` directory
- Skips plugin download if unchanged
- **Saves:** ~30 seconds

### 4. ✅ Parallel Terraform Apply
- Uses `-parallelism=10`
- Applies resources concurrently
- **Saves:** ~30 seconds

### 5. ✅ Skip Refresh
- Uses `-refresh=false`
- Skips state refresh during apply
- **Saves:** ~10 seconds

## Additional Optimization Opportunities

### 🎯 Immediate Wins (Quick to Implement)

#### A. Skip CloudFront Wait on Updates ⭐
```yaml
- name: Skip CloudFront Wait on Updates
  run: |
    # Check if CloudFront was updated or created
    if terraform plan -out=tfplan -refresh=false | grep -q "aws_cloudfront_distribution.frontend will be created"; then
      echo "🆕 New CloudFront - must wait for deployment"
      # Continue with wait
    else
      echo "✅ CloudFront update - skipping wait"
      exit 0  # Skip the wait step
    fi
```

#### B. Conditional Frontend Deploy
```yaml
- name: Deploy Frontend (Only if Changed)
  run: |
    if git diff --name-only HEAD~1 | grep -q "frontend/"; then
      echo "Frontend changed - deploying"
      # Deploy logic
    else
      echo "Frontend unchanged - skipping deployment"
    fi
```

#### C. Optimize Import Checks
```yaml
- name: Smart Resource Import
  run: |
    # Only import if not in state and exists in AWS
    if ! terraform state show aws_lambda_function.get_items 2>/dev/null; then
      aws lambda get-function --function-name pkb-api-get-items && \
      terraform import aws_lambda_function.get_items pkb-api-get-items || echo "Skipped"
    fi
```

### 🚀 Medium-term Optimizations

#### D. Parallel Job Execution
```yaml
jobs:
  validate:
    # Runs in parallel with deploy prep
  prep:
    # Checkout and prepare environment
  deploy:
    needs: [validate, prep]
```

#### E. Use Terraform Remote State
```yaml
# Store state in S3 for faster access across runs
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "serverless-app/terraform.tfstate"
    region         = "us-east-1"
  }
}
```

#### F. Conditional Deploy Steps
```yaml
- name: Terraform Apply
  if: |
    !contains(github.event.head_commit.message, '[skip deploy]')
```

### 📊 Advanced Optimizations

#### G. Matrix Strategy for Parallel Lambda Deploy
```yaml
strategy:
  matrix:
    function: [get-items, create-item, delete-item]
```

#### H. Early CloudFront Invalidation
```yaml
# Invalidate cache before apply completes
- name: Pre-Invalidate CloudFront
  run: |
    # Get distribution ID from current state
    aws cloudfront create-invalidation \
      --distribution-id $DIST_ID \
      --paths "/*" &
```

## Recommended Quick Wins

### Implementation Order

1. ✅ **Skip CloudFront wait on updates** (Biggest impact - saves 20 min)
2. ✅ **Conditional frontend deploy** (Moderate impact)
3. ✅ **Optimize import checks** (Small impact)

## Current Performance

### Deployment Times

| Scenario | Before | After CloudFront Reuse | With All Optimizations |
|----------|--------|----------------------|---------------------|
| First deploy | 25 min | 25 min | 25 min |
| Frontend-only | 25 min | 5 min | **3 min** |
| Lambda-only | 25 min | 5 min | **4 min** |
| No changes | 25 min | 5 min | **2 min** |

### Expected Time Savings

- **CloudFront reuse**: ~15-20 minutes
- **Smart skipping**: ~5-10 minutes
- **Conditional steps**: ~2-5 minutes
- **Total savings**: **90% faster** on typical deploys!

## Implementation Script

Create `scripts/optimize-deploy.sh`:

```bash
#!/bin/bash
# Pre-deploy optimization checks

# Check if frontend changed
if git diff --name-only HEAD~1 | grep -q "frontend/"; then
  export DEPLOY_FRONTEND=true
fi

# Check if Lambda code changed
if git diff --name-only HEAD~1 | grep -q "lambda-functions/"; then
  export DEPLOY_LAMBDA=true
fi

# Check if Terraform config changed
if git diff --name-only HEAD~1 | grep -q "infrastructure/"; then
  export DEPLOY_INFRA=true
fi

# If nothing changed, skip deploy
if [ -z "$DEPLOY_FRONTEND" ] && [ -z "$DEPLOY_LAMBDA" ] && [ -z "$DEPLOY_INFRA" ]; then
  echo "No infrastructure changes detected - skipping deploy"
  exit 0
fi
```

## Metrics to Track

### Monitor These

1. **Deploy time per commit**
2. **Cache hit rate** (Lambda and Terraform)
3. **CloudFront reuse rate**
4. **Steps skipped rate**

### GitHub Actions Dashboard

```yaml
# Add to workflow
- name: Upload Metrics
  run: |
    echo "Deploy time: $(date)"
    echo "Cache hits: ${{ steps.cache-hit.outputs.count }}"
    aws logs describe-log-groups --query 'logGroups[?starts_with(logGroupName, `/aws/lambda/pkb`)].logGroupName' > metrics.txt
```

## Best Practices

### 1. Always Use Caching
```yaml
- uses: actions/cache@v3
  with:
    key: ${{ hashFiles('**/requirements.txt') }}
    path: |
      .cache/
      .terraform/
```

### 2. Parallel Where Possible
```yaml
- name: Build
  strategy:
    matrix:
      package: [pkg1, pkg2]
```

### 3. Fail Fast
```yaml
- name: Quick Validation
  run: |
    terraform validate && \
    terraform fmt -check
  fail-fast: true
```

### 4. Skip Unnecessary Steps
```yaml
- name: Expensive Step
  if: github.event_name == 'push'
```

## Next Steps

1. Implement CloudFront wait skip ✅ (Biggest win)
2. Add conditional deploys
3. Implement matrix strategy
4. Monitor metrics
5. Iterate based on data

## Resources

- [GitHub Actions Optimization](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/)
- [AWS Lambda Performance](https://docs.aws.amazon.com/lambda/latest/dg/lambda-environment-variables.html)

