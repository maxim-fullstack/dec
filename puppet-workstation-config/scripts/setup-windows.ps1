#
# Windows PowerShell Puppet Masterless Runner Script
# This script applies the Puppet configuration in masterless mode on Windows
#

[CmdletBinding()]
param(
    [switch]$Help
)

# Set error action preference for better error handling
$ErrorActionPreference = 'Stop'

# Script configuration
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptRoot
$ManifestFile = Join-Path $ProjectRoot "manifests\site.pp"
$ModulePath = Join-Path $ProjectRoot "modules"
$HieraConfig = Join-Path $ProjectRoot "config\hiera.yaml"

# Logging functions
function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-ErrorMessage {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Show help
function Show-Help {
    Write-Host "Puppet Workstation Configuration Script"
    Write-Host "======================================="
    Write-Host ""
    Write-Host "This script applies Puppet configuration in masterless mode to configure"
    Write-Host "the workstation with Git and other development tools."
    Write-Host ""
    Write-Host "Usage: .\setup-windows.ps1 [-Help]"
    Write-Host ""
    Write-Host "Parameters:"
    Write-Host "  -Help         Show this help message"
    Write-Host ""
    Write-Host "Requirements:"
    Write-Host "  - PowerShell must be run as Administrator"
    Write-Host "  - Windows 10/11 with winget available"
    Write-Host "  - Internet connection for downloading packages"
    Write-Host ""
    Write-Host "Note: Puppet will be automatically installed if not present."
}

# Check if running as Administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Check if running with appropriate privileges
function Test-Privileges {
    if (-not (Test-Administrator)) {
        Write-ErrorMessage "This script must be run as Administrator"
        Write-Info "Please run PowerShell as Administrator and try again"
        return $false
    }
    return $true
}

# Check if Puppet is installed
function Test-Puppet {
    try {
        $null = Get-Command puppet -ErrorAction Stop
        $puppetVersion = & puppet --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Info "Found Puppet version: $puppetVersion"
            return $true
        }
    }
    catch {
        # Puppet command not found
    }
    
    Write-Warning "Puppet is not installed"
    return $false
}

# Install Puppet on Windows
function Install-Puppet {
    Write-Info "Installing Puppet..."
    
    # Check if winget is available for installation
    if (-not (Test-CommandExists "winget")) {
        Write-ErrorMessage "winget is required to install Puppet automatically"
        Write-Info "Please install Puppet manually from: https://puppet.com/docs/puppet/latest/install_puppet.html"
        return $false
    }
    
    try {
        Write-Info "Installing Puppet using winget..."
        & winget install --id PuppetLabs.Puppet --silent --accept-package-agreements --accept-source-agreements
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Puppet installed successfully"
            
            # Refresh PATH environment variable
            Write-Info "Refreshing environment variables..."
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
            
            # Verify installation
            try {
                $puppetVersion = & puppet --version 2>$null
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "Puppet installation verified: $puppetVersion"
                    return $true
                }
            }
            catch {
                Write-Warning "Puppet installed but not immediately available in PATH"
                Write-Info "You may need to restart your terminal after the script completes"
                return $true
            }
        }
        else {
            Write-ErrorMessage "Failed to install Puppet via winget"
            Write-Info "Please install Puppet manually from: https://puppet.com/docs/puppet/latest/install_puppet.html"
            return $false
        }
    }
    catch {
        Write-ErrorMessage "Error installing Puppet: $($_.Exception.Message)"
        Write-Info "Please install Puppet manually from: https://puppet.com/docs/puppet/latest/install_puppet.html"
        return $false
    }
}

# Check if command exists
function Test-CommandExists {
    param([string]$Command)
    try {
        $null = Get-Command $Command -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

# Check if winget is available
function Test-Winget {
    try {
        $null = Get-Command winget -ErrorAction Stop
        $wingetVersion = & winget --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Info "Found winget version: $wingetVersion"
            return $true
        }
    }
    catch {
        # winget command not found
    }
    
    Write-Warning "winget is not available. Some package installations may fail."
    Write-Info "winget is available on Windows 10 (version 1809 or later) and Windows 11"
    return $false
}

# Validate project structure
function Test-ProjectStructure {
    $requiredPaths = @(
        $ManifestFile,
        $HieraConfig,
        $ModulePath
    )
    
    foreach ($path in $requiredPaths) {
        if (-not (Test-Path -Path $path)) {
            Write-ErrorMessage "Required file/directory not found: $path"
            return $false
        }
    }
    
    Write-Success "Project structure validation passed"
    return $true
}

# Run Puppet in masterless mode
function Invoke-Puppet {
    Write-Info "Starting Puppet masterless run..."
    
    # Store current location to restore later
    $originalLocation = Get-Location
    
    try {
        # Change to project directory
        Set-Location -Path $ProjectRoot
        
        # Build the Puppet command arguments
        $puppetArgs = @(
            'apply'
            "--modulepath=$ModulePath"
            "--hiera_config=$HieraConfig"
            '--detailed-exitcodes'
            '--verbose'
            $ManifestFile
        )
        
        Write-Info "Executing: puppet $($puppetArgs -join ' ')"
        
        # Run Puppet and capture exit code
        try {
            & puppet $puppetArgs
            $exitCode = $LASTEXITCODE
        }
        catch {
            Write-ErrorMessage "Failed to execute Puppet: $($_.Exception.Message)"
            return $false
        }
        
        # Handle Puppet exit codes
        switch ($exitCode) {
            0 {
                Write-Success "Puppet run completed successfully - no changes made"
                return $true
            }
            2 {
                Write-Success "Puppet run completed successfully - changes were made"
                return $true
            }
            4 {
                Write-Warning "Puppet run completed with failures"
                return $false
            }
            6 {
                Write-Warning "Puppet run completed with changes and failures"
                return $false
            }
            default {
                Write-ErrorMessage "Puppet run failed with exit code: $exitCode"
                return $false
            }
        }
    }
    finally {
        # Restore original location
        Set-Location -Path $originalLocation
    }
}

# Main execution function
function Main {
    Write-Info "Starting Puppet Workstation Configuration"
    Write-Info "Project root: $ProjectRoot"
    
    try {
        # Perform all checks
        if (-not (Test-Privileges)) { 
            Write-ErrorMessage "Privilege check failed"
            exit 1 
        }
        # Check and install Puppet if needed
        if (-not (Test-Puppet)) {
            Write-Info "Puppet not found, attempting automatic installation..."
            if (-not (Install-Puppet)) {
                Write-ErrorMessage "Puppet installation failed"
                exit 1
            }
        }
        
        # Test winget but don't exit on failure (warning only)
        $null = Test-Winget
        
        if (-not (Test-ProjectStructure)) { 
            Write-ErrorMessage "Project structure validation failed"
            exit 1 
        }
        
        # Run Puppet
        if (Invoke-Puppet) {
            Write-Success "Workstation configuration completed successfully!"
            Write-Info "You may need to restart your terminal or reload your PowerShell profile"
            Write-Info "to use newly installed software."
            Write-Host ""
            Write-Info "To reload your PATH in this session, run: refreshenv"
        }
        else {
            Write-ErrorMessage "Workstation configuration completed with errors"
            Write-Info "Check the output above for details"
            exit 1
        }
    }
    catch {
        Write-ErrorMessage "An unexpected error occurred: $($_.Exception.Message)"
        Write-Info "Stack trace: $($_.ScriptStackTrace)"
        exit 1
    }
}

# Handle script parameters
if ($Help) {
    Show-Help
    exit 0
}

# Run main function with error handling
try {
    Main
}
catch {
    Write-Host "[FATAL] Script execution failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
