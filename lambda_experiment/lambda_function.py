
import json


def lambda_handler(event, context):
    print("lambda from ide")

    return {
        "statusCode": 200,
        "body": json.dumps("hello lambda from ide")
    }