import json
import boto3
import os

sns = boto3.client('sns')

def handler(event, context):
    """Send budget alert via SNS."""
    
    try:
        # Get environment variables
        topic_arn = os.environ['SNS_TOPIC_ARN']
        sns_enabled = os.environ.get('SNS_ENABLED', 'true').lower() == 'true'
        
        if not sns_enabled:
            return {
                'statusCode': 200,
                'body': json.dumps({'message': 'SNS alerts disabled'})
            }
        
        # Parse event
        body = json.loads(event.get('body', '{}'))
        subject = body.get('subject', 'Budget Alert')
        message = body.get('message', '')
        
        # Send SNS notification
        response = sns.publish(
            TopicArn=topic_arn,
            Subject=subject,
            Message=message
        )
        
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'message': 'Alert sent successfully',
                'message_id': response['MessageId']
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

