#!/bin/bash

# Enable command echoing
set -x

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log_message "Starting post-api-helpers.sh script"

import boto3
import ansible_runner

def run_playbook():
    # Assume role in the vended account
    sts = boto3.client('sts')
    assumed_role = sts.assume_role(
        RoleArn=f"arn:aws:iam::{VENDED_ACCOUNT_ID}:role/AWSAFTExecution",
        RoleSessionName="AFTAnsibleSession"
    )
    
    # Set up credentials for the assumed role
    credentials = assumed_role['Credentials']
    os.environ['AWS_ACCESS_KEY_ID'] = credentials['AccessKeyId']
    os.environ['AWS_SECRET_ACCESS_KEY'] = credentials['SecretAccessKey']
    os.environ['AWS_SESSION_TOKEN'] = credentials['SessionToken']

    # Run Ansible playbook
    result = ansible_runner.run(playbook='path/to/your/playbook.yml')
    print(result.status)
    print(result.stdout.read())

if __name__ == "__main__":
    run_playbook()