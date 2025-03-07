#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Get cursor configs directory
script_dir=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
repo_dir=$(dirname $script_dir)
cursor_configs_dir="$repo_dir/configs/cursor"

# Function to display usage information
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Load cursor configuration files from repository to home directory."
    echo ""
    echo "Options:"
    echo "  -h, --help     Display this help message and exit"
}

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

# Parse command line arguments
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            echo "Error: Invalid option: $1" >&2
            show_usage
            exit 1
            ;;
    esac
    shift
done

# Determine Cursor config directory based on OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    platform="macos"
    dest_dir="$HOME/Library/Application Support/Cursor/User"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    platform="linux"
    dest_dir="$HOME/.config/Cursor/User"
elif [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "cygwin"* || "$OSTYPE" == "win32" ]]; then
    # Windows
    platform="windows"
    dest_dir="$APPDATA/Cursor/User"
else
    echo "Error: Unsupported operating system: $OSTYPE" >&2
    exit 1
fi

source_dir="$cursor_configs_dir/$platform"

# Check if source directory exists
if [[ ! -d "$source_dir" ]]; then
    echo "Error: Source directory not found: $source_dir" >&2
    exit 1
fi

# Check if destination directory exists
if [[ ! -d "$dest_dir" ]]; then
    echo "Error: Destination directory not found: $dest_dir" >&2
    exit 1
fi

# Define source files
source_settings="$source_dir/settings.json"
source_keybindings="$source_dir/keybindings.json"

# Define destination files
dest_settings="$dest_dir/settings.json"
dest_keybindings="$dest_dir/keybindings.json"

# Confirm before copying
echo "This script will copy Cursor configuration files to your Cursor config directory."
echo "Source directory: $source_dir"
echo "Destination directory: $dest_dir"
echo "The following files will be copied if they exist:"
echo "  $source_settings -> $dest_settings"
echo "  $source_keybindings -> $dest_keybindings"
echo "Existing files will be backed up with .bak extension."
read -p "Do you want to continue? (y/n): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 0
fi

# Perform the backup and copy operations
backup_and_copy "$source_settings" "$dest_settings"
backup_and_copy "$source_keybindings" "$dest_keybindings"
echo "Cursor configuration files have been copied successfully."
echo "You may need to restart Cursor for changes to take effect."
