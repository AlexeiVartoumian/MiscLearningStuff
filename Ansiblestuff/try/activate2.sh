#!/bin/bash

set -e

# Create a temporary directory for our package
PACKAGE_DIR=$(mktemp -d)
echo "Creating package in $PACKAGE_DIR"

# Create a virtual environment
python3 -m venv $PACKAGE_DIR/ansible_venv

# Activate the virtual environment
source $PACKAGE_DIR/ansible_venv/bin/activate

# Upgrade pip with TLS verification disabled
pip install --upgrade pip --trusted-host pypi.org --trusted-host files.pythonhosted.org --no-cache-dir --cert=""

# Install Ansible with TLS verification disabled
pip install ansible --trusted-host pypi.org --trusted-host files.pythonhosted.org --no-cache-dir --cert=""

# Install AWS collections with certificate verification ignored
ansible-galaxy collection install amazon.aws --ignore-certs
ansible-galaxy collection install community.aws --ignore-certs

# Create a wrapper script for Ansible commands
cat > $PACKAGE_DIR/ansible_wrapper.sh << EOL
#!/bin/bash
SCRIPT_DIR="/opt/ansible_package"
source "\$SCRIPT_DIR/ansible_venv/bin/activate"
export ANSIBLE_COLLECTIONS_PATH="\$SCRIPT_DIR/ansible_venv/lib/python3.*/site-packages/ansible_collections"
export ANSIBLE_LIBRARY="\$SCRIPT_DIR/ansible_venv/lib/python3.*/site-packages/ansible/modules"
export PIP_TRUSTED_HOST="pypi.org files.pythonhosted.org"
export PIP_NO_CACHE_DIR=1
export PIP_CERT=""
export ANSIBLE_HOST_KEY_CHECKING=False
export ANSIBLE_CONFIG="\$SCRIPT_DIR/ansible.cfg"
"\$SCRIPT_DIR/ansible_venv/bin/\$(basename \$0)" "\$@" --ignore-certs
deactivate
EOL

chmod +x $PACKAGE_DIR/ansible_wrapper.sh

# Create ansible.cfg
cat > $PACKAGE_DIR/ansible.cfg << EOL
[defaults]
collections_paths = /opt/ansible_package/ansible_venv/lib/python3.*/site-packages/ansible_collections
library = /opt/ansible_package/ansible_venv/lib/python3.*/site-packages/ansible/modules
host_key_checking = False
EOL

# Create installation script
cat > $PACKAGE_DIR/install.sh << EOL
#!/bin/bash
set -e

INSTALL_DIR="/opt/ansible_package"

# Create the installation directory
sudo mkdir -p \$INSTALL_DIR
sudo cp -R . \$INSTALL_DIR

# Set correct permissions
sudo chown -R root:root \$INSTALL_DIR
sudo chmod -R 755 \$INSTALL_DIR

# Create global symlinks for Ansible commands
sudo ln -sf \$INSTALL_DIR/ansible_wrapper.sh /usr/local/bin/ansible
sudo ln -sf \$INSTALL_DIR/ansible_wrapper.sh /usr/local/bin/ansible-playbook
sudo ln -sf \$INSTALL_DIR/ansible_wrapper.sh /usr/local/bin/ansible-galaxy

# Set environment variables
echo "export ANSIBLE_CONFIG=\$INSTALL_DIR/ansible.cfg" | sudo tee -a /etc/environment
echo "export PIP_TRUSTED_HOST='pypi.org files.pythonhosted.org'" | sudo tee -a /etc/environment
echo "export PIP_NO_CACHE_DIR=1" | sudo tee -a /etc/environment
echo "export PIP_CERT=''" | sudo tee -a /etc/environment
echo "export ANSIBLE_HOST_KEY_CHECKING=False" | sudo tee -a /etc/environment

echo "Ansible package installed successfully!"
echo "Please log out and log back in, or run 'source /etc/environment' to use Ansible commands globally."
EOL

chmod +x $PACKAGE_DIR/install.sh

# Create README
cat > $PACKAGE_DIR/README.md << EOL
# Ansible Package

This package contains Ansible and required AWS collections.

To install:
1. Unzip this package
2. Navigate to the unzipped directory
3. Run: sudo ./install.sh
4. Log out and log back in, or run: source /etc/environment

After installation, you can use ansible, ansible-playbook, and ansible-galaxy commands globally.

Note: This package is configured to bypass TLS verification for pip installations and ignore certificate checks for Ansible Galaxy.
EOL

# Create the zip package
(cd $PACKAGE_DIR && zip -r ../ansible_package.zip .)

echo "Ansible package created: ansible_package.zip"
echo "You can distribute this zip file to your EC2 instances."

# Clean up
rm -rf $PACKAGE_DIR