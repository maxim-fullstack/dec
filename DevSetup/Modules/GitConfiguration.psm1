# DEC (Desired Environment Configuration) - Git Configuration Module
# This module handles Git aliases and configuration setup

# Import required modules
Import-Module "$PSScriptRoot\Constants.psm1" -Force
Import-Module "$PSScriptRoot\Logging.psm1" -Force

<#
.SYNOPSIS
    Configures Git with enhanced aliases and settings
.DESCRIPTION
    Sets up a comprehensive Git configuration with useful aliases, colors, and settings
.PARAMETER Force
    Force overwrite existing Git configuration
.PARAMETER BackupExisting
    Create a backup of existing configuration before overwriting
#>
function Set-GitConfiguration {
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$Force,
        
        [Parameter()]
        [switch]$BackupExisting = $true
    )
    
    Write-LogMessage "Configuring Git with enhanced aliases and settings..." "INFO"
    
    try {
        # Wait for Git to be available
        Wait-ForGitAvailability
        
        # Get Git config path
        $gitConfigPath = Get-GitConfigPath
        
        # Backup existing config if requested and exists
        if ($BackupExisting -and (Test-Path $gitConfigPath)) {
            Backup-GitConfig -ConfigPath $gitConfigPath
        }
        
        # Create enhanced Git configuration
        New-GitConfiguration -ConfigPath $gitConfigPath -Force:$Force
        
        # Verify configuration
        Test-GitConfiguration
        
        Write-LogMessage "[SUCCESS] Git configuration completed successfully" "INFO"
        Write-LogMessage "Try 'git aliases' to see all available aliases" "INFO"
    }
    catch {
        Write-ErrorAndExit -Message "Git configuration failed: $($_.Exception.Message)" -ThrowException
    }
}

<#
.SYNOPSIS
    Waits for Git to become available after installation
#>
function Wait-ForGitAvailability {
    [CmdletBinding()]
    param()
    
    $maxRetries = 30
    $retryCount = 0
    
    Write-LogMessage "Checking Git availability..." "DEBUG"
    
    do {
        try {
            $gitVersion = & git --version 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-LogMessage "Git is available: $gitVersion" "INFO"
                return
            }
        }
        catch {
            # Git not available yet
        }
        
        Start-Sleep -Seconds 2
        $retryCount++
        Write-LogMessage "Waiting for Git to become available... ($retryCount/$maxRetries)" "DEBUG"
        
    } while ($retryCount -lt $maxRetries)
    
    throw "Git is not available after waiting $($maxRetries * 2) seconds"
}

<#
.SYNOPSIS
    Gets the path to the Git global configuration file
#>
function Get-GitConfigPath {
    [CmdletBinding()]
    [OutputType([string])]
    param()
    
    $gitConfigPath = Join-Path $env:USERPROFILE '.gitconfig'
    Write-LogMessage "Git config path: $gitConfigPath" "DEBUG"
    
    return $gitConfigPath
}

<#
.SYNOPSIS
    Creates a backup of the existing Git configuration
.PARAMETER ConfigPath
    Path to the Git configuration file
#>
function Backup-GitConfig {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ConfigPath
    )
    
    if (Test-Path $ConfigPath) {
        $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $backupPath = "$ConfigPath.backup.$timestamp"
        
        Copy-Item $ConfigPath $backupPath
        Write-LogMessage "Existing Git config backed up to: $backupPath" "INFO"
    }
}

<#
.SYNOPSIS
    Creates the enhanced Git configuration
.PARAMETER ConfigPath
    Path to the Git configuration file
.PARAMETER Force
    Force overwrite existing configuration
#>
function New-GitConfiguration {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ConfigPath,
        
        [Parameter()]
        [switch]$Force
    )
    
    if ((Test-Path $ConfigPath) -and -not $Force) {
        throw "Git configuration already exists. Use -Force to overwrite or -BackupExisting to backup first."
    }
    
    $gitConfig = Get-EnhancedGitConfig
    
    Set-Content -Path $ConfigPath -Value $gitConfig -Encoding UTF8
    Write-LogMessage "Enhanced Git configuration created at: $ConfigPath" "INFO"
}

<#
.SYNOPSIS
    Gets the enhanced Git configuration content
