# Puppet Workstation Configuration

A masterless Puppet project for configuring development workstations with clean architecture principles and cross-platform support.

## Overview

This project provides a complete masterless Puppet configuration for setting up development workstations. It follows clean architecture principles with proper separation of concerns and modular design for easy extensibility.

## Features

- **Cross-platform Git installation** using platform-specific package managers:
  - Windows: winget
  - Debian/Ubuntu: apt
- **Git configuration management** with extensible structure
- **Masterless Puppet setup** with complete runner scripts
- **Clean architecture** with proper separation of concerns
- **Platform detection** and error handling
- **Modular design** for future extensibility

## Project Structure

```
puppet-workstation-config/
├── manifests/           # Main Puppet manifests
├── modules/             # Custom Puppet modules
├── data/               # Hiera data files
├── scripts/            # Runner and utility scripts
├── config/             # Configuration files
├── docs/               # Documentation
└── README.md           # This file
```

## Quick Start

### Prerequisites

- Administrator/root privileges for package installation
- Internet connection for downloading packages
- **Windows**: Windows 10 (version 1809 or later) or Windows 11 with winget
- **Linux**: Supported distributions: Ubuntu, Debian, CentOS, RHEL, Fedora

**Note**: Puppet will be automatically installed if not present on the system.

### Installation

1. Clone or download this project to your workstation
2. Navigate to the project directory
3. Run the appropriate setup script for your platform:

**Windows (PowerShell as Administrator):**
```powershell
.\scripts\setup-windows.ps1
```

**Linux (as root or with sudo):**
```bash
sudo ./scripts/setup-linux.sh
```

### Manual Execution

You can also run Puppet manually:

```bash
# Apply the main configuration
puppet apply --modulepath=modules manifests/site.pp

# Apply with specific data
puppet apply --modulepath=modules --hiera_config=config/hiera.yaml manifests/site.pp
```

### Validation

Before running the configuration, you can validate the project:

**Windows (PowerShell):**
```powershell
.\scripts\validate-project.ps1
```

**Linux:**
```bash
./scripts/validate-project.sh
```

The validation script checks:
- Project structure completeness
- Puppet manifest syntax
- YAML file syntax
- Script syntax and permissions

## Configuration

### Git Settings

Edit `data/common.yaml` to customize Git configuration:

```yaml
git::config:
  user.name: "Your Name"
  user.email: "your.email@example.com"
  core.editor: "code --wait"
```

### Platform-Specific Settings

Platform-specific configurations are in:
- `data/os/Windows.yaml` - Windows-specific settings
- `data/os/Debian.yaml` - Debian/Ubuntu-specific settings

## Extending the Project

### Adding New Software

1. Create a new module in `modules/your_software/`
2. Follow the existing module structure
3. Add platform-specific package names in data files
4. Include the module in `manifests/site.pp`

### Adding Platform Support

1. Add platform detection in `modules/platform/`
2. Create platform-specific data file in `data/os/`
3. Test with the new platform

## Best Practices

This project implements Puppet best practices:

- **Idempotent operations**: All operations can be run multiple times safely
- **Resource declarations**: Clear, declarative resource management
- **Module separation**: Each concern is separated into its own module
- **Data separation**: Configuration data is separated from code
- **Error handling**: Proper error handling and validation
- **Platform abstraction**: Clean abstraction between platforms

## Troubleshooting

### Common Issues

1. **Permission Denied**: Ensure you're running with appropriate privileges
2. **Package Manager Not Found**: 
   - Windows: Ensure winget is available (Windows 10 1809+ or Windows 11)
   - Linux: Ensure your distribution is supported
3. **Git Already Configured**: The configuration will update existing settings
4. **Puppet Installation Failed**: Check internet connectivity and package manager availability
5. **PATH Issues**: Restart your terminal after installation to refresh environment variables

### Installation Logs

If Puppet installation fails, check:
- Internet connectivity
- Package manager functionality
- System compatibility

### Logs

Check Puppet logs for detailed error information:
- Windows: `C:\ProgramData\PuppetLabs\puppet\var\log\`
- Linux: `/var/log/puppetlabs/puppet/`