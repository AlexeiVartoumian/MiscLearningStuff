#!/bin/bash

set -e

# Configuration file (you can make this an argument to the script)
CONFIG_FILE="cloudformation_config.json"

# Function to log to CloudWatch
log_to_cloudwatch() {
    local message="$1"
    local timestamp=$(date +%s000)
    aws logs put-log-events \
        --log-group-name "$LOG_GROUP_NAME" \
        --log-stream-name "$LOG_STREAM_NAME" \
        --log-events "timestamp=$timestamp,message=$message"
}

# Ensure log group exists
ensure_log_group() {
    if ! aws logs describe-log-groups --log-group-name-prefix "$LOG_GROUP_NAME" | grep -q "$LOG_GROUP_NAME"; then
        aws logs create-log-group --log-group-name "$LOG_GROUP_NAME"
        log_to_cloudwatch "Created log group: $LOG_GROUP_NAME"
    fi
    aws logs create-log-stream --log-group-name "$LOG_GROUP_NAME" --log-stream-name "$LOG_STREAM_NAME"
}

# Function to check the status of the change set
check_change_set_status() {
    aws cloudformation describe-change-set \
        --stack-name "$STACK_NAME" \
        --change-set-name "$CHANGE_SET_NAME" \
        --query 'Status' --output text
}

# Function to delete the stack
delete_stack() {
    log_to_cloudwatch "Deleting stack due to failure..."
    aws cloudformation delete-stack --stack-name "$STACK_NAME"
    if [ $? -eq 0 ]; then
        log_to_cloudwatch "Stack deleted successfully."
    else
        log_to_cloudwatch "Failed to delete stack. Manual cleanup may be necessary."
    fi
}

# Read configuration
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Extract values from configuration
STACK_NAME=$(jq -r '.stack_name' "$CONFIG_FILE")
TEMPLATE_FILE=$(jq -r '.template_file' "$CONFIG_FILE")
PROFILE=$(jq -r '.profile' "$CONFIG_FILE")
REGION=$(jq -r '.region' "$CONFIG_FILE")

CHANGE_SET_NAME="${STACK_NAME}-changes-$(date +%Y%m%d-%H%M%S)"
LOG_GROUP_NAME="/aws/cloudformation/${STACK_NAME}-change-sets"
LOG_STREAM_NAME="change-set-$(date +%Y%m%d-%H%M%S)"

# Ensure log group and stream exist
ensure_log_group

# Prepare parameters for AWS CLI
PARAMS=()
while IFS='=' read -r key value; do
    PARAMS+=("ParameterKey=$key,ParameterValue=$value")
done < <(jq -r '.parameters | to_entries[] | "\(.key)=\(.value)"' "$CONFIG_FILE")

# Create change set
log_to_cloudwatch "Creating change set '$CHANGE_SET_NAME' for stack '$STACK_NAME'..."
aws cloudformation create-change-set \
    --stack-name "$STACK_NAME" \
    --template-body "file://$TEMPLATE_FILE" \
    --change-set-name "$CHANGE_SET_NAME" \
    --description "Change set for $STACK_NAME" \
    --parameters "${PARAMS[@]}" \
    --profile "$PROFILE" \
    --region "$REGION"

# Wait for change set creation to complete
log_to_cloudwatch "Waiting for change set creation to complete..."
while true; do
    STATUS=$(check_change_set_status)
    if [ "$STATUS" == "CREATE_COMPLETE" ]; then
        log_to_cloudwatch "Change set created successfully."
        break
    elif [ "$STATUS" == "FAILED" ]; then
        log_to_cloudwatch "Change set creation failed. Cleaning up..."
        aws cloudformation delete-change-set \
            --stack-name "$STACK_NAME" \
            --change-set-name "$CHANGE_SET_NAME"
        exit 1
    fi
    sleep 10
done

# Describe the change set and log it
log_to_cloudwatch "Describing change set..."
CHANGE_SET_DESCRIPTION=$(aws cloudformation describe-change-set \
    --stack-name "$STACK_NAME" \
    --change-set-name "$CHANGE_SET_NAME")
log_to_cloudwatch "Change set description: $CHANGE_SET_DESCRIPTION"

# Execute change set
log_to_cloudwatch "Executing change set..."
aws cloudformation execute-change-set \
    --stack-name "$STACK_NAME" \
    --change-set-name "$CHANGE_SET_NAME"

# Monitor the stack operation
log_to_cloudwatch "Monitoring stack operation..."
while true; do
    STATUS=$(aws cloudformation describe-stacks \
        --stack-name "$STACK_NAME" \
        --query 'Stacks[0].StackStatus' \
        --output text)
    
    log_to_cloudwatch "Stack status: $STATUS"
    if [ "$STATUS" == "CREATE_COMPLETE" ] || [ "$STATUS" == "UPDATE_COMPLETE" ]; then
        log_to_cloudwatch "Stack operation completed successfully."
        break
    elif [[ "$STATUS" == *FAILED ]] || [ "$STATUS" == "ROLLBACK_COMPLETE" ]; then
        log_to_cloudwatch "Stack operation failed. Deleting stack..."
        delete_stack
        exit 1
    fi
    sleep 30
done

log_to_cloudwatch "Process completed successfully."