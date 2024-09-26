#!/bin/bash
set -e

INSTALL_DIR="/opt/ansible_package"
CURRENT_DIR="$(pwd)"

# Create the installation directory
sudo mkdir -p $INSTALL_DIR
sudo cp -R $CURRENT_DIR/* $INSTALL_DIR

# Create global symlinks for Ansible commands
sudo ln -sf $INSTALL_DIR/ansible_wrapper.sh /usr/local/bin/ansible
sudo ln -sf $INSTALL_DIR/ansible_wrapper.sh /usr/local/bin/ansible-playbook
sudo ln -sf $INSTALL_DIR/ansible_wrapper.sh /usr/local/bin/ansible-galaxy

# Set the ANSIBLE_CONFIG environment variable
echo "export ANSIBLE_CONFIG=$INSTALL_DIR/ansible.cfg" | sudo tee -a /etc/environment
echo "export PIP_TRUSTED_HOST='pypi.org files.pythonhosted.org'" | sudo tee -a /etc/environment
echo "export PIP_NO_CACHE_DIR=1" | sudo tee -a /etc/environment
echo "export PIP_CERT=''" | sudo tee -a /etc/environment
echo "export ANSIBLE_HOST_KEY_CHECKING=False" | sudo tee -a /etc/environment

# Update the ansible_wrapper.sh script with the correct path
sudo sed -i "s|SCRIPT_DIR=.*|SCRIPT_DIR=\"$INSTALL_DIR\"|" $INSTALL_DIR/ansible_wrapper.sh

echo "Ansible package installed successfully!"
echo "Please log out and log back in, or run 'source /etc/environment' to use Ansible commands globally."