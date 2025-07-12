# Quick setup script - minimal version for quick testing

param(
    [switch]$Help
)

if ($Help) {
    Write-Host "DEC Quick Setup - Minimal configuration for testing"
    Write-Host "Usage: .\quick-setup.ps1"
    exit 0
}

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

Write-ColorOutput "=== DEC Quick Setup ===" "Cyan"

# Check if we're in the right directory
if (-not (Test-Path "playbooks\main.yml")) {
    Write-ColorOutput "Error: Please run this script from the DEC project directory" "Red"
    exit 1
}

# Create config if it doesn't exist
if (-not (Test-Path "config.yml")) {
    Write-ColorOutput "Creating config.yml from example..." "Yellow"
    Copy-Item "config.example.yml" "config.yml"
}

# Check Ansible installation
try {
    $ansibleVersion = ansible --version 2>&1
    Write-ColorOutput "Ansible found: $($ansibleVersion.Split("`n")[0])" "Green"
}
catch {
    Write-ColorOutput "Installing Ansible..." "Yellow"
    try {
        pip install ansible
        Write-ColorOutput "Ansible installed successfully." "Green"
    }
    catch {
        Write-ColorOutput "Please install Ansible manually" "Red"
        exit 1
    }
}

# Run basic configuration
Write-ColorOutput "Running basic DEC configuration..." "Cyan"
try {
    & ansible-playbook playbooks/main.yml -i inventory/hosts.yml --extra-vars "@config.yml" --connection=local --inventory=localhost, --tags=basic
    Write-ColorOutput "Quick setup complete!" "Green"
}
catch {
    Write-ColorOutput "Error during configuration: $_" "Red"
    exit 1
}
