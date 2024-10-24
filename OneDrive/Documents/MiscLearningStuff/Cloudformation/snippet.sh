CONFIG_FILE="cloudformation_config.json"

# Read configuration
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Read the entire JSON file into a variable
JSON_CONTENT=$(<"$CONFIG_FILE")

# Extract values from configuration
STACK_NAME=$(jq -r '.stack_name' <<< "$JSON_CONTENT")
TEMPLATE_FILE=$(jq -r '.template_file' <<< "$JSON_CONTENT")
PROFILE=$(jq -r '.profile' <<< "$JSON_CONTENT")
REGION=$(jq -r '.region' <<< "$JSON_CONTENT")

# Print the extracted values for debugging
echo "STACK_NAME: $STACK_NAME"
echo "TEMPLATE_FILE: $TEMPLATE_FILE"
echo "PROFILE: $PROFILE"
echo "REGION: $REGION"

# Prepare parameters for AWS CLI
PARAMS=()
while IFS='=' read -r key value; do
    PARAMS+=("ParameterKey=$key,ParameterValue=$value")
done < <(jq -r '.parameters | to_entries[] | "\(.key)=\(.value)"' <<< "$JSON_CONTENT")

# Print the parameters for debugging
echo "Parameters:"
printf '%s\n' "${PARAMS[@]}"

log_to_cloudwatch() {
    local message="$1"
    local timestamp=$(date +%s000)
    
    if aws logs put-log-events \
        --log-group-name "$LOG_GROUP_NAME" \
        --log-stream-name "$LOG_STREAM_NAME" \
        --log-events "timestamp=$timestamp,message=$message" 2>/dev/null; then
        echo "Logged to CloudWatch: $message"
    else
        echo "Failed to log to CloudWatch: $message"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Failed to log to CloudWatch: $message" >> cloudwatch_errors.log
    fi
}

# Ensure log group exists
ensure_log_group() {
    # Check if log group exists
    if ! aws logs describe-log-groups --log-group-name-prefix "$LOG_GROUP_NAME" | grep -q "$LOG_GROUP_NAME"; then
        echo "Creating log group: $LOG_GROUP_NAME"
        if aws logs create-log-group --log-group-name "$LOG_GROUP_NAME"; then
            echo "Log group created successfully"
        else
            echo "Failed to create log group"
            return 1
        fi
    else
        echo "Log group already exists: $LOG_GROUP_NAME"
    fi

    # Check if log stream exists
    if ! aws logs describe-log-streams --log-group-name "$LOG_GROUP_NAME" --log-stream-name-prefix "$LOG_STREAM_NAME" | grep -q "$LOG_STREAM_NAME"; then
        echo "Creating log stream: $LOG_STREAM_NAME"
        if aws logs create-log-stream --log-group-name "$LOG_GROUP_NAME" --log-stream-name "$LOG_STREAM_NAME"; then
            echo "Log stream created successfully"
        else
            echo "Failed to create log stream"
            return 1
        fi
    else
        echo "Log stream already exists: $LOG_STREAM_NAME"
    fi

    return 0
}

# ... (rest of the script)

# Before using CloudWatch logs, ensure the group and stream exist
if ensure_log_group; then
    echo "Log group and stream are ready"
    log_to_cloudwatch "Starting CloudFormation change set process"
else
    echo "Failed to set up log group and stream. Exiting."
    exit 1
fi
#------------------------------------------------

create_and_log_change_set() {
    local stack_name="$1"
    local template_file="$2"
    local change_set_name="$3"
    local parameters=("${@:4}")

    echo "Creating change set '$change_set_name' for stack '$stack_name'..."
    aws cloudformation create-change-set \
        --stack-name "$stack_name" \
        --template-body "file://$template_file" \
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

    echo "Change set created. Fetching and logging details..."
    change_set_details=$(aws cloudformation describe-change-set \
        --stack-name "$stack_name" \
        --change-set-name "$change_set_name" \
        --region "$REGION")

    # Log change set details
    echo "Change Set Details:" >> "$LOG_FILE"
    echo "$change_set_details" >> "$LOG_FILE"
    echo "----------------------------------------" >> "$LOG_FILE"

    # Print a summary to console
    echo "Change set creation complete. Summary:"
    echo "$change_set_details" | jq -r '.Changes[] | "- \(.ResourceChange.Action) \(.ResourceChange.LogicalResourceId) (\(.ResourceChange.ResourceType))"'
}

# ... (keep existing code for reading config and resolving paths)

# Set up logging
LOG_DIR="${SCRIPT_DIR}/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="${LOG_DIR}/changeset_log_${STACK_NAME}_$(date +%Y%m%d-%H%M%S).json"

# Generate a unique change set name
CHANGE_SET_NAME="${STACK_NAME}-changes-$(date +%Y%m%d-%H%M%S)"

# Create and log the change set
create_and_log_change_set "$STACK_NAME" "$TEMPLATE_FILE" "$CHANGE_SET_NAME" "${PARAMS[@]}"

echo "Change set details have been logged to $LOG_FILE"



###0----------------------------------------------------

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
    aws cloudformation create-stack \
        --stack-name "$stack_name" \
        --template-body "file://$template_file" \
        --parameters "${parameters[@]}" \
        --capabilities CAPABILITY_NAMED_IAM \
        --region "$REGION"

    echo "Waiting for stack creation to complete..."
    aws cloudformation wait stack-create-complete --stack-name "$stack_name" --region "$REGION"
    echo "Stack created successfully."
}

# Check if the stack exists
if stack_exists "$STACK_NAME"; then
    echo "Stack $STACK_NAME exists. Creating a change set."
    create_and_log_change_set "$STACK_NAME" "$TEMPLATE_FILE" "$CHANGE_SET_NAME" "${PARAMS[@]}"
    echo "Change set details have been logged to $LOG_FILE"
else
    echo "Stack $STACK_NAME does not exist. Creating a new stack."
    create_stack "$STACK_NAME" "$TEMPLATE_FILE" "${PARAMS[@]}"
    echo "Stack creation details:" >> "$LOG_FILE"
    aws cloudformation describe-stacks --stack-name "$STACK_NAME" --region "$REGION" >> "$LOG_FILE"
    echo "----------------------------------------" >> "$LOG_FILE"
    echo "Stack creation details have been logged to $LOG_FILE"
fi

# Optionally, you can add logic here to decide whether to execute the change set if one was created
# For example:
# if stack_exists "$STACK_NAME"; then
#     read -p "Do you want to execute this change set? (y/n) " -n 1 -r
#     if [[ $REPLY =~ ^[Yy]$ ]]
#     then
#         aws cloudformation execute-change-set --stack-name "$STACK_NAME" --change-set-name "$CHANGE_SET_NAME" --region "$REGION"
#     fi
# fi