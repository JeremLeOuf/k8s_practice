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
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': str(e)
            })
        }

