import boto3
import uuid
import botocore
import json
import os

def assume_role(account_id):
    sts_client = boto3.client('sts')
    role_arn = f'arn:aws:iam::{account_id}:role/AWSAFTExecution'
    
    try:
        assumed_role_object = sts_client.assume_role(
            RoleArn=role_arn,
            RoleSessionName="AFTAssumeRoleSession"
        )
        credentials = assumed_role_object['Credentials']
        print(f"Successfully assumed role in account {account_id}")
        return credentials
    except Exception as e:
        print(f"Error assuming role: {str(e)}")
        return None

def create_bucket(credentials):
    bucket_name = f"aft-customization-{uuid.uuid4()}"
    
    s3 = boto3.client(
        's3',
        aws_access_key_id=credentials['AccessKeyId'],
        aws_secret_access_key=credentials['SecretAccessKey'],
        aws_session_token=credentials['SessionToken']
    )
    
    try:
        # Try to create the bucket
        response = s3.create_bucket(Bucket=bucket_name)
        print(f"Successfully created bucket: {bucket_name}")
        print(f"Response: {json.dumps(response, default=str)}")
        
        # Try to get the bucket location
        location = s3.get_bucket_location(Bucket=bucket_name)
        print(f"Bucket location: {location['LocationConstraint']}")
        
    except botocore.exceptions.ClientError as e:
        error_code = e.response['Error']['Code']
        error_message = e.response['Error']['Message']
        print(f"Error creating bucket: {error_code} - {error_message}")
        print(f"Full error response: {json.dumps(e.response, default=str)}")
    
    except Exception as e:
        print(f"Unexpected error: {str(e)}")

if __name__ == "__main__":
    vended_account_id = os.environ.get('VENDED_ACCOUNT_ID')
    if not vended_account_id:
        print("Error: VENDED_ACCOUNT_ID environment variable not set")
        exit(1)
    
    print(f"Attempting to create bucket in account: {vended_account_id}")
    
    credentials = assume_role(vended_account_id)
    if credentials:
        create_bucket(credentials)
    else:
        print("Failed to assume role. Cannot create bucket.")



import os
import boto3
import botocore
import json

def assume_role(account_id):
    sts_client = boto3.client('sts')
    role_arn = f'arn:aws:iam::{account_id}:role/AWSAFTExecution'
    
    try:
        assumed_role_object = sts_client.assume_role(
            RoleArn=role_arn,
            RoleSessionName="AFTAssumeRoleSession"
        )
        credentials = assumed_role_object['Credentials']
        print(f"Successfully assumed role in account {account_id}")
        return credentials
    except Exception as e:
        print(f"Error assuming role: {str(e)}")
        return None

def create_iam_user(credentials):
    iam = boto3.client(
        'iam',
        aws_access_key_id=credentials['AccessKeyId'],
        aws_secret_access_key=credentials['SecretAccessKey'],
        aws_session_token=credentials['SessionToken']
    )
    
    try:
        response = iam.create_user(UserName="AFTCreatedUser")
        print(f"Successfully created IAM user: {json.dumps(response, default=str)}")
    except botocore.exceptions.ClientError as e:
        error_code = e.response['Error']['Code']
        error_message = e.response['Error']['Message']
        print(f"Error creating IAM user: {error_code} - {error_message}")
    except Exception as e:
        print(f"Unexpected error: {str(e)}")

if __name__ == "__main__":
    vended_account_id = os.environ.get('VENDED_ACCOUNT_ID')
    if not vended_account_id:
        print("Error: VENDED_ACCOUNT_ID environment variable not set")
    else:
        print(f"Attempting to create IAM user in account: {vended_account_id}")
        credentials = assume_role(vended_account_id)
        if credentials:
            create_iam_user(credentials)
        else:
            print("Failed to assume role. Cannot create IAM user.")