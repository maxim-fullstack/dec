# DEC (Desired Environment Configuration) - Template Manager Module
# Handles loading and processing template files for DSC configuration

<#
.SYNOPSIS
    Template manager for the DEC configuration system
.DESCRIPTION
    Provides functions to load and process template files used in DSC configurations
#>

<#
.SYNOPSIS
    Gets the PowerShell profile template content
.DESCRIPTION
    Loads the PowerShell profile template and returns it as a string
.PARAMETER TemplateDirectory
    The directory containing template files
.EXAMPLE
    Get-PowerShellProfileTemplate -TemplateDirectory "C:\DEC\Templates"
#>
function Get-PowerShellProfileTemplate {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$TemplateDirectory
    )
    
    $templatePath = Join-Path $TemplateDirectory "PowerShellProfile.ps1"
    
    if (-not (Test-Path $templatePath)) {
        throw "PowerShell profile template not found at: $templatePath"
    }
    
    try {
        $templateContent = Get-Content -Path $templatePath -Raw -Encoding UTF8
        return $templateContent
    }
    catch {
        throw "Failed to read PowerShell profile template: $($_.Exception.Message)"
    }
}

<#
.SYNOPSIS
    Gets the Git configuration template content
.DESCRIPTION
    Loads the Git configuration template and returns it as a string
.PARAMETER TemplateDirectory
    The directory containing template files
.EXAMPLE
    Get-GitConfigTemplate -TemplateDirectory "C:\DEC\Templates"
#>
function Get-GitConfigTemplate {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$TemplateDirectory
    )
    
    $templatePath = Join-Path $TemplateDirectory "GitConfig.template"
    
    if (-not (Test-Path $templatePath)) {
        throw "Git configuration template not found at: $templatePath"
    }
    
    try {
        $templateContent = Get-Content -Path $templatePath -Raw -Encoding UTF8
        return $templateContent
    }
    catch {
        throw "Failed to read Git configuration template: $($_.Exception.Message)"
    }
}

<#
.SYNOPSIS
    Processes a template with variable substitution
.DESCRIPTION
    Replaces placeholders in template content with actual values
.PARAMETER TemplateContent
    The template content as a string
.PARAMETER Variables
    A hashtable of variables to substitute in the template
.EXAMPLE
    $variables = @{ 'UserName' = 'John Doe'; 'Email' = 'john@example.com' }
    Invoke-TemplateProcessing -TemplateContent $template -Variables $variables
#>
function Invoke-TemplateProcessing {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$TemplateContent,
        
        [Parameter()]
        [hashtable]$Variables = @{}
    )
    
    $processedContent = $TemplateContent
    
    # Replace standard variables
    $processedContent = $processedContent.Replace('$(Get-Date)', (Get-Date).ToString())
    
    # Replace custom variables
    foreach ($variable in $Variables.GetEnumerator()) {
        $placeholder = "`$($($variable.Key))"
        $processedContent = $processedContent.Replace($placeholder, $variable.Value)
    }
    
    return $processedContent
}

<#
.SYNOPSIS
    Gets the template directory path
.DESCRIPTION
    Returns the path to the template directory relative to the current script location
.PARAMETER BasePath
    The base path to calculate the template directory from
.EXAMPLE
    Get-TemplateDirectory -BasePath $PSScriptRoot
#>
function Get-TemplateDirectory {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter()]
        [string]$BasePath = $PSScriptRoot
    )
    
    $templateDir = Join-Path $BasePath "Templates"
    
    if (-not (Test-Path $templateDir)) {
        throw "Template directory not found at: $templateDir"
    }
    
    return $templateDir
}

<#
.SYNOPSIS
    Validates that all required template files exist
.DESCRIPTION
    Checks that all required template files are present in the template directory
.PARAMETER TemplateDirectory
    The directory containing template files
.EXAMPLE
    Test-TemplateFiles -TemplateDirectory "C:\DEC\Templates"
#>
function Test-TemplateFiles {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$TemplateDirectory
    )
    
    $requiredTemplates = @(
        'PowerShellProfile.ps1',
        'GitConfig.template'
    )
    
    $missingTemplates = @()
    
    foreach ($template in $requiredTemplates) {
        $templatePath = Join-Path $TemplateDirectory $template
        if (-not (Test-Path $templatePath)) {
            $missingTemplates += $template
        }
    }
    
    if ($missingTemplates.Count -gt 0) {
        Write-Error "Missing template files: $($missingTemplates -join ', ')"
        return $false
    }
    
    return $true
}

# Export public functions
Export-ModuleMember -Function Get-PowerShellProfileTemplate, Get-GitConfigTemplate, Invoke-TemplateProcessing, Get-TemplateDirectory, Test-TemplateFiles
