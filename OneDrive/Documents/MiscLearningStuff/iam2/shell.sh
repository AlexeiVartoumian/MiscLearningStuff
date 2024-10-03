#!/bin/bash

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log_message "Starting AWS Ansible runner script"

# Debug information
log_message "Current directory: $(pwd)"
log_message "Contents of current directory:"
ls -la

# Determine the correct paths
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CUSTOMIZATION_ROOT="$(dirname "$SCRIPT_DIR")"
ANSIBLE_DIR="$SCRIPT_DIR/ansible"

log_message "SCRIPT_DIR: $SCRIPT_DIR"
log_message "CUSTOMIZATION_ROOT: $CUSTOMIZATION_ROOT"
log_message "ANSIBLE_DIR: $ANSIBLE_DIR"

# Function to install a package and check for errors
install_package() {
    package=$1
    log_message "Installing $package"
    if command -v yum &> /dev/null; then
        sudo yum install -y $package
    elif command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y $package
    else
        log_message "Error: Unable to determine package manager"
        return 1
    fi
    if [ $? -eq 0 ]; then
        log_message "$package installed successfully"
    else
        log_message "Error: Failed to install $package"
    fi
}

# Install required packages
packages=(python3 python3-pip ansible)
for package in "${packages[@]}"; do
    install_package $package
done

# Install AWS CLI if not already installed
if ! command -v aws &> /dev/null; then
    log_message "Installing AWS CLI"
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf aws awscliv2.zip
fi

# Install required Python packages
log_message "Installing required Python packages"
sudo pip3 install boto3 botocore

# Install amazon.aws collection
log_message "Installing amazon.aws collection"
ansible-galaxy collection install amazon.aws --ignore-certs
if [ $? -eq 0 ]; then
    log_message "amazon.aws collection installed successfully"
else
    log_message "Warning: Failed to install amazon.aws collection, but continuing script"
fi

# Get the vended account ID
VENDED_ACCOUNT_ID=$(aws ssm get-parameter --name "/aft/account-request/account-id" --query "Parameter.Value" --output text)
log_message "Vended Account ID: $VENDED_ACCOUNT_ID"

# Function to run an Ansible playbook
run_playbook() {
    playbook=$1
    log_message "Running Ansible playbook: $playbook"
    ansible-playbook -i $ANSIBLE_DIR/inventory $ANSIBLE_DIR/$playbook \
        -e "vended_account_id=$VENDED_ACCOUNT_ID" \
        --extra-vars "@$ANSIBLE_DIR/vars/main.yml"
    
    if [ $? -eq 0 ]; then
        log_message "Ansible playbook $playbook executed successfully"
    else
        log_message "Warning: Ansible playbook $playbook execution failed"
    fi
}

# Run Ansible playbooks
run_playbook "setup_iam.yml"
run_playbook "configure_vpc.yml"
run_playbook "deploy_ec2.yml"

log_message "AWS Ansible runner script completed"