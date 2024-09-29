

export https_proxy= '10.111.234.6:8888'
export http_proxy= '10.111.234.6:8888'


sudo dnf install python3 python3-pip -y
pip3 install --trusted-host pypi.org --trusted-host files.pythonhosted.org --no-cache-dir --cert="" ansible PyYAML paramiko botocore boto3

