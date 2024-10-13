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

log() {
    local message="$1"
    echo "$message"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> script_log.txt
}

# Function to create log group
create_log_group() {
    log "Creating log group: $LOG_GROUP_NAME"
    if aws logs create-log-group --log-group-name "$LOG_GROUP_NAME"; then
        log "Log group created successfully"
        return 0
    else
        log "Failed to create log group"
        return 1
    fi
}

# Function to create log stream
create_log_stream() {
    log "Creating log stream: $LOG_STREAM_NAME"
    if aws logs create-log-stream --log-group-name "$LOG_GROUP_NAME" --log-stream-name "$LOG_STREAM_NAME"; then
        log "Log stream created successfully"
        return 0
    else
        log "Failed to create log stream"
        return 1
    fi
}

# Function to ensure log group and stream exist
ensure_log_group_and_stream() {
    # Check if log group exists
    if ! aws logs describe-log-groups --log-group-name-prefix "$LOG_GROUP_NAME" | grep -q "$LOG_GROUP_NAME"; then
        create_log_group || return 1
    else
        log "Log group already exists: $LOG_GROUP_NAME"
    fi

    # Check if log stream exists
    if ! aws logs describe-log-streams --log-group-name "$LOG_GROUP_NAME" --log-stream-name-prefix "$LOG_STREAM_NAME" | grep -q "$LOG_STREAM_NAME"; then
        create_log_stream || return 1
    else
        log "Log stream already exists: $LOG_STREAM_NAME"
    fi

    return 0
}

# Function to log to CloudWatch
log_to_cloudwatch() {
    local message="$1"
    local timestamp=$(date +%s000)
    
    if aws logs put-log-events \
        --log-group-name "$LOG_GROUP_NAME" \
        --log-stream-name "$LOG_STREAM_NAME" \
        --log-events "timestamp=$timestamp,message=$message" 2>/dev/null; then
        log "Logged to CloudWatch: $message"
    else
        log "Failed to log to CloudWatch: $message"
    fi
}

# ... (rest of the script)

# Before using CloudWatch logs, ensure the group and stream exist
if ensure_log_group_and_stream; then
    log "Log group and stream are ready"
else
    log "Failed to set up log group and stream. Exiting."
    exit 1
fi

# Now you can use log_to_cloudwatch function in the rest of your script
log_to_cloudwatch "Starting CloudFormation change set process"