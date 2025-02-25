#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to display usage information
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Load Cursor configuration files from repository to Cursor config directory."
    echo ""
    echo "Options:"
    echo "  -i, --input    Specify input directory containing Cursor configuration files"
    echo "  -h, --help     Display this help message and exit"
}

# Get workspace directory
script_dir=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
repo_dir=$(dirname $script_dir)
configs_dir="$repo_dir/configs"

# Default source directory
SOURCE_DIR="$configs_dir/cursor"

# Parse command line arguments
while [ $# -gt 0 ]; do
    case "$1" in
        -i|--input)
            shift
            if [[ -n "$1" && "$1" != -* ]]; then
                SOURCE_DIR="$1"
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
            # First positional argument is treated as input directory
            if [[ "$1" != -* ]]; then
                SOURCE_DIR="$1"
            else
                echo "Unknown option: $1" >&2
                show_usage
                exit 1
            fi
            ;;
    esac
    shift
done

# Verify the source directory exists (after all parsing)
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory $SOURCE_DIR does not exist." >&2
    exit 1
fi

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
SOURCE_SETTINGS="$SOURCE_DIR/settings.json"
SOURCE_KEYBINDINGS="$SOURCE_DIR/keybindings.json"

# Define destination files
DEST_SETTINGS="$CURSOR_CONFIG_DIR/settings.json"
DEST_KEYBINDINGS="$CURSOR_CONFIG_DIR/keybindings.json"

# Function to backup and copy a file
backup_and_copy() {
    local source_file=$1
    local dest_file=$2

    # Check if source file exists
    if [ ! -f "$source_file" ]; then
        echo "Warning: Source file $source_file does not exist, skipping."
        return 0
    fi

    # Check if destination file exists
    if [ -f "$dest_file" ]; then
        echo "Backing up existing $dest_file to ${dest_file}.bak"
        cp "$dest_file" "${dest_file}.bak"
    fi

    # Copy the file
    echo "Copying $source_file to $dest_file"
    cp "$source_file" "$dest_file"
}

# Confirm before copying
echo "This script will copy Cursor configuration files to your Cursor config directory."
echo "Source directory: $SOURCE_DIR"
echo "Destination directory: $CURSOR_CONFIG_DIR"
echo "The following files will be copied if they exist:"
echo "  $SOURCE_SETTINGS -> $DEST_SETTINGS"
echo "  $SOURCE_KEYBINDINGS -> $DEST_KEYBINDINGS"
echo "Existing files will be backed up with .bak extension."
read -p "Do you want to continue? (y/n): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 0
fi

# Perform the backup and copy operations
backup_and_copy "$SOURCE_SETTINGS" "$DEST_SETTINGS"
backup_and_copy "$SOURCE_KEYBINDINGS" "$DEST_KEYBINDINGS"
echo "Cursor configuration files have been copied successfully."
echo "You may need to restart Cursor for changes to take effect."
