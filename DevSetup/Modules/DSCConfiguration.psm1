<#
.SYNOPSIS
    PowerShell DSC configuration module for the DEC configuration system
.DESCRIPTION
    Handles the PowerShell DSC configuration phase of the setup process
#>

# Import required modules
Import-Module "$PSScriptRoot\Constants.psm1" -Force
Import-Module "$PSScriptRoot\Logging.psm1" -Force

<#
.SYNOPSIS
    Executes the PowerShell DSC configuration process
.PARAMETER BasePath
    Base directory containing the DSC configuration files
#>
function Invoke-PowerShellDSC {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$BasePath = $PSScriptRoot
    )
    
    Write-LogMessage "Starting PowerShell DSC configuration phase..." "INFO"
    
    try {
        $dscPaths = Get-DSCPaths -BasePath $BasePath
        Confirm-DSCScriptExists -Path $dscPaths.ConfigScript
        
        $originalLocation = Get-Location
        Set-Location $dscPaths.DSCPath
        
        try {
            Import-DSCConfiguration -ScriptPath $dscPaths.ConfigScript
            $configData = Get-DSCConfigurationData -DataPath $dscPaths.ConfigData
            $outputPath = New-DSCOutputDirectory -DSCPath $dscPaths.DSCPath
            
            Start-DSCCompilation -OutputPath $outputPath -ConfigData $configData
            Start-DSCApplication -OutputPath $outputPath
            
            Write-LogMessage "✓ PowerShell DSC configuration completed successfully" "INFO"
        }
        finally {
            Set-Location $originalLocation
        }
    }
    catch {
        Write-ErrorAndExit -Message "PowerShell DSC configuration failed: $($_.Exception.Message)" -ThrowException
    }
}

<#
.SYNOPSIS
    Gets the paths for DSC configuration files
.PARAMETER BasePath
    Base directory to search for DSC files
#>
function Get-DSCPaths {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter()]
        [string]$BasePath = $PSScriptRoot
    )
    
    $dscPath = Join-Path $BasePath $DSC_FOLDER_NAME
    
    $paths = @{
        DSCPath      = $dscPath
        ConfigScript = Join-Path $dscPath "CustomConfiguration.ps1"
        ConfigData   = Join-Path $dscPath "ConfigurationData.psd1"
    }
    
    Write-LogMessage "DSC paths configured: $($paths | ConvertTo-Json -Compress)" "DEBUG"
    
    return $paths
}

<#
.SYNOPSIS
    Confirms the DSC configuration script exists
.PARAMETER Path
    The path to the DSC script
#>
function Confirm-DSCScriptExists {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )
    
    Write-LogMessage "Validating DSC script: $Path" "DEBUG"
    
    if (-not (Test-Path $Path)) {
        throw "DSC configuration script not found: $Path"
    }
    
    Write-LogMessage "✓ DSC script validated" "DEBUG"
}

<#
.SYNOPSIS
    Imports the DSC configuration script
.PARAMETER ScriptPath
    The path to the DSC script
#>
function Import-DSCConfiguration {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScriptPath
    )
    
    Write-LogMessage "Loading DSC configuration from: $ScriptPath" "INFO"
    
    try {
        . $ScriptPath
        Write-LogMessage "✓ DSC configuration script loaded successfully" "DEBUG"
    }
    catch {
        throw "Failed to load DSC configuration script: $($_.Exception.Message)"
    }
}

<#
.SYNOPSIS
    Gets the DSC configuration data if it exists
.PARAMETER DataPath
    The path to the configuration data file
#>
function Get-DSCConfigurationData {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$DataPath
    )
    
    $configData = @{}
    
    if (Test-Path $DataPath) {
        $configData.ConfigurationData = $DataPath
        Write-LogMessage "Using configuration data from: $DataPath" "INFO"
    }
    else {
        Write-LogMessage "No configuration data file found, using defaults" "DEBUG"
    }
    
    return $configData
}

<#
.SYNOPSIS
    Creates the output directory for DSC MOF files
.PARAMETER DSCPath
    The base DSC path
#>
function New-DSCOutputDirectory {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$DSCPath
    )
    
    $outputPath = Join-Path $DSCPath "Output"
    
    if (-not (Test-Path $outputPath)) {
        Write-LogMessage "Creating DSC output directory: $outputPath" "DEBUG"
        New-Item -ItemType Directory -Path $outputPath -Force | Out-Null
    }
    
    return $outputPath
}

<#
.SYNOPSIS
    Compiles the DSC configuration
.PARAMETER OutputPath
    The path where MOF files will be generated
.PARAMETER ConfigData
    The configuration data hashtable
#>
function Start-DSCCompilation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$OutputPath,
        
        [Parameter(Mandatory = $true)]
        [hashtable]$ConfigData
    )
    
    Write-LogMessage "Compiling DSC configuration..." "INFO"
    
    try {
        $null = CustomConfiguration -OutputPath $OutputPath @ConfigData
        Write-LogMessage "✓ DSC configuration compiled to: $OutputPath" "INFO"
    }
    catch {
        throw "Failed to compile DSC configuration: $($_.Exception.Message)"
    }
}

<#
.SYNOPSIS
    Applies the compiled DSC configuration
.PARAMETER OutputPath
    The path containing the compiled MOF files
#>
function Start-DSCApplication {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$OutputPath
    )
    
    Write-LogMessage "Applying DSC configuration..." "INFO"
    
    try {
        Start-DscConfiguration -Path $OutputPath -Wait -Verbose -Force -ErrorAction Stop
        Write-LogMessage "✓ DSC configuration applied successfully" "INFO"
    }
    catch {
        throw "Failed to apply DSC configuration: $($_.Exception.Message)"
    }
}

# Export public functions
Export-ModuleMember -Function Invoke-PowerShellDSC
