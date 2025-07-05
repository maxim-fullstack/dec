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
                # === Status and Information ===
                @{
                    Name        = 'st'
                    Command     = 'status'
                    Description = 'Git status'
                },
                @{
                    Name        = 's'
                    Command     = 'status --short --branch'
                    Description = 'Git short status with branch info'
                },
                @{
                    Name        = 'info'
                    Command     = 'remote show origin'
                    Description = 'Show remote repository information'
                },
                
                # === Branch Management ===
                @{
                    Name        = 'br'
                    Command     = 'branch'
                    Description = 'Git branch'
                },
                @{
                    Name        = 'branches'
                    Command     = 'branch -a'
                    Description = 'List all branches'
                },
                @{
                    Name        = 'co'
                    Command     = 'checkout'
                    Description = 'Git checkout'
                },
                @{
                    Name        = 'cob'
                    Command     = 'checkout -b'
                    Description = 'Create and checkout new branch'
                },
                @{
                    Name        = 'com'
                    Command     = 'checkout main'
                    Description = 'Checkout main branch'
                },
                @{
                    Name        = 'cod'
                    Command     = 'checkout develop'
                    Description = 'Checkout develop branch'
                },
                
                # === Commit Operations ===
                @{
                    Name        = 'ci'
                    Command     = 'commit'
                    Description = 'Git commit'
                },
                @{
                    Name        = 'cm'
                    Command     = 'commit -m'
                    Description = 'Commit with message'
                },
                @{
                    Name        = 'ca'
                    Command     = 'commit -am'
                    Description = 'Add all and commit with message'
                },
                @{
                    Name        = 'amend'
                    Command     = 'commit --amend'
                    Description = 'Amend last commit'
                },
                
                # === Staging Operations ===
                @{
                    Name        = 'a'
                    Command     = 'add'
                    Description = 'Git add'
                },
                @{
                    Name        = 'aa'
                    Command     = 'add .'
                    Description = 'Add all files'
                },
                @{
                    Name        = 'unstage'
                    Command     = 'reset HEAD --'
                    Description = 'Unstage files'
                },
                
                # === Log and History ===
                @{
                    Name        = 'last'
                    Command     = 'log -1 HEAD'
                    Description = 'Show last commit'
                },
                @{
                    Name        = 'logs'
                    Command     = 'log --oneline --graph --decorate'
                    Description = 'Show log in oneline format with graph'
                },
                @{
                    Name        = 'tree'
                    Command     = 'log --graph --pretty=format:''%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'' --abbrev-commit --all'
                    Description = 'Show commit tree with colors'
                },
                @{
                    Name        = 'lg'
                    Command     = 'log --color --graph --pretty=format:''%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'' --abbrev-commit'
                    Description = 'Show colored log graph'
                },
                
                # === Diff Operations ===
                @{
                    Name        = 'd'
                    Command     = 'diff'
                    Description = 'Git diff'
                },
                @{
                    Name        = 'dc'
                    Command     = 'diff --cached'
                    Description = 'Diff staged changes'
                },
                @{
                    Name        = 'dt'
                    Command     = 'difftool'
                    Description = 'Launch diff tool'
                },
                
                # === Stash Operations ===
                @{
                    Name        = 'save'
                    Command     = 'stash save -u'
                    Description = 'Stash changes including untracked files'
                },
                @{
                    Name        = 'load'
                    Command     = 'stash pop'
                    Description = 'Apply and remove last stash'
                },
                @{
                    Name        = 'stashes'
                    Command     = 'stash list'
                    Description = 'List all stashes'
                },
                
                # === Remote Operations ===
                @{
                    Name        = 'f'
                    Command     = 'fetch'
                    Description = 'Git fetch'
                },
                @{
                    Name        = 'p'
                    Command     = 'push'
                    Description = 'Git push'
                },
                @{
                    Name        = 'pl'
                    Command     = 'pull'
                    Description = 'Git pull'
                },
                @{
                    Name        = 'up'
                    Command     = 'push -u origin HEAD'
                    Description = 'Push and set upstream'
                },
                
                # === Reset Operations ===
                @{
                    Name        = 'uncommit'
                    Command     = 'reset --soft HEAD~1'
                    Description = 'Undo last commit but keep changes staged'
                },
                
                # === Utility Aliases ===
                @{
                    Name        = 'aliases'
                    Command     = 'config --get-regexp alias'
                    Description = 'List all Git aliases'
                },
                @{
                    Name        = 'remotes'
                    Command     = 'remote -v'
                    Description = 'List all remotes'
                },
                @{
                    Name        = 'tags'
                    Command     = 'tag -l'
                    Description = 'List all tags'
                },
                @{
                    Name        = 'visual'
                    Command     = '!gitk'
                    Description = 'Launch git GUI'
                },
                
                # === Advanced Operations ===
                @{
                    Name        = 'cleanup'
                    Command     = '!git branch --merged | grep -v ''\\*'' | xargs -n 1 git branch -d'
                    Description = 'Delete merged branches'
                },
                @{
                    Name        = 'publish'
                    Command     = '!git push -u origin $(git branch-name)'
                    Description = 'Publish current branch'
                },
                @{
                    Name        = 'unpublish'
                    Command     = '!git push origin :$(git branch-name)'
                    Description = 'Delete remote branch'
                },
                @{
                    Name        = 'branch-name'
                    Command     = '!git rev-parse --abbrev-ref HEAD'
                    Description = 'Get current branch name'
                },
                
                # === Search and Find ===
                @{
                    Name        = 'find'
                    Command     = '!git ls-files | grep -i'
                    Description = 'Find files by name'
                },
                @{
                    Name        = 'grep'
                    Command     = 'grep -Ii'
                    Description = 'Search in repository content'
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
