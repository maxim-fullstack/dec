<#
.SYNOPSIS
    Logging module for the DEC configuration system
.DESCRIPTION
    Provides centralized logging functionality with both console and file output
#>

# Import constants
Import-Module "$PSScriptRoot\Constants.psm1" -Force

# Module-level variables
$Script:LogPath = $null
$Script:CurrentLogLevel = "INFO"

<#
.SYNOPSIS
    Initializes the logging system
.PARAMETER LogLevel
    The minimum log level to display on console
.PARAMETER LogPath
    Optional custom path for the log file
#>
function Initialize-Logging {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateSet("DEBUG", "INFO", "WARN", "ERROR")]
        [string]$LogLevel = "INFO",
        
        [Parameter()]
        [string]$LogPath
    )
    
    $Script:CurrentLogLevel = $LogLevel
    
    if (-not $LogPath) {
        $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $Script:LogPath = Join-Path $PSScriptRoot "configuration-$timestamp.log"
    } else {
        $Script:LogPath = $LogPath
    }
    
    Write-LogMessage "Logging initialized - Level: $LogLevel, File: $Script:LogPath" "DEBUG"
}

<#
.SYNOPSIS
    Writes a structured log message to both console and log file
.PARAMETER Message
    The message to log
.PARAMETER Level
    The log level (DEBUG, INFO, WARN, ERROR)
#>
function Write-LogMessage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter()]
        [ValidateSet("DEBUG", "INFO", "WARN", "ERROR")]
        [string]$Level = "INFO"
    )
    
    $logDateFormat = Get-LogDateFormat
    $timestamp = Get-Date -Format $logDateFormat
    $logEntry = "[$timestamp] [$Level] $Message"
    
    # Write to console based on log level
    if (Test-ShouldLog -Level $Level) {
        Write-ConsoleMessage -Entry $logEntry -Level $Level
    }
    
    # Always write to log file
    Write-FileMessage -Entry $logEntry
}

<#
.SYNOPSIS
    Writes an error message and optionally throws an exception
.PARAMETER Message
    The error message
.PARAMETER ThrowException
    Whether to throw an exception after logging
#>
function Write-ErrorAndExit {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter()]
        [switch]$ThrowException
    )
    
    Write-LogMessage -Message $Message -Level "ERROR"
    
    if ($ThrowException) {
        throw $Message
    }
}

<#
.SYNOPSIS
    Gets the current log file path
#>
function Get-LogPath {
    [CmdletBinding()]
    [OutputType([string])]
    param()
    
    return $Script:LogPath
}

<#
.SYNOPSIS
    Determines if a message should be logged based on current log level
.PARAMETER Level
    The log level to test
#>
function Test-ShouldLog {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Level
    )
    
    $logLevels = Get-LogLevels
    return $logLevels[$Level] -le $logLevels[$Script:CurrentLogLevel]
}

<#
.SYNOPSIS
    Writes a message to the console with appropriate coloring
.PARAMETER Entry
    The log entry to write
.PARAMETER Level
    The log level for color selection
#>
function Write-ConsoleMessage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Entry,
        
        [Parameter(Mandatory = $true)]
        [string]$Level
    )
    
    $color = switch ($Level) {
        "ERROR" { "Red" }
        "WARN"  { "Yellow" }
        "INFO"  { "Green" }
        "DEBUG" { "Cyan" }
        default { "White" }
    }
    
    Write-Host $Entry -ForegroundColor $color
}

<#
.SYNOPSIS
    Writes a message to the log file
.PARAMETER Entry
    The log entry to write
#>
function Write-FileMessage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Entry
    )
    
    if (-not $Script:LogPath) {
        return
    }
    
    try {
        Add-Content -Path $Script:LogPath -Value $Entry -ErrorAction Stop
    }
    catch {
        Write-Warning "Failed to write to log file: $($_.Exception.Message)"
    }
}

# Export public functions
Export-ModuleMember -Function Initialize-Logging, Write-LogMessage, Write-ErrorAndExit, Get-LogPath
