import boto3

client = boto3.client('dynamodb', region_name = "eu-west-2")

try:
    resp = client.delete_table(
        TableName = "Books",
    )
except Exception as e:
    print("Error deleting table.")
    print(e)