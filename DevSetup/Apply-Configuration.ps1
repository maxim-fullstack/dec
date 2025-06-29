#Requires -RunAsAdministrator

<#
.SYNOPSIS
    DEC (Desired Environment Configuration) - Main Configuration Orchestrator
.DESCRIPTION
    This script orchestrates the complete developer environment setup by:
    1. Checking prerequisites
    2. Running winget configure for applications and Windows settings
    3. Running PowerShell DSC for custom configurations
.PARAMETER SkipWinget
    Skip the winget configuration phase
.PARAMETER SkipDSC
    Skip the PowerShell DSC configuration phase
.PARAMETER LogLevel
    Set the logging level (DEBUG, INFO, WARN, ERROR)
.EXAMPLE
    .\Apply-Configuration.ps1
    Run the complete configuration setup
.EXAMPLE
    .\Apply-Configuration.ps1 -SkipWinget -LogLevel DEBUG
    Run configuration without winget phase with debug logging
.NOTES
    Must be run as Administrator
    Author: DEC Project Team
    Version: 1.0
#>

[CmdletBinding()]
param(
    [Parameter(HelpMessage = "Skip the winget configuration phase")]
    [switch]$SkipWinget,
    
    [Parameter(HelpMessage = "Skip the PowerShell DSC configuration phase")]
    [switch]$SkipDSC,
    
    [Parameter(HelpMessage = "Set the logging level")]
    [ValidateSet("DEBUG", "INFO", "WARN", "ERROR")]
    [string]$LogLevel = "INFO"
)

# Set error handling preference
$ErrorActionPreference = "Stop"

# Import the configuration orchestrator module
$modulePath = Join-Path $PSScriptRoot "Modules\ConfigurationOrchestrator.psm1"
Import-Module $modulePath -Force

try {
    # Start the configuration process
    Start-ConfigurationProcess -SkipWinget:$SkipWinget -SkipDSC:$SkipDSC -LogLevel $LogLevel
}
catch {
    Write-Error "Configuration process failed: $($_.Exception.Message)"
    exit 1
}
