#!/bin/bash
#
# Linux/macOS Puppet Masterless Runner Script
# This script applies the Puppet configuration in masterless mode
#

set -euo pipefail

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
MANIFEST_FILE="$PROJECT_ROOT/manifests/site.pp"
MODULE_PATH="$PROJECT_ROOT/modules"
HIERA_CONFIG="$PROJECT_ROOT/config/hiera.yaml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root or with sudo
check_privileges() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root or with sudo privileges"
        log_info "Please run: sudo $0"
        exit 1
    fi
}

# Check if Puppet is installed
check_puppet() {
    if command -v puppet &> /dev/null; then
        local puppet_version
        puppet_version=$(puppet --version)
        log_info "Found Puppet version: $puppet_version"
        return 0
    fi
    
    log_warning "Puppet is not installed"
    return 1
}

# Install Puppet on Linux
install_puppet() {
    log_info "Installing Puppet..."
    
    # Detect the Linux distribution
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        local distro="$ID"
        local version="$VERSION_ID"
    else
        log_error "Cannot detect Linux distribution"
        return 1
    fi
    
    case "$distro" in
        ubuntu|debian)
            log_info "Installing Puppet on Debian/Ubuntu..."
            
            # Download and install Puppet repository
            local puppet_release_url
            if [[ "$distro" == "ubuntu" ]]; then
                puppet_release_url="https://apt.puppetlabs.com/puppet7-release-${ID}-${VERSION_CODENAME}.deb"
            else
                # For Debian, use the version number
                local debian_version
                case "$version" in
                    "10"*) debian_version="buster" ;;
                    "11"*) debian_version="bullseye" ;;
                    "12"*) debian_version="bookworm" ;;
                    *) debian_version="bullseye" ;;  # Default fallback
                esac
                puppet_release_url="https://apt.puppetlabs.com/puppet7-release-${debian_version}.deb"
            fi
            
            # Download and install the release package
            local temp_file="/tmp/puppet-release.deb"
            if wget -O "$temp_file" "$puppet_release_url" 2>/dev/null; then
                if dpkg -i "$temp_file" &>/dev/null; then
                    log_info "Puppet repository added successfully"
                else
                    log_error "Failed to install Puppet repository package"
                    return 1
                fi
                rm -f "$temp_file"
            else
                log_error "Failed to download Puppet repository package"
                return 1
            fi
            
            # Update package cache
            log_info "Updating package cache..."
            if apt-get update &>/dev/null; then
                log_info "Package cache updated"
            else
                log_warning "Failed to update package cache, continuing anyway..."
            fi
            
            # Install Puppet
            log_info "Installing Puppet agent..."
            if apt-get install -y puppet-agent &>/dev/null; then
                log_success "Puppet installed successfully"
                
                # Add Puppet to PATH for this session
                export PATH="/opt/puppetlabs/bin:$PATH"
                
                # Verify installation
                if command -v puppet &> /dev/null; then
                    local puppet_version
                    puppet_version=$(puppet --version)
                    log_success "Puppet installation verified: $puppet_version"
                    return 0
                else
                    log_warning "Puppet installed but not immediately available in PATH"
                    log_info "Added /opt/puppetlabs/bin to PATH for this session"
                    return 0
                fi
            else
                log_error "Failed to install Puppet agent"
                return 1
            fi
            ;;
        centos|rhel|fedora)
            log_info "Installing Puppet on Red Hat family..."
            
            # Determine package manager and release URL
            local pkg_manager
            local puppet_release_url
            
            if command -v dnf &>/dev/null; then
                pkg_manager="dnf"
            elif command -v yum &>/dev/null; then
                pkg_manager="yum"
            else
                log_error "No suitable package manager found (dnf or yum)"
                return 1
            fi
            
            # Set release URL based on distribution
            case "$distro" in
                fedora)
                    puppet_release_url="https://yum.puppetlabs.com/puppet7/puppet7-release-fedora-${version}.noarch.rpm"
                    ;;
                centos)
                    puppet_release_url="https://yum.puppetlabs.com/puppet7/puppet7-release-el-${version}.noarch.rpm"
                    ;;
                rhel)
                    puppet_release_url="https://yum.puppetlabs.com/puppet7/puppet7-release-el-${version}.noarch.rpm"
                    ;;
            esac
            
            # Install Puppet repository
            if $pkg_manager install -y "$puppet_release_url" &>/dev/null; then
                log_info "Puppet repository added successfully"
            else
                log_error "Failed to install Puppet repository"
                return 1
            fi
            
            # Install Puppet
            log_info "Installing Puppet agent..."
            if $pkg_manager install -y puppet-agent &>/dev/null; then
                log_success "Puppet installed successfully"
                
                # Add Puppet to PATH for this session
                export PATH="/opt/puppetlabs/bin:$PATH"
                
                # Verify installation
                if command -v puppet &> /dev/null; then
                    local puppet_version
                    puppet_version=$(puppet --version)
                    log_success "Puppet installation verified: $puppet_version"
                    return 0
                else
                    log_warning "Puppet installed but not immediately available in PATH"
                    log_info "Added /opt/puppetlabs/bin to PATH for this session"
                    return 0
                fi
            else
                log_error "Failed to install Puppet agent"
                return 1
            fi
            ;;
        *)
            log_error "Unsupported Linux distribution: $distro"
            log_info "Please install Puppet manually from: https://puppet.com/docs/puppet/latest/install_puppet.html"
            return 1
            ;;
    esac
}

