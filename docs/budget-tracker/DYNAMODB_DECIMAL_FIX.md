# 🔧 DynamoDB Decimal Type Fix

## Problem

DynamoDB doesn't support Python's `float` type. It requires `Decimal` from the `decimal` module.

**Error**: 
```
error: "Float types are not supported. Use Decimal types instead."
```

## Solution

### 1. Import Decimal Module

```python
from decimal import Decimal
```

### 2. Convert Float to Decimal Before Storing

```python
# ❌ Before (fails)
amount = float(body.get('amount'))
item = {'amount': amount}  # DynamoDB rejects this

# ✅ After (works)
amount = Decimal(str(body.get('amount')))
item = {'amount': amount}  # DynamoDB accepts this
```

### 3. Convert Decimal to Float for JSON Responses

```python
# Decimal is not JSON serializable
return json.dumps({'balance': balance})  # ❌ Fails

# Convert to float
return json.dumps({'balance': float(balance)})  # ✅ Works
```

### 4. Handle Decimal Type in Calculations

```python
# Use Decimal for calculations
balance = Decimal('0')

for item in response['Items']:
    amount = item['amount'] if isinstance(item['amount'], Decimal) else Decimal(str(item['amount']))
    balance += amount  # Decimal arithmetic

# Convert to float for return
return float(balance)
```

## Files Fixed

- `budget-tracker/lambda-functions/add-transaction/lambda_function.py`
- `budget-tracker/lambda-functions/get-balance/lambda_function.py`

## Key Changes

### Add Transaction

```python
# Convert input to Decimal
amount = Decimal(str(body.get('amount')))

# Use Decimal in item
item = {'amount': amount}  # DynamoDB compatible

# Convert Decimal to float in response
'balance': float(get_current_balance(table))
```

### Get Balance

```python
# Use Decimal for calculations
balance = Decimal('0')
balance += amount  # Decimal arithmetic

# Convert to float for JSON
'balance': float(balance)
```

## Why This Matters

DynamoDB Number type requires:
- **Decimal** (Python) ✅
- **float** (Python) ❌

JSON serialization requires:
- **float** ✅
- **Decimal** ❌

**Solution**: Convert between types as needed!

## Best Practices

1. **Always use Decimal for DynamoDB** - Store as Decimal
2. **Convert to float for responses** - JSON serialization
3. **Handle both types** - Defensive programming
4. **Use str() for conversion** - `Decimal(str(value))`

## Testing

```bash
# Test adding a transaction
curl -X POST https://YOUR-API/prod/transactions \
  -H "Content-Type: application/json" \
  -d '{"amount": 50.99, "type": "expense", "category": "food"}'

# Should return 200 OK with balance
```

## Resources

- [DynamoDB Number Type](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.NamingRulesDataTypes.html)
- [Python Decimal Documentation](https://docs.python.org/3/library/decimal.html)