#>
function Get-EnhancedGitConfig {
    [CmdletBinding()]
    [OutputType([string])]
    param()
    
    return @"
# DEC (Desired Environment Configuration) - Enhanced Git Configuration
# Generated on $(Get-Date)

[user]
    name = Developer
    email = developer@example.com

[core]
    autocrlf = true
    editor = code --wait
    longpaths = true
    pager = less -FRSX
    quotePath = false

[init]
    defaultBranch = main

[pull]
    rebase = false

[push]
    default = simple
    autoSetupRemote = true

[fetch]
    prune = true

[merge]
    tool = vscode
    ff = false

[mergetool "vscode"]
    cmd = code --wait `$MERGED

[diff]
    tool = vscode
    colorMoved = zebra

[difftool "vscode"]
    cmd = code --wait --diff `$LOCAL `$REMOTE

# ====================================
# COMPREHENSIVE GIT ALIASES
# ====================================
[alias]
    # === Status and Information ===
    st = status
    s = status --short --branch
    info = remote show origin
    
    # === Branch Management ===
    br = branch
    branches = branch -a
    co = checkout
    cob = checkout -b
    com = checkout main
    cod = checkout develop
    
    # === Commit Operations ===
    ci = commit
    cm = commit -m
    ca = commit -am
    amend = commit --amend
    
    # === Staging Operations ===
    a = add
    aa = add .
    unstage = reset HEAD --
    
    # === Log and History ===
    last = log -1 HEAD
    logs = log --oneline --graph --decorate
    tree = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all
    lg = log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
    
    # === Diff Operations ===
    d = diff
    dc = diff --cached
    dt = difftool
    
    # === Stash Operations ===
    save = stash save -u
    load = stash pop
    stashes = stash list
    
    # === Remote Operations ===
    f = fetch
    p = push
    pl = pull
    up = push -u origin HEAD
    
    # === Reset Operations ===
    uncommit = reset --soft HEAD~1
    
    # === Utility Aliases ===
    aliases = config --get-regexp alias
    remotes = remote -v
    tags = tag -l
    visual = !gitk
    
    # === Advanced Operations ===
    cleanup = "!git branch --merged | grep -v '\\*' | xargs -n 1 git branch -d"
    publish = "!git push -u origin `$(git branch-name)"
    unpublish = "!git push origin :`$(git branch-name)"
    branch-name = "!git rev-parse --abbrev-ref HEAD"
    
    # === Search and Find ===
    find = "!git ls-files | grep -i"
    grep = grep -Ii

[color]
    ui = auto
    branch = auto
    diff = auto
    status = auto
    
[color "branch"]
    current = yellow reverse
    local = yellow
    remote = green
    
[color "diff"]
    meta = yellow bold
    frag = magenta bold
    old = red bold
    new = green bold
    
[color "status"]
    added = yellow
    changed = green
    untracked = cyan
    
[credential]
    helper = manager-core
"@
}

<#
.SYNOPSIS
    Tests the Git configuration to ensure it was applied correctly
#>
function Test-GitConfiguration {
    [CmdletBinding()]
    param()
    
    try {
        $aliasCount = (& git config --global --get-regexp "alias\." 2>$null | Measure-Object).Count
        Write-LogMessage "Successfully configured $aliasCount Git aliases" "INFO"
        
        # Test a few key aliases
        $testAliases = @('st', 'co', 'br', 'ci', 'aliases')
        foreach ($alias in $testAliases) {
            $aliasValue = & git config --global "alias.$alias" 2>$null
            if ($aliasValue) {
                Write-LogMessage "✓ Alias '$alias' -> '$aliasValue'" "DEBUG"
            }
            else {
                Write-LogMessage "✗ Alias '$alias' not found" "WARN"
            }
        }
    }
    catch {
        Write-LogMessage "Could not verify Git configuration (this may be normal during initial setup)" "WARN"
    }
}

<#
.SYNOPSIS
    Shows all configured Git aliases
#>
function Show-GitAliases {
    [CmdletBinding()]
    param()
    
    Write-LogMessage "Configured Git Aliases:" "INFO"
    
    try {
        $aliases = & git config --global --get-regexp "alias\." 2>$null
        if ($aliases) {
            $aliases | ForEach-Object {
                $parts = $_ -split ' ', 2
                $alias = $parts[0] -replace 'alias\.', ''
                $command = $parts[1]
                Write-LogMessage "  $alias -> $command" "INFO"
            }
        }
        else {
            Write-LogMessage "No Git aliases found" "WARN"
        }
    }
    catch {
        Write-LogMessage "Could not retrieve Git aliases" "ERROR"
    }
}

# Export public functions
Export-ModuleMember -Function Set-GitConfiguration, Show-GitAliases
