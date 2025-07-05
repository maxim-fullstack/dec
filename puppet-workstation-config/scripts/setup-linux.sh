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
    if ! command -v puppet &> /dev/null; then
        log_error "Puppet is not installed or not in PATH"
        log_info "Please install Puppet and try again"
        log_info "Installation instructions: https://puppet.com/docs/puppet/latest/install_puppet.html"
        exit 1
    fi
    
    local puppet_version
    puppet_version=$(puppet --version)
    log_info "Found Puppet version: $puppet_version"
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
    check_puppet
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
        echo "  - Puppet must be installed"
        echo "  - Script must be run with root/sudo privileges"
        exit 0
        ;;
    *)
        main
        ;;
esac
