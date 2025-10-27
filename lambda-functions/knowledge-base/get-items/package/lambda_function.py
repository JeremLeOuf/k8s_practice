import json
import boto3
import os
from decimal import Decimal

# DynamoDB client
dynamodb = boto3.resource('dynamodb')
TABLE_NAME = os.environ.get('TABLE_NAME', 'PersonalKnowledgeBase')
table = dynamodb.Table(TABLE_NAME)

def handler(event, context):
    """
    Lambda function to get all items from DynamoDB
    """
    try:
        # Debug: log the event structure
        print(f"Event received: {json.dumps(event)}")
        
        # Scan table to get all items
        response = table.scan()
        
        # Convert Decimal to string for JSON serialization
        items = response.get('Items', [])
        for item in items:
            for key, value in item.items():
                if isinstance(value, Decimal):
                    item[key] = float(value)
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'items': items,
                'count': len(items)
            })
        }
    
    except Exception as e:
        error_msg = f"Error: {str(e)}"
        import traceback
        error_details = traceback.format_exc()
        print(error_msg)
        print(error_details)
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': error_msg,
                'details': error_details
            })
        }

