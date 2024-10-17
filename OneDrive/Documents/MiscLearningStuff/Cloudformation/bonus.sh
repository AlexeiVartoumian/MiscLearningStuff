format_change_set() {
    local stack_name="$1"
    local change_set_name="$2"
    
    echo "Change Set Description for $stack_name:"
    aws cloudformation describe-change-set \
        --stack-name "$stack_name" \
        --change-set-name "$change_set_name" \
        --region "$REGION" \
        --output json | jq '
            "Stack Name: \(.StackName)",
            "Change Set Name: \(.ChangeSetName)",
            "Status: \(.Status)",
            "Execution Status: \(.ExecutionStatus)",
            "Description: \(.Description)",
            "Changes:",
            "  Additions:",
            (.Changes[] | select(.ResourceChange.Action == "Add") | "    - \(.ResourceChange.LogicalResourceId) (\(.ResourceChange.ResourceType))"),
            "  Deletions:",
            (.Changes[] | select(.ResourceChange.Action == "Remove") | "    - \(.ResourceChange.LogicalResourceId) (\(.ResourceChange.ResourceType))"),
            "  Modifications:",
            (.Changes[] | select(.ResourceChange.Action == "Modify") | "    - \(.ResourceChange.LogicalResourceId) (\(.ResourceChange.ResourceType)), Replacement: \(.ResourceChange.Replacement)")'
}

format_change_set() {
    local stack_name="$1"
    local change_set_name="$2"
    
    echo "Change Set Description for $stack_name:"
    aws cloudformation describe-change-set \
        --stack-name "$stack_name" \
        --change-set-name "$change_set_name" \
        --region "$REGION" \
        --output json | jq '
            "Stack Name: \(.StackName)",
            "Change Set Name: \(.ChangeSetName)",
            "Status: \(.Status)",
            "Execution Status: \(.ExecutionStatus)",
            "Description: \(.Description)",
            "Changes:",
            "  Additions:",
            (.Changes[] | select(.ResourceChange.Action == "Add") | "    - \(.ResourceChange.LogicalResourceId) (\(.ResourceChange.ResourceType))"),
            "  Deletions:",
            (.Changes[] | select(.ResourceChange.Action == "Remove") | "    - \(.ResourceChange.LogicalResourceId) (\(.ResourceChange.ResourceType))"),
            "  Modifications:",
            (.Changes[] | select(.ResourceChange.Action == "Modify") | "    - \(.ResourceChange.LogicalResourceId) (\(.ResourceChange.ResourceType)), Replacement: \(.ResourceChange.Replacement)")'
}