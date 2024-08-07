from __future__ import print_function

import json
import boto3
import uuid


#{"TransactionType": "PURCHASE"}
#{"TransactionType": "REFUND"}
def initiate_purchase(event, context):
    print("Initiating purchase process")
    print(event)

    # Extract the task token
    task_token = event['token']

    # Generate a unique transaction ID
    transaction_id = str(uuid.uuid4())

    # Store the task token and transaction details
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('PendingTransactions')
    
    table.put_item(
        Item={
            'TransactionId': transaction_id,
            'TaskToken': task_token,
            'Type': 'PURCHASE',
            'Status': 'PENDING'
        }
    )

    # In a real scenario, you would now initiate your purchase process
    # For example, you might send the transaction_id to an external system

    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Purchase process initiated. Waiting for callback.',
            'transactionId': transaction_id
        })
    }