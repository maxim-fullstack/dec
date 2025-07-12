# DEC - Desired Environment Configuration

DEC (Desired Environment Configuration) is a cross-platform toolkit for reproducible workstation configuration using Ansible. It provides a declarative approach to setting up and maintaining consistent development environments across Windows 10/11 and Ubuntu/Debian systems.

## 🚀 Quick Start

### Prerequisites
- **Windows**: PowerShell 5.1+ (Run as Administrator)
- **Linux**: Bash shell with sudo access

### One-Command Setup

**Windows:**
```powershell
# Clone and setup
git clone <your-repo-url> dec
cd dec
.\setup.ps1
```

**Linux:**
```bash
# Clone and setup
git clone <your-repo-url> dec
cd dec
chmod +x setup.sh
./setup.sh
```

## 📁 Project Structure

```
DEC/
├── ansible.cfg              # Ansible configuration
├── config.example.yml       # Example configuration file
├── requirements.txt         # Python dependencies
├── setup.ps1               # Windows setup script
├── setup.sh                # Linux setup script
├── quick-setup.ps1         # Windows quick setup
├── quick-setup.sh          # Linux quick setup
├── group_vars/
│   └── all.yml             # Global variables
├── inventory/
│   └── hosts.yml           # Ansible inventory
├── playbooks/
│   └── main.yml            # Main orchestration playbook
├── roles/
│   ├── git-setup/          # Git installation and configuration
│   ├── theme-config/       # Desktop theme configuration
│   ├── dotfiles-manager/   # yadm integration for dotfiles
│   ├── package-manager/    # Cross-platform package management
│   └── system-config/      # System-level configuration
└── scripts/
    ├── validate.sh         # Linux validation script
    └── validate.ps1        # Windows validation script
```

## ⚙️ Configuration

1. **Copy the example configuration:**
   ```bash
   cp config.example.yml config.yml
   ```

2. **Edit config.yml with your preferences:**
   ```yaml
   # User Information
   user:
     name: "Your Name"
     email: "your.email@example.com"

   # Git Configuration
   git:
     user_name: "{{ user.name }}"
     user_email: "{{ user.email }}"
     aliases:
       st: "status"
       co: "checkout"
       br: "branch"
       # ... more aliases

   # Theme Configuration
   theme:
     dark_mode: true

   # Package Installation
   packages:
     common:
       - git
       - curl
       - vim
     windows:
       - Microsoft.WindowsTerminal
       - Microsoft.VisualStudioCode
     linux:
       - htop
       - neofetch

   # Dotfiles Management
   dotfiles:
     enabled: true
     repository: "git@github.com:yourusername/dotfiles.git"
   ```

## 🎯 Features

### ✅ Cross-Platform Package Management
- **Windows**: winget
- **Linux**: apt

### ✅ Git Setup
- Automatic Git installation
- User configuration (name, email)
- SSH key generation
- Git aliases setup

### ✅ Desktop Theme Configuration
- **Windows**: Dark theme, accent colors, Windows Terminal themes
- **Linux**: GTK themes, GNOME preferences, terminal themes

### ✅ Dotfiles Integration
- yadm (Yet Another Dotfiles Manager) installation
- Repository cloning and initialization
- Bootstrap script execution

### ✅ System Configuration
- Timezone setup
- Automatic updates configuration
- Firewall settings
- Performance optimizations

## 🔧 Usage

### Basic Setup
```bash
# Run full configuration
./setup.sh

# Windows
.\setup.ps1
```

### Advanced Usage

**Run specific roles only:**
```bash
# Linux
./setup.sh --tags git,theme

# Windows
.\setup.ps1 -Tags "git,theme"
```

**Check mode (dry run):**
```bash
# Linux
./setup.sh --check

# Windows
.\setup.ps1 -CheckMode
```

**Verbose output:**
```bash
# Linux
./setup.sh --verbose

# Windows
.\setup.ps1 -Verbose
```

### Validation

Check your configuration after setup:
```bash
# Linux
chmod +x scripts/validate.sh
./scripts/validate.sh

# Windows
.\scripts\validate.ps1
```

## 🏷️ Available Tags

- `basic` - Essential configuration (git, packages, theme)
- `git` - Git installation and configuration
- `theme` - Desktop theme configuration
- `packages` - Package installation
- `dotfiles` - Dotfiles management
- `system` - System configuration

## 🌐 Remote Execution

For remote workstation setup:

1. **Update inventory/hosts.yml:**
   ```yaml
   all:
     hosts:
       workstation1:
         ansible_host: 192.168.1.100
         ansible_user: username
   ```

2. **Run against remote host:**
   ```bash
   ansible-playbook playbooks/main.yml -i inventory/hosts.yml --extra-vars @config.yml
   ```

## 🔒 Security Considerations

- Store sensitive configuration in Ansible Vault
- Use SSH keys for Git authentication
- Review package lists before installation
- Test in a VM before running on production systems

## 🛠️ Customization

### Adding New Roles

1. Create role directory: `roles/my-role/`
2. Add tasks: `roles/my-role/tasks/main.yml`
3. Include in main playbook: `playbooks/main.yml`

### Platform-Specific Tasks

Each role supports platform-specific tasks:
- `tasks/linux.yml` - Linux-specific tasks
- `tasks/win32nt.yml` - Windows-specific tasks
- `tasks/main.yml` - Common tasks

### Example Role Structure
```
roles/my-role/
├── tasks/
│   ├── main.yml     # Include platform-specific tasks
│   ├── linux.yml    # Linux-specific tasks
│   └── win32nt.yml  # Windows-specific tasks
├── vars/
│   └── main.yml     # Role variables
└── defaults/
    └── main.yml     # Default variables
```

## 🐛 Troubleshooting

### Common Issues

**Windows: Execution Policy Error**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Linux: Permission Denied**
```bash
chmod +x setup.sh
sudo ./setup.sh
```

**Ansible Not Found**
```bash
# Linux
pip3 install --user ansible

# Windows
pip install ansible
```

### Debug Mode

Run with maximum verbosity:
```bash
# Linux
./setup.sh -v -v -v

# Windows
.\setup.ps1 -Verbose
```

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Test your changes on both Windows and Linux
4. Submit a pull request

## 📚 Documentation

- [Ansible Documentation](https://docs.ansible.com/)
- [yadm Documentation](https://yadm.io/)
- [Winget Documentation](https://docs.microsoft.com/en-us/windows/package-manager/winget/)

---

**DEC - Declarative, Cross-platform, Complete workstation configuration**
