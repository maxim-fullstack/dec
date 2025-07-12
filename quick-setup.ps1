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
Write-ColorOutput "Checking Ansible installation..." "Yellow"

# Function to find Ansible executable
function Find-AnsibleExecutable {
    $ansiblePaths = @(
        "ansible",
        "$env:LOCALAPPDATA\Programs\Python\Python312\Scripts\ansible.exe",
        "$env:LOCALAPPDATA\Programs\Python\Python311\Scripts\ansible.exe",
        "$env:LOCALAPPDATA\Programs\Python\Python310\Scripts\ansible.exe"
    )
    
    foreach ($path in $ansiblePaths) {
        try {
            $version = & $path --version 2>&1
            if ($version -match "ansible \[core") {
                return $path
            }
        }
        catch {
            continue
        }
    }
    return $null
}

$ansibleExe = Find-AnsibleExecutable
if ($ansibleExe) {
    $ansibleVersion = & $ansibleExe --version 2>&1
    Write-ColorOutput "Ansible found: $($ansibleVersion.Split("`n")[0])" "Green"
}
else {
    Write-ColorOutput "Installing Ansible..." "Yellow"
    try {
        # Try different pip commands
        $pipCommands = @("pip", "pip3", "python -m pip", "python3 -m pip")
        $installed = $false
        
        foreach ($pipCmd in $pipCommands) {
            try {
                Invoke-Expression "$pipCmd install ansible"
                $installed = $true
                break
            }
            catch {
                continue
            }
        }
        
        if ($installed) {
            Write-ColorOutput "Ansible installed successfully." "Green"
        }
        else {
            throw "All pip installation methods failed"
        }
    }
    catch {
        Write-ColorOutput "Please install Ansible manually:" "Red"
        Write-ColorOutput "1. Install Python from https://python.org" "Yellow"
        Write-ColorOutput "2. Run: pip install ansible" "Yellow"
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
