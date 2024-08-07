import boto3
import json

def list_tables():
    dynamodb = boto3.client('dynamodb', region_name='eu-west-2')
    response = dynamodb.list_tables()
    print("DynamoDB Tables:")
    for table in response['TableNames']:
        print(f"- {table}")

def describe_table(table_name):
    dynamodb = boto3.client('dynamodb', region_name='eu-west-2')
    try:
        response = dynamodb.describe_table(TableName=table_name)
        print(f"Table details for {table_name}:")
        print(json.dumps(response['Table'], indent=2))
    except dynamodb.exceptions.ResourceNotFoundException:
        print(f"Table {table_name} not found")

def scan_table(table_name):
    dynamodb = boto3.client('dynamodb', region_name='eu-west-2')
    try:
        response = dynamodb.scan(TableName=table_name)
        print(f"Scan results for {table_name}:")
        print(json.dumps(response['Items'], indent=2))
    except Exception as e:
        print(f"Error scanning table: {str(e)}")

if __name__ == "__main__":
    print("AWS Account ID:", boto3.client('sts').get_caller_identity()['Account'])
    print("Region:", boto3.session.Session().region_name)
    
    list_tables()
    print("\n")
    describe_table('PendingTransactions')
    print("\n")
    scan_table('PendingTransactions')