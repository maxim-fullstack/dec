<#
.SYNOPSIS
    Configuration orchestrator for the DEC configuration system
.DESCRIPTION
    Orchestrates the entire configuration process including prerequisites, winget, and DSC phases
#>

# Import required modules
Import-Module "$PSScriptRoot\Constants.psm1" -Force
Import-Module "$PSScriptRoot\Logging.psm1" -Force
Import-Module "$PSScriptRoot\Prerequisites.psm1" -Force
Import-Module "$PSScriptRoot\WingetConfiguration.psm1" -Force
Import-Module "$PSScriptRoot\DSCConfiguration.psm1" -Force

<#
.SYNOPSIS
    Main orchestration function that coordinates the entire configuration process
.PARAMETER SkipWinget
    Whether to skip the winget configuration phase
.PARAMETER SkipDSC
    Whether to skip the PowerShell DSC configuration phase
.PARAMETER LogLevel
    The logging level to use
#>
function Start-ConfigurationProcess {
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$SkipWinget,
        
        [Parameter()]
        [switch]$SkipDSC,
        
        [Parameter()]
        [ValidateSet("DEBUG", "INFO", "WARN", "ERROR")]
        [string]$LogLevel = "INFO"
    )
    
    $startTime = Get-Date
    
    # Initialize logging
    Initialize-Logging -LogLevel $LogLevel
    
    Write-LogMessage "Starting DEC (Desired Environment Configuration) v1.0.0" "INFO"
    Write-LogMessage "Log file: $(Get-LogPath)" "INFO"
    
    try {
        # Phase 1: Prerequisites validation
        Invoke-PrerequisitePhase
        
        # Phase 2: Winget configuration
        Invoke-WingetPhase -Skip:$SkipWinget
        
        # Phase 3: PowerShell DSC configuration
        Invoke-DSCPhase -Skip:$SkipDSC
        
        # Phase 4: Summary and completion
        Show-ConfigurationSummary -StartTime $startTime
        
    }
    catch {
        Write-ErrorAndExit -Message "FATAL ERROR: $($_.Exception.Message)"
        Write-LogMessage "Configuration failed. Check the log file for details: $(Get-LogPath)" "ERROR"
        throw
    }
}

<#
.SYNOPSIS
    Executes the prerequisite validation phase
#>
function Invoke-PrerequisitePhase {
    [CmdletBinding()]
    param()
    
    Write-LogMessage "=== PHASE 1: Prerequisites Validation ===" "INFO"
    Test-Prerequisites
}

<#
.SYNOPSIS
    Executes the winget configuration phase
.PARAMETER Skip
    Whether to skip this phase
#>
function Invoke-WingetPhase {
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$Skip
    )
    
    Write-LogMessage "=== PHASE 2: Winget Configuration ===" "INFO"
    
    if ($Skip) {
        Write-LogMessage "Skipping winget configuration (SkipWinget flag set)" "WARN"
        return
    }
    
    Invoke-WingetConfiguration
}

<#
.SYNOPSIS
    Executes the PowerShell DSC configuration phase
.PARAMETER Skip
    Whether to skip this phase
#>
function Invoke-DSCPhase {
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$Skip
    )
    
    Write-LogMessage "=== PHASE 3: PowerShell DSC Configuration ===" "INFO"
    
    if ($Skip) {
        Write-LogMessage "Skipping PowerShell DSC configuration (SkipDSC flag set)" "WARN"
        return
    }
    
    Invoke-PowerShellDSC
}

<#
.SYNOPSIS
    Displays a comprehensive summary of the configuration process
.PARAMETER StartTime
    The time when the configuration process started
#>
function Show-ConfigurationSummary {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [datetime]$StartTime
    )
    
    $endTime = Get-Date
    $duration = $endTime - $StartTime
    
    $summarySeparator = "=" * 60
    $scriptVersion = "1.0.0"
    $logDateFormat = "yyyy-MM-dd HH:mm:ss"
    
    Write-LogMessage $summarySeparator "INFO"
    Write-LogMessage "CONFIGURATION SUMMARY" "INFO"
    Write-LogMessage $summarySeparator "INFO"
    Write-LogMessage "Script Version: $scriptVersion" "INFO"
    Write-LogMessage "Start Time: $($StartTime.ToString($logDateFormat))" "INFO"
    Write-LogMessage "End Time: $($endTime.ToString($logDateFormat))" "INFO"
    Write-LogMessage "Total Duration: $($duration.ToString('hh\:mm\:ss'))" "INFO"
    Write-LogMessage "Log File: $(Get-LogPath)" "INFO"
    Write-LogMessage $summarySeparator "INFO"
    Write-LogMessage "✓ Developer environment configuration completed successfully!" "INFO"
    Write-LogMessage "Please restart your computer to ensure all changes take effect." "WARN"
    Write-LogMessage $summarySeparator "INFO"
}

# Export public functions
Export-ModuleMember -Function Start-ConfigurationProcess
