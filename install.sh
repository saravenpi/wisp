#!/usr/bin/env bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Installation paths
INSTALL_DIR="$HOME/.local/bin"
PLUGIN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

print_header() {
    echo -e "${BLUE}🌟 WISP - Work Session Manager${NC}"
    echo -e "${BLUE}================================${NC}"
    echo
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

check_dependencies() {
    print_info "Checking dependencies..."

    # Check for bash
    if ! command -v bash >/dev/null 2>&1; then
        print_error "bash is required but not installed"
        exit 1
    fi

    # Check for tmux (optional)
    if ! command -v tmux >/dev/null 2>&1; then
        print_warning "tmux not found - tmux integration will not be available"
        TMUX_AVAILABLE=false
    else
        TMUX_AVAILABLE=true
        print_success "tmux found"
    fi

    print_success "Dependencies checked"
}

install_cli() {
    print_info "Installing wisp CLI..."

    # Create install directory if it doesn't exist
    mkdir -p "$INSTALL_DIR"

    # Copy wisp binary
    cp "$PLUGIN_DIR/bin/wisp" "$INSTALL_DIR/wisp"
    chmod +x "$INSTALL_DIR/wisp"

    # Copy wisp-format script
    cp "$PLUGIN_DIR/scripts/wisp-format.sh" "$INSTALL_DIR/wisp-format"
    chmod +x "$INSTALL_DIR/wisp-format"

    print_success "wisp CLI installed to $INSTALL_DIR"
}

setup_formats() {
    print_info "Setting up format templates..."

    local config_dir="$HOME/.config/wisp"
    mkdir -p "$config_dir/formats"

    # Copy format files
    cp "$PLUGIN_DIR/formats/"*.sh "$config_dir/formats/"
    chmod +x "$config_dir/formats/"*.sh

    print_success "Format templates installed to $config_dir/formats"
}

check_path() {
    if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
        print_warning "$INSTALL_DIR is not in your PATH"
        echo
        print_info "Add the following to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
        echo -e "${YELLOW}export PATH=\"\$PATH:$INSTALL_DIR\"${NC}"
        echo
        return 1
    else
        print_success "$INSTALL_DIR is already in PATH"
        return 0
    fi
}

install_tmux_plugin() {
    if [ "$TMUX_AVAILABLE" = false ]; then
        print_warning "Skipping tmux plugin installation (tmux not available)"
        return
    fi

    print_info "TMux plugin setup..."
    echo
    print_info "To use wisp as a tmux plugin, add this to your tmux.conf:"
    echo -e "${YELLOW}set -g @plugin 'path/to/wisp'${NC}"
    echo
    print_info "Or manually source the plugin:"
    echo -e "${YELLOW}run-shell '$PLUGIN_DIR/wisp.tmux'${NC}"
    echo
    print_info "Key bindings (customizable):"
    echo -e "  ${YELLOW}prefix + m${NC}  - Toggle work session"
    echo -e "  ${YELLOW}prefix + M${NC}  - Show wisp menu"
    echo -e "  ${YELLOW}prefix + _${NC}  - Stop current session"
    echo
}

show_usage() {
    echo -e "${BLUE}🚀 Getting Started${NC}"
    echo -e "${BLUE}==================${NC}"
    echo
    echo "Basic commands:"
    echo -e "  ${YELLOW}wisp start${NC}       - Start a 25-minute work session"
    echo -e "  ${YELLOW}wisp start 45${NC}    - Start a 45-minute work session"
    echo -e "  ${YELLOW}wisp toggle${NC}      - Toggle session (start/pause/resume)"
    echo -e "  ${YELLOW}wisp stop${NC}        - Stop current session"
    echo -e "  ${YELLOW}wisp stats${NC}       - Show work statistics"
    echo -e "  ${YELLOW}wisp history${NC}     - Show session history"
    echo
    echo "Status formatting:"
    echo -e "  ${YELLOW}wisp-format${NC}           - Default format"
    echo -e "  ${YELLOW}wisp-format tmux${NC}      - For tmux status bar"
    echo -e "  ${YELLOW}wisp-format minimal${NC}   - Minimal output"
    echo
    echo "Sessions are logged to ~/.wisp.yml"
    echo
}

main() {
    print_header

    check_dependencies
    install_cli
    setup_formats

    local path_ok=true
    check_path || path_ok=false

    install_tmux_plugin

    echo
    print_success "Installation complete!"
    echo

    if [ "$path_ok" = false ]; then
        print_warning "Please add $INSTALL_DIR to your PATH and restart your shell"
        echo
    fi

    show_usage
}

# Handle command line arguments
case "${1:-}" in
    "--help"|"-h")
        print_header
        echo "Usage: $0 [--help]"
        echo
        echo "Installs wisp CLI and sets up configuration files."
        echo "The CLI will be installed to $INSTALL_DIR"
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac