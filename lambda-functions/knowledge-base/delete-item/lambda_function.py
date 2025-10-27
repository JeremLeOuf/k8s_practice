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
        # Debug: log the event structure
        print(f"Event received: {json.dumps(event)}")
        
        # Get item ID from path parameters
        path_params = event.get('pathParameters', {})
        item_id = path_params.get('id') if path_params else None
        
        if not item_id:
            return {
                'statusCode': 400,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({
                    'error': 'Missing item ID',
                    'event': event
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

