#!/bin/bash
# AppleScript Utilities Setup Script
# This script sets up the shell functions for easy AppleScript management

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FUNCTIONS_FILE="$SCRIPT_DIR/shell_functions.sh"

# Cross-shell compatible read function
prompt_user() {
    local prompt="$1"
    local default="$2"
    local response

    if [ -n "$ZSH_VERSION" ]; then
        # zsh version
        echo -n "$prompt"
        read response
    else
        # bash version
        read -p "$prompt" response
    fi

    # Use default if empty
    if [ -z "$response" ]; then
        response="$default"
    fi

    echo "$response"
}

# Detect shell and config file
if [ -n "$ZSH_VERSION" ]; then
    # Try to find the correct zsh config file
    if [ -f "$HOME/.zshrc" ]; then
        SHELL_RC="$HOME/.zshrc"
    elif [ -f "$HOME/.zsh/.zshrc" ]; then
        SHELL_RC="$HOME/.zsh/.zshrc"
    else
        SHELL_RC="$HOME/.zshrc"  # Default, will be created if it doesn't exist
    fi
    SHELL_NAME="zsh"
elif [ -n "$BASH_VERSION" ]; then
    if [ -f "$HOME/.bash_profile" ]; then
        SHELL_RC="$HOME/.bash_profile"
    elif [ -f "$HOME/.bashrc" ]; then
        SHELL_RC="$HOME/.bashrc"
    else
        SHELL_RC="$HOME/.bash_profile"  # Default for macOS
    fi
    SHELL_NAME="bash"
else
    echo "Unsupported shell. Please manually source the functions file."
    echo "Add this line to your shell config:"
    echo "source \"$FUNCTIONS_FILE\""
    exit 1
fi

echo "🍎 AppleScript Utilities Setup"
echo "================================"
echo "Shell detected: $SHELL_NAME"
echo "Config file: $SHELL_RC"
echo ""

# Create config file if it doesn't exist
if [ ! -f "$SHELL_RC" ]; then
    echo "Creating config file: $SHELL_RC"
    touch "$SHELL_RC"
fi

# Check if functions are already sourced
if grep -q "shell_functions.sh" "$SHELL_RC" 2>/dev/null; then
    echo "⚠️  AppleScript utilities appear to already be set up in $SHELL_RC"
    response=$(prompt_user "Do you want to update the setup? (y/N): " "N")
    if [[ ! $response =~ ^[Yy]$ ]]; then
        echo "Setup cancelled."
        exit 0
    fi

    # Remove old entry
    if command -v gsed >/dev/null 2>&1; then
        gsed -i '/# AppleScript Utilities/,/shell_functions\.sh/d' "$SHELL_RC"
    else
        sed -i '' '/# AppleScript Utilities/,/shell_functions\.sh/d' "$SHELL_RC"
    fi
fi

# Add source command to shell config
echo "" >> "$SHELL_RC"
echo "# AppleScript Utilities" >> "$SHELL_RC"
echo "if [ -f \"$FUNCTIONS_FILE\" ]; then" >> "$SHELL_RC"
echo "    source \"$FUNCTIONS_FILE\"" >> "$SHELL_RC"
echo "fi" >> "$SHELL_RC"

echo "✅ Setup complete!"
echo ""
echo "To start using the utilities:"
echo "  1. Restart your terminal, or"
echo "  2. Run: source $SHELL_RC"
echo ""
echo "Available commands after setup:"
echo "  • run_applescript <file>"
echo "  • check_applescript <file>"
echo "  • applescript_to_app <file> [name]"
echo "  • convert_heic"
echo "  • list_applescripts"
echo "  • applescript_help"
echo ""

# Ask if they want to source immediately
response=$(prompt_user "Would you like to source the functions now? (Y/n): " "Y")
if [[ $response =~ ^[Nn]$ ]]; then
    echo "You can source them later with: source $SHELL_RC"
else
    source "$FUNCTIONS_FILE"
    echo "✅ Functions are now available in this session!"
    echo ""
    echo "Try running: applescript_help"
fi
