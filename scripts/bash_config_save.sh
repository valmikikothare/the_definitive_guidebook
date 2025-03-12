#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Get bash configs directory
script_dir=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
repo_dir=$(dirname $script_dir)
bash_configs_dir="$repo_dir/configs/bash"

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

dest_dir="$bash_configs_dir/$platform"

# Create output directory if it doesn't exist
mkdir -p "$dest_dir"

# Define source files
source_bashrc="$HOME/.bashrc"
source_bash_aliases="$HOME/.bash_aliases"
source_profile="$HOME/.profile"
source_bash_profile="$HOME/.bash_profile"

# Define destination files
dest_bashrc="$dest_dir/.bashrc"
dest_bash_aliases="$dest_dir/.bash_aliases"
dest_profile="$dest_dir/.profile"
dest_bash_profile="$dest_dir/.bash_profile"

# Confirm before copying
echo "This script will copy the bash configuration files in $source_dir" \
     "to $dest_dir."
echo "The following files will be copied if they exist:"
echo "  $source_bashrc -> $dest_bashrc"
echo "  $source_bash_aliases -> $dest_bash_aliases"
echo "  $source_profile -> $dest_profile"
echo "  $source_bash_profile -> $dest_bash_profile"
echo "Existing files in $dest_dir will be backed up with .bak extension."
read -p "Do you want to continue? (y/n): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 0
fi

# Perform the backup and copy operations
backup_and_copy "$source_bashrc" "$dest_bashrc"
backup_and_copy "$source_bash_aliases" "$dest_bash_aliases"
backup_and_copy "$source_profile" "$dest_profile"
backup_and_copy "$source_bash_profile" "$dest_bash_profile"
echo "Bash configuration files have been saved successfully to $dest_dir."
