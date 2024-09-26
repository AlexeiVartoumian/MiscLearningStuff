mkdir ansible_aws_package
cd ansible_aws_package



python3 -m venv ansible_venv
source ansible_venv/bin/activate



pip install ansible boto3 botocore
ansible-galaxy collection install amazon.aws



pip freeze > requirements.txt

Create a wrapper script to set up the environment:

chmod +x run_ansible.sh

#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export PYTHONPATH="$SCRIPT_DIR/ansible_venv/lib/python3.*/site-packages:$PYTHONPATH"
export ANSIBLE_COLLECTIONS_PATH="$SCRIPT_DIR/ansible_venv/lib/python3.*/site-packages/ansible_collections"
"$SCRIPT_DIR/ansible_venv/bin/ansible-playbook" "$@"


zip -r ansible_aws_package.zip ansible_venv requirements.txt run_ansible.sh test_aws.yml

aws s3 cp ansible_aws_package.zip s3://your-bucket-name/


aws s3 cp s3://your-bucket-name/ansible_aws_package.zip .
unzip ansible_aws_package.zip


./run_ansible.sh test_aws.yml



sudo mv ansible_venv/bin/ansible* /usr/local/bin/
sudo nano /usr/lib/python3.x/site-packages/ansible.pth
add below to above file
ansible_venv/lib/python3.x/site-packages

sudo mkdir -p /etc/ansible
sudo nano /etc/ansible/ansible.cfg



[defaults]
collections_paths = ansible_venv/lib/python3.x/site-packages/ansible_collections
library = /ansible_venv/lib/python3.x/site-packages/ansible/modules
module_utils = /ansible_venv/lib/python3.x/site-packages/ansible/module_utils


echo 'export PATH=$PATH:/home/ec2-user/ansible_aws_package/ansible_venv/bin' >> ~/.bashrc

source ~/.bashrc

#!/bin/bash
set -x

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "SCRIPT_DIR: $SCRIPT_DIR"

PYTHON_VERSION=$(ls "$SCRIPT_DIR/ansible_venv/lib/" | grep python)
echo "PYTHON_VERSION: $PYTHON_VERSION"

export PYTHONPATH="$SCRIPT_DIR/ansible_venv/lib/$PYTHON_VERSION/site-packages:$PYTHONPATH"
echo "PYTHONPATH: $PYTHONPATH"

export ANSIBLE_COLLECTIONS_PATH="$SCRIPT_DIR/ansible_venv/lib/$PYTHON_VERSION/site-packages/ansible_collections"
echo "ANSIBLE_COLLECTIONS_PATH: $ANSIBLE_COLLECTIONS_PATH"

# Function to execute a command using the virtual environment's Python
run_command() {
    local cmd="$1"
    shift
    echo "Attempting to run: $SCRIPT_DIR/ansible_venv/bin/python $SCRIPT_DIR/ansible_venv/bin/$cmd $@"
    "$SCRIPT_DIR/ansible_venv/bin/python" "$SCRIPT_DIR/ansible_venv/bin/$cmd" "$@"
}

# Check which command is being called
case "$1" in
    ansible-playbook)
        run_command "ansible-playbook" "${@:2}"
        ;;
    ansible-galaxy)
        run_command "ansible-galaxy" "${@:2}"
        ;;
    ansible-community)
        run_command "ansible-community" "${@:2}"
        ;;
    pip|pip3)
        run_command "$1" "${@:2}"
        ;;
    *)
        echo "Usage: $0 {ansible-playbook|ansible-galaxy|ansible-community|pip|pip3} [arguments]"
        exit 1
        ;;
esac