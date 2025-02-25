#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to display usage information
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Load bash configuration files from repository to home directory."
    echo ""
    echo "Options:"
    echo "  -i, --input    Specify input directory containing bash configuration files"
    echo "  -h, --help     Display this help message and exit"
}

# Get workspace directory
script_dir=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
repo_dir=$(dirname $script_dir)
configs_dir="$repo_dir/configs"

# Default source directory
SOURCE_DIR="$configs_dir/bash"

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

# Define source files
SOURCE_BASHRC="$SOURCE_DIR/.bashrc"
SOURCE_BASH_ALIASES="$SOURCE_DIR/.bash_aliases"
SOURCE_PROFILE="$SOURCE_DIR/.profile"
SOURCE_BASH_PROFILE="$SOURCE_DIR/.bash_profile"

# Define destination files
DEST_BASHRC="$HOME/.bashrc"
DEST_BASH_ALIASES="$HOME/.bash_aliases"
DEST_PROFILE="$HOME/.profile"
DEST_BASH_PROFILE="$HOME/.bash_profile"

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
echo "This script will copy bash configuration files to your home directory."
echo "Source directory: $SOURCE_DIR"
echo "The following files will be copied if they exist:"
echo "  $SOURCE_BASHRC -> $DEST_BASHRC"
echo "  $SOURCE_BASH_ALIASES -> $DEST_BASH_ALIASES"
echo "  $SOURCE_PROFILE -> $DEST_PROFILE"
echo "  $SOURCE_BASH_PROFILE -> $DEST_BASH_PROFILE"
echo "Existing files will be backed up with .bak extension."
read -p "Do you want to continue? (y/n): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 0
fi

# Perform the backup and copy operations
backup_and_copy "$SOURCE_BASHRC" "$DEST_BASHRC"
backup_and_copy "$SOURCE_BASH_ALIASES" "$DEST_BASH_ALIASES"
backup_and_copy "$SOURCE_PROFILE" "$DEST_PROFILE"
backup_and_copy "$SOURCE_BASH_PROFILE" "$DEST_BASH_PROFILE"
echo "Bash configuration files have been copied successfully."
echo "You may need to restart your terminal or run 'source ~/.bashrc' for changes to take effect."
