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
VENV_PATH="$DEFAULT_PATH/aft-venv"

log_message "SCRIPT_DIR: $SCRIPT_DIR"
log_message "CUSTOMIZATION_ROOT: $CUSTOMIZATION_ROOT"
log_message "PYTHON_DIR: $PYTHON_DIR"
log_message "VENV_PATH: $VENV_PATH"

# Check if VENDED_ACCOUNT_ID is set
if [ -z "$VENDED_ACCOUNT_ID" ]; then
    log_message "Error: VENDED_ACCOUNT_ID is not set"
else
    log_message "VENDED_ACCOUNT_ID: $VENDED_ACCOUNT_ID"
fi

# Activate virtual environment
if [ -f "$VENV_PATH/bin/activate" ]; then
    source $VENV_PATH/bin/activate
    log_message "Virtual environment activated"
else
    log_message "Error: Virtual environment not found at $VENV_PATH"
    # Continue instead of exiting
fi

# Print Python path and installed packages for debugging
log_message "Python path: $(which python)"
log_message "Installed packages:"
pip list

# Run the Python script with the vended account ID
log_message "Running iam_user.py"
python $PYTHON_DIR/iam_user.py

# Check if the Python script executed successfully
if [ $? -eq 0 ]; then
    log_message "Python script executed successfully"
else
    log_message "Warning: Python script execution failed, but continuing"
fi

# Create a simple Ansible playbook
mkdir -p $SCRIPT_DIR/ansible_test
cat << EOF > $SCRIPT_DIR/ansible_test/test_playbook.yml
---
- name: Test Playbook
  hosts: localhost
  connection: local
  gather_facts: false
  tasks:
    - name: Print hello world
      debug:
        msg: "Hello, World from Ansible in AFT customization!"
    
    - name: Get AWS account info
      aws_caller_info:
      register: aws_info
    
    - name: Display AWS account info
      debug:
        var: aws_info
EOF

# Create a Python script to run the Ansible playbook using ansible-runner
cat << EOF > $SCRIPT_DIR/run_ansible_playbook.py
import ansible_runner
import os

def run_playbook():
    playbook_path = os.path.join(os.path.dirname(__file__), 'ansible_test', 'test_playbook.yml')
    r = ansible_runner.run(playbook=playbook_path, quiet=False)
    
    print(f"Playbook Status: {r.status}")
    print(f"Final RC: {r.rc}")
    
    # Print out all the events
    for event in r.events:
        print(event)

if __name__ == "__main__":
    run_playbook()
EOF

# Run the Ansible playbook using ansible-runner
log_message "Running Ansible playbook using ansible-runner"
python $SCRIPT_DIR/run_ansible_playbook.py

# Deactivate virtual environment
deactivate
log_message "Virtual environment deactivated"

log_message "pre-api-helpers.sh script completed"