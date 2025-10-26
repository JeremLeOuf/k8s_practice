import json
import boto3
import os

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['TABLE_NAME'])

def handler(event, context):
    """Get current balance and recent transactions."""
    
    try:
        # Scan for all transactions
        response = table.scan()
        
        balance = 0
        transactions = []
        
        # Calculate balance and prepare transaction list
        for item in response['Items']:
            transactions.append({
                'id': item['id'],
                'amount': item['amount'],
                'category': item['category'],
                'description': item['description'],
                'type': item['type'],
                'timestamp': item['timestamp']
            })
            
            if item['type'] == 'income':
                balance += item['amount']
            else:
                balance -= item['amount']
        
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
                'balance': balance,
                'transactions': recent_transactions,
                'total_count': len(transactions)
            })
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

