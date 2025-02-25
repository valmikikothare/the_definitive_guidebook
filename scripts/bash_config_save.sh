#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to display usage information
show_usage() {
    echo "Usage: $0 [OPTIONS] [OUTPUT_DIR]"
    echo "Save bash configuration files from home directory to repository."
    echo ""
    echo "Options:"
    echo "  -o, --output DIR    Specify output directory (default: repo_dir/configs/bash)"
    echo "  -h, --help          Display this help message and exit"
}

# Get workspace directory
script_dir=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
repo_dir=$(dirname $script_dir)
configs_dir="$repo_dir/configs"

# Default output directory
OUTPUT_DIR="$configs_dir/bash"

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

# Define source files
SOURCE_BASHRC="$HOME/.bashrc"
SOURCE_BASH_ALIASES="$HOME/.bash_aliases"
SOURCE_PROFILE="$HOME/.profile"
SOURCE_BASH_PROFILE="$HOME/.bash_profile"

# Define destination files
DEST_BASHRC="$OUTPUT_DIR/.bashrc"
DEST_BASH_ALIASES="$OUTPUT_DIR/.bash_aliases"
DEST_PROFILE="$OUTPUT_DIR/.profile"
DEST_BASH_PROFILE="$OUTPUT_DIR/.bash_profile"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Check if any destination files already exist and ask for confirmation before overwriting
if [ -f "$DEST_BASHRC" ] || [ -f "$DEST_BASH_ALIASES" ] || [ -f "$DEST_PROFILE" ] || [ -f "$DEST_BASH_PROFILE" ]; then
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
copy_file "$SOURCE_BASHRC" "$DEST_BASHRC"
copy_file "$SOURCE_BASH_ALIASES" "$DEST_BASH_ALIASES"
copy_file "$SOURCE_PROFILE" "$DEST_PROFILE"
copy_file "$SOURCE_BASH_PROFILE" "$DEST_BASH_PROFILE"

echo "Bash configuration files have been saved successfully to $OUTPUT_DIR."
