#
# PowerShell Validation Script for Puppet Workstation Configuration
# This script validates syntax and style of all project files on Windows
#

[CmdletBinding()]
param(
    [switch]$Help
)

# Set error action preference
$ErrorActionPreference = 'Continue'

# Script configuration
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptRoot

# Logging functions
function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-ErrorMessage {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Show help
function Show-Help {
    Write-Host "Puppet Workstation Configuration Validation Script"
    Write-Host "=================================================="
    Write-Host ""
    Write-Host "This script validates the syntax and structure of the Puppet"
    Write-Host "workstation configuration project."
    Write-Host ""
    Write-Host "Usage: .\validate-project.ps1 [-Help]"
    Write-Host ""
    Write-Host "Parameters:"
    Write-Host "  -Help         Show this help message"
    Write-Host ""
    Write-Host "Validations performed:"
    Write-Host "  - Project structure completeness"
    Write-Host "  - Puppet manifest syntax"
    Write-Host "  - YAML file syntax"
    Write-Host "  - PowerShell script syntax"
    Write-Host "  - File permissions"
}

# Check if command exists
function Test-CommandExists {
    param([string]$Command)
    try {
        $null = Get-Command $Command -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

# Validate Puppet syntax
function Test-PuppetSyntax {
    Write-Info "Validating Puppet manifest syntax..."
    
    if (-not (Test-CommandExists "puppet")) {
        Write-Warning "Puppet not found, skipping syntax validation"
        return $true
    }
    
    $errors = 0
    $puppetFiles = Get-ChildItem -Path $ProjectRoot -Filter "*.pp" -Recurse
    
    if ($puppetFiles.Count -eq 0) {
        Write-Warning "No Puppet manifest files found"
        return $true
    }
    
    foreach ($file in $puppetFiles) {
        Write-Info "Checking: $($file.FullName)"
        try {
            $result = & puppet parser validate $file.FullName 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-ErrorMessage "Syntax error in: $($file.FullName)"
                Write-ErrorMessage $result
                $errors++
            }
        }
        catch {
            Write-ErrorMessage "Failed to validate: $($file.FullName) - $($_.Exception.Message)"
            $errors++
        }
    }
    
    if ($errors -eq 0) {
        Write-Success "All Puppet manifests have valid syntax"
        return $true
    }
    else {
        Write-ErrorMessage "Found $errors syntax errors in Puppet manifests"
        return $false
    }
}

# Validate YAML syntax
function Test-YAMLSyntax {
    Write-Info "Validating YAML file syntax..."
    
    $errors = 0
    $yamlFiles = Get-ChildItem -Path $ProjectRoot -Include "*.yaml", "*.yml" -Recurse
    
    if ($yamlFiles.Count -eq 0) {
        Write-Warning "No YAML files found"
        return $true
    }
    
    foreach ($file in $yamlFiles) {
        Write-Info "Checking: $($file.FullName)"
        try {
            # Try to parse YAML using PowerShell-Yaml if available
            if (Test-CommandExists "ConvertFrom-Yaml") {
                $content = Get-Content -Path $file.FullName -Raw
                $null = ConvertFrom-Yaml $content
            }
            else {
                # Basic validation - check if file can be read and has basic YAML structure
                $content = Get-Content -Path $file.FullName
                if ($content -match "^\s*[^:]+:\s*$" -or $content -match "^\s*-\s+") {
                    # Looks like YAML structure
                }
                else {
                    Write-Warning "Cannot validate YAML syntax for $($file.FullName) - no YAML parser available"
                }
            }
        }
        catch {
            Write-ErrorMessage "YAML syntax error in: $($file.FullName) - $($_.Exception.Message)"
            $errors++
        }
    }
    
    if ($errors -eq 0) {
        Write-Success "All YAML files appear to have valid syntax"
        return $true
    }
    else {
        Write-ErrorMessage "Found $errors syntax errors in YAML files"
        return $false
    }
}

# Validate project structure
function Test-ProjectStructure {
    Write-Info "Validating project structure..."
    
    $requiredFiles = @(
        "manifests\site.pp",
        "config\hiera.yaml",
        "config\puppet.conf",
        "data\common.yaml",
        "modules\platform\manifests\init.pp",
        "modules\git\manifests\init.pp",
        "modules\git\manifests\install.pp",
        "modules\git\manifests\config.pp",
        "scripts\setup-linux.sh",
        "scripts\setup-windows.ps1"
    )
    
    $requiredDirs = @(
        "manifests",
        "modules",
        "data",
        "config",
        "scripts",
        "docs"
    )
    
    $errors = 0
    
    # Check required files
    foreach ($file in $requiredFiles) {
        $fullPath = Join-Path $ProjectRoot $file
        if (-not (Test-Path -Path $fullPath)) {
            Write-ErrorMessage "Required file missing: $file"
            $errors++
        }
    }
    
    # Check required directories
    foreach ($dir in $requiredDirs) {
        $fullPath = Join-Path $ProjectRoot $dir
        if (-not (Test-Path -Path $fullPath -PathType Container)) {
            Write-ErrorMessage "Required directory missing: $dir"
            $errors++
        }
    }
    
    if ($errors -eq 0) {
        Write-Success "Project structure validation passed"
        return $true
    }
    else {
        Write-ErrorMessage "Project structure validation failed with $errors errors"
        return $false
    }
}

# Validate PowerShell scripts
function Test-PowerShellSyntax {
    Write-Info "Validating PowerShell script syntax..."
    
    $errors = 0
    $psFiles = Get-ChildItem -Path $ProjectRoot -Filter "*.ps1" -Recurse
    
    if ($psFiles.Count -eq 0) {
        Write-Warning "No PowerShell script files found"
        return $true
    }
    
    foreach ($file in $psFiles) {
        Write-Info "Checking: $($file.FullName)"
        try {
            $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content -Path $file.FullName -Raw), [ref]$null)
        }
        catch {
            Write-ErrorMessage "Syntax error in PowerShell script: $($file.FullName) - $($_.Exception.Message)"
            $errors++
        }
    }
    
    if ($errors -eq 0) {
        Write-Success "All PowerShell scripts have valid syntax"
        return $true
    }
    else {
        Write-ErrorMessage "Found $errors syntax errors in PowerShell scripts"
        return $false
    }
}

