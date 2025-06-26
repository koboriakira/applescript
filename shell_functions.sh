#!/bin/bash
# AppleScript Utilities - Shell Functions
# Source this file in your shell profile to use these functions

# Function to run AppleScript files
run_applescript() {
    if [ $# -eq 0 ]; then
        echo "Usage: run_applescript <script_name.applescript>"
        return 1
    fi

    local script_path="$1"
    if [ ! -f "$script_path" ]; then
        echo "Error: AppleScript file '$script_path' not found"
        return 1
    fi

    echo "Running AppleScript: $script_path"
    osascript "$script_path"
}

# Function to compile and check AppleScript syntax
check_applescript() {
    if [ $# -eq 0 ]; then
        echo "Usage: check_applescript <script_name.applescript>"
        return 1
    fi

    local script_path="$1"
    if [ ! -f "$script_path" ]; then
        echo "Error: AppleScript file '$script_path' not found"
        return 1
    fi

    echo "Checking syntax for: $script_path"
    osacompile -c "$script_path" && echo "✓ Syntax OK" || echo "✗ Syntax Error"
}

# Function to convert AppleScript to app bundle
applescript_to_app() {
    if [ $# -lt 1 ]; then
        echo "Usage: applescript_to_app <script_name.applescript> [output_name]"
        return 1
    fi

    local script_path="$1"
    local output_name="${2:-${script_path%.*}}"

    if [ ! -f "$script_path" ]; then
        echo "Error: AppleScript file '$script_path' not found"
        return 1
    fi

    echo "Converting '$script_path' to application '$output_name.app'"
    osacompile -o "$output_name.app" "$script_path"

    if [ $? -eq 0 ]; then
        echo "✓ Successfully created: $output_name.app"
        echo "  You can now double-click to run or drag files onto it"
        # Make the app executable and add to dock if desired
        chmod +x "$output_name.app"
    else
        echo "✗ Error: Failed to create application"
        return 1
    fi
}

# Function to run HEIC to JPEG converter specifically
convert_heic() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local converter_script="$script_dir/convert_downloads_heic_to_jpeg.applescript"

    if [ -f "$converter_script" ]; then
        echo "🖼️  Running HEIC to JPEG converter..."
        osascript "$converter_script"
    else
        echo "Error: HEIC converter script not found at $converter_script"
        echo "Make sure you're in the correct directory or update the path"
        return 1
    fi
}

# Function to list all AppleScript files in current directory
list_applescripts() {
    echo "📋 AppleScript files in current directory:"
    local scripts=($(find . -name "*.applescript" -type f | sort))

    if [ ${#scripts[@]} -eq 0 ]; then
        echo "  No AppleScript files found"
        return 1
    fi

    for script in "${scripts[@]}"; do
        echo "  • ${script#./}"
    done
}

# Function to create a backup of AppleScript before modification
backup_applescript() {
    if [ $# -eq 0 ]; then
        echo "Usage: backup_applescript <script_name.applescript>"
        return 1
    fi

    local script_path="$1"
    if [ ! -f "$script_path" ]; then
        echo "Error: AppleScript file '$script_path' not found"
        return 1
    fi

    local backup_name="${script_path%.*}_backup_$(date +%Y%m%d_%H%M%S).applescript"
    cp "$script_path" "$backup_name"
    echo "✓ Backup created: $backup_name"
}

# Function to show AppleScript file info
applescript_info() {
    if [ $# -eq 0 ]; then
        echo "Usage: applescript_info <script_name.applescript>"
        return 1
    fi

    local script_path="$1"
    if [ ! -f "$script_path" ]; then
        echo "Error: AppleScript file '$script_path' not found"
        return 1
    fi

    echo "📄 AppleScript Info: $script_path"
    echo "   Size: $(du -h "$script_path" | cut -f1)"
    echo "   Modified: $(stat -f "%Sm" "$script_path")"
    echo "   Lines: $(wc -l < "$script_path")"

    # Check if it has drag-and-drop support
    if grep -q "on open" "$script_path"; then
        echo "   ✓ Supports drag & drop"
    else
        echo "   ✗ No drag & drop support"
    fi

    # Check syntax
    if osacompile -c "$script_path" 2>/dev/null; then
        echo "   ✓ Syntax valid"
    else
        echo "   ✗ Syntax errors"
    fi
}

# Help function
applescript_help() {
    echo "🍎 AppleScript Utilities - Available Functions:"
    echo ""
    echo "  run_applescript <file>          - Run an AppleScript file"
    echo "  check_applescript <file>        - Check syntax of AppleScript"
    echo "  applescript_to_app <file> [name] - Convert AppleScript to app"
    echo "  convert_heic                    - Run HEIC to JPEG converter"
    echo "  list_applescripts               - List all .applescript files"
    echo "  backup_applescript <file>       - Create timestamped backup"
    echo "  applescript_info <file>         - Show file information"
    echo "  applescript_help                - Show this help"
    echo ""
    echo "Examples:"
    echo "  run_applescript my_script.applescript"
    echo "  applescript_to_app converter.applescript 'File Converter'"
    echo "  convert_heic"
}

# Auto-completion for AppleScript files (zsh only)
if [ -n "$ZSH_VERSION" ] && command -v compdef >/dev/null 2>&1; then
    _applescript_completion() {
        local scripts=($(find . -name "*.applescript" -type f 2>/dev/null | sed 's|^\./||'))
        if [ ${#scripts[@]} -gt 0 ]; then
            compadd "${scripts[@]}"
        fi
    }

    # Only set up completion if compdef is available
    compdef _applescript_completion run_applescript 2>/dev/null || true
    compdef _applescript_completion check_applescript 2>/dev/null || true
    compdef _applescript_completion applescript_to_app 2>/dev/null || true
    compdef _applescript_completion backup_applescript 2>/dev/null || true
    compdef _applescript_completion applescript_info 2>/dev/null || true
fi

echo "🍎 AppleScript utilities loaded! Type 'applescript_help' for usage info."
