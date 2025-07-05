#!/bin/bash
#
# Manual Puppet Runner Script
# Use this script to run Puppet manually with custom options
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Default values
MANIFEST_FILE="$PROJECT_ROOT/manifests/site.pp"
MODULE_PATH="$PROJECT_ROOT/modules"
HIERA_CONFIG="$PROJECT_ROOT/config/hiera.yaml"
VERBOSE=false
DRY_RUN=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

show_help() {
    cat << EOF
Manual Puppet Runner Script

Usage: $0 [OPTIONS]

Options:
    -h, --help          Show this help message
    -v, --verbose       Enable verbose output
    -n, --noop          Perform a dry run (no changes made)
    -m, --manifest FILE Use custom manifest file
    --module-path PATH  Use custom module path
    --hiera-config FILE Use custom Hiera configuration

Examples:
    $0                          # Run with defaults
    $0 --verbose --noop         # Dry run with verbose output
    $0 -m custom.pp             # Use custom manifest

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -n|--noop)
            DRY_RUN=true
            shift
            ;;
        -m|--manifest)
            MANIFEST_FILE="$2"
            shift 2
            ;;
        --module-path)
            MODULE_PATH="$2"
            shift 2
            ;;
        --hiera-config)
            HIERA_CONFIG="$2"
            shift 2
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Validate files exist
if [[ ! -f "$MANIFEST_FILE" ]]; then
    log_error "Manifest file not found: $MANIFEST_FILE"
    exit 1
fi

if [[ ! -d "$MODULE_PATH" ]]; then
    log_error "Module path not found: $MODULE_PATH"
    exit 1
fi

if [[ ! -f "$HIERA_CONFIG" ]]; then
    log_error "Hiera config not found: $HIERA_CONFIG"
    exit 1
fi

# Build Puppet command
PUPPET_CMD=(
    puppet apply
    --modulepath="$MODULE_PATH"
    --hiera_config="$HIERA_CONFIG"
    --detailed-exitcodes
)

if [[ "$VERBOSE" == "true" ]]; then
    PUPPET_CMD+=(--verbose)
fi

if [[ "$DRY_RUN" == "true" ]]; then
    PUPPET_CMD+=(--noop)
    log_info "Performing dry run (no changes will be made)"
fi

PUPPET_CMD+=("$MANIFEST_FILE")

# Change to project root
cd "$PROJECT_ROOT"

log_info "Running Puppet with command: ${PUPPET_CMD[*]}"

# Execute Puppet
"${PUPPET_CMD[@]}"
exit_code=$?

case $exit_code in
    0)
        if [[ "$DRY_RUN" == "true" ]]; then
            log_success "Dry run completed - no changes would be made"
        else
            log_success "Puppet run completed successfully - no changes made"
        fi
        ;;
    2)
        if [[ "$DRY_RUN" == "true" ]]; then
            log_success "Dry run completed - changes would be made"
        else
            log_success "Puppet run completed successfully - changes were made"
        fi
        ;;
    4)
        log_error "Puppet run completed with failures"
        ;;
    6)
        log_error "Puppet run completed with changes and failures"
        ;;
    *)
        log_error "Puppet run failed with exit code: $exit_code"
        ;;
esac

exit $exit_code
