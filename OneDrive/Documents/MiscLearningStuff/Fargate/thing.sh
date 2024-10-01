#!/bin/bash

# Enable command echoing
set -x

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log_message "Starting post-api-helpers.sh script"

# Debug information
log_message "CUSTOMIZATION: $CUSTOMIZATION"
log_message "DEFAULT_PATH: $DEFAULT_PATH"
log_message "Current directory: $(pwd)"
log_message "Contents of current directory:"
ls -la

# Activate the virtual environment
if [ -f "$DEFAULT_PATH/api-helpers-venv/bin/activate" ]; then
    source $DEFAULT_PATH/api-helpers-venv/bin/activate
    log_message "Virtual environment activated"
else
    log_message "Error: Virtual environment not found"
    exit 1
fi

# Print Python packages
log_message "Installed Python packages:"
pip list

# Change to the directory containing the Ansible playbook
if [ -d "$DEFAULT_PATH/$CUSTOMIZATION/ansible_playbooks" ]; then
    cd $DEFAULT_PATH/$CUSTOMIZATION/ansible_playbooks
    log_message "Changed to ansible_playbooks directory"
else
    log_message "Error: ansible_playbooks directory not found"
    exit 1
fi

log_message "Contents of ansible_playbooks directory:"
ls -la

# Run the Ansible playbook
if [ -f hello_world.yml ]; then
    log_message "Running Ansible playbook"
    ansible-playbook hello_world.yml
else
    log_message "Error: hello_world.yml not found in $(pwd)"
    exit 1
fi

# Deactivate the virtual environment
deactivate
log_message "Virtual environment deactivated"

# Return to the original directory
cd $DEFAULT_PATH
log_message "Returned to original directory"

log_message "post-api-helpers.sh script completed"

# Disable command echoing
set +x