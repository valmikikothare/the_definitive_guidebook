#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Get workspace directory
script_dir=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
repo_dir=$(dirname $script_dir)
configs_dir="$repo_dir/configs/udev"

# Load utils
source "$script_dir/utils.sh"

# Function to display usage information
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Update udev rules by copying them to /etc/udev/rules.d/ and reloading."
    echo ""
    echo "Options:"
    echo "  -h, --help     Display this help message and exit"
}

# Check platform
case "$platform" in
    "windows")
        echo "Error: Udev is not supported on Windows." >&2
        exit 1
        ;;
esac

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

# Confirm before copying
echo "The following files will be copied to /etc/udev/rules.d/:"
for file in "$configs_dir/*.rules"; do
    echo "  $file"
done
read -p "Do you want to continue? (y/n): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 0
fi

# Copy each file
for source_file in "$configs_dir/*.rules"; do
    dest_file="/etc/udev/rules.d/$(basename $source_file)"
    backup_and_copy "$source_file" "$dest_file" --sudo
done

# Reload udev rules
echo "Reloading udev rules..."
sudo udevadm control --reload-rules
sudo udevadm trigger

echo "Udev rules have been updated successfully."
