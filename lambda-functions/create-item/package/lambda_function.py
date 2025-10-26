import json
import boto3
import uuid
from datetime import datetime

# DynamoDB client
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('PersonalKnowledgeBase')

def handler(event, context):
    """
    Lambda function to create a new item in DynamoDB
    """
    try:
        # Parse request body
        body = json.loads(event.get('body', '{}'))
        
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

