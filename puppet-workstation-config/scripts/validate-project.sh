#!/bin/bash
#
# Validation Script for Puppet Workstation Configuration
# This script validates syntax and style of all project files
#

set -euo pipefail

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Validate Puppet syntax
validate_puppet_syntax() {
    log_info "Validating Puppet manifest syntax..."
    
    # Check for Puppet in common locations
    local puppet_cmd=""
    if command -v puppet >/dev/null 2>&1; then
        puppet_cmd="puppet"
    elif [[ -x "/opt/puppetlabs/bin/puppet" ]]; then
        puppet_cmd="/opt/puppetlabs/bin/puppet"
        log_info "Using Puppet from: /opt/puppetlabs/bin/puppet"
    else
        log_warning "Puppet not found, skipping syntax validation"
        log_info "Install Puppet to enable syntax validation"
        return 0
    fi
    
    local errors=0
    
    # Find all .pp files and validate them
    while IFS= read -r -d '' file; do
        log_info "Checking: $file"
        if ! "$puppet_cmd" parser validate "$file"; then
            log_error "Syntax error in: $file"
            ((errors++))
        fi
    done < <(find "$PROJECT_ROOT" -name "*.pp" -print0)
    
    if [[ $errors -eq 0 ]]; then
        log_success "All Puppet manifests have valid syntax"
        return 0
    else
        log_error "Found $errors syntax errors in Puppet manifests"
        return 1
    fi
}

# Validate YAML syntax
validate_yaml_syntax() {
    log_info "Validating YAML file syntax..."
    
    local errors=0
    local yaml_files_found=false
    
    # Find all .yaml and .yml files
    while IFS= read -r -d '' file; do
        yaml_files_found=true
        log_info "Checking: $file"
        
        # Try different YAML validators
        if command_exists yamllint; then
            if ! yamllint "$file"; then
                log_error "YAML syntax error in: $file"
                ((errors++))
            fi
        elif command_exists python3; then
            if ! python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null; then
                log_error "YAML syntax error in: $file"
                ((errors++))
            fi
        elif command_exists python; then
            if ! python -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null; then
                log_error "YAML syntax error in: $file"
                ((errors++))
            fi
        else
            log_warning "No YAML validator found, skipping YAML validation"
            return 0
        fi
    done < <(find "$PROJECT_ROOT" -name "*.yaml" -o -name "*.yml" -print0)
    
    if [[ "$yaml_files_found" == false ]]; then
        log_warning "No YAML files found"
        return 0
    fi
    
    if [[ $errors -eq 0 ]]; then
        log_success "All YAML files have valid syntax"
        return 0
    else
        log_error "Found $errors syntax errors in YAML files"
        return 1
    fi
}

# Validate project structure
validate_project_structure() {
    log_info "Validating project structure..."
    
    local required_files=(
        "$PROJECT_ROOT/manifests/site.pp"
        "$PROJECT_ROOT/config/hiera.yaml"
        "$PROJECT_ROOT/config/puppet.conf"
        "$PROJECT_ROOT/data/common.yaml"
        "$PROJECT_ROOT/modules/platform/manifests/init.pp"
        "$PROJECT_ROOT/modules/git/manifests/init.pp"
        "$PROJECT_ROOT/modules/git/manifests/install.pp"
        "$PROJECT_ROOT/modules/git/manifests/config.pp"
        "$PROJECT_ROOT/scripts/setup-linux.sh"
        "$PROJECT_ROOT/scripts/setup-windows.ps1"
    )
    
    local required_dirs=(
        "$PROJECT_ROOT/manifests"
        "$PROJECT_ROOT/modules"
        "$PROJECT_ROOT/data"
        "$PROJECT_ROOT/config"
        "$PROJECT_ROOT/scripts"
        "$PROJECT_ROOT/docs"
    )
    
    local errors=0
    
    # Check required files
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            log_error "Required file missing: $file"
            ((errors++))
        fi
    done
    
    # Check required directories
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            log_error "Required directory missing: $dir"
            ((errors++))
        fi
    done
    
    if [[ $errors -eq 0 ]]; then
        log_success "Project structure validation passed"
        return 0
    else
        log_error "Project structure validation failed with $errors errors"
        return 1
    fi
}

# Validate shell scripts
validate_shell_scripts() {
    log_info "Validating shell script syntax..."
    
    if ! command_exists bash; then
        log_warning "Bash not found, skipping shell script validation"
        return 0
    fi
    
    local errors=0
    
    # Find all .sh files and validate them
    while IFS= read -r -d '' file; do
        log_info "Checking: $file"
        if ! bash -n "$file"; then
            log_error "Syntax error in shell script: $file"
            ((errors++))
        fi
    done < <(find "$PROJECT_ROOT" -name "*.sh" -print0)
    
    if [[ $errors -eq 0 ]]; then
        log_success "All shell scripts have valid syntax"
        return 0
    else
        log_error "Found $errors syntax errors in shell scripts"
        return 1
    fi
}

# Check file permissions
check_file_permissions() {
    log_info "Checking file permissions..."
    
    local warnings=0
    
    # Check that shell scripts are executable
    while IFS= read -r -d '' file; do
        if [[ ! -x "$file" ]]; then
            log_warning "Shell script is not executable: $file"
            log_info "Run: chmod +x '$file'"
            ((warnings++))
        fi
    done < <(find "$PROJECT_ROOT" -name "*.sh" -print0)
    
    if [[ $warnings -eq 0 ]]; then
        log_success "File permissions check passed"
    else
        log_warning "Found $warnings permission warnings"
    fi
    
    return 0
}

# Main validation function
main() {
    log_info "Starting validation of Puppet Workstation Configuration"
    log_info "Project root: $PROJECT_ROOT"
    echo
    
    local total_errors=0
    
    # Run all validations
    validate_project_structure || ((total_errors++))
    echo
    
    validate_puppet_syntax || ((total_errors++))
    echo
    
    validate_yaml_syntax || ((total_errors++))
    echo
    
    validate_shell_scripts || ((total_errors++))
    echo
    
    check_file_permissions
    echo
    
    # Summary
    if [[ $total_errors -eq 0 ]]; then
        log_success "All validations passed! Project is ready to use."
        echo
        log_info "To run the configuration:"
        log_info "  Linux:   sudo ./scripts/setup-linux.sh"
        log_info "  Windows: .\scripts\setup-windows.ps1 (as Administrator)"
    else
        log_error "Validation failed with $total_errors errors"
        log_info "Please fix the errors above before using the project"
        exit 1
    fi
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [--help]"
        echo ""
        echo "This script validates the syntax and structure of the Puppet"
        echo "workstation configuration project."
        echo ""
        echo "Options:"
        echo "  --help, -h    Show this help message"
        echo ""
        echo "Validations performed:"
        echo "  - Project structure completeness"
        echo "  - Puppet manifest syntax"
        echo "  - YAML file syntax"
        echo "  - Shell script syntax"
        echo "  - File permissions"
        exit 0
        ;;
    *)
        main
        ;;
esac
