# DEC (Desired Environment Configuration) - PowerShell DSC Custom Configuration
# This configuration handles custom tasks not covered by winget configure

Configuration CustomConfiguration {
    param(
        [string[]]$ComputerName = 'localhost'
    )
    
    # Ensure PSDscResources module is available
    if (-not (Get-Module -ListAvailable -Name PSDscResources)) {
        Install-Module -Name PSDscResources -Force -Scope CurrentUser
    }
    
    # Import template manager module
    $templateManagerPath = Join-Path $PSScriptRoot "..\Modules\TemplateManager.psm1"
    if (Test-Path $templateManagerPath) {
        Import-Module $templateManagerPath -Force
    }
    
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
                
                try {
                    # Load PowerShell profile template
                    $templateDir = Join-Path $using:PSScriptRoot "Templates"
                    $profileContent = Get-PowerShellProfileTemplate -TemplateDirectory $templateDir
                    
                    # Process template with current date
                    $processedContent = Invoke-TemplateProcessing -TemplateContent $profileContent
                    
                    # Write the profile content
                    Set-Content -Path $profilePath -Value $processedContent -Encoding UTF8
                    Write-Verbose "PowerShell profile created at: $profilePath"
                }
                catch {
                    # Fallback to basic profile if template loading fails
                    $basicProfile = @"
# DEC (Desired Environment Configuration) - PowerShell Profile (Basic)
# Generated on $(Get-Date)

Set-Alias -Name ll -Value Get-ChildItem
Set-Alias -Name la -Value Get-ChildItem
Set-Alias -Name grep -Value Select-String
Set-Alias -Name touch -Value New-Item
Set-Alias -Name which -Value Get-Command

Write-Host "DEC PowerShell Profile Loaded!" -ForegroundColor Green
"@
                    Set-Content -Path $profilePath -Value $basicProfile -Encoding UTF8
                    Write-Verbose "Basic PowerShell profile created at: $profilePath (template loading failed)"
                }
            }
        }
        
        # ====================================
        # GIT CONFIGURATION
        # ====================================
        Script GitGlobalConfig {
            GetScript  = {
                $gitConfigPath = Join-Path $env:USERPROFILE '.gitconfig'
                $exists = Test-Path $gitConfigPath
                $gitAliases = @()
                
                if ($exists) {
                    # Check for existing Git aliases
                    try {
                        $gitOutput = & git config --global --get-regexp "alias\." 2>$null
                        if ($gitOutput) {
                            $gitAliases = $gitOutput | ForEach-Object { $_.Split(' ')[0] -replace 'alias\.', '' }
                        }
                    }
                    catch {
                        # Git not available or config error
                    }
                }
                
                return @{
                    Result     = @{
                        ConfigExists = $exists
                        Aliases      = $gitAliases
                    }
                    GetScript  = $GetScript
                    SetScript  = $SetScript
                    TestScript = $TestScript
                }
            }
            
            TestScript = {
                $gitConfigPath = Join-Path $env:USERPROFILE '.gitconfig'
                
                # Check if Git is available
                try {
                    $null = & git --version 2>$null
                }
                catch {
                    Write-Verbose "Git not yet available, configuration will be applied when Git is installed"
                    return $false
                }
                
                if (-not (Test-Path $gitConfigPath)) {
                    return $false
                }
                
                # Check if required aliases exist
                $requiredAliases = @('st', 'co', 'br', 'ci', 'unstage', 'last', 'logs', 'tree', 'uncommit', 'save', 'load', 'aliases')
                
                foreach ($alias in $requiredAliases) {
                    try {
                        $aliasValue = & git config --global "alias.$alias" 2>$null
                        if (-not $aliasValue) {
                            Write-Verbose "Missing Git alias: $alias"
                            return $false
                        }
                    }
                    catch {
                        Write-Verbose "Error checking Git alias: $alias"
                        return $false
                    }
                }
                
                return $true
            }
            
            SetScript  = {
                $gitConfigPath = Join-Path $env:USERPROFILE '.gitconfig'
                
                # Wait for Git to be available (since it might still be installing)
                $maxRetries = 30
                $retryCount = 0
                
                do {
                    try {
                        $null = & git --version 2>$null
                        break
                    }
                    catch {
                        Start-Sleep -Seconds 2
                        $retryCount++
                        Write-Verbose "Waiting for Git to become available... ($retryCount/$maxRetries)"
                    }
                } while ($retryCount -lt $maxRetries)
                
                if ($retryCount -ge $maxRetries) {
                    throw "Git is not available after waiting. Please ensure Git is properly installed."
                }
                
                try {
                    # Load Git configuration template
                    $templateDir = Join-Path $using:PSScriptRoot "Templates"
                    $gitConfig = Get-GitConfigTemplate -TemplateDirectory $templateDir
                    
                    # Backup existing config if it exists
                    if (Test-Path $gitConfigPath) {
                        $backupPath = "$gitConfigPath.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
                        Copy-Item $gitConfigPath $backupPath
                        Write-Verbose "Existing Git config backed up to: $backupPath"
                    }
                    
                    Set-Content -Path $gitConfigPath -Value $gitConfig -Encoding UTF8
                    Write-Verbose "Enhanced Git global configuration created at: $gitConfigPath"
                }
                catch {
                    Write-Verbose "Template loading failed, using fallback Git configuration: $($_.Exception.Message)"
                    
                    # Fallback basic Git configuration
                    $basicGitConfig = @"
[user]
    name = Developer
    email = developer@example.com

[core]
    autocrlf = true
    editor = code --wait
    longpaths = true

[init]
    defaultBranch = main

[alias]
    st = status
    co = checkout
    br = branch
    ci = commit
    unstage = reset HEAD --
    last = log -1 HEAD
    
[color]
    ui = auto
"@
                    Set-Content -Path $gitConfigPath -Value $basicGitConfig -Encoding UTF8
                    Write-Verbose "Basic Git configuration created at: $gitConfigPath"
                }
                
                # Verify the configuration was applied
                Start-Sleep -Seconds 1
                try {
                    $aliasCount = (& git config --global --get-regexp "alias\." | Measure-Object).Count
                    Write-Verbose "Successfully configured $aliasCount Git aliases"
                }
                catch {
                    Write-Verbose "Note: Git configuration created, but verification failed (this is normal during initial setup)"
                }
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
