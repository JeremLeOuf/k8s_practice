import json
import boto3
import os
from datetime import datetime
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['TABLE_NAME'])

def handler(event, context):
    """Add a new transaction to the budget tracker."""
    
    try:
        body = json.loads(event.get('body', '{}'))
        
        # Extract transaction details
        # Convert float to Decimal for DynamoDB compatibility
        amount = Decimal(str(body.get('amount')))
        category = body.get('category', 'other')
        description = body.get('description', '')
        transaction_type = body.get('type', 'expense')  # 'expense' or 'income'
        transaction_id = body.get('id', f"trans-{datetime.now().isoformat()}")
        
        # Create transaction item
        item = {
            'id': transaction_id,
            'amount': amount,  # Already Decimal
            'category': category,
            'description': description,
            'type': transaction_type,
            'timestamp': datetime.now().isoformat()
        }
        
        # Store in DynamoDB
        table.put_item(Item=item)
        
        # Check balance and send alert if needed (optional - don't fail if this errors)
        try:
            if transaction_type == 'expense':
                # Get current balance
                balance = get_current_balance(table)
                
                # If balance is low, trigger SNS alert
                if balance < 0:
                    trigger_alert(table, balance)
        except Exception as alert_error:
            # Don't fail the transaction if alert fails
            print(f"Alert check failed (non-critical): {alert_error}")
        
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'message': 'Transaction added successfully',
                'transaction_id': transaction_id,
                'balance': float(get_current_balance(table))
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

def get_current_balance(table):
    """Calculate current balance from all transactions."""
    response = table.scan()
    balance = Decimal('0')
    
    for item in response['Items']:
        # Convert DynamoDB Decimal to Decimal type
        amount = item['amount'] if isinstance(item['amount'], Decimal) else Decimal(str(item['amount']))
        if item['type'] == 'income':
            balance += amount
        else:
            balance -= amount
    
    return balance

def trigger_alert(table, balance):
    """Trigger SNS alert for low balance."""
    sns = boto3.client('sns')
    topic_arn = os.environ.get('SNS_TOPIC_ARN')
    
    if topic_arn:
        message = f"⚠️ Budget Alert: Your current balance is ${balance:.2f}. You are over budget!"
        sns.publish(
            TopicArn=topic_arn,
            Subject='Budget Alert',
            Message=message
        )

