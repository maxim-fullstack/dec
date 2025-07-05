# DEC (Desired Environment Configuration) - PowerShell Profile
# Auto-generated on $(Get-Date)

# ====================================
# ALIASES
# ====================================
Set-Alias -Name ll -Value Get-ChildItem
Set-Alias -Name la -Value Get-ChildItem
Set-Alias -Name grep -Value Select-String
Set-Alias -Name touch -Value New-Item
Set-Alias -Name which -Value Get-Command

# ====================================
# FUNCTIONS
# ====================================
function Set-DevLocation { Set-Location 'C:\Dev' }
function Set-ProjectsLocation { Set-Location 'C:\Dev\Projects' }
function Set-ToolsLocation { Set-Location 'C:\Dev\Tools' }
function Set-ScriptsLocation { Set-Location 'C:\Dev\Scripts' }

# Convenient aliases for navigation
Set-Alias -Name cddev -Value Set-DevLocation
Set-Alias -Name cdprojects -Value Set-ProjectsLocation
Set-Alias -Name cdtools -Value Set-ToolsLocation
Set-Alias -Name cdscripts -Value Set-ScriptsLocation

# Git shortcuts
function Invoke-GitStatus { git status }
function Invoke-GitAddAll { git add . }
function Invoke-GitCommit { param([string]$message) git commit -m $message }
function Invoke-GitPush { git push }
function Invoke-GitLog { git log --oneline -10 }

# Git aliases
Set-Alias -Name gs -Value Invoke-GitStatus
Set-Alias -Name ga -Value Invoke-GitAddAll
Set-Alias -Name gc -Value Invoke-GitCommit
Set-Alias -Name gp -Value Invoke-GitPush
Set-Alias -Name gl -Value Invoke-GitLog

# ====================================
# PROMPT CUSTOMIZATION
# ====================================
function prompt {
    $currentPath = Get-Location
    $gitBranch = ""
    
    # Check if we're in a git repository
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $gitStatus = git rev-parse --abbrev-ref HEAD 2>$null
        if ($gitStatus) {
            $gitBranch = " [git:$gitStatus]"
        }
    }
    
    $promptText = "PS $($currentPath)$gitBranch> "
    return $promptText
}

# ====================================
# MODULE IMPORTS
# ====================================
# Import useful modules if available
if (Get-Module -ListAvailable -Name posh-git) {
    Import-Module posh-git
}

Write-Host "DEC PowerShell Profile Loaded!" -ForegroundColor Green
