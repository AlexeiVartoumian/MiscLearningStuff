#!/bin/bash

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log_message "Starting pre-api-helpers.sh script"

# Debug information
log_message "Current directory: $(pwd)"
log_message "Contents of current directory:"
ls -la

# Determine the correct paths
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CUSTOMIZATION_ROOT="$(dirname "$SCRIPT_DIR")"
PYTHON_DIR="$SCRIPT_DIR/python"
VENV_PATH="$(pwd)/aft-venv"
PLAYBOOKS_DIR="$CUSTOMIZATION_ROOT/playbooks"  # Adjust this path as needed

log_message "SCRIPT_DIR: $SCRIPT_DIR"
log_message "CUSTOMIZATION_ROOT: $CUSTOMIZATION_ROOT"
log_message "PYTHON_DIR: $PYTHON_DIR"
log_message "VENV_PATH: $VENV_PATH"
log_message "PLAYBOOKS_DIR: $PLAYBOOKS_DIR"

# Activate virtual environment
if [ -f "$VENV_PATH/bin/activate" ]; then
    source $VENV_PATH/bin/activate
    log_message "Virtual environment activated"
else
    log_message "Error: Virtual environment not found at $VENV_PATH"
    exit 1
fi

# Function to install a package and check for errors
install_package() {
    package=$1
    log_message "Installing $package"
    pip install $package
    if [ $? -eq 0 ]; then
        log_message "$package installed successfully"
    else
        log_message "Error: Failed to install $package"
        return 1
    fi
}

# Install required packages
packages=(boto3 ansible PyYAML paramiko botocore ansible-runner awscli)
for package in "${packages[@]}"; do
    install_package $package
    if [ $? -ne 0 ]; then
        log_message "Error: Package installation failed. Exiting."
        exit 1
    fi
done

# Print Python path and installed packages for debugging
log_message "Python path: $(which python)"
log_message "Installed packages:"
pip list

# Install amazon.aws collection
log_message "Installing amazon.aws collection"
ansible-galaxy collection install amazon.aws --ignore-certs
if [ $? -eq 0 ]; then
    log_message "amazon.aws collection installed successfully"
else
    log_message "Warning: Failed to install amazon.aws collection, but continuing script"
fi

# Set up CloudWatch logging
LOG_GROUP_NAME="/aft/ansible/created-resources"
LOG_STREAM_NAME="ansible-run-$(date +%Y-%m-%d-%H-%M-%S)"

# Create log group if it doesn't exist
if ! aws logs describe-log-groups --log-group-name-prefix $LOG_GROUP_NAME | grep -q $LOG_GROUP_NAME; then
    log_message "Creating CloudWatch log group: $LOG_GROUP_NAME"
    aws logs create-log-group --log-group-name $LOG_GROUP_NAME
else
    log_message "CloudWatch log group $LOG_GROUP_NAME already exists"
fi

# Create log stream
aws logs create-log-stream --log-group-name $LOG_GROUP_NAME --log-stream-name $LOG_STREAM_NAME

if command -v ansible &> /dev/null; then
    log_message "ansible is available"

    if command -v ansible-playbook &> /dev/null; then
        log_message "ansible-playbook is available. Executing playbook"

        SAMPLE_PLAYBOOK="$PLAYBOOKS_DIR/sample_playbook.yml"
        if [ -f "$SAMPLE_PLAYBOOK" ]; then 
            # Run Ansible playbook and capture output
            ANSIBLE_OUTPUT=$(ANSIBLE_STDOUT_CALLBACK=json ansible-playbook "$SAMPLE_PLAYBOOK" -v)
            
            # Send output to CloudWatch Logs
            echo "$ANSIBLE_OUTPUT" | aws logs put-log-events --log-group-name $LOG_GROUP_NAME --log-stream-name $LOG_STREAM_NAME --log-events file:///dev/stdin
            
            log_message "Ansible playbook output sent to CloudWatch Logs"
        else
            log_message "ERROR: sample playbook not found at $SAMPLE_PLAYBOOK"
        fi
    else
        log_message "ERROR: ansible-playbook command not found"
    fi
else
    log_message "ERROR: ansible command not found"
fi

deactivate
echo "Script completed successfully"
log_message "Finished pre-api-helpers script"



if command -v ansible-playbook &> /dev/null; then
    log_message "ansible-playbook is available. Executing playbook"

    SAMPLE_PLAYBOOK="$PLAYBOOKS_DIR/sample_playbook.yml"
    if [ -f "$SAMPLE_PLAYBOOK" ]; then 
        # Run Ansible playbook and capture both stdout and stderr
        ANSIBLE_OUTPUT=$(ansible-playbook "$SAMPLE_PLAYBOOK" 2>&1)
        ANSIBLE_EXIT_CODE=$?

        # Log the Ansible output
        echo "$ANSIBLE_OUTPUT" >> /tmp/ansible_full_output.log

        # Check if the JSON output file was created
        if [ -f "/tmp/ansible_resource_output.json" ]; then
            log_message "Ansible resource output JSON file created successfully"
            
            # Append the JSON content to the full output log
            echo "Resource Output JSON:" >> /tmp/ansible_full_output.log
            cat /tmp/ansible_resource_output.json >> /tmp/ansible_full_output.log
        else
            log_message "ERROR: Ansible resource output JSON file was not created"
        fi

        # Check Ansible exit code
        if [ $ANSIBLE_EXIT_CODE -ne 0 ]; then
            log_message "ERROR: Ansible playbook execution failed"
            exit 1
        fi
    else
        log_message "ERROR: sample playbook not found at $SAMPLE_PLAYBOOK"
        exit 1
    fi
else
    log_message "ERROR: ansible-playbook command not found"
    exit 1
fi