<#
.SYNOPSIS
    Prerequisite validation module for the DEC configuration system
.DESCRIPTION
    Validates all prerequisites required for the configuration process
#>

# Import required modules
Import-Module "$PSScriptRoot\Constants.psm1" -Force
Import-Module "$PSScriptRoot\Logging.psm1" -Force

<#
.SYNOPSIS
    Validates all prerequisites required for the configuration process
#>
function Test-Prerequisites {
    [CmdletBinding()]
    param()
    
    Write-LogMessage "Starting prerequisite validation..." "INFO"
    
    try {
        Confirm-AdministratorPrivileges
        Confirm-WingetAvailability
        Confirm-DSCModule
        Import-RequiredModules
        
        Write-LogMessage "✓ All prerequisites validated successfully" "INFO"
    }
    catch {
        Write-ErrorAndExit -Message "Prerequisite validation failed: $($_.Exception.Message)" -ThrowException
    }
}

<#
.SYNOPSIS
    Confirms the script is running with Administrator privileges
#>
function Confirm-AdministratorPrivileges {
    [CmdletBinding()]
    param()
    
    Write-LogMessage "Checking administrator privileges..." "DEBUG"
    
    try {
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        $isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        
        if (-not $isAdmin) {
            throw "This script must be run as Administrator. Please restart PowerShell as Administrator and try again."
        }
        
        Write-LogMessage "✓ Running with Administrator privileges" "INFO"
    }
    catch {
        throw "Failed to verify administrator privileges: $($_.Exception.Message)"
    }
}

<#
.SYNOPSIS
    Confirms winget is available and functioning
#>
function Confirm-WingetAvailability {
    [CmdletBinding()]
    param()
    
    Write-LogMessage "Checking winget availability..." "DEBUG"
    
    try {
        $wingetVersion = & winget --version 2>$null
        if ($LASTEXITCODE -ne 0) {
            throw "winget command failed with exit code: $LASTEXITCODE"
        }
        
        Write-LogMessage "✓ winget is available (Version: $wingetVersion)" "INFO"
    }
    catch {
        throw "winget is required but not available. Please install the App Installer package from Microsoft Store."
    }
}

<#
.SYNOPSIS
    Confirms or installs the required DSC module
#>
function Confirm-DSCModule {
    [CmdletBinding()]
    param()
    
    Write-LogMessage "Checking DSC module availability..." "DEBUG"
    
    try {
        $dscModule = Get-Module -ListAvailable -Name $DSC_MODULE_NAME
        if (-not $dscModule) {
            Install-DSCModule
        }
        else {
            Write-LogMessage "✓ $DSC_MODULE_NAME module is available" "INFO"
        }
    }
    catch {
        throw "Failed to validate DSC module: $($_.Exception.Message)"
    }
}

<#
.SYNOPSIS
    Installs the required DSC module
#>
function Install-DSCModule {
    [CmdletBinding()]
    param()
    
    Write-LogMessage "Installing $DSC_MODULE_NAME module..." "INFO"
    
    try {
        Install-Module -Name $DSC_MODULE_NAME -Force -AllowClobber -Scope AllUsers -ErrorAction Stop
        Write-LogMessage "✓ $DSC_MODULE_NAME module installed successfully" "INFO"
    }
    catch {
        throw "Failed to install $DSC_MODULE_NAME module: $($_.Exception.Message)"
    }
}

<#
.SYNOPSIS
    Imports all required PowerShell modules
#>
function Import-RequiredModules {
    [CmdletBinding()]
    param()
    
    Write-LogMessage "Importing required modules..." "DEBUG"
    
    try {
        Import-Module $DSC_MODULE_NAME -Force -ErrorAction Stop
        Write-LogMessage "✓ Required modules imported successfully" "INFO"
    }
    catch {
        throw "Failed to import required modules: $($_.Exception.Message)"
    }
}

# Export public functions
Export-ModuleMember -Function Test-Prerequisites
