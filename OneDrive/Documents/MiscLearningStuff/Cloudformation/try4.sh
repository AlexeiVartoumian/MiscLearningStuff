#!/bin/bash

set -e

# ... (previous code remains unchanged)

# Function to format change set details
format_change_set() {
    local stack_name="$1"
    local change_set_name="$2"
    
    aws cloudformation describe-change-set \
        --stack-name "$stack_name" \
        --change-set-name "$change_set_name" \
        --region "$REGION" \
        --query 'Changes[].{Action: ResourceChange.Action, LogicalResourceId: ResourceChange.LogicalResourceId, ResourceType: ResourceChange.ResourceType, Replacement: ResourceChange.Replacement}' \
        --output json | jq -r '.[] | "Action: \(.Action), Resource: \(.LogicalResourceId) (\(.ResourceType)), Replacement: \(.Replacement)"'
}

# Function to create a change set and apply it if successful
create_apply_change_set() {
    local stack_name="$1"
    local template_file="$2"
    local change_set_name="$3"
    local change_set_type="$4"
    local parameters=("${@:5}")

    echo "Creating change set '$change_set_name' for stack '$stack_name'..."
    aws cloudformation create-change-set \
        --stack-name "$stack_name" \
        --template-body "file://$template_file" \
        --change-set-type "$change_set_type" \
        --change-set-name "$change_set_name" \
        --description "Change set for $stack_name" \
        --parameters "${parameters[@]}" \
        --capabilities CAPABILITY_NAMED_IAM \
        --region "$REGION"

    echo "Waiting for change set creation to complete..."
    if ! aws cloudformation wait change-set-create-complete \
        --stack-name "$stack_name" \
        --change-set-name "$change_set_name" \
        --region "$REGION"; then
        echo "Change set creation failed or timed out. Checking status..."
        change_set_status=$(aws cloudformation describe-change-set \
            --stack-name "$stack_name" \
            --change-set-name "$change_set_name" \
            --region "$REGION" \
            --query 'Status' \
            --output text)
        echo "Change set status: $change_set_status"
        if [ "$change_set_status" == "FAILED" ]; then
            echo "Change set creation failed. Deleting change set and exiting."
            aws cloudformation delete-change-set \
                --stack-name "$stack_name" \
                --change-set-name "$change_set_name" \
                --region "$REGION"
            exit 1
        fi
    fi

    # Capture and log change set details
    echo "Change set details:" | tee -a change_set_log.txt
    format_change_set "$stack_name" "$change_set_name" | tee -a change_set_log.txt

    # Check if the change set has any changes
    changes=$(aws cloudformation describe-change-set \
        --stack-name "$stack_name" \
        --change-set-name "$change_set_name" \
        --region "$REGION" \
        --query 'Changes[].ResourceChange.LogicalResourceId' \
        --output text)

    if [ -z "$changes" ]; then
        echo "No changes detected in the change set. Deleting the change set." | tee -a change_set_log.txt
        aws cloudformation delete-change-set \
            --stack-name "$stack_name" \
            --change-set-name "$change_set_name" \
            --region "$REGION"
    else
        echo "Changes detected. Applying the change set..." | tee -a change_set_log.txt
        aws cloudformation execute-change-set \
            --stack-name "$stack_name" \
            --change-set-name "$change_set_name" \
            --region "$REGION"

        echo "Waiting for stack update to complete..."
        while true; do
            status=$(check_stack_status "$stack_name")
            echo "Current stack status: $status" | tee -a change_set_log.txt
            case $status in
                *COMPLETE)
                    echo "Stack operation completed." | tee -a change_set_log.txt
                    break
                    ;;
                *FAILED)
                    echo "Stack operation failed. Check CloudFormation console for details." | tee -a change_set_log.txt
                    exit 1
                    ;;
                *IN_PROGRESS)
                    echo "Stack operation in progress. Waiting..." | tee -a change_set_log.txt
                    sleep 30
                    ;;
                *)
                    echo "Unknown stack status. Exiting." | tee -a change_set_log.txt
                    exit 1
                    ;;
            esac
        done
        
        echo "Change set applied successfully." | tee -a change_set_log.txt
        log_to_cloudwatch change_set_log.txt
    fi

    log_to_cloudwatch "Change Set Applied for stack: $stack_name"
}



##change logging
log_to_cloudwatch() {
    local message="$1"
    local timestamp=$(date +%s000)
    
    # Escape newlines and double quotes in the message
    message=$(echo "$message" | jq -R -s '.')
    
    # Construct the log event JSON
    local log_event='[{"timestamp":'$timestamp',"message":'$message'}]'
    
    # Get the sequence token
    local sequence_token=$(aws logs describe-log-streams \
        --log-group-name "$LOG_GROUP_NAME" \
        --log-stream-name "$LOG_STREAM_NAME" \
        --query 'logStreams[0].uploadSequenceToken' \
        --output text 2>/dev/null)
    
    local put_log_cmd="aws logs put-log-events \
        --log-group-name \"$LOG_GROUP_NAME\" \
        --log-stream-name \"$LOG_STREAM_NAME\" \
        --log-events \"$log_event\""
    
    # Add sequence token if it exists
    if [ "$sequence_token" != "None" ] && [ -n "$sequence_token" ]; then
        put_log_cmd="$put_log_cmd --sequence-token $sequence_token"
    fi
    
    if eval $put_log_cmd 2>&1 | tee cloudwatch_output.log; then
        echo "Logged to CloudWatch successfully"
    else
        echo "Failed to log to CloudWatch. Check cloudwatch_output.log for details."
        echo "$(date +%Y%m%d-%H%M%S) - Failed to log to CloudWatch: $message" >> cloudwatch_errors.log
    fi
}