# Validate project structure
validate_project() {
    local required_files=(
        "$MANIFEST_FILE"
        "$HIERA_CONFIG"
        "$MODULE_PATH"
    )
    
    for file in "${required_files[@]}"; do
        if [[ ! -e "$file" ]]; then
            log_error "Required file/directory not found: $file"
            exit 1
        fi
    done
    
    log_success "Project structure validation passed"
}

# Run Puppet in masterless mode
run_puppet() {
    log_info "Starting Puppet masterless run..."
    
    # Change to project directory
    cd "$PROJECT_ROOT"
    
    # Build the Puppet command
    local puppet_cmd=(
        puppet apply
        --modulepath="$MODULE_PATH"
        --hiera_config="$HIERA_CONFIG"
        --detailed-exitcodes
        --verbose
        "$MANIFEST_FILE"
    )
    
    log_info "Executing: ${puppet_cmd[*]}"
    
    # Run Puppet and capture exit code
    local exit_code=0
    "${puppet_cmd[@]}" || exit_code=$?
    
    # Handle Puppet exit codes
    case $exit_code in
        0)
            log_success "Puppet run completed successfully - no changes made"
            ;;
        2)
            log_success "Puppet run completed successfully - changes were made"
            ;;
        4)
            log_warning "Puppet run completed with failures"
            return 1
            ;;
        6)
            log_warning "Puppet run completed with changes and failures"
            return 1
            ;;
        *)
            log_error "Puppet run failed with exit code: $exit_code"
            return 1
            ;;
    esac
}

# Main execution
main() {
    log_info "Starting Puppet Workstation Configuration"
    log_info "Project root: $PROJECT_ROOT"
    
    check_privileges
    
    # Check and install Puppet if needed
    if ! check_puppet; then
        log_info "Puppet not found, attempting automatic installation..."
        if ! install_puppet; then
            log_error "Puppet installation failed"
            exit 1
        fi
    fi
    
    validate_project
    
    if run_puppet; then
        log_success "Workstation configuration completed successfully!"
        log_info "You may need to restart your terminal or reload your shell profile"
        log_info "to use newly installed software."
    else
        log_error "Workstation configuration completed with errors"
        log_info "Check the output above for details"
        exit 1
    fi
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [--help]"
        echo ""
        echo "This script applies Puppet configuration in masterless mode to configure"
        echo "the workstation with Git and other development tools."
        echo ""
        echo "Options:"
        echo "  --help, -h    Show this help message"
        echo ""
        echo "Requirements:"
        echo "  - Script must be run with root/sudo privileges"
        echo "  - Internet connection for downloading packages"
        echo "  - Supported OS: Ubuntu, Debian, CentOS, RHEL, Fedora"
        echo ""
        echo "Note: Puppet will be automatically installed if not present."
        exit 0
        ;;
    *)
        main
        ;;
esac
