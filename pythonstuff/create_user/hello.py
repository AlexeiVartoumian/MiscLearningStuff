

import boto3
import os
import boto3.session
import logger
import re
import subprocess
import time
from dotenv import load_dotenv,set_key, find_dotenv
from botocore.exceptions import ClientError

load_dotenv()
access = os.environ.get("ACCESS_KEY")
secret = os.environ.get("SECRET_KEY")
region = os.environ.get("REGION")


def write_to_env(key,value):
    dotenv_path = find_dotenv() or ".env"

    set_key(dotenv_path,key,value)

def read_from_env(key):
    load_dotenv()
    secret_Iam_access_key = os.getenv(key)
    if not  secret_Iam_access_key:
        raise ValueError("AWS credentials are not set in the .env file.")

    return secret_Iam_access_key
    
iam_users = boto3.client("iam")
policy_arn = "arn:aws:iam::390746273208:policy/random_policy"
              
# print(iam_users)


# print( iam_users.list_users()) 

def create(a_user, policy_arn):
    try:
        response = iam_users.create_user(UserName = a_user, PermissionsBoundary = policy_arn)
        # arn should be passed in 
    except ClientError:
        logger.exception("could not create user %s", a_user)
        raise
    else:
        return response


def find_resource_arn_from_policy(client ,policy_arn):

    await_policy  = client.get_policy(PolicyArn = policy_arn)
    #print(await_policy)
    policy_version_id  = await_policy['Policy']['DefaultVersionId']
    policy_version = client.get_policy_version(
        PolicyArn = policy_arn,
        VersionId = policy_version_id
    )
    #print(policy_version)
    policy_document = policy_version['PolicyVersion']['Document']
    bucket_arn = None

    for statement in policy_document['Statement']:
        if 'Resource' in statement and isinstance(statement['Resource'], str):
            if 'arn:aws:s3:::' in statement['Resource']:
                bucket_arn = statement['Resource']
                break
        elif 'Resource' in statement and isinstance(statement['Resource'], list):
            for resource in statement['Resource']:
                if 'arn:aws:s3:::' in resource:
                    bucket_arn = resource
                    break
    return bucket_arn                
found = False

for items in iam_users.list_users()['Users']:
    if items['UserName'] == 'bob':
        found = True



def configure_aws_cli(access_key, secret_key,profile, region='eu-west-2', output_format='json', ):
    subprocess.run(f'aws configure set aws_access_key_id {access_key} --profile {profile}', shell=True)
    subprocess.run(f'aws configure set aws_secret_access_key {secret_key} --profile {profile}', shell=True)
    subprocess.run(f'aws configure set region {region} --profile {profile}', shell=True)
    subprocess.run(f'aws configure set output {output_format} --profile {profile}', shell=True)

def delete_aws_cli_access_key(profile):
    subprocess.run(f'aws configure set aws_access_key_id "" --profile {profile}', shell=True)
    subprocess.run(f'aws configure set aws_secret_access_key "" --profile {profile}', shell=True)
    print(f"Deleted AWS CLI access keys for profile {profile}")


if not found:
    print("init bob!")
    bob = create("bob", policy_arn)
    iam_users.attach_user_policy(UserName = "bob", PolicyArn = policy_arn)
    print("bobs in commission!")
    await_access_key = iam_users.create_access_key(UserName = "bob")
    #print(await_access_key)
    access_key_id = await_access_key['AccessKey']['AccessKeyId']
    secret_access_key = await_access_key['AccessKey']['SecretAccessKey']
    
    configure_aws_cli(access_key_id, secret_access_key, "bob")
    time.sleep(6)
    busy_bob = boto3.session.Session(
        aws_access_key_id = access_key_id,
        aws_secret_access_key = secret_access_key
    )
    credentials =  busy_bob.get_credentials() 
    print("Access Key ID:", credentials.access_key)
    print("Secret Access Key:", credentials.secret_key)
    
   
    s3Bucket = busy_bob.resource("s3")
    print(find_resource_arn_from_policy(iam_users , policy_arn))
    s3Bucket = busy_bob.resource("s3")
    
    bucketname = find_resource_arn_from_policy(iam_users , policy_arn)
    bucketname = re.search(r'arn:aws:s3:::([^/]+)', bucketname).group(1)
    print("bucket name" , bucketname)
    file_to_upload = r"C:\Users\alexv\OneDrive\Documents\MiscLearningStuff\pythonstuff\create_user\bobs_file_Top_secret.txt"
    s3_key = "Bobs_file_Top_secret"
    # print(access_key_id)
    # print(secret_access_key)
    bucket = s3Bucket.Bucket(bucketname)
    bucket.upload_file(file_to_upload, s3_key)
    write_to_env("IAM_KEY", secret_access_key)

else:
    access_key_id_metadata= iam_users.list_access_keys(UserName = "bob")['AccessKeyMetadata']
    access_key_id = access_key_id_metadata[0]['AccessKeyId']  
    #secret_access_key = access_key_id_metadata[0]['SecretKey']
    thing = read_from_env("IAM_KEY")
    busy_bob = boto3.Session(
        aws_access_key_id=access_key_id,
        aws_secret_access_key= read_from_env("IAM_KEY")

    )
    print(access_key_id)
    print(thing + " " + "haha")
    s3 = busy_bob.resource('s3')
    bucketname = find_resource_arn_from_policy(iam_users , policy_arn)
    bucketname = re.search(r'arn:aws:s3:::([^/]+)', bucketname).group(1)
   
    bucket = s3.Bucket(bucketname)

    bucket.delete_objects(Bucket = bucketname,Delete = {"Objects" :[{"Key":"Bobs_file_Top_secret"}]} )
    #delete_obj = s3.Object("mygitlabbucket2024","Bobs_file_Top_secret")
    
   
    # delete_obj.delete()
   
    #delete_aws_cli_access_key("bob")
    print("bob no longer has aws cli access!")
    response = iam_users.list_attached_user_policies(UserName="bob")
    print(response)
    print("bobs creds taken away!")
    for attrs in access_key_id_metadata:
        iam_users.delete_access_key(UserName = "bob" , AccessKeyId = attrs['AccessKeyId'])
    
    iam_users.detach_user_policy(UserName="bob", PolicyArn="arn:aws:iam::390746273208:policy/random_policy")
    print("decomissioning bob!")
    bye_bye_bob = iam_users.delete_user(UserName = "bob")

