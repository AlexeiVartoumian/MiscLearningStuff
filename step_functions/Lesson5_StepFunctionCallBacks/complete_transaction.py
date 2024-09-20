import boto3
import json
from boto3.dynamodb.conditions import Attr
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
session = boto3.Session()
print(f"Default region: {session.region_name}")

sts_client = session.client('sts')
caller_identity = sts_client.get_caller_identity()
print(f"Caller Identity: {caller_identity}")
def get_pending_transactions():
    print(f"Default region: {boto3.Session().region_name}")
    logger.info("Retrieving pending transactions from DynamoDB")
    
    dynamodb = boto3.resource('dynamodb', region_name='eu-west-2')
    table_name = 'PendingTransactions'
    
    try:
        table = dynamodb.Table(table_name)
        response = table.scan(
            FilterExpression=Attr('Status').eq('PENDING')
        )
        
        items = response.get('Items', [])
        logger.info(f"Retrieved {len(items)} pending transactions")
        return items
    
    except Exception as e:
        logger.error(f"Error retrieving pending transactions: {str(e)}")
        raise

def complete_transaction(transaction, success=True, details="Transaction processed by 3rd party"):
    logger.info(f"Completing transaction {transaction['TransactionId']}")
    
    task_token = transaction.get('TaskToken')
    if not task_token:
        raise ValueError(f"No TaskToken found for transaction: {transaction['TransactionId']}")
    
    sfn_client = boto3.client('stepfunctions', region_name='eu-west-2')
    
    try:
        if success:
            logger.info("Sending task success to Step Functions")
            sfn_client.send_task_success(
                taskToken=task_token,
                output=json.dumps({
                    'Status': 'SUCCESS',
                    'TransactionType': transaction.get('Type', 'UNKNOWN'),
                    'Details': details
                })
            )
        else:
            logger.info("Sending task failure to Step Functions")
            sfn_client.send_task_failure(
                taskToken=task_token,
                error='TransactionFailedError',
                cause=f'Transaction process failed: {details}'
            )
        
        logger.info("Step Functions API call completed")
        return True
    
    except Exception as e:
        logger.error(f"Error completing transaction: {str(e)}")
        raise

if __name__ == "__main__":
    try:
        # Get all pending transactions
        pending_transactions = get_pending_transactions()
        
        if not pending_transactions:
            print("No pending transactions found.")
        else:
            print(f"Found {len(pending_transactions)} pending transactions.")
            
            # Process each pending transaction
            for transaction in pending_transactions:
                print(f"\nProcessing transaction: {transaction['TransactionId']}")
                print(json.dumps(transaction, indent=2))
                
                # Simulate processing and complete the transaction
                # You can add your own logic here to determine success/failure
                success = True  # or some condition based on the transaction
                result = complete_transaction(transaction, success)
                
                if result:
                    print(f"Transaction {transaction['TransactionId']} completed successfully")
                else:
                    print(f"Failed to complete transaction {transaction['TransactionId']}")
    
    except Exception as e:
        print(f"Error processing transactions: {str(e)}")
