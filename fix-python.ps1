# Python Installation Fix Script for Windows
# This script helps resolve common Python installation issues on Windows

param(
    [switch]$Force,
    [switch]$Help
)

if ($Help) {
    Write-Host "Python Installation Fix Script"
    Write-Host "Usage: .\fix-python.ps1 [-Force]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Force    Force reinstall Python even if detected"
    Write-Host "  -Help     Show this help message"
    exit 0
}

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

Write-ColorOutput "=== Python Installation Fix Script ===" "Cyan"

# Check if running as administrator
if (-not (Test-Administrator)) {
    Write-ColorOutput "Warning: Not running as administrator. Some fixes may not work." "Yellow"
}

# Step 1: Disable Windows Store Python aliases
Write-ColorOutput "Step 1: Disabling Windows Store Python aliases..." "Yellow"
try {
    $aliases = @(
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\AliasData\python.exe",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\AliasData\python3.exe",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\AliasData\pip.exe",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\AliasData\pip3.exe"
    )
    
    foreach ($alias in $aliases) {
        if (Test-Path $alias) {
            try {
                Set-ItemProperty -Path $alias -Name "State" -Value 3 -ErrorAction SilentlyContinue
                Write-ColorOutput "  Disabled alias: $($alias.Split('\')[-1])" "Green"
            }
            catch {
                Write-ColorOutput "  Could not disable alias: $($alias.Split('\')[-1])" "Yellow"
            }
        }
    }
}
catch {
    Write-ColorOutput "Warning: Could not modify some registry entries." "Yellow"
}

# Step 2: Check current Python installations
Write-ColorOutput "Step 2: Checking for existing Python installations..." "Yellow"

$pythonPaths = @(
    @{ Path = "python"; Type = "Command" },
    @{ Path = "python3"; Type = "Command" },
    @{ Path = "$env:LOCALAPPDATA\Programs\Python\Python312\python.exe"; Type = "User Install" },
    @{ Path = "$env:LOCALAPPDATA\Programs\Python\Python311\python.exe"; Type = "User Install" },
    @{ Path = "$env:ProgramFiles\Python312\python.exe"; Type = "System Install" },
    @{ Path = "$env:ProgramFiles\Python311\python.exe"; Type = "System Install" }
)

$foundPython = $false
foreach ($pythonPath in $pythonPaths) {
    try {
        $version = & $pythonPath.Path --version 2>&1
        if ($version -match "Python \d+\.\d+") {
            Write-ColorOutput "  Found: $version ($($pythonPath.Type)) at $($pythonPath.Path)" "Green"
            $foundPython = $true
        }
    }
    catch {
        # Silent continue
    }
}

# Step 3: Install Python if not found or force flag is used
if (-not $foundPython -or $Force) {
    Write-ColorOutput "Step 3: Installing Python via winget..." "Yellow"
    try {
        # Check if winget is available
        $wingetVersion = winget --version 2>&1
        Write-ColorOutput "  Using winget version: $wingetVersion" "Gray"
        
        if ($Force) {
            Write-ColorOutput "  Force flag detected, reinstalling Python..." "Yellow"
            winget uninstall Python.Python.3.12 --silent 2>&1 | Out-Null
        }
        
        winget install Python.Python.3.12 --accept-source-agreements --accept-package-agreements --silent
        Write-ColorOutput "  Python installation completed." "Green"
        
        # Wait for installation to settle
        Start-Sleep -Seconds 5
    }
    catch {
        Write-ColorOutput "  Error installing via winget: $_" "Red"
        Write-ColorOutput "  Please install Python manually from https://python.org" "Yellow"
        Write-ColorOutput "  Make sure to check 'Add Python to PATH' during installation." "Yellow"
    }
}
else {
    Write-ColorOutput "Step 3: Python already installed, skipping installation." "Green"
}

# Step 4: Refresh environment variables
Write-ColorOutput "Step 4: Refreshing environment variables..." "Yellow"
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")

# Step 5: Test Python installation
Write-ColorOutput "Step 5: Testing Python installation..." "Yellow"
$workingPython = $null
foreach ($pythonPath in $pythonPaths) {
    try {
        $version = & $pythonPath.Path --version 2>&1
        if ($version -match "Python \d+\.\d+") {
            Write-ColorOutput "  ✓ $($pythonPath.Path): $version" "Green"
            if (-not $workingPython) {
                $workingPython = $pythonPath.Path
            }
        }
    }
    catch {
        Write-ColorOutput "  ✗ $($pythonPath.Path): Not working" "Red"
    }
}

# Step 6: Test pip installation
if ($workingPython) {
    Write-ColorOutput "Step 6: Testing pip installation..." "Yellow"
    try {
        $pipVersion = & $workingPython -m pip --version 2>&1
        Write-ColorOutput "  ✓ pip: $pipVersion" "Green"
    }
    catch {
        Write-ColorOutput "  ✗ pip not working, attempting to install..." "Yellow"
        try {
            & $workingPython -m ensurepip --upgrade
            & $workingPython -m pip install --upgrade pip
            Write-ColorOutput "  ✓ pip installed successfully" "Green"
        }
        catch {
            Write-ColorOutput "  ✗ Failed to install pip: $_" "Red"
        }
    }
    
    # Step 7: Test Ansible installation
    Write-ColorOutput "Step 7: Testing Ansible installation..." "Yellow"
    try {
        $ansibleVersion = & $workingPython -m pip show ansible 2>&1
        if ($ansibleVersion -match "Version:") {
            Write-ColorOutput "  ✓ Ansible is installed" "Green"
        }
        else {
            throw "Ansible not found"
        }
    }
    catch {
        Write-ColorOutput "  Installing Ansible..." "Yellow"
        try {
            & $workingPython -m pip install ansible
            Write-ColorOutput "  ✓ Ansible installed successfully" "Green"
        }
        catch {
            Write-ColorOutput "  ✗ Failed to install Ansible: $_" "Red"
        }
    }
}
else {
    Write-ColorOutput "Step 6-7: Skipped - No working Python installation found" "Red"
}

Write-ColorOutput "=== Fix Script Complete ===" "Cyan"

if ($workingPython) {
    Write-ColorOutput "Success! Python is working at: $workingPython" "Green"
    Write-ColorOutput "You can now run the main setup script: .\setup.ps1" "Green"
}
else {
    Write-ColorOutput "Python installation issues persist. Manual installation may be required." "Red"
    Write-ColorOutput "Please visit https://python.org and install Python manually." "Yellow"
    Write-ColorOutput "Make sure to check 'Add Python to PATH' during installation." "Yellow"
}
