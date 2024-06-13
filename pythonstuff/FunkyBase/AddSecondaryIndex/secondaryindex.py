
#creating secondary index for books table.what if  we want to query by a specific attribute then secondary indexes are useful.
# 

import boto3

client = boto3.client('dynamodb' , region_name = 'eu-west-2')

try:
    resp = client.update_table(
        TableName="Books",
        AttributeDefinitions=[
            {
                "AttributeName": "Category",
                "AttributeType": "S"
            },
        ],
        GlobalSecondaryIndexUpdates=[
            {
                "Create": {
                    # You need to name your index and specifically refer to it when using it for queries.
                    "IndexName": "CategoryIndex",
                    # Like the table itself, you need to specify the key schema for an index.
                    # For a global secondary index, you can use a simple or composite key schema.
                    "KeySchema": [
                        {
                            "AttributeName": "Category",
                            "KeyType": "HASH"
                        }
                    ],
                    # You can choose to copy only specific attributes from the original item into the index.
                    # You might want to copy only a few attributes to save space.
                    "Projection": {
                        "ProjectionType": "ALL"
                    },
                    # Global secondary indexes have read and write capacity separate from the underlying table.
                    "ProvisionedThroughput": {
                        "ReadCapacityUnits": 1,
                        "WriteCapacityUnits": 1,
                    }
                }
            }
        ],
    )
except Exception as e:
    print("Error updating table:")
    print(e)