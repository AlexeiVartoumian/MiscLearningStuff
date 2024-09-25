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


[defaults]
collections_paths = ansible_venv/lib/python3.x/site-packages/ansible_collections
library = /ansible_venv/lib/python3.x/site-packages/ansible/modules
module_utils = /ansible_venv/lib/python3.x/site-packages/ansible/module_utils


echo 'export PATH=$PATH:/home/ec2-user/ansible_aws_package/ansible_venv/bin' >> ~/.bashrc