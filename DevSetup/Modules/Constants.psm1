<#
.SYNOPSIS
    Application constants for the DEC configuration system
.DESCRIPTION
    Centralized definition of all constants used throughout the DEC system
#>

# Script metadata
New-Variable -Name SCRIPT_VERSION -Value "1.0.0" -Option ReadOnly -Scope Script -Force
New-Variable -Name LOG_DATE_FORMAT -Value "yyyy-MM-dd HH:mm:ss" -Option ReadOnly -Scope Script -Force
New-Variable -Name SUMMARY_SEPARATOR -Value ("=" * 60) -Option ReadOnly -Scope Script -Force

# Module and file names
New-Variable -Name DSC_MODULE_NAME -Value "PSDscResources" -Option ReadOnly -Scope Script -Force
New-Variable -Name CONFIG_FILE_NAME -Value "configuration.dsc.yaml" -Option ReadOnly -Scope Script -Force
New-Variable -Name DSC_FOLDER_NAME -Value "DscCustom" -Option ReadOnly -Scope Script -Force

# Log levels
New-Variable -Name LOG_LEVELS -Value @{
    "ERROR" = 0
    "WARN"  = 1
    "INFO"  = 2
    "DEBUG" = 3
} -Option ReadOnly -Scope Script -Force

# Export constants for use in other modules
Export-ModuleMember -Variable SCRIPT_VERSION, LOG_DATE_FORMAT, SUMMARY_SEPARATOR, DSC_MODULE_NAME, CONFIG_FILE_NAME, DSC_FOLDER_NAME, LOG_LEVELS
