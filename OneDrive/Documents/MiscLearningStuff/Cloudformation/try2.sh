#!/bin/bash

set -e

# Get the directory of the script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." &> /dev/null && pwd )"
# Configuration file path
CONFIG_FILE="${SCRIPT_DIR}/cloudformation_config.json"

# Function to resolve file paths
resolve_path() {
    local base_dir="$1"
    local file_path="$2"
    
    echo "$PROJECT_ROOT/files/$file_name"
}


# Function to log to CloudWatch
log_to_cloudwatch() {
    local message="$1"
    local timestamp=$(date +%s000)
    
    aws logs put-log-events \
        --log-group-name "$LOG_GROUP_NAME" \
        --log-stream-name "$LOG_STREAM_NAME" \
        --log-events "timestamp=$timestamp,message=$message"
}

# Function to check if a stack exists
stack_exists() {
    local stack_name="$1"
    if aws cloudformation describe-stacks --stack-name "$stack_name" --region "$REGION" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to create a new stack
create_stack() {
    local stack_name="$1"
    local template_file="$2"
    local parameters=("${@:3}")

    echo "Creating new stack: $stack_name"
    # local output=$(aws cloudformation create-stack \
    #     --stack-name "$stack_name" \
    #     --template-body "file://$template_file" \
    #     --parameters "${parameters[@]}" \
    #     --capabilities CAPABILITY_NAMED_IAM \
    #     --region "$REGION" 2>&1)

    aws cloudformation create-change-set \
        --stack-name "$stack_name" \
        --template-body "file://$template_file" \
        --change-set-type "CREATE"
        --change-set-name "$change_set_name" \
        --description "Change set for $stack_name" \
        --parameters "${parameters[@]}" \
        --capabilities CAPABILITY_NAMED_IAM \
        --region "$REGION" 
    
    echo "$output"
    log_to_cloudwatch "Stack Creation Initiated: $output"

    echo "Waiting for stack creation to complete..."
    aws cloudformation wait stack-create-complete --stack-name "$stack_name" --region "$REGION"
    echo "Stack created successfully."

    local stack_details=$(aws cloudformation describe-stacks --stack-name "$stack_name" --region "$REGION")
    log_to_cloudwatch "Stack Creation Completed. Details: $stack_details"
}



# Read configuration
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Configuration file not found: $CONFIG_FILE"
    exit 1
fi

printf '%s\n' "${PARAMS[@]}"
# Extract values from configuration
JSON_CONTENT=$(<"$CONFIG_FILE")  
STACK_NAME=$(jq -r '.stack_name' <<< "$JSON_CONTENT")
TEMPLATE_FILE=$(jq -r '.template_file' "$JSON_CONTENT")
REGION=$(jq -r '.region' <<< "$JSON_CONTENT")


CHANGE_SET_NAME="${STACK_NAME}-changes-$(date +%Y%m%d-%H%M%S)"

LOG_GROUP_NAME=$(jq -r '.log_group_name' "$CONFIG_FILE")
LOG_STREAM_NAME=$(jq -r '.log_stream_name' "$CONFIG_FILE")

# Resolve the template file path
#TEMPLATE_FILE=$(resolve_path "$SCRIPT_DIR" "$TEMPLATE_FILE")

# Check if the template file exists
# if [ ! -f "$TEMPLATE_FILE" ]; then
#     echo "Template file not found: $TEMPLATE_FILE"
#     exit 1
# fi

# Prepare parameters for AWS CLI
PARAMS=()
while IFS='=' read -r key value; do
    PARAMS+=("ParameterKey=$key,ParameterValue=$value")
done < <(jq -r '.parameters | to_entries[] | "\(.key)=\(.value)"' "$CONFIG_FILE")

# Function to create a change set and log its details
create_and_log_change_set() {
    local stack_name="$1"
    local template_file="$2"
    local change_set_name="$3"
    local parameters=("${@:4}")

    echo "Creating change set '$change_set_name' for stack '$stack_name'..."
    aws cloudformation create-change-set \
        --stack-name "$stack_name" \
        --template-body "file://$template_file" \
        --change-set-type "UPDATE" \
        --change-set-name "$change_set_name" \
        --description "Change set for $stack_name" \
        --parameters "${parameters[@]}" \
        --capabilities CAPABILITY_NAMED_IAM \
        --region "$REGION" 
    
    echo "$output"
    log_to_cloudwatch "Change Set Creation Initiated: $output"

    echo "Waiting for change set creation to complete..."
    aws cloudformation wait change-set-create-complete \
        --stack-name "$stack_name" \
        --change-set-name "$change_set_name" \
        --region "$REGION"

    change_set_details=$(aws cloudformation describe-change-set \
        --stack-name "$stack_name" \
        --change-set-name "$change_set_name" \
        --region "$REGION")

    log_to_cloudwatch "Change Set Created. Details: $change_set_details"

    echo "Change set creation complete. Summary:"
    echo "$change_set_details" | jq -r '.Changes[] | "- \(.ResourceChange.Action) \(.ResourceChange.LogicalResourceId) (\(.ResourceChange.ResourceType))"'
}

# Main execution
if stack_exists "$STACK_NAME"; then
    echo "Stack $STACK_NAME exists. Creating a change set."
    create_and_log_change_set "$STACK_NAME" "$TEMPLATE_FILE" "$CHANGE_SET_NAME" "${PARAMS[@]}"
else
    echo "Stack $STACK_NAME does not exist. Creating a new stack."
    create_stack "$STACK_NAME" "$TEMPLATE_FILE" "${PARAMS[@]}"
fi

echo "Process completed."



#----------------------------------
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
    aws cloudformation wait change-set-create-complete \
        --stack-name "$stack_name" \
        --change-set-name "$change_set_name" \
        --region "$REGION"

    # Check if the change set has any changes
    changes=$(aws cloudformation describe-change-set \
        --stack-name "$stack_name" \
        --change-set-name "$change_set_name" \
        --region "$REGION" \
        --query 'Changes[].ResourceChange.LogicalResourceId' \
        --output text)

    if [ -z "$changes" ]; then
        echo "No changes detected in the change set. Deleting the change set."
        aws cloudformation delete-change-set \
            --stack-name "$stack_name" \
            --change-set-name "$change_set_name" \
            --region "$REGION"
    else
        echo "Changes detected. Applying the change set..."
        aws cloudformation execute-change-set \
            --stack-name "$stack_name" \
            --change-set-name "$change_set_name" \
            --region "$REGION"

        echo "Waiting for stack update to complete..."
        aws cloudformation wait stack-update-complete \
            --stack-name "$stack_name" \
            --region "$REGION"

        echo "Change set applied successfully."
    fi

    log_to_cloudwatch "Change Set Applied for stack: $stack_name"
}

# Main execution
if stack_exists "$STACK_NAME"; then
    echo "Stack $STACK_NAME exists. Creating and applying an update change set."
    create_apply_change_set "$STACK_NAME" "$TEMPLATE_FILE" "$CHANGE_SET_NAME" "UPDATE" "${PARAMS[@]}"
else
    echo "Stack $STACK_NAME does not exist. Creating a new stack with an initial change set."
    create_apply_change_set "$STACK_NAME" "$TEMPLATE_FILE" "$CHANGE_SET_NAME" "CREATE" "${PARAMS[@]}"
fi

echo "Process completed."