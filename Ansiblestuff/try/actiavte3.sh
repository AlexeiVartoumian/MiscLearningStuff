#!/bin/bash
SCRIPT_DIR="/opt/ansible_package"
source "$SCRIPT_DIR/ansible_venv/bin/activate"
export ANSIBLE_COLLECTIONS_PATH="$SCRIPT_DIR/ansible_venv/lib/python3.*/site-packages/ansible_collections"
export ANSIBLE_LIBRARY="$SCRIPT_DIR/ansible_venv/lib/python3.*/site-packages/ansible/modules"
export PIP_TRUSTED_HOST="pypi.org files.pythonhosted.org"
export PIP_NO_CACHE_DIR=1
export PIP_CERT=""
export ANSIBLE_HOST_KEY_CHECKING=False
export ANSIBLE_CONFIG="$SCRIPT_DIR/ansible.cfg"

COMMAND=$(basename "$0")
exec "$SCRIPT_DIR/ansible_venv/bin/python" "$SCRIPT_DIR/ansible_venv/bin/$COMMAND" "$@"