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

## Key Patterns

- **File Selection**: Use `choose file` with appropriate file type filters
- **Shell Integration**: Use `do shell script` for system command execution (like `sips` for image conversion)
- **Path Handling**: Convert between AppleScript aliases and POSIX paths using `POSIX path of`
- **Batch Processing**: Iterate through file collections using `repeat with` loops
- **Error Display**: Show errors to users via `display dialog` rather than silent failures