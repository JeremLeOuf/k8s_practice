import json
import boto3
import os

# DynamoDB client
dynamodb = boto3.resource('dynamodb')
TABLE_NAME = os.environ.get('TABLE_NAME', 'PersonalKnowledgeBase')
table = dynamodb.Table(TABLE_NAME)

def handler(event, context):
    """
    Lambda function to delete an item from DynamoDB
    """
    try:
        # Get item ID from path parameters
        item_id = event.get('pathParameters', {}).get('id')
        
        if not item_id:
            return {
                'statusCode': 400,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({
                    'error': 'Missing item ID'
                })
            }
        
        # Delete item from DynamoDB
        response = table.delete_item(
            Key={'id': item_id},
            ReturnValues='ALL_OLD'
        )
        
        if 'Attributes' not in response:
            return {
                'statusCode': 404,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({
                    'error': 'Item not found'
                })
            }
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'message': 'Item deleted successfully',
                'deleted_item': response['Attributes']
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