# Check file permissions and attributes
function Test-FilePermissions {
    Write-Info "Checking file permissions and attributes..."
    
    $warnings = 0
    
    # Check PowerShell execution policy for scripts
    $psFiles = Get-ChildItem -Path $ProjectRoot -Filter "*.ps1" -Recurse
    foreach ($file in $psFiles) {
        # Check if file is blocked
        if (Get-Item -Path $file.FullName -Stream Zone.Identifier -ErrorAction SilentlyContinue) {
            Write-Warning "PowerShell script may be blocked: $($file.FullName)"
            Write-Info "Run: Unblock-File '$($file.FullName)'"
            $warnings++
        }
    }
    
    if ($warnings -eq 0) {
        Write-Success "File permissions check passed"
    }
    else {
        Write-Warning "Found $warnings permission warnings"
    }
    
    return $true
}

# Main validation function
function Main {
    Write-Info "Starting validation of Puppet Workstation Configuration"
    Write-Info "Project root: $ProjectRoot"
    Write-Host ""
    
    $totalErrors = 0
    
    # Run all validations
    if (-not (Test-ProjectStructure)) { $totalErrors++ }
    Write-Host ""
    
    if (-not (Test-PuppetSyntax)) { $totalErrors++ }
    Write-Host ""
    
    if (-not (Test-YAMLSyntax)) { $totalErrors++ }
    Write-Host ""
    
    if (-not (Test-PowerShellSyntax)) { $totalErrors++ }
    Write-Host ""
    
    Test-FilePermissions | Out-Null
    Write-Host ""
    
    # Summary
    if ($totalErrors -eq 0) {
        Write-Success "All validations passed! Project is ready to use."
        Write-Host ""
        Write-Info "To run the configuration:"
        Write-Info "  Windows: .\scripts\setup-windows.ps1 (as Administrator)"
        Write-Info "  Linux:   sudo ./scripts/setup-linux.sh"
    }
    else {
        Write-ErrorMessage "Validation failed with $totalErrors errors"
        Write-Info "Please fix the errors above before using the project"
        exit 1
    }
}

# Handle script parameters
if ($Help) {
    Show-Help
    exit 0
}

# Run main function
try {
    Main
}
catch {
    Write-Host "[FATAL] Validation script failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
