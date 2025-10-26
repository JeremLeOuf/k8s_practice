# Lambda Functions Reorganization

## Before

```
lambda-functions/                    # Knowledge base functions
├── get-items/
├── create-item/
└── delete-item/

budget-tracker/
└── lambda-functions/                # Budget tracker functions (separate location!)
    ├── add-transaction/
    ├── get-balance/
    └── send-alert/
```

**Problems:**
- ❌ Two separate Lambda folders in different locations
- ❌ Duplicate infrastructure code
- ❌ Build script had to handle two different paths
- ❌ Terraform had different path references

## After

```
lambda-functions/                    # Unified location
├── knowledge-base/                  # Knowledge base app
│   ├── get-items/
│   ├── create-item/
│   └── delete-item/
│
└── budget-tracker/                  # Budget tracker app
    ├── add-transaction/
    ├── get-balance/
    └── send-alert/
```

**Benefits:**
- ✅ Single unified location for all Lambda functions
- ✅ Organized by application/module
- ✅ Simpler build script
- ✅ Cleaner Terraform configuration
- ✅ Easier to add new apps
- ✅ Better maintainability

## Changes Made

### 1. Directory Structure
- Moved knowledge base functions to `lambda-functions/knowledge-base/`
- Moved budget tracker functions to `lambda-functions/budget-tracker/`
- Removed duplicate `budget-tracker/lambda-functions/` folder

### 2. Build Script (`scripts/build-lambda.sh`)
- Updated to handle organized structure
- Builds by app grouping
- Single unified build process

### 3. Terraform Configuration
- Updated `infrastructure/main.tf` to use new paths
- Updated `infrastructure/budget-tracker.tf` to use new paths
- All references now point to unified location

## Building Lambda Functions

```bash
# Build all Lambda functions
./scripts/build-lambda.sh

# Output:
# 📦 Building optimized Lambda function packages...
# 📚 Building Knowledge Base Lambda functions...
#   ✅ get-items packaged (4.0K) in 0s
#   ✅ create-item packaged (4.0K) in 0s
#   ✅ delete-item packaged (4.0K) in 0s
# 
# 💰 Building Budget Tracker Lambda functions...
#   ✅ add-transaction packaged (4.0K) in 0s
#   ✅ get-balance packaged (4.0K) in 0s
#   ✅ send-alert packaged (4.0K) in 0s
```

## Adding New Lambda Functions

Simply add your function to the appropriate folder:

```
lambda-functions/
└── your-new-app/
    └── your-function/
        ├── lambda_function.py
        └── requirements.txt
```

Then update the build script to include it in the build loop.

## Infrastructure Deployment

After reorganization, everything works the same:

```bash
# Build Lambda functions
./scripts/build-lambda.sh

# Deploy infrastructure
cd infrastructure
terraform apply
```

## File Path References

### Knowledge Base Functions
- Old: `lambda-functions/get-items/function.zip`
- New: `lambda-functions/knowledge-base/get-items/function.zip`

### Budget Tracker Functions
- Old: `budget-tracker/lambda-functions/add-transaction/function.zip`
- New: `lambda-functions/budget-tracker/add-transaction/function.zip`

## Status

✅ Reorganization complete
✅ Build script updated
✅ Terraform configuration updated
✅ All functions building successfully
✅ Ready for deployment

