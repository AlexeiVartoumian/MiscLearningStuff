#!/bin/bash

set -e

# Create a temporary directory for our package
PACKAGE_DIR=$(mktemp -d)
echo "Creating package in $PACKAGE_DIR"

# Create a virtual environment
python3 -m venv $PACKAGE_DIR/ansible_venv

# Activate the virtual environment
source $PACKAGE_DIR/ansible_venv/bin/activate

# Upgrade pip
pip install --upgrade pip

# Install Ansible
pip install ansible

# Install AWS collections
ansible-galaxy collection install amazon.aws -p $PACKAGE_DIR/ansible_venv/lib/python3.*/site-packages/ansible_collections
ansible-galaxy collection install community.aws -p $PACKAGE_DIR/ansible_venv/lib/python3.*/site-packages/ansible_collections

# Create a wrapper script for Ansible commands
cat > $PACKAGE_DIR/ansible_wrapper.sh << EOL
#!/bin/bash
SCRIPT_DIR="\$( cd "\$( dirname "\${BASH_SOURCE[0]}" )" && pwd )"
source "\$SCRIPT_DIR/ansible_venv/bin/activate"
export ANSIBLE_COLLECTIONS_PATH="\$SCRIPT_DIR/ansible_venv/lib/python3.*/site-packages/ansible_collections"
export ANSIBLE_LIBRARY="\$SCRIPT_DIR/ansible_venv/lib/python3.*/site-packages/ansible/modules"
"\$SCRIPT_DIR/ansible_venv/bin/\$1" "\${@:2}"
deactivate
EOL

chmod +x $PACKAGE_DIR/ansible_wrapper.sh

# Create ansible.cfg
cat > $PACKAGE_DIR/ansible.cfg << EOL
[defaults]
collections_paths = ./ansible_venv/lib/python3.*/site-packages/ansible_collections
library = ./ansible_venv/lib/python3.*/site-packages/ansible/modules
EOL

# Create installation script
cat > $PACKAGE_DIR/install.sh << EOL
#!/bin/bash
set -e

INSTALL_DIR="/opt/ansible_package"

# Create the installation directory
sudo mkdir -p \$INSTALL_DIR
sudo cp -R . \$INSTALL_DIR

# Create global symlinks for Ansible commands
sudo ln -sf \$INSTALL_DIR/ansible_wrapper.sh /usr/local/bin/ansible
sudo ln -sf \$INSTALL_DIR/ansible_wrapper.sh /usr/local/bin/ansible-playbook
sudo ln -sf \$INSTALL_DIR/ansible_wrapper.sh /usr/local/bin/ansible-galaxy

# Set the ANSIBLE_CONFIG environment variable
echo "export ANSIBLE_CONFIG=\$INSTALL_DIR/ansible.cfg" | sudo tee -a /etc/environment

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
2. Run: sudo ./install.sh
3. Log out and log back in, or run: source /etc/environment

After installation, you can use ansible, ansible-playbook, and ansible-galaxy commands globally.
EOL

# Create the zip package
zip -r ansible_package.zip $PACKAGE_DIR

echo "Ansible package created: ansible_package.zip"
echo "You can distribute this zip file to your EC2 instances."

# Clean up
rm -rf $PACKAGE_DIR