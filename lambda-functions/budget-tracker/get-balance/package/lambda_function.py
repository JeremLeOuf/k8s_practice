import json
import boto3
import os
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['TABLE_NAME'])

def handler(event, context):
    """Get current balance and recent transactions."""
    
    try:
        # Scan for all transactions
        response = table.scan()
        
        balance = Decimal('0')
        transactions = []
        
        # Calculate balance and prepare transaction list
        for item in response['Items']:
            # Convert amount to float for JSON serialization
            amount_value = float(item['amount']) if isinstance(item['amount'], Decimal) else item['amount']
            
            transactions.append({
                'id': item['id'],
                'amount': amount_value,
                'category': item['category'],
                'description': item['description'],
                'type': item['type'],
                'timestamp': item['timestamp']
            })
            
            # Use Decimal for calculations
            amount = item['amount'] if isinstance(item['amount'], Decimal) else Decimal(str(item['amount']))
            if item['type'] == 'income':
                balance += amount
            else:
                balance -= amount
        
        # Sort by timestamp (most recent first)
        transactions.sort(key=lambda x: x['timestamp'], reverse=True)
        
        # Limit to last 20 transactions
        recent_transactions = transactions[:20]
        
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'balance': float(balance),  # Convert Decimal to float for JSON
                'transactions': recent_transactions,
                'total_count': len(transactions)
            }, default=str)  # Handle Decimal type in JSON serialization
        }
        
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Content-Type': 'application/json'
            },
            'body': json.dumps({'error': str(e)})
        }

