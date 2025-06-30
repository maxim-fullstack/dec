<#
.SYNOPSIS
    Application constants for the DEC configuration system
.DESCRIPTION
    Centralized definition of all constants used throughout the DEC system
#>

# Script metadata
$script:SCRIPT_VERSION = "1.0.0"
$script:LOG_DATE_FORMAT = "yyyy-MM-dd HH:mm:ss"
$script:SUMMARY_SEPARATOR = "=" * 60

# Module and file names
$script:DSC_MODULE_NAME = "PSDscResources"
$script:CONFIG_FILE_NAME = "configuration.dsc.yaml"
$script:DSC_FOLDER_NAME = "DscCustom"

# Log levels
$script:LOG_LEVELS = @{
    "ERROR" = 0
    "WARN"  = 1
    "INFO"  = 2
    "DEBUG" = 3
}

# Functions to get constants (this ensures proper access across modules)
function Get-ScriptVersion { return $script:SCRIPT_VERSION }
function Get-LogDateFormat { return $script:LOG_DATE_FORMAT }
function Get-SummarySeparator { return $script:SUMMARY_SEPARATOR }
function Get-DSCModuleName { return $script:DSC_MODULE_NAME }
function Get-ConfigFileName { return $script:CONFIG_FILE_NAME }
function Get-DSCFolderName { return $script:DSC_FOLDER_NAME }
function Get-LogLevels { return $script:LOG_LEVELS }

# Export constants for use in other modules
Export-ModuleMember -Function Get-ScriptVersion, Get-LogDateFormat, Get-SummarySeparator, Get-DSCModuleName, Get-ConfigFileName, Get-DSCFolderName, Get-LogLevels
