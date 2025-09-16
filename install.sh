#!/usr/bin/env bash

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

INSTALL_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/wisp"
PLUGIN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }

main() {
    echo -e "${BLUE}🌟 WISP - Work Session Manager${NC}"
    echo -e "${BLUE}================================${NC}"
    echo

    if ! command -v bash >/dev/null 2>&1; then
        print_error "bash is required but not installed"
        exit 1
    fi

    if ! command -v tmux >/dev/null 2>&1; then
        print_warning "tmux not found - tmux integration will not be available"
        TMUX_AVAILABLE=false
    else
        TMUX_AVAILABLE=true
        print_success "tmux found"
    fi

    print_info "Installing wisp CLI..."
    mkdir -p "$INSTALL_DIR"
    cp "$PLUGIN_DIR/bin/wisp" "$INSTALL_DIR/wisp"
    cp "$PLUGIN_DIR/scripts/wisp-format.sh" "$INSTALL_DIR/wisp-format"
    chmod +x "$INSTALL_DIR/wisp" "$INSTALL_DIR/wisp-format"
    print_success "wisp CLI installed to $INSTALL_DIR"

    print_info "Setting up format templates..."
    mkdir -p "$CONFIG_DIR/formats"
    cp "$PLUGIN_DIR/formats/"*.sh "$CONFIG_DIR/formats/"
    chmod +x "$CONFIG_DIR/formats/"*.sh
    print_success "Format templates installed to $CONFIG_DIR/formats"

    if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
        print_warning "$INSTALL_DIR is not in your PATH"
        echo
        print_info "Add the following to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
        echo -e "${YELLOW}export PATH=\"\$PATH:$INSTALL_DIR\"${NC}"
        echo
        PATH_OK=false
    else
        print_success "$INSTALL_DIR is already in PATH"
        PATH_OK=true
    fi

    if [ "$TMUX_AVAILABLE" = true ]; then
        print_info "TMux integration available. Add to your tmux.conf:"
        echo -e "${YELLOW}set -g status-right \"#(wisp-format tmux)#[fg=default,bg=default]\"${NC}"
        echo -e "${YELLOW}bind m run-shell \"wisp toggle\"${NC}"
        echo -e "${YELLOW}bind M run-shell \"wisp-menu\"${NC}"
        echo -e "${YELLOW}bind _ run-shell \"wisp stop\"${NC}"
        echo
        print_info "Or use as TPM plugin:"
        echo -e "${YELLOW}set -g @plugin 'saravenpi/wisp'${NC}"
        echo
    fi

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
    echo "Sessions are logged to ~/.wisp.yml"
    echo

    print_success "Installation complete!"

    if [ "$PATH_OK" = false ]; then
        print_warning "Please add $INSTALL_DIR to your PATH and restart your shell"
    fi
}

case "${1:-}" in
    "--help"|"-h")
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