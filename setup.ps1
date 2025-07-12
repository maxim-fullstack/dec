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

# Function to find Python executable
function Find-PythonExecutable {
    $pythonPaths = @(
        "python",
        "python3",
        "$env:LOCALAPPDATA\Programs\Python\Python312\python.exe",
        "$env:LOCALAPPDATA\Programs\Python\Python311\python.exe",
        "$env:LOCALAPPDATA\Programs\Python\Python310\python.exe",
        "$env:ProgramFiles\Python312\python.exe",
        "$env:ProgramFiles\Python311\python.exe",
        "$env:ProgramFiles\Python310\python.exe"
    )
    
    foreach ($path in $pythonPaths) {
        try {
            $version = & $path --version 2>&1
            if ($version -match "Python \d+\.\d+") {
                return $path
            }
        }
        catch {
            continue
        }
    }
    return $null
}

$pythonExe = Find-PythonExecutable
if ($pythonExe) {
    $pythonVersion = & $pythonExe --version 2>&1
    Write-ColorOutput "Found: $pythonVersion at $pythonExe" "Green"
}
else {
    Write-ColorOutput "Python not found. Installing Python via winget..." "Yellow"
    try {
        # Disable app execution aliases for Python
        $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\AliasData\python.exe"
        if (Test-Path $regPath) {
            Remove-ItemProperty -Path $regPath -Name "State" -ErrorAction SilentlyContinue
        }
        $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\AliasData\python3.exe"
        if (Test-Path $regPath) {
            Remove-ItemProperty -Path $regPath -Name "State" -ErrorAction SilentlyContinue
        }
        
        winget install Python.Python.3.12 --accept-source-agreements --accept-package-agreements --silent
        Write-ColorOutput "Python installed successfully." "Green"
        
        # Refresh PATH
        $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
        
        # Wait a moment for installation to complete
        Start-Sleep -Seconds 3
        
        # Try to find Python again
        $pythonExe = Find-PythonExecutable
        if (-not $pythonExe) {
            Write-ColorOutput "Warning: Python installed but not found in PATH. You may need to restart your terminal." "Yellow"
            $pythonExe = "python"
        }
    }
    catch {
        Write-ColorOutput "Failed to install Python. Please install manually from https://python.org" "Red"
        Write-ColorOutput "Make sure to check 'Add Python to PATH' during installation." "Yellow"
        exit 1
    }
}

# Check if pip is available
Write-ColorOutput "Checking pip availability..." "Yellow"

# Function to find pip executable
function Find-PipExecutable {
    $pipPaths = @(
        "pip",
        "pip3",
        "$env:LOCALAPPDATA\Programs\Python\Python312\Scripts\pip.exe",
        "$env:LOCALAPPDATA\Programs\Python\Python311\Scripts\pip.exe",
        "$env:LOCALAPPDATA\Programs\Python\Python310\Scripts\pip.exe",
        "$env:ProgramFiles\Python312\Scripts\pip.exe",
        "$env:ProgramFiles\Python311\Scripts\pip.exe",
        "$env:ProgramFiles\Python310\Scripts\pip.exe"
    )
    
    foreach ($path in $pipPaths) {
        try {
            $version = & $path --version 2>&1
            if ($version -match "pip \d+\.\d+") {
                return $path
            }
        }
        catch {
            continue
        }
    }
    return $null
}

$pipExe = Find-PipExecutable
if ($pipExe) {
    $pipVersion = & $pipExe --version 2>&1
    Write-ColorOutput "Found: $pipVersion" "Green"
}
else {
    Write-ColorOutput "pip not found. Installing pip..." "Yellow"
    try {
        & $pythonExe -m ensurepip --upgrade
        & $pythonExe -m pip install --upgrade pip
        Write-ColorOutput "pip installed successfully." "Green"
        
        # Try to find pip again
        $pipExe = Find-PipExecutable
        if (-not $pipExe) {
            $pipExe = "$pythonExe -m pip"
        }
    }
    catch {
        Write-ColorOutput "Failed to install pip. Using python -m pip instead." "Yellow"
        $pipExe = "$pythonExe -m pip"
    }
}

# Check if Ansible is installed
Write-ColorOutput "Checking Ansible installation..." "Yellow"

# Function to find Ansible executable
function Find-AnsibleExecutable {
    $ansiblePaths = @(
        "ansible",
        "$env:LOCALAPPDATA\Programs\Python\Python312\Scripts\ansible.exe",
        "$env:LOCALAPPDATA\Programs\Python\Python311\Scripts\ansible.exe",
        "$env:LOCALAPPDATA\Programs\Python\Python310\Scripts\ansible.exe",
        "$env:ProgramFiles\Python312\Scripts\ansible.exe",
        "$env:ProgramFiles\Python311\Scripts\ansible.exe",
        "$env:ProgramFiles\Python310\Scripts\ansible.exe"
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
    Write-ColorOutput "Found: $($ansibleVersion.Split("`n")[0])" "Green"
}
else {
    Write-ColorOutput "Ansible not found. Installing Ansible..." "Yellow"
    try {
        # Install Ansible using the found pip executable
        if ($pipExe -like "*python*") {
            # Using python -m pip
            Invoke-Expression "$pipExe install ansible"
        }
        else {
            # Using direct pip executable
            & $pipExe install ansible
        }
        
        Write-ColorOutput "Ansible installed successfully." "Green"
        
        # Try to find Ansible again
        $ansibleExe = Find-AnsibleExecutable
        if (-not $ansibleExe) {
            Write-ColorOutput "Warning: Ansible installed but not found in PATH. You may need to restart your terminal." "Yellow"
            $ansibleExe = "ansible"
        }
    }
    catch {
        Write-ColorOutput "Failed to install Ansible. Error: $_" "Red"
        Write-ColorOutput "Please try installing manually with: $pipExe install ansible" "Yellow"
        exit 1
    }
}

# Install required Ansible collections
Write-ColorOutput "Installing required Ansible collections..." "Yellow"
try {
    # Use the found ansible-galaxy executable or construct the path
    $ansibleGalaxyExe = $ansibleExe -replace "ansible\.exe", "ansible-galaxy.exe"
    if (-not (Test-Path $ansibleGalaxyExe)) {
        $ansibleGalaxyExe = "ansible-galaxy"
    }
    
    & $ansibleGalaxyExe collection install community.windows --force
    & $ansibleGalaxyExe collection install ansible.windows --force
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

# Use the found ansible-playbook executable or construct the path
$ansiblePlaybookExe = $ansibleExe -replace "ansible\.exe", "ansible-playbook.exe"
if (-not (Test-Path $ansiblePlaybookExe)) {
    $ansiblePlaybookExe = "ansible-playbook"
}

Write-ColorOutput "Command: $ansiblePlaybookExe $($ansibleArgs -join ' ')" "Gray"

try {
    & $ansiblePlaybookExe @ansibleArgs
    Write-ColorOutput "DEC configuration completed successfully!" "Green"
}
catch {
    Write-ColorOutput "Error running Ansible playbook: $_" "Red"
    exit 1
}

Write-ColorOutput "=== Setup Complete ===" "Cyan"
Write-ColorOutput "Your workstation configuration has been applied." "Green"
Write-ColorOutput "You may need to restart your shell or system for all changes to take effect." "Yellow"
