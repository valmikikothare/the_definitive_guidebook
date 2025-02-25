#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to display usage information
show_usage() {
    echo "Usage: $0 [OPTIONS] [OUTPUT_DIR]"
    echo "Save Cursor configuration files from Cursor config directory to repository."
    echo ""
    echo "Options:"
    echo "  -o, --output DIR    Specify output directory (default: repo_dir/configs/cursor)"
    echo "  --help              Display this help message and exit"
}

# Get workspace directory
script_dir=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
repo_dir=$(dirname $script_dir)
configs_dir="$repo_dir/configs"

# Default output directory
OUTPUT_DIR="$configs_dir/cursor"

# Parse command line arguments
# Flag to track if output directory has been set
OUTPUT_DIR_SET=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -o|--output)
            if $OUTPUT_DIR_SET; then
                echo "Error: Output directory already specified" >&2
                show_usage
                exit 1
            fi

            shift
            if [[ -n "$1" && "$1" != -* ]]; then
                OUTPUT_DIR="$1"
                OUTPUT_DIR_SET=true
            else
                echo "Error: Argument for $1 is missing" >&2
                show_usage
                exit 1
            fi
            ;;
        --help|-h)
            show_usage
            exit 0
            ;;
        *)
            # First positional argument is treated as output directory
            if [[ "$1" != -* ]]; then
                if $OUTPUT_DIR_SET; then
                    echo "Error: Output directory already specified" >&2
                    show_usage
                    exit 1
                fi
                OUTPUT_DIR="$1"
                OUTPUT_DIR_SET=true
            else
                echo "Error: Unknown option $1" >&2
                show_usage
                exit 1
            fi
            ;;
    esac
    shift
done

# Determine Cursor config directory based on OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    CURSOR_CONFIG_DIR="$HOME/Library/Application Support/Cursor/User"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    CURSOR_CONFIG_DIR="$HOME/.config/Cursor/User"
elif [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "cygwin"* || "$OSTYPE" == "win32" ]]; then
    # Windows
    CURSOR_CONFIG_DIR="$APPDATA/Cursor/User"
else
    echo "Error: Unsupported operating system: $OSTYPE" >&2
    exit 1
fi

# Define source files
SOURCE_SETTINGS="$CURSOR_CONFIG_DIR/settings.json"
SOURCE_KEYBINDINGS="$CURSOR_CONFIG_DIR/keybindings.json"

# Define destination files
DEST_SETTINGS="$OUTPUT_DIR/settings.json"
DEST_KEYBINDINGS="$OUTPUT_DIR/keybindings.json"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Check if any destination files already exist and ask for confirmation before overwriting
if [ -f "$DEST_SETTINGS" ] || [ -f "$DEST_KEYBINDINGS" ]; then
    read -p "One or more destination files already exist in $OUTPUT_DIR! Overwrite? (y/n): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Operation cancelled."
        exit 0
    fi
fi

# Function to copy a file if source exists
copy_file() {
    local source_file=$1
    local dest_file=$2

    # Check if source file exists
    if [ ! -f "$source_file" ]; then
        echo "Warning: Source file $source_file does not exist, skipping."
        return 0
    fi

    # Copy the file
    echo "Copying $source_file to $dest_file"
    cp "$source_file" "$dest_file"
}

# Perform the copy operations
copy_file "$SOURCE_SETTINGS" "$DEST_SETTINGS"
copy_file "$SOURCE_KEYBINDINGS" "$DEST_KEYBINDINGS"

echo "Cursor configuration files have been saved successfully to $OUTPUT_DIR."
