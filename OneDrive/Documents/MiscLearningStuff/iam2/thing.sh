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

log_message "SCRIPT_DIR: $SCRIPT_DIR"
log_message "CUSTOMIZATION_ROOT: $CUSTOMIZATION_ROOT"
log_message "PYTHON_DIR: $PYTHON_DIR"

# Activate virtual environment
if [ -f "$CUSTOMIZATION_ROOT/venv/bin/activate" ]; then
    source $CUSTOMIZATION_ROOT/venv/bin/activate
    log_message "Virtual environment activated"
else
    log_message "Error: Virtual environment not found"
    exit 1
fi

# Run the Python script
log_message "Running create_s3_bucket.py"
python $PYTHON_DIR/create_s3_bucket.py

# Check if the Python script executed successfully
if [ $? -eq 0 ]; then
    log_message "Python script executed successfully"
else
    log_message "Error: Python script failed to execute"
    exit 1
fi

# Deactivate virtual environment
deactivate
log_message "Virtual environment deactivated"

log_message "pre-api-helpers.sh script completed"