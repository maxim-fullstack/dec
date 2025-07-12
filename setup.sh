#!/bin/bash
# DEC (Desired Environment Configuration) Setup Script for Linux
# This script installs Ansible if not present and runs the main playbook

set -euo pipefail

# Default values
CONFIG_FILE="config.yml"
VERBOSE=""
CHECK_MODE=""
TAGS=""
SKIP_TAGS=""

# Color output functions
red() { echo -e "\033[31m$1\033[0m"; }
green() { echo -e "\033[32m$1\033[0m"; }
yellow() { echo -e "\033[33m$1\033[0m"; }
cyan() { echo -e "\033[36m$1\033[0m"; }
gray() { echo -e "\033[90m$1\033[0m"; }

# Help function
show_help() {
    cat << EOF
DEC (Desired Environment Configuration) Setup Script

Usage: $0 [OPTIONS]

OPTIONS:
    -c, --config FILE       Configuration file (default: config.yml)
    -v, --verbose          Enable verbose output
    -C, --check            Run in check mode (dry run)
    -t, --tags TAGS        Run only tasks with specified tags
    -s, --skip-tags TAGS   Skip tasks with specified tags
    -h, --help             Show this help message

Examples:
    $0                     # Run with default config
    $0 -c custom.yml       # Use custom config file
    $0 -v -t git           # Verbose mode, only git tasks
    $0 -C                  # Dry run mode
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE="-v"
            shift
            ;;
        -C|--check)
            CHECK_MODE="--check"
            shift
            ;;
        -t|--tags)
            TAGS="--tags $2"
            shift 2
            ;;
        -s|--skip-tags)
            SKIP_TAGS="--skip-tags $2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Check if running as root for system operations
check_sudo() {
    if ! sudo -n true 2>/dev/null; then
        yellow "This script may require sudo privileges for package installation."
        yellow "You may be prompted for your password."
    fi
}

cyan "=== DEC (Desired Environment Configuration) Setup ==="
green "Platform: Linux ($(lsb_release -si 2>/dev/null || echo "Unknown"))"

# Check sudo availability
check_sudo

# Detect package manager and install Python if needed
yellow "Checking Python installation..."
if command -v python3 >/dev/null 2>&1; then
    PYTHON_VERSION=$(python3 --version)
    green "Found: $PYTHON_VERSION"
    PYTHON_CMD="python3"
elif command -v python >/dev/null 2>&1; then
    PYTHON_VERSION=$(python --version)
    green "Found: $PYTHON_VERSION"
    PYTHON_CMD="python"
else
    yellow "Python not found. Installing Python..."
    if command -v apt >/dev/null 2>&1; then
        sudo apt update
        sudo apt install -y python3 python3-pip python3-venv
        PYTHON_CMD="python3"
    elif command -v yum >/dev/null 2>&1; then
        sudo yum install -y python3 python3-pip
        PYTHON_CMD="python3"
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y python3 python3-pip
        PYTHON_CMD="python3"
    else
        red "No supported package manager found (apt, yum, dnf). Please install Python manually."
        exit 1
    fi
    green "Python installed successfully."
fi

# Check pip availability
yellow "Checking pip availability..."
if command -v pip3 >/dev/null 2>&1; then
    PIP_CMD="pip3"
elif command -v pip >/dev/null 2>&1; then
    PIP_CMD="pip"
else
    yellow "pip not found. Installing pip..."
    if command -v apt >/dev/null 2>&1; then
        sudo apt install -y python3-pip
        PIP_CMD="pip3"
    else
        $PYTHON_CMD -m ensurepip --upgrade
        PIP_CMD="pip"
    fi
fi

PIP_VERSION=$($PIP_CMD --version)
green "Found: $PIP_VERSION"

# Check if Ansible is installed
yellow "Checking Ansible installation..."
if command -v ansible >/dev/null 2>&1; then
    ANSIBLE_VERSION=$(ansible --version | head -n1)
    green "Found: $ANSIBLE_VERSION"
else
    yellow "Ansible not found. Installing Ansible..."
    
    # Install system dependencies for Ansible
    if command -v apt >/dev/null 2>&1; then
        sudo apt update
        sudo apt install -y software-properties-common
    fi
    
    # Install Ansible via pip
    $PIP_CMD install --user ansible
    
    # Add local bin to PATH if not already there
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    fi
    
    green "Ansible installed successfully."
fi

# Install required Ansible collections
yellow "Installing required Ansible collections..."
ansible-galaxy collection install community.general || yellow "Warning: Failed to install community.general collection"

# Verify configuration file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    yellow "Configuration file '$CONFIG_FILE' not found. Creating default config..."
    if [[ -f "config.example.yml" ]]; then
        cp config.example.yml "$CONFIG_FILE"
    else
        red "Error: No configuration file found and cannot create default."
        exit 1
    fi
fi

# Build Ansible command
ANSIBLE_ARGS=(
    "playbooks/main.yml"
    "-i" "inventory/hosts.yml"
    "--extra-vars" "@$CONFIG_FILE"
    "--connection=local"
    "--inventory=localhost,"
)

if [[ -n "$VERBOSE" ]]; then ANSIBLE_ARGS+=("$VERBOSE"); fi
if [[ -n "$CHECK_MODE" ]]; then ANSIBLE_ARGS+=("$CHECK_MODE"); fi
if [[ -n "$TAGS" ]]; then ANSIBLE_ARGS+=($TAGS); fi
if [[ -n "$SKIP_TAGS" ]]; then ANSIBLE_ARGS+=($SKIP_TAGS); fi

# Run Ansible playbook
cyan "Running DEC configuration..."
gray "Command: ansible-playbook ${ANSIBLE_ARGS[*]}"

if ansible-playbook "${ANSIBLE_ARGS[@]}"; then
    green "DEC configuration completed successfully!"
else
    red "Error running Ansible playbook."
    exit 1
fi

cyan "=== Setup Complete ==="
green "Your workstation configuration has been applied."
yellow "You may need to restart your shell or system for all changes to take effect."
