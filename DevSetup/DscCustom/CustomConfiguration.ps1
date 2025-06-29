# DEC (Desired Environment Configuration) - PowerShell DSC Custom Configuration
# This configuration handles custom tasks not covered by winget configure

Configuration CustomConfiguration {
    param(
        [string[]]$ComputerName = 'localhost'
    )
    
    Import-DscResource -ModuleName PSDscResources
    
    Node $ComputerName {
        
        # ====================================
        # ENVIRONMENT VARIABLES
        # ====================================
        Script MachineEnvironmentVariables {
            GetScript  = {
                $devPath = [Environment]::GetEnvironmentVariable('DEV_PATH', 'Machine')
                return @{
                    Result     = @{
                        DEV_PATH = $devPath
                    }
                    GetScript  = $GetScript
                    SetScript  = $SetScript
                    TestScript = $TestScript
                }
            }
            
            TestScript = {
                $devPath = [Environment]::GetEnvironmentVariable('DEV_PATH', 'Machine')
                return ($devPath -eq 'C:\Dev')
            }
            
            SetScript  = {
                [Environment]::SetEnvironmentVariable('DEV_PATH', 'C:\Dev', 'Machine')
                Write-Verbose "Set machine environment variable DEV_PATH to C:\Dev"
            }
        }
        
        Script UserEnvironmentVariables {
            GetScript  = {
                $gitConfig = [Environment]::GetEnvironmentVariable('GIT_CONFIG_GLOBAL', 'User')
                return @{
                    Result     = @{
                        GIT_CONFIG_GLOBAL = $gitConfig
                    }
                    GetScript  = $GetScript
                    SetScript  = $SetScript
                    TestScript = $TestScript
                }
            }
            
            TestScript = {
                $gitConfig = [Environment]::GetEnvironmentVariable('GIT_CONFIG_GLOBAL', 'User')
                $expectedPath = Join-Path $env:USERPROFILE '.gitconfig'
                return ($gitConfig -eq $expectedPath)
            }
            
            SetScript  = {
                $gitConfigPath = Join-Path $env:USERPROFILE '.gitconfig'
                [Environment]::SetEnvironmentVariable('GIT_CONFIG_GLOBAL', $gitConfigPath, 'User')
                Write-Verbose "Set user environment variable GIT_CONFIG_GLOBAL to $gitConfigPath"
            }
        }
        
        # ====================================
        # DIRECTORY STRUCTURE
        # ====================================
        File DevDirectory {
            DestinationPath = 'C:\Dev'
            Type            = 'Directory'
            Ensure          = 'Present'
        }
        
        File ProjectsDirectory {
            DestinationPath = 'C:\Dev\Projects'
            Type            = 'Directory'
            Ensure          = 'Present'
            DependsOn       = '[File]DevDirectory'
        }
        
        File ToolsDirectory {
            DestinationPath = 'C:\Dev\Tools'
            Type            = 'Directory'
            Ensure          = 'Present'
            DependsOn       = '[File]DevDirectory'
        }
        
        File ScriptsDirectory {
            DestinationPath = 'C:\Dev\Scripts'
            Type            = 'Directory'
            Ensure          = 'Present'
            DependsOn       = '[File]DevDirectory'
        }
        
        # ====================================
        # POWERSHELL PROFILE CONFIGURATION
        # ====================================
        Script PowerShellProfile {
            GetScript  = {
                $profilePath = $PROFILE.AllUsersAllHosts
                $exists = Test-Path $profilePath
                return @{
                    Result     = $exists
                    GetScript  = $GetScript
                    SetScript  = $SetScript
                    TestScript = $TestScript
                }
            }
            
            TestScript = {
                $profilePath = $PROFILE.AllUsersAllHosts
                if (-not (Test-Path $profilePath)) {
                    return $false
                }
                
                $content = Get-Content $profilePath -Raw
                $requiredContent = @(
                    'Set-Alias -Name ll -Value Get-ChildItem',
                    'Set-Alias -Name grep -Value Select-String',
                    'Set-Alias -Name touch -Value New-Item'
                )
                
                foreach ($line in $requiredContent) {
                    if ($content -notlike "*$line*") {
                        return $false
                    }
                }
                return $true
            }
            
            SetScript  = {
                $profilePath = $PROFILE.AllUsersAllHosts
                $profileDir = Split-Path $profilePath -Parent
                
                # Create profile directory if it doesn't exist
                if (-not (Test-Path $profileDir)) {
                    New-Item -ItemType Directory -Path $profileDir -Force
                }
                
                # PowerShell profile content
                $profileContent = @"
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
function cd-dev { Set-Location 'C:\Dev' }
function cd-projects { Set-Location 'C:\Dev\Projects' }
function cd-tools { Set-Location 'C:\Dev\Tools' }
function cd-scripts { Set-Location 'C:\Dev\Scripts' }

# Git shortcuts
function gs { git status }
function ga { git add . }
function gc { param([string]`$message) git commit -m `$message }
function gp { git push }
function gl { git log --oneline -10 }

# ====================================
# PROMPT CUSTOMIZATION
# ====================================
function prompt {
    `$currentPath = Get-Location
    `$gitBranch = ""
    
    # Check if we're in a git repository
    if (Get-Command git -ErrorAction SilentlyContinue) {
        `$gitStatus = git rev-parse --abbrev-ref HEAD 2>`$null
        if (`$gitStatus) {
            `$gitBranch = " [git:`$gitStatus]"
        }
    }
    
    `$promptText = "PS `$(`$currentPath)`$gitBranch> "
    return `$promptText
}

# ====================================
# MODULE IMPORTS
# ====================================
# Import useful modules if available
if (Get-Module -ListAvailable -Name posh-git) {
    Import-Module posh-git
}

Write-Host "DEC PowerShell Profile Loaded!" -ForegroundColor Green
"@
                
                # Write the profile content
                Set-Content -Path $profilePath -Value $profileContent -Encoding UTF8
                Write-Verbose "PowerShell profile created at: $profilePath"
            }
        }
        
        # ====================================
        # GIT CONFIGURATION
        # ====================================
        Script GitGlobalConfig {
            GetScript  = {
                $gitConfigPath = Join-Path $env:USERPROFILE '.gitconfig'
                $exists = Test-Path $gitConfigPath
                return @{
                    Result     = $exists
                    GetScript  = $GetScript
                    SetScript  = $SetScript
                    TestScript = $TestScript
                }
            }
            
            TestScript = {
                $gitConfigPath = Join-Path $env:USERPROFILE '.gitconfig'
                return (Test-Path $gitConfigPath)
            }
            
            SetScript  = {
                $gitConfigPath = Join-Path $env:USERPROFILE '.gitconfig'
                
                # Basic git configuration
                $gitConfig = @"
[user]
    name = Developer
    email = developer@example.com

[core]
    autocrlf = true
    editor = code --wait
    longpaths = true

[init]
    defaultBranch = main

[pull]
    rebase = false

[push]
    default = simple

[alias]
    st = status
    co = checkout
    br = branch
    ci = commit
    unstage = reset HEAD --
    last = log -1 HEAD
    visual = !gitk
    
[color]
    ui = auto
    
[credential]
    helper = manager-core
"@
                
                Set-Content -Path $gitConfigPath -Value $gitConfig -Encoding UTF8
                Write-Verbose "Git global configuration created at: $gitConfigPath"
            }
        }
        
        # ====================================
        # DESKTOP SHORTCUTS
        # ====================================
        Script DesktopShortcuts {
            GetScript  = {
                $desktopPath = [Environment]::GetFolderPath('Desktop')
                $shortcuts = @(
                    'Visual Studio Code.lnk',
                    'Windows Terminal.lnk',
                    'Dev Folder.lnk'
                )
                
                $existingShortcuts = @()
                foreach ($shortcut in $shortcuts) {
                    $shortcutPath = Join-Path $desktopPath $shortcut
                    if (Test-Path $shortcutPath) {
                        $existingShortcuts += $shortcut
                    }
                }
                
                return @{
                    Result     = $existingShortcuts
                    GetScript  = $GetScript
                    SetScript  = $SetScript
                    TestScript = $TestScript
                }
            }
            
            TestScript = {
                $desktopPath = [Environment]::GetFolderPath('Desktop')
                $requiredShortcuts = @(
                    'Dev Folder.lnk'
                )
                
                foreach ($shortcut in $requiredShortcuts) {
                    $shortcutPath = Join-Path $desktopPath $shortcut
                    if (-not (Test-Path $shortcutPath)) {
                        return $false
                    }
                }
                return $true
            }
            
            SetScript  = {
                $desktopPath = [Environment]::GetFolderPath('Desktop')
                $shell = New-Object -ComObject WScript.Shell
                
                # Create Dev Folder shortcut
                $devShortcutPath = Join-Path $desktopPath 'Dev Folder.lnk'
                $devShortcut = $shell.CreateShortcut($devShortcutPath)
                $devShortcut.TargetPath = 'C:\Dev'
                $devShortcut.Description = 'Development Folder'
                $devShortcut.IconLocation = 'shell32.dll,3'
                $devShortcut.Save()
                
                Write-Verbose "Desktop shortcuts created"
            }
        }
        
        # ====================================
        # WINDOWS FEATURES
        # ====================================        
        WindowsOptionalFeature LinuxSubsystem {
            Name   = 'Microsoft-Windows-Subsystem-Linux'
            Ensure = 'Enable'
        }
        
        # ====================================
        # REGISTRY SETTINGS
        # ====================================
        Registry ShowFileExtensions {
            Key       = 'HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
            ValueName = 'HideFileExt'
            ValueData = '0'
            ValueType = 'Dword'
            Ensure    = 'Present'
        }
        
        Registry ShowHiddenFiles {
            Key       = 'HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
            ValueName = 'Hidden'
            ValueData = '1'
            ValueType = 'Dword'
            Ensure    = 'Present'
        }
        
        # ====================================
        # CUSTOM APPLICATION INSTALLATION PLACEHOLDER
        # ====================================
        Script CustomApplications {
            GetScript  = {
                # Check for custom applications that might be installed from local installers
                $customApps = @()
                
                # Example: Check if a custom application is installed
                # $customAppPath = "C:\Program Files\CustomApp\CustomApp.exe"
                # if (Test-Path $customAppPath) {
                #     $customApps += "CustomApp"
                # }
                
                return @{
                    Result     = $customApps
                    GetScript  = $GetScript
                    SetScript  = $SetScript
                    TestScript = $TestScript
                }
            }
            
            TestScript = {
                # Always return true for now as this is a placeholder
                # In a real scenario, you would check if specific applications are installed
                return $true
            }
            
            SetScript  = {
                # Placeholder for installing applications from local EXE/MSI installers
                Write-Verbose "Custom application installation placeholder"
                
                # Example installation pattern:
                # $installerPath = "C:\Dev\Tools\Installers\CustomApp.msi"
                # if (Test-Path $installerPath) {
                #     Start-Process -FilePath "msiexec.exe" -ArgumentList "/i", $installerPath, "/quiet" -Wait
                #     Write-Verbose "Installed CustomApp from local installer"
                # }
            }
        }
    }
}
