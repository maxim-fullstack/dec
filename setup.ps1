# DEC (Desired Environment Configuration) Setup Script for Windows
# This script installs Ansible if not present and runs the main playbook

param(
    [string]$ConfigFile = "config.yml",
    [switch]$Verbose,
    [switch]$CheckMode,
    [string]$Tags = "",
    [string]$SkipTags = ""
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Function to write colored output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Function to check if running as administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Check if running as administrator
if (-not (Test-Administrator)) {
    Write-ColorOutput "This script requires administrator privileges. Please run as administrator." "Red"
    exit 1
}

Write-ColorOutput "=== DEC (Desired Environment Configuration) Setup ===" "Cyan"
Write-ColorOutput "Platform: Windows" "Green"

# Check if Python is installed
Write-ColorOutput "Checking Python installation..." "Yellow"
try {
    $pythonVersion = python --version 2>&1
    Write-ColorOutput "Found: $pythonVersion" "Green"
}
catch {
    Write-ColorOutput "Python not found. Installing Python via winget..." "Yellow"
    try {
        winget install Python.Python.3.12 --accept-source-agreements --accept-package-agreements
        Write-ColorOutput "Python installed successfully." "Green"
        # Refresh PATH
        $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
    }
    catch {
        Write-ColorOutput "Failed to install Python. Please install manually." "Red"
        exit 1
    }
}

# Check if pip is available
Write-ColorOutput "Checking pip availability..." "Yellow"
try {
    $pipVersion = pip --version 2>&1
    Write-ColorOutput "Found: $pipVersion" "Green"
}
catch {
    Write-ColorOutput "pip not found. Installing pip..." "Yellow"
    python -m ensurepip --upgrade
}

# Check if Ansible is installed
Write-ColorOutput "Checking Ansible installation..." "Yellow"
try {
    $ansibleVersion = ansible --version 2>&1
    if ($ansibleVersion -match "ansible \[core") {
        Write-ColorOutput "Found: $($ansibleVersion.Split("`n")[0])" "Green"
    }
    else {
        throw "Ansible not found"
    }
}
catch {
    Write-ColorOutput "Ansible not found. Installing Ansible..." "Yellow"
    try {
        pip install ansible
        Write-ColorOutput "Ansible installed successfully." "Green"
    }
    catch {
        Write-ColorOutput "Failed to install Ansible. Please check your Python/pip installation." "Red"
        exit 1
    }
}

# Install required Ansible collections
Write-ColorOutput "Installing required Ansible collections..." "Yellow"
try {
    ansible-galaxy collection install community.windows
    ansible-galaxy collection install ansible.windows
    Write-ColorOutput "Ansible collections installed successfully." "Green"
}
catch {
    Write-ColorOutput "Warning: Failed to install some Ansible collections. Continuing anyway..." "Yellow"
}

# Verify configuration file exists
if (-not (Test-Path $ConfigFile)) {
    Write-ColorOutput "Configuration file '$ConfigFile' not found. Creating default config..." "Yellow"
    Copy-Item "config.example.yml" $ConfigFile -ErrorAction SilentlyContinue
    if (-not (Test-Path $ConfigFile)) {
        Write-ColorOutput "Error: No configuration file found and cannot create default." "Red"
        exit 1
    }
}

# Build Ansible command
$ansibleArgs = @(
    "playbooks/main.yml"
    "-i", "inventory/hosts.yml"
    "--extra-vars", "@$ConfigFile"
    "--connection=local"
    "--inventory=localhost,"
)

if ($Verbose) { $ansibleArgs += "-v" }
if ($CheckMode) { $ansibleArgs += "--check" }
if ($Tags) { $ansibleArgs += "--tags", $Tags }
if ($SkipTags) { $ansibleArgs += "--skip-tags", $SkipTags }

# Run Ansible playbook
Write-ColorOutput "Running DEC configuration..." "Cyan"
Write-ColorOutput "Command: ansible-playbook $($ansibleArgs -join ' ')" "Gray"

try {
    & ansible-playbook @ansibleArgs
    Write-ColorOutput "DEC configuration completed successfully!" "Green"
}
catch {
    Write-ColorOutput "Error running Ansible playbook: $_" "Red"
    exit 1
}

Write-ColorOutput "=== Setup Complete ===" "Cyan"
Write-ColorOutput "Your workstation configuration has been applied." "Green"
Write-ColorOutput "You may need to restart your shell or system for all changes to take effect." "Yellow"
