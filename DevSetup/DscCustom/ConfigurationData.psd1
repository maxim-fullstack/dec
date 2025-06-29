# DEC (Desired Environment Configuration) - Configuration Data
# This file contains data used by the PowerShell DSC configuration

@{
    AllNodes = @(
        @{
            NodeName             = 'localhost'
            
            # PowerShell Aliases Configuration
            PowerShellAliases    = @(
                @{
                    Name        = 'll'
                    Command     = 'Get-ChildItem'
                    Description = 'List files and directories'
                },
                @{
                    Name        = 'la'
                    Command     = 'Get-ChildItem'
                    Description = 'List all files and directories'
                },
                @{
                    Name        = 'grep'
                    Command     = 'Select-String'
                    Description = 'Search text patterns'
                },
                @{
                    Name        = 'touch'
                    Command     = 'New-Item'
                    Description = 'Create new file'
                },
                @{
                    Name        = 'which'
                    Command     = 'Get-Command'
                    Description = 'Find command location'
                }
            )
            
            # Git Aliases Configuration
            GitAliases           = @(
                @{
                    Name        = 'st'
                    Command     = 'status'
                    Description = 'Git status'
                },
                @{
                    Name        = 'co'
                    Command     = 'checkout'
                    Description = 'Git checkout'
                },
                @{
                    Name        = 'br'
                    Command     = 'branch'
                    Description = 'Git branch'
                },
                @{
                    Name        = 'ci'
                    Command     = 'commit'
                    Description = 'Git commit'
                },
                @{
                    Name        = 'unstage'
                    Command     = 'reset HEAD --'
                    Description = 'Unstage files'
                },
                @{
                    Name        = 'last'
                    Command     = 'log -1 HEAD'
                    Description = 'Show last commit'
                },
                @{
                    Name        = 'visual'
                    Command     = '!gitk'
                    Description = 'Launch git GUI'
                }
            )
            
            # Environment Variables
            EnvironmentVariables = @(
                @{
                    Name        = 'DEV_PATH'
                    Value       = 'C:\Dev'
                    Target      = 'Machine'
                    Description = 'Main development directory'
                },
                @{
                    Name        = 'EDITOR'
                    Value       = 'code'
                    Target      = 'User'
                    Description = 'Default text editor'
                },
                @{
                    Name        = 'GIT_EDITOR'
                    Value       = 'code --wait'
                    Target      = 'User'
                    Description = 'Git default editor'
                }
            )
            
            # Directory Structure
            DirectoryStructure   = @(
                @{
                    Path        = 'C:\Dev'
                    Description = 'Main development directory'
                },
                @{
                    Path        = 'C:\Dev\Projects'
                    Description = 'Active development projects'
                },
                @{
                    Path        = 'C:\Dev\Tools'
                    Description = 'Development tools and utilities'
                },
                @{
                    Path        = 'C:\Dev\Scripts'
                    Description = 'Utility scripts and automation'
                },
                @{
                    Path        = 'C:\Dev\Installers'
                    Description = 'Local application installers'
                },
                @{
                    Path        = 'C:\Dev\Temp'
                    Description = 'Temporary development files'
                }
            )
            
            # Desktop Shortcuts
            DesktopShortcuts     = @(
                @{
                    Name        = 'Dev Folder'
                    Target      = 'C:\Dev'
                    Icon        = 'shell32.dll,3'
                    Description = 'Development folder shortcut'
                },
                @{
                    Name        = 'Visual Studio Code'
                    Target      = '%LocalAppData%\Programs\Microsoft VS Code\Code.exe'
                    Icon        = '%LocalAppData%\Programs\Microsoft VS Code\Code.exe,0'
                    Description = 'VS Code shortcut'
                },
                @{
                    Name        = 'Windows Terminal'
                    Target      = 'wt.exe'
                    Icon        = 'shell32.dll,24'
                    Description = 'Windows Terminal shortcut'
                }
            )
            
            # Registry Settings
            RegistrySettings     = @(
                @{
                    Key         = 'HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
                    ValueName   = 'HideFileExt'
                    ValueData   = '0'
                    ValueType   = 'Dword'
                    Description = 'Show file extensions'
                },
                @{
                    Key         = 'HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
                    ValueName   = 'Hidden'
                    ValueData   = '1'
                    ValueType   = 'Dword'
                    Description = 'Show hidden files'
                },
                @{
                    Key         = 'HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
                    ValueName   = 'ShowSuperHidden'
                    ValueData   = '1'
                    ValueType   = 'Dword'
                    Description = 'Show system files'
                }
            )
            
            # Windows Features to Enable
            WindowsFeatures      = @(
                @{
                    Name        = 'Microsoft-Windows-Subsystem-Linux'
                    Description = 'Windows Subsystem for Linux'
                }
            )
            
            # Custom Applications (from local installers)
            CustomApplications   = @(
                # @{
                #     Name          = 'CustomApp'
                #     InstallerPath = 'C:\Dev\Tools\Installers\CustomApp.msi'
                #     InstallerType = 'MSI'
                #     CheckPath     = 'C:\Program Files\CustomApp\CustomApp.exe'
                #     Description   = 'Example custom application'
                #     Enabled       = $false
                # }
                # Add more custom applications as needed
                # @{
                #     Name = 'AnotherApp'
                #     InstallerPath = 'C:\Dev\Tools\Installers\AnotherApp.exe'
                #     InstallerType = 'EXE'
                #     CheckPath = 'C:\Program Files\AnotherApp\AnotherApp.exe'
                #     Description = 'Another custom application'
                #     Enabled = $false
                # }
            )
        }
    )
}
