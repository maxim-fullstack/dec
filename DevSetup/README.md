# DEC DevSetup - Hybrid Configuration Project

DEC (Desired Environment Configuration) DevSetup is a hybrid configuration project that combines the power of `winget configure` for modern package management with traditional PowerShell DSC for custom, complex tasks.

## 🚀 Quick Start

**Prerequisites:**
- Windows 10/11 with Administrator privileges
- Windows Package Manager (winget) installed
- PowerShell 5.1 or PowerShell 7+

**One-Command Setup:**
```powershell
# Run this single command as Administrator to configure your entire development environment
.\Apply-Configuration.ps1
```

## 📁 Project Structure

```
DevSetup/
├── Apply-Configuration.ps1      # 🎯 Main orchestrator script (run this!)
├── configuration.dsc.yaml      # 📦 winget configure file
├── DscCustom/                   # 🔧 PowerShell DSC components
│   ├── CustomConfiguration.ps1 # 🛠️ DSC configuration script
│   └── ConfigurationData.psd1   # 📋 Configuration data and settings
└── README.md                    # 📖 This file
```

## 🎯 What Gets Configured

### Stage 1: Applications & Windows Settings (winget)
- **Core Development:** Git, Visual Studio Code, PowerShell 7, Windows Terminal, Docker, Vim, Neovim
- **Node.js & JavaScript:** NVM for Windows, pnpm package manager
- **Browsers:** Google Chrome, Google Chrome Dev, Firefox Developer Edition
- **Productivity:** 7-Zip, Notepad++, Grammarly, Obsidian, Microsoft Sticky Notes, draw.io
- **Azure & Cloud:** Azure Data Studio, Dev Home Azure Extension
- **GitHub & Version Control:** GitHub Desktop, GitHub CLI, Dev Home GitHub Extension
- **System Utilities:** PowerToys, DevToys, Sysinternals Suite, Windows Performance Analyzer
- **Terminal Enhancement:** Oh My Posh, Warp terminal
- **Windows Settings:** Dark mode, Developer mode, Taskbar alignment

### Stage 2: Custom Configuration (PowerShell DSC)
- **Directory Structure:** Creates organized development folders (`C:\Dev\Projects`, `C:\Dev\Tools`, `C:\Dev\Scripts`, `C:\Dev\Installers`, `C:\Dev\Temp`)
- **PowerShell Profile:** Custom aliases, functions, and prompt with Git integration
- **Git Configuration:** Global git settings with useful aliases
- **Environment Variables:** Development-focused environment setup (DEV_PATH, EDITOR, GIT_EDITOR)
- **Desktop Shortcuts:** Quick access to development tools and folders (Dev Folder, VS Code, Windows Terminal)
- **Registry Settings:** Show file extensions, hidden files, and system files
- **Windows Features:** Enables WSL (Linux Subsystem)
- **Custom Apps:** Framework for installing local EXE/MSI packages
- **Data-Driven Configuration:** Structured configuration via ConfigurationData.psd1

## 🛠️ Usage Options

### Standard Usage
```powershell
# Run complete configuration
.\Apply-Configuration.ps1
```

### Advanced Options
```powershell
# Skip winget configuration (applications only)
.\Apply-Configuration.ps1 -SkipWinget

# Skip PowerShell DSC (custom config only)
.\Apply-Configuration.ps1 -SkipDSC

# Verbose output
.\Apply-Configuration.ps1 -Verbose
```

## 📋 Detailed Configuration

### Complete Applications List

**Core Development Tools:**
- Git (version control)
- Microsoft Visual Studio Code (code editor)
- PowerShell 7 (advanced shell)
- Windows Terminal (modern terminal)
- Docker Desktop (containerization)
- Vim (text editor)
- Neovim (modern Vim)

**Node.js & JavaScript:**
- NVM for Windows (Node version manager)
- pnpm (fast package manager)

**Browsers & Web Development:**
- Google Chrome (primary browser)
- Google Chrome Dev (development browser)
- Firefox Developer Edition (web development)

**Productivity & Office:**
- 7-Zip (file archiving)
- Notepad++ (text editor)
- Grammarly for Windows (writing assistant)
- Obsidian (note-taking)
- Microsoft Sticky Notes (quick notes)
- draw.io Diagrams (diagramming tool)

**Azure & Cloud Development:**
- Azure Data Studio (database management)
- Dev Home Azure Extension (Azure integration)

**GitHub & Version Control:**
- GitHub Desktop (Git GUI)
- GitHub CLI (command-line interface)
- Dev Home GitHub Extension (GitHub integration)

**System Utilities & Tools:**
- PowerToys (Windows utilities)
- DevToys (developer utilities)
- Sysinternals Suite (system tools)
- Windows Performance Analyzer (performance analysis)

**Terminal & Shell Enhancement:**
- Oh My Posh (prompt theming)
- Warp (modern terminal)

### Applications Installed via winget

| Category | Applications |
|----------|-------------|
| **Core Development** | Git, Visual Studio Code, PowerShell 7, Windows Terminal, Docker Desktop, Vim, Neovim |
| **Node.js & JavaScript** | NVM for Windows, pnpm |
| **Browsers & Web Dev** | Google Chrome, Google Chrome Dev, Firefox Developer Edition |
| **Productivity & Office** | 7-Zip, Notepad++, Grammarly for Windows, Obsidian, Microsoft Sticky Notes, draw.io Diagrams |
| **Azure & Cloud** | Azure Data Studio, Dev Home Azure Extension |
| **GitHub & Version Control** | GitHub Desktop, GitHub CLI, Dev Home GitHub Extension |
| **System Utilities** | PowerToys, DevToys, Sysinternals Suite, Windows Performance Analyzer |
| **Terminal Enhancement** | Oh My Posh, Warp terminal |

