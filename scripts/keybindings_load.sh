#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to display usage information
show_usage() {
    echo "Usage: $0 [OPTIONS] [INPUT_DIR]"
    echo "Load GNOME keybindings from saved dconf files."
    echo ""
    echo "Options:"
    echo "  --help    Display this help message and exit"
}

# Get workspace directory
script_dir=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
repo_dir=$(dirname $script_dir)

# Define default file paths
INPUT_DIR="$repo_dir/keybindings"
KEYBINDINGS_FILE="keybindings.dconf"
CUSTOM_KEYBINDINGS_FILE="custom-keybindings.dconf"

# Parse command line arguments
while [ $# -gt 0 ]; do
    case "$1" in
        --help|-h)
            show_usage
            exit 0
            ;;
        *)
            # First positional argument is treated as input directory
            if [[ "$1" != -* ]]; then
                INPUT_DIR="$1"
            else
                echo "Unknown option: $1"
                show_usage
                exit 1
            fi
            ;;
    esac
    shift
done

# Set full paths
KEYBINDINGS_PATH="$INPUT_DIR/$KEYBINDINGS_FILE"
CUSTOM_KEYBINDINGS_PATH="$INPUT_DIR/$CUSTOM_KEYBINDINGS_FILE"

# Check if keybindings files exist
if [ ! -f "$KEYBINDINGS_PATH" ]; then
    echo "Error: $KEYBINDINGS_PATH does not exist."
    exit 1
fi

if [ ! -f "$CUSTOM_KEYBINDINGS_PATH" ]; then
    echo "Error: $CUSTOM_KEYBINDINGS_PATH does not exist."
    exit 1
fi

# Confirm before loading
echo "Loading keybindings from $KEYBINDINGS_PATH and $CUSTOM_KEYBINDINGS_PATH"
echo "This will overwrite your current keybindings!"
read -p "Are you sure you want to continue? (y/n): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 0
fi

echo "Applying window manager keybindings..."
dconf load '/org/gnome/desktop/wm/keybindings/' < $KEYBINDINGS_PATH

echo "Applying custom keybindings..."
dconf load '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/' < $CUSTOM_KEYBINDINGS_PATH

echo "Keybindings have been loaded successfully."