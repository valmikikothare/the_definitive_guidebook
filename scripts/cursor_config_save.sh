#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Get cursor configs directory
script_dir=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
repo_dir=$(dirname $script_dir)
cursor_configs_dir="$repo_dir/configs/cursor"

# Load utils
source "$script_dir/utils.sh"

# Function to display usage information
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Load cursor configuration files from repository to home directory."
    echo ""
    echo "Options:"
    echo "  -h, --help     Display this help message and exit"
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
case "$platform" in
    "mac")
        source_dir="$HOME/Library/Application Support/Cursor/User"
        ;;
    "linux")
        source_dir="$HOME/.config/Cursor/User"
        ;;
    "windows")
        source_dir="$APPDATA/Cursor/User"
        ;;
esac

dest_dir="$cursor_configs_dir/$platform"

# Create output directory if it doesn't exist
mkdir -p "$dest_dir"

# Define source files
source_settings="$source_dir/settings.json"
source_keybindings="$source_dir/keybindings.json"

# Define destination files
dest_settings="$dest_dir/settings.json"
dest_keybindings="$dest_dir/keybindings.json"

# Confirm before copying
echo "This script will copy the cursor configuration files in $source_dir" \
     "to $dest_dir."
echo "The following files will be copied if they exist:"
echo "  $source_settings -> $dest_settings"
echo "  $source_keybindings -> $dest_keybindings"
echo "Existing files in $dest_dir will be backed up with .bak extension."
read -p "Do you want to continue? (y/n): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 0
fi

# Perform the backup and copy operations
backup_and_copy "$source_settings" "$dest_settings"
backup_and_copy "$source_keybindings" "$dest_keybindings"
echo "Cursor configuration files have been saved successfully to $dest_dir."