#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to display usage information
show_usage() {
    echo "Usage: $0 [OPTIONS] [OUTPUT_DIR]"
    echo "Save GNOME keybindings to dconf files."
    echo ""
    echo "Options:"
    echo "  --help    Display this help message and exit"
}

# Get workspace directory
script_dir=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
repo_dir=$(dirname $script_dir)

# Define default file paths
OUTPUT_DIR="$repo_dir/keybindings"
KEYBINDINGS_FILE="keybindings.dconf"
CUSTOM_KEYBINDINGS_FILE="custom-keybindings.dconf"

# Parse command line arguments
for arg in "$@"; do
    case $arg in
        --help|-h)
            show_usage
            exit 0
            ;;
        *)
            # First positional argument is treated as output directory
            if [[ "$arg" != -* ]]; then
                OUTPUT_DIR="$arg"
            else
                echo "Unknown option: $arg"
                show_usage
                exit 1
            fi
            ;;
    esac
done

mkdir -p $OUTPUT_DIR

# Set full paths
KEYBINDINGS_PATH="$OUTPUT_DIR/$KEYBINDINGS_FILE"
CUSTOM_KEYBINDINGS_PATH="$OUTPUT_DIR/$CUSTOM_KEYBINDINGS_FILE"

# Check if either keybindings file exists and ask for confirmation before overwriting
if [ -f "$KEYBINDINGS_PATH" ] || [ -f "$CUSTOM_KEYBINDINGS_PATH" ]; then
    read -p "$KEYBINDINGS_PATH and/or $CUSTOM_KEYBINDINGS_PATH already exists! Overwrite? (y/n): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Operation cancelled."
        exit 0
    fi
fi

echo "Saving window manager keybindings..."
dconf dump '/org/gnome/desktop/wm/keybindings/' > $KEYBINDINGS_PATH

echo "Saving custom keybindings..."
dconf dump '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/' > $CUSTOM_KEYBINDINGS_PATH

echo "Keybindings have been saved successfully to $OUTPUT_DIR."
