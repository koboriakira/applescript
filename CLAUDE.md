# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is an AppleScript repository containing utilities for macOS automation. The codebase consists of AppleScript files that provide system-level automation functionality.

## Code Architecture

- **AppleScript Files**: Each `.applescript` file is a standalone automation script
- **File Processing Pattern**: Scripts follow a pattern of file selection, processing, and user feedback
- **Error Handling**: Scripts include try-catch blocks with user-friendly error dialogs
- **Dual Execution Modes**: Scripts support both manual execution (run handlers) and drag-and-drop operation (open handlers)

## Development Commands

### Testing AppleScript Files
```bash
# Run an AppleScript file
osascript filename.applescript

# Compile and check syntax
osacompile -c filename.applescript
```

### File Operations
AppleScript files use:
- `choose file` for file selection dialogs
- `do shell script` for system command execution
- `display dialog` for user feedback
- `info for` for file metadata operations

## Shell Script Functions

### Convenience Functions for AppleScript Execution
Add these functions to your shell profile (`~/.zshrc` or `~/.bash_profile`):

```bash
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
    osacompile -c "$script_path" && echo "Syntax OK" || echo "Syntax Error"
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
        echo "Successfully created: $output_name.app"
        echo "You can now double-click to run or drag files onto it"
    else
        echo "Error: Failed to create application"
    fi
}

# Function to run HEIC to JPEG converter specifically
convert_heic() {
    local script_dir="$(dirname "${BASH_SOURCE[0]}")"
    local converter_script="$script_dir/convert_downloads_heic_to_jpeg.applescript"
    
    if [ -f "$converter_script" ]; then
        echo "Running HEIC to JPEG converter..."
        osascript "$converter_script"
    else
        echo "Error: HEIC converter script not found at $converter_script"
        echo "Make sure you're in the correct directory or update the path"
    fi
}

# Function to list all AppleScript files in current directory
list_applescripts() {
    echo "AppleScript files in current directory:"
    find . -name "*.applescript" -type f | sort
}
```

### Quick Setup
To set up these functions, run:
```bash
# Add functions to your shell profile
curl -s https://raw.githubusercontent.com/your-repo/applescript/main/shell_functions.sh >> ~/.zshrc
source ~/.zshrc

# Or manually add the functions above to your ~/.zshrc file
```

### Usage Examples
```bash
# Run any AppleScript
run_applescript convert_downloads_heic_to_jpeg.applescript

# Check syntax
check_applescript heic_to_jpeg_converter.applescript

# Convert to standalone app
applescript_to_app convert_downloads_heic_to_jpeg.applescript "HEIC Converter"

# Quick HEIC conversion (if in the script directory)
convert_heic

# List all AppleScript files
list_applescripts
```

## AppleScript Implementation Best Practices and Common Issues

Based on troubleshooting experience, here are key implementation patterns and solutions for AppleScript development:

### Type Conversion Issues

#### String Concatenation with Numbers
**Problem**: AppleScript cannot directly concatenate numbers with strings
```applescript
-- ❌ This will cause a type conversion error
set message to fileCount & "個のファイルが見つかりました"
```

**Solution**: Explicitly convert numbers to strings using `as string`
```applescript
-- ✅ Correct approach
set message to (fileCount as string) & "個のファイルが見つかりました"
```

#### List Iteration and Alias Handling
**Problem**: When iterating through lists with `repeat with item in list`, the item becomes a reference that cannot be directly used with file operations
```applescript
-- ❌ This causes "cannot convert to alias" errors
repeat with heicFile in heicFiles
    set parentFolder to POSIX path of (container of heicFile as alias)
end repeat
```

**Solution**: Explicitly convert the item to alias at the beginning of the loop
```applescript
-- ✅ Correct approach
repeat with heicFile in heicFiles
    set heicFileAlias to heicFile as alias
    -- Now use heicFileAlias for all operations
end repeat
```

#### Container Path Resolution
**Problem**: `container of` operations can fail with complex alias references
```applescript
-- ❌ May fail with type conversion errors
set parentFolder to POSIX path of (container of heicFileAlias as alias)
```

**Solution**: Use shell commands for reliable path operations
```applescript
-- ✅ More reliable approach
set filePath to POSIX path of heicFileAlias
set parentFolder to do shell script "dirname '" & filePath & "'"
set outputPath to parentFolder & "/" & baseName & ".jpeg"
```

### File Operation Patterns

#### Safe File Processing Loop
```applescript
on convertFiles(fileList)
    set successCount to 0
    repeat with fileItem in fileList
        -- Convert to alias immediately
        set fileAlias to fileItem as alias
        
        if processFile(fileAlias) then
            set successCount to successCount + 1
        end if
    end repeat
    
    -- Use string conversion for result display
    display dialog (successCount as string) & "個のファイルが処理されました。"
end convertFiles
```

#### Error Handling with Context
```applescript
on processFile(fileAlias)
    try
        -- File operations here
        return true
    on error errorMessage
        -- Include file name in error message for debugging
        set fileName to name of (info for fileAlias)
        display dialog "ファイル処理エラー (" & fileName & "): " & errorMessage
        log "処理エラー: " & errorMessage
        return false
    end try
end processFile
```

### Shell Command Integration

#### Safe Path Handling
Always quote paths when using shell commands to handle spaces and special characters:
```applescript
-- ✅ Properly quoted shell command
set shellCommand to "sips -s format jpeg '" & filePath & "' --out '" & outputPath & "'"
do shell script shellCommand
```

#### Path Manipulation
Use shell utilities for reliable path operations:
```applescript
-- Get parent directory
set parentDir to do shell script "dirname '" & filePath & "'"

-- Get filename without extension
set baseName to do shell script "basename '" & filePath & "' .heic"
```

### Common Error Patterns and Solutions

1. **Type Conversion Errors**: Always use explicit `as string` or `as alias` conversions
2. **List Iteration Issues**: Convert list items to proper types immediately in loops
3. **Path Handling**: Use shell commands for complex path operations instead of AppleScript's container operations
4. **Error Context**: Include file names and context in error messages for easier debugging
5. **String Building**: Build complex strings step by step with proper type conversions

### Testing and Debugging Tips

- Use `log` statements to trace execution flow
- Test with single files before processing batches
- Include file names in error messages
- Use try-catch blocks around individual file operations
- Validate file existence before processing
