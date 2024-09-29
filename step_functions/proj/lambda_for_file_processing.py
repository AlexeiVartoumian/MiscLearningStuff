import boto3
import os
from urllib.parse import urlparse
import logging
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info(f"Received event: {event}")
    s3 = boto3.client('s3')
    
    try:
        transcription_job = event
        source_key = f"{transcription_job['TranscriptionJobName']}.json"
        media_file_uri = transcription_job['Media']['MediaFileUri']
        transcript_file_uri = transcription_job['Transcript']['TranscriptFileUri']

        logger.info(f"Source key: {source_key}")
        logger.info(f"MediaFileUri: {media_file_uri}")
        logger.info(f"TranscriptFileUri: {transcript_file_uri}")

        
        parsed_media_uri = urlparse(media_file_uri)
        bucket_name = parsed_media_uri.netloc

       
        original_filename = os.path.basename(parsed_media_uri.path)
        new_key = f"{os.path.splitext(original_filename)[0]}.json"

        logger.info(f"Bucket name: {bucket_name}")
        logger.info(f"Renaming {source_key} to {new_key} in bucket {bucket_name}")

       
        s3.copy_object(
            Bucket=bucket_name,
            CopySource={'Bucket': bucket_name, 'Key': source_key},
            Key=new_key
        )
        
        # Delete the original file referenced by source key
        s3.delete_object(Bucket=bucket_name, Key=source_key)
        
        return {
            'statusCode': 200,
            'body': f"Successfully renamed {source_key} to {new_key} in bucket {bucket_name}"
        }
    except ClientError as e:
        error_code = e.response['Error']['Code']
        error_message = e.response['Error']['Message']
        logger.error(f"ClientError: {error_code} - {error_message}")
        return {
            'statusCode': 500,
            'body': f"Error renaming file: {error_code} - {error_message}"
        }
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}")
        return {
            'statusCode': 500,
            'body': f"Unexpected error renaming file: {str(e)}"
        }