#Requires -RunAsAdministrator

<#
.SYNOPSIS
    DEC (Desired Environment Configuration) - Main Configuration Orchestrator
.DESCRIPTION
    This script orchestrates the complete developer environment setup by:
    1. Checking prerequisites
    2. Running winget configure for applications and Windows settings
    3. Running PowerShell DSC for custom configurations
.NOTES
    Must be run as Administrator
#>

[CmdletBinding()]
param(
    [switch]$SkipWinget,
    [switch]$SkipDSC,
    [switch]$Verbose
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Initialize logging
$LogPath = Join-Path $PSScriptRoot "configuration.log"
$StartTime = Get-Date

function Write-LogMessage {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    Write-Host $logEntry
    Add-Content -Path $LogPath -Value $logEntry
}

function Test-Prerequisites {
    Write-LogMessage "Checking prerequisites..." "INFO"
    
    # Check if running as Administrator
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "This script must be run as Administrator. Please restart PowerShell as Administrator and try again."
    }
    Write-LogMessage "✓ Running as Administrator" "INFO"
    
    # Check winget availability
    try {
        $wingetVersion = winget --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-LogMessage "✓ winget is available (Version: $wingetVersion)" "INFO"
        }
        else {
            throw "winget is not available"
        }
    }
    catch {
        throw "winget is required but not available. Please install the App Installer package from Microsoft Store."
    }
    
    # Check and install PSDscResources module if needed
    $dscModule = Get-Module -ListAvailable -Name PSDscResources
    if (-not $dscModule) {
        Write-LogMessage "Installing PSDscResources module..." "INFO"
        try {
            Install-Module -Name PSDscResources -Force -AllowClobber -Scope AllUsers
            Write-LogMessage "✓ PSDscResources module installed" "INFO"
        }
        catch {
            throw "Failed to install PSDscResources module: $($_.Exception.Message)"
        }
    }
    else {
        Write-LogMessage "✓ PSDscResources module is available" "INFO"
    }
    
    # Import required modules
    Import-Module PSDscResources -Force
    Write-LogMessage "✓ Required modules imported" "INFO"
}

function Invoke-WingetConfiguration {
    Write-LogMessage "Starting winget configuration..." "INFO"
    
    $configPath = Join-Path $PSScriptRoot "configuration.dsc.yaml"
    if (-not (Test-Path $configPath)) {
        throw "Configuration file not found: $configPath"
    }
    
    try {
        Write-LogMessage "Executing: winget configure --file $configPath" "INFO"
        $result = winget configure --file $configPath 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-LogMessage "✓ winget configuration completed successfully" "INFO"
            Write-LogMessage "winget output: $result" "DEBUG"
        }
        else {
            Write-LogMessage "winget configuration failed with exit code: $LASTEXITCODE" "ERROR"
            Write-LogMessage "winget output: $result" "ERROR"
            throw "winget configuration failed"
        }
    }
    catch {
        Write-LogMessage "Error during winget configuration: $($_.Exception.Message)" "ERROR"
        throw
    }
}

function Invoke-PowerShellDSC {
    Write-LogMessage "Starting PowerShell DSC configuration..." "INFO"
    
    $dscPath = Join-Path $PSScriptRoot "DscCustom"
    $configScript = Join-Path $dscPath "CustomConfiguration.ps1"
    $configData = Join-Path $dscPath "ConfigurationData.psd1"
    
    if (-not (Test-Path $configScript)) {
        throw "DSC configuration script not found: $configScript"
    }
    
    try {
        # Change to DSC directory for relative path resolution
        Push-Location $dscPath
        
        # Dot-source the configuration script
        Write-LogMessage "Loading DSC configuration from: $configScript" "INFO"
        . $configScript
        
        # Load configuration data if it exists
        $configDataParam = @{}
        if (Test-Path $configData) {
            $configDataParam.ConfigurationData = $configData
            Write-LogMessage "Using configuration data from: $configData" "INFO"
        }
        
        # Create output directory for MOF files
        $outputPath = Join-Path $dscPath "Output"
        if (-not (Test-Path $outputPath)) {
            New-Item -ItemType Directory -Path $outputPath -Force | Out-Null
        }
        
        # Compile the configuration
        Write-LogMessage "Compiling DSC configuration..." "INFO"
        $mofPath = CustomConfiguration -OutputPath $outputPath @configDataParam
        Write-LogMessage "✓ DSC configuration compiled to: $outputPath" "INFO"
        
        # Apply the configuration
        Write-LogMessage "Applying DSC configuration..." "INFO"
        Start-DscConfiguration -Path $outputPath -Wait -Verbose -Force
        Write-LogMessage "✓ DSC configuration applied successfully" "INFO"
        
    }
    catch {
        Write-LogMessage "Error during PowerShell DSC configuration: $($_.Exception.Message)" "ERROR"
        throw
    }
    finally {
        Pop-Location
    }
}

function Show-Summary {
    $EndTime = Get-Date
    $Duration = $EndTime - $StartTime
    
    Write-LogMessage "=" * 60 "INFO"
    Write-LogMessage "CONFIGURATION SUMMARY" "INFO"
    Write-LogMessage "=" * 60 "INFO"
    Write-LogMessage "Start Time: $StartTime" "INFO"
    Write-LogMessage "End Time: $EndTime" "INFO"
    Write-LogMessage "Total Duration: $($Duration.ToString('hh\:mm\:ss'))" "INFO"
    Write-LogMessage "Log File: $LogPath" "INFO"
    Write-LogMessage "=" * 60 "INFO"
    Write-LogMessage "✓ Developer environment configuration completed successfully!" "INFO"
    Write-LogMessage "Please restart your computer to ensure all changes take effect." "INFO"
}

# Main execution flow
try {
    Write-LogMessage "Starting DEC (Desired Environment Configuration)" "INFO"
    Write-LogMessage "Log file: $LogPath" "INFO"
    
    # Step 1: Prerequisites check
    Test-Prerequisites
    
    # Step 2: winget configuration
    if (-not $SkipWinget) {
        Invoke-WingetConfiguration
    }
    else {
        Write-LogMessage "Skipping winget configuration (SkipWinget flag set)" "INFO"
    }
    
    # Step 3: PowerShell DSC configuration
    if (-not $SkipDSC) {
        Invoke-PowerShellDSC
    }
    else {
        Write-LogMessage "Skipping PowerShell DSC configuration (SkipDSC flag set)" "INFO"
    }
    
    # Step 4: Show summary
    Show-Summary
    
}
catch {
    Write-LogMessage "FATAL ERROR: $($_.Exception.Message)" "ERROR"
    Write-LogMessage "Configuration failed. Check the log file for details: $LogPath" "ERROR"
    exit 1
}
