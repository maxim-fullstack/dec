<#
.SYNOPSIS
    Winget configuration module for the DEC configuration system
.DESCRIPTION
    Handles the winget configuration phase of the setup process
#>

# Import required modules
Import-Module "$PSScriptRoot\Constants.psm1" -Force
Import-Module "$PSScriptRoot\Logging.psm1" -Force

<#
.SYNOPSIS
    Executes the winget configuration process
.PARAMETER ConfigPath
    Optional custom path to the configuration file
#>
function Invoke-WingetConfiguration {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$ConfigPath
    )
    
    Write-LogMessage "Starting winget configuration phase..." "INFO"
    
    try {
        if (-not $ConfigPath) {
            $ConfigPath = Get-WingetConfigurationPath
        }
        
        Confirm-ConfigurationFileExists -Path $ConfigPath
        Start-WingetCommand -ConfigPath $ConfigPath
        
        Write-LogMessage "[SUCCESS] Winget configuration completed successfully" "INFO"
    }
    catch {
        Write-ErrorAndExit -Message "Winget configuration failed: $($_.Exception.Message)" -ThrowException
    }
}

<#
.SYNOPSIS
    Gets the path to the winget configuration file
.PARAMETER BasePath
    Base directory to search for the configuration file
#>
function Get-WingetConfigurationPath {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter()]
        [string]$BasePath = (Split-Path $PSScriptRoot -Parent)
    )
    
    $configPath = Join-Path $BasePath "configuration.dsc.yaml"
    Write-LogMessage "Using winget configuration file: $configPath" "DEBUG"
    
    return $configPath
}

<#
.SYNOPSIS
    Confirms the configuration file exists at the specified path
.PARAMETER Path
    The path to the configuration file
#>
function Confirm-ConfigurationFileExists {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )
    
    Write-LogMessage "Validating configuration file: $Path" "DEBUG"
    
    if (-not (Test-Path $Path)) {
        throw "Configuration file not found: $Path"
    }
    
    Write-LogMessage "[SUCCESS] Configuration file validated" "DEBUG"
}

<#
.SYNOPSIS
    Starts the winget configuration command
.PARAMETER ConfigPath
    The path to the configuration file
#>
function Start-WingetCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ConfigPath
    )
    
    Write-LogMessage "Executing: winget configure --file `"$ConfigPath`"" "INFO"
    Write-LogMessage "Note: winget may require user interaction - please respond to any prompts" "WARN"
    
    try {
        # Execute winget command with proper error handling
        & winget configure --file $ConfigPath
        
        if ($LASTEXITCODE -ne 0) {
            throw "winget configuration failed with exit code: $LASTEXITCODE"
        }
        
        Write-LogMessage "[SUCCESS] Winget command executed successfully" "DEBUG"
    }
    catch {
        throw "Failed to execute winget command: $($_.Exception.Message)"
    }
}

# Export public functions
Export-ModuleMember -Function Invoke-WingetConfiguration
