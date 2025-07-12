#!/bin/bash
# DEC Validation Script - Check system state and configuration

set -euo pipefail

# Color functions
red() { echo -e "\033[31m$1\033[0m"; }
green() { echo -e "\033[32m$1\033[0m"; }
yellow() { echo -e "\033[33m$1\033[0m"; }
cyan() { echo -e "\033[36m$1\033[0m"; }
blue() { echo -e "\033[34m$1\033[0m"; }

ISSUES=0
WARNINGS=0

check_result() {
    local status=$1
    local message=$2
    local warning=${3:-false}
    
    if [[ $status -eq 0 ]]; then
        green "✓ $message"
    else
        if [[ $warning == "true" ]]; then
            yellow "⚠ $message"
            ((WARNINGS++))
        else
            red "✗ $message"
            ((ISSUES++))
        fi
    fi
}

cyan "=== DEC Configuration Validation ==="

# Check if Git is installed and configured
blue "Checking Git configuration..."
if command -v git >/dev/null 2>&1; then
    check_result 0 "Git is installed ($(git --version | cut -d' ' -f3))"
    
    git_name=$(git config --global user.name 2>/dev/null || echo "")
    git_email=$(git config --global user.email 2>/dev/null || echo "")
    
    if [[ -n "$git_name" ]]; then
        check_result 0 "Git user name configured: $git_name"
    else
        check_result 1 "Git user name not configured"
    fi
    
    if [[ -n "$git_email" ]]; then
        check_result 0 "Git user email configured: $git_email"
    else
        check_result 1 "Git user email not configured"
    fi
else
    check_result 1 "Git is not installed"
fi

# Check SSH key
blue "Checking SSH configuration..."
if [[ -f "$HOME/.ssh/id_ed25519" ]] || [[ -f "$HOME/.ssh/id_rsa" ]]; then
    check_result 0 "SSH key found"
else
    check_result 1 "No SSH key found" true
fi

# Check yadm if dotfiles are enabled
blue "Checking dotfiles management..."
if command -v yadm >/dev/null 2>&1; then
    check_result 0 "yadm is installed"
    if yadm status >/dev/null 2>&1; then
        check_result 0 "yadm repository initialized"
    else
        check_result 1 "yadm repository not initialized" true
    fi
else
    check_result 1 "yadm is not installed" true
fi

# Check common packages
blue "Checking common packages..."
common_packages=("curl" "wget" "vim" "tree")
for pkg in "${common_packages[@]}"; do
    if command -v "$pkg" >/dev/null 2>&1; then
        check_result 0 "$pkg is installed"
    else
        check_result 1 "$pkg is not installed" true
    fi
done

# Check desktop theme (Linux)
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    blue "Checking desktop theme..."
    if command -v gsettings >/dev/null 2>&1; then
        theme=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null || echo "unknown")
        if [[ "$theme" == *"dark"* ]] || [[ "$theme" == *"Dark"* ]]; then
            check_result 0 "Dark theme is active: $theme"
        else
            check_result 1 "Dark theme may not be active: $theme" true
        fi
    else
        check_result 1 "Cannot check desktop theme (gsettings not available)" true
    fi
fi

# Summary
cyan "=== Validation Summary ==="
if [[ $ISSUES -eq 0 ]]; then
    green "✓ All critical checks passed!"
else
    red "✗ $ISSUES critical issue(s) found"
fi

if [[ $WARNINGS -gt 0 ]]; then
    yellow "⚠ $WARNINGS warning(s) found"
fi

exit $ISSUES
