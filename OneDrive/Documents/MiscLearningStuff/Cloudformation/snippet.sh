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