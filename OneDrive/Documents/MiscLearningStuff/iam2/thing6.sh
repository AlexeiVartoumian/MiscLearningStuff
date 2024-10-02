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
PLAYBOOKS_DIR="$CUSTOMIZATION_ROOT/ansible_playbooks"

log_message "SCRIPT_DIR: $SCRIPT_DIR"
log_message "CUSTOMIZATION_ROOT: $CUSTOMIZATION_ROOT"
log_message "PYTHON_DIR: $PYTHON_DIR"
log_message "VENV_PATH: $VENV_PATH"
log_message "PLAYBOOKS_DIR: $PLAYBOOKS_DIR"

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

# Create a Python script to run Ansible playbooks using ansible-runner
cat << EOF > $SCRIPT_DIR/run_ansible_playbooks.py
import ansible_runner
import os
import sys

def run_playbook(playbook_path):
    print(f"Running playbook: {playbook_path}")
    r = ansible_runner.run(playbook=playbook_path, quiet=False)
    
    print(f"Playbook Status: {r.status}")
    print(f"Final RC: {r.rc}")
    
    # Print out all the events
    for event in r.events:
        print(event)
    
    return r.rc == 0

def run_playbooks_in_directory(directory):
    success = True
    for filename in sorted(os.listdir(directory)):
        if filename.endswith(".yml") or filename.endswith(".yaml"):
            playbook_path = os.path.join(directory, filename)
            if not run_playbook(playbook_path):
                print(f"Playbook {filename} failed.")
                success = False
    return success

if __name__ == "__main__":
    playbooks_dir = sys.argv[1]
    if run_playbooks_in_directory(playbooks_dir):
        print("All playbooks executed successfully.")
    else:
        print("One or more playbooks failed.")
        sys.exit(1)
EOF

# Run the Ansible playbooks using ansible-runner
log_message "Running Ansible playbooks using ansible-runner"
python $SCRIPT_DIR/run_ansible_playbooks.py "$PLAYBOOKS_DIR"

# Check if the Python script executed successfully
if [ $? -eq 0 ]; then
    log_message "All Ansible playbooks executed successfully"
else
    log_message "Warning: One or more Ansible playbooks failed"
fi

# Deactivate virtual environment
deactivate
log_message "Virtual environment deactivated"

log_message "pre-api-helpers.sh script completed"