### Custom PowerShell Profile Features

#### Aliases
- `ll`, `la` → `Get-ChildItem` (list files)
- `grep` → `Select-String` (search text)
- `touch` → `New-Item` (create files)
- `which` → `Get-Command` (find commands)

#### Functions
- `cd-dev` → Navigate to `C:\Dev`
- `cd-projects` → Navigate to `C:\Dev\Projects`
- `gs` → `git status`
- `ga` → `git add .`
- `gc "message"` → `git commit -m "message"`

#### Enhanced Prompt
- Shows current directory
- Displays git branch when in a repository  
- Clean, informative format

#### Environment Variables
- `DEV_PATH` → Points to `C:\Dev` (machine-level)
- `EDITOR` → Set to `code` (user-level)
- `GIT_EDITOR` → Set to `code --wait` (user-level)

#### Desktop Shortcuts Created
- **Dev Folder** → Quick access to `C:\Dev`
- **Visual Studio Code** → Direct launch of VS Code
- **Windows Terminal** → Quick access to modern terminal

### Directory Structure Created
```
C:\Dev/
├── Projects/     # Active development projects
├── Tools/        # Development tools and utilities
├── Scripts/      # Utility scripts and automation
├── Installers/   # Local application installers
└── Temp/         # Temporary development files
```

## 🔧 Customization

### Adding Applications
Edit `configuration.dsc.yaml` to add more winget packages:
```yaml
- resource: Microsoft.WinGet.DSC/WinGetPackage
  directives:
    description: Install Your App
    allowPrerelease: true
  settings:
    id: Publisher.AppName
    source: winget
```

### Configuration Data Structure
The project uses a structured approach with `ConfigurationData.psd1` containing:

- **PowerShell Aliases**: Customize command shortcuts
- **Git Aliases**: Configure git command shortcuts  
- **Environment Variables**: Set system and user environment variables
- **Directory Structure**: Define folders to create
- **Desktop Shortcuts**: Specify desktop shortcuts to create
- **Registry Settings**: Configure Windows registry settings
- **Windows Features**: List Windows features to enable
- **Custom Applications**: Define local installers to run

### Modifying Configuration Data
Edit `DscCustom\ConfigurationData.psd1` to customize:

```powershell
# Add new PowerShell aliases
PowerShellAliases = @(
    @{
        Name        = 'your-alias'
        Command     = 'Your-Command'
        Description = 'Description of your alias'
    }
)

# Add environment variables
EnvironmentVariables = @(
    @{
        Name        = 'YOUR_VAR'
        Value       = 'YourValue'
        Target      = 'User'  # or 'Machine'
        Description = 'Your custom environment variable'
    }
)
```

### Custom Local Installers
1. Place your `.msi` or `.exe` files in `C:\Dev\Tools\Installers\`
2. Edit `DscCustom\ConfigurationData.psd1` to add your applications:
```powershell
CustomApplications = @(
    @{
        Name          = 'YourApp'
        InstallerPath = 'C:\Dev\Tools\Installers\YourApp.msi'
        InstallerType = 'MSI'
        CheckPath     = 'C:\Program Files\YourApp\YourApp.exe'
        Description   = 'Your custom application'
        Enabled       = $true
    }
)
```

Alternatively, you can modify the `CustomApplications` Script resource directly in `DscCustom\CustomConfiguration.ps1`:

```powershell
SetScript = {
    $installerPath = "C:\Dev\Tools\Installers\YourApp.msi"
    if (Test-Path $installerPath) {
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i", $installerPath, "/quiet" -Wait
        Write-Verbose "Installed YourApp from local installer"
    }
}
```

### Modifying PowerShell Profile
Edit the profile content in `DscCustom\CustomConfiguration.ps1` under the `PowerShellProfile` script resource.

## 📊 Logging & Troubleshooting

### Log File
All operations are logged to `configuration.log` in the script directory.

### Common Issues

**"winget is not available"**
- Install App Installer from Microsoft Store
- Update Windows to latest version

**"Must be run as Administrator"**
- Right-click PowerShell and select "Run as Administrator"
- Or use `Start-Process PowerShell -Verb RunAs`

**DSC Module Issues**
- The script automatically installs `PSDscResources` module
- Ensure you have internet connectivity

### Manual Steps
If automated configuration fails, you can run components individually:

```powershell
# Run only winget configuration
winget configure --file .\configuration.dsc.yaml

# Run only DSC configuration
cd DscCustom
. .\CustomConfiguration.ps1
CustomConfiguration -OutputPath .\Output
Start-DscConfiguration -Path .\Output -Wait -Verbose
```

## 🎨 Windows Settings Applied

- **Theme:** Dark mode for system and applications
- **Taskbar:** Left-aligned, always visible
- **Developer Mode:** Enabled
- **File Explorer:** Show file extensions, hidden files, and system files
- **Features:** Windows Subsystem for Linux (WSL) enabled

## 🔄 Running Again

The configuration is designed to be idempotent - you can run it multiple times safely. It will:
- Skip already installed applications
- Update existing configurations
- Not duplicate settings

## 🤝 Contributing

To extend this configuration:

1. **For new applications:** Add to `configuration.dsc.yaml`
2. **For custom settings:** Modify `DscCustom\CustomConfiguration.ps1`
3. **For data-driven config:** Update `DscCustom\ConfigurationData.psd1`

## 📝 License

This project follows the same license as the parent DEC project (MIT License).

## 🆘 Support

- Check the `configuration.log` file for detailed operation logs
- Review Windows Event Logs for DSC-related issues
- Ensure all prerequisites are met before running

---

**Happy Coding! 🚀**

*This configuration sets up a comprehensive development environment in minutes, not hours.*
