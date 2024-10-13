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