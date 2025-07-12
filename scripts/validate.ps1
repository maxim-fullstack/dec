# DEC Validation Script - Check system state and configuration (Windows)

param(
    [switch]$Detailed
)

$Issues = 0
$Warnings = 0

function Check-Result {
    param(
        [bool]$Status,
        [string]$Message,
        [bool]$Warning = $false
    )
    
    if ($Status) {
        Write-Host "✓ $Message" -ForegroundColor Green
    }
    else {
        if ($Warning) {
            Write-Host "⚠ $Message" -ForegroundColor Yellow
            $script:Warnings++
        }
        else {
            Write-Host "✗ $Message" -ForegroundColor Red
            $script:Issues++
        }
    }
}

Write-Host "=== DEC Configuration Validation ===" -ForegroundColor Cyan

# Check if Git is installed and configured
Write-Host "Checking Git configuration..." -ForegroundColor Blue
try {
    $gitVersion = git --version
    Check-Result $true "Git is installed ($gitVersion)"
    
    try {
        $gitName = git config --global user.name
        Check-Result $true "Git user name configured: $gitName"
    }
    catch {
        Check-Result $false "Git user name not configured"
    }
    
    try {
        $gitEmail = git config --global user.email
        Check-Result $true "Git user email configured: $gitEmail"
    }
    catch {
        Check-Result $false "Git user email not configured"
    }
}
catch {
    Check-Result $false "Git is not installed"
}

# Check SSH key
Write-Host "Checking SSH configuration..." -ForegroundColor Blue
$sshKeyPaths = @(
    "$env:USERPROFILE\.ssh\id_ed25519",
    "$env:USERPROFILE\.ssh\id_rsa"
)
$sshKeyFound = $false
foreach ($keyPath in $sshKeyPaths) {
    if (Test-Path $keyPath) {
        $sshKeyFound = $true
        break
    }
}
Check-Result $sshKeyFound "SSH key found" -Warning $true

# Check yadm if dotfiles are enabled
Write-Host "Checking dotfiles management..." -ForegroundColor Blue
try {
    $yadmPath = "$env:USERPROFILE\.local\bin\yadm.cmd"
    if (Test-Path $yadmPath) {
        Check-Result $true "yadm is installed"
        try {
            & $yadmPath status 2>$null | Out-Null
            Check-Result $true "yadm repository initialized"
        }
        catch {
            Check-Result $false "yadm repository not initialized" -Warning $true
        }
    }
    else {
        Check-Result $false "yadm is not installed" -Warning $true
    }
}
catch {
    Check-Result $false "yadm is not available" -Warning $true
}

# Check common packages via winget
Write-Host "Checking common packages..." -ForegroundColor Blue
$commonPackages = @("Git.Git", "Microsoft.WindowsTerminal", "Microsoft.VisualStudioCode")
foreach ($pkg in $commonPackages) {
    try {
        $result = winget list --id $pkg --exact 2>$null
        if ($LASTEXITCODE -eq 0) {
            Check-Result $true "$pkg is installed"
        }
        else {
            Check-Result $false "$pkg is not installed" -Warning $true
        }
    }
    catch {
        Check-Result $false "$pkg check failed" -Warning $true
    }
}

# Check Windows theme
Write-Host "Checking Windows theme..." -ForegroundColor Blue
try {
    $themeReg = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -ErrorAction SilentlyContinue
    if ($themeReg -and $themeReg.AppsUseLightTheme -eq 0) {
        Check-Result $true "Dark theme is active"
    }
    else {
        Check-Result $false "Dark theme may not be active" -Warning $true
    }
}
catch {
    Check-Result $false "Cannot check theme settings" -Warning $true
}

# Summary
Write-Host "=== Validation Summary ===" -ForegroundColor Cyan
if ($Issues -eq 0) {
    Write-Host "✓ All critical checks passed!" -ForegroundColor Green
}
else {
    Write-Host "✗ $Issues critical issue(s) found" -ForegroundColor Red
}

if ($Warnings -gt 0) {
    Write-Host "⚠ $Warnings warning(s) found" -ForegroundColor Yellow
}

exit $Issues
