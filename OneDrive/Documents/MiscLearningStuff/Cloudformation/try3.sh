check_stack_status() {
    local stack_name="$1"
    aws cloudformation describe-stacks \
        --stack-name "$stack_name" \
        --region "$REGION" \
        --query 'Stacks[0].StackStatus' \
        --output text
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
        while true; do
            status=$(check_stack_status "$stack_name")
            echo "Current stack status: $status"
            case $status in
                *COMPLETE)
                    echo "Stack operation completed."
                    break
                    ;;
                *FAILED)
                    echo "Stack operation failed. Check CloudFormation console for details."
                    exit 1
                    ;;
                *IN_PROGRESS)
                    echo "Stack operation in progress. Waiting..."
                    sleep 30
                    ;;
                *)
                    echo "Unknown stack status. Exiting."
                    exit 1
                    ;;
            esac
        done

        echo "Change set applied successfully."
    fi

    log_to_cloudwatch "Change Set Applied for stack: $stack_name"
}