import boto3
import os
import logger
import subprocess
from dotenv import load_dotenv


load_dotenv

access = os.environ.get("ACCESS_KEY")
secret = os.environ.get("SECRET_KEY")
region = os.environ.get("REGION")

client = boto3.client("dynamodb", region_name = region)

try:
    resp = client.create_table(
        TableName= "Books", 
        KeySchema = [
            {
                "AttributeName": "Author",
                "KeyType" : "HASH"
        },
        {
            "AttributeName": "Title",
            "KeyType": "RANGE"
        }
        ],
        AttributeDefinitions=[
            {
                "AttributeName": "Author",
                "AttributeType": "S"
            },
            {
                "AttributeName": "Title",
                "AttributeType": "S"
            }
        ],
        ProvisionedThroughput= {
            "ReadCapacityUnits":1,
            "WriteCapacityUnits": 1
        }
    )
    print("Table created succesfully")
except Exception as e:
    print("error creating table")
    print(e)





