import json
import boto3
import uuid
import os
from datetime import datetime

# DynamoDB client
dynamodb = boto3.resource('dynamodb')
TABLE_NAME = os.environ.get('TABLE_NAME', 'PersonalKnowledgeBase')
table = dynamodb.Table(TABLE_NAME)

def handler(event, context):
    """
    Lambda function to create a new item in DynamoDB
    """
    try:
        # Debug: log the event structure
        print(f"Event received: {json.dumps(event)}")
        
        # Parse request body - handle different event structures
        body_str = event.get('body') or '{}'
        if isinstance(body_str, str):
            body = json.loads(body_str)
        else:
            body = body_str
        
        # Validate required fields
        if 'title' not in body or 'content' not in body:
            return {
                'statusCode': 400,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({
                    'error': 'Missing required fields: title and content'
                })
            }
        
        # Create item
        item = {
            'id': str(uuid.uuid4()),
            'title': body['title'],
            'content': body['content'],
            'type': body.get('type', 'note'),
            'created_at': datetime.utcnow().isoformat(),
            'updated_at': datetime.utcnow().isoformat()
        }
        
        # Add optional fields
        if 'tags' in body:
            item['tags'] = body['tags']
        
        # Save to DynamoDB
        table.put_item(Item=item)
        
        return {
            'statusCode': 201,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'message': 'Item created successfully',
                'item': item
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

