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

log_message "SCRIPT_DIR: $SCRIPT_DIR"
log_message "CUSTOMIZATION_ROOT: $CUSTOMIZATION_ROOT"
log_message "PYTHON_DIR: $PYTHON_DIR"
log_message "VENV_PATH: $VENV_PATH"

# Activate virtual environment
if [ -f "$VENV_PATH/bin/activate" ]; then
    source $VENV_PATH/bin/activate
    log_message "Virtual environment activated"
else
    log_message "Error: Virtual environment not found at $VENV_PATH"
    # Continue instead of exiting
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
    fi
}

# Install required packages
packages=(boto3 ansible PyYAML paramiko botocore ansible-runner)
for package in "${packages[@]}"; do
    install_package $package
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

# Get the vended account ID
VENDED_ACCOUNT_ID=$(aws ssm get-parameter --name "/aft/account-request/account-id" --query "Parameter.Value" --output text)
log_message "Vended Account ID: $VENDED_ACCOUNT_ID"

# Run the Python script with the vended account ID
log_message "Running iam_user.py"
VENDED_ACCOUNT_ID=$VENDED_ACCOUNT_ID python $PYTHON_DIR/iam_user.py

# Check if the Python script executed successfully
if [ $? -eq 0 ]; then
    log_message "Python script executed successfully"
else
    log_message "Warning: Python script execution failed, but continuing"
fi

# Deactivate virtual environment
deactivate
log_message "Virtual environment deactivated"

log_message "pre-api-helpers.sh script completed"