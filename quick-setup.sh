#!/bin/bash
# Quick setup script - minimal version for quick testing

set -euo pipefail

# Color functions
red() { echo -e "\033[31m$1\033[0m"; }
green() { echo -e "\033[32m$1\033[0m"; }
yellow() { echo -e "\033[33m$1\033[0m"; }
cyan() { echo -e "\033[36m$1\033[0m"; }

cyan "=== DEC Quick Setup ==="

# Check if we're in the right directory
if [[ ! -f "playbooks/main.yml" ]]; then
    red "Error: Please run this script from the DEC project directory"
    exit 1
fi

# Create config if it doesn't exist
if [[ ! -f "config.yml" ]]; then
    yellow "Creating config.yml from example..."
    cp config.example.yml config.yml
fi

# Quick package manager detection and Ansible installation
if command -v ansible >/dev/null 2>&1; then
    green "Ansible found: $(ansible --version | head -n1)"
else
    yellow "Installing Ansible..."
    if command -v pip3 >/dev/null 2>&1; then
        pip3 install --user ansible
    elif command -v apt >/dev/null 2>&1; then
        sudo apt update && sudo apt install -y ansible
    else
        red "Please install Ansible manually"
        exit 1
    fi
fi

# Run basic configuration
cyan "Running basic DEC configuration..."
ansible-playbook playbooks/main.yml -i inventory/hosts.yml --extra-vars @config.yml --connection=local --inventory=localhost, --tags="basic"

green "Quick setup complete!"
