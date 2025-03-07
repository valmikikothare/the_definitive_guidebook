#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to display usage information
show_usage() {
    echo "Usage: $0 [OPTIONS] [INPUT_FILE_OR_DIR...]"
    echo "Update udev rules by copying them to /etc/udev/rules.d/ and reloading."
    echo ""
    echo "Options:"
    echo "  -i, --input    Specify input file or directory containing udev rules"
    echo "                 Can be specified multiple times"
    echo "  -h, --help     Display this help message and exit"
}

# Get workspace directory
script_dir=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
repo_dir=$(dirname $script_dir)
configs_dir="$repo_dir/configs"

# Default source directory/file
INPUT_PATHS=()

# Parse command line arguments
while [ $# -gt 0 ]; do
    case "$1" in
        -i|--input)
            shift
            if [[ -n "$1" && "$1" != -* ]]; then
                INPUT_PATHS+=("$1")
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
            # Positional arguments are treated as input paths
            if [[ "$1" != -* ]]; then
                INPUT_PATHS+=("$1")
            else
                echo "Unknown option: $1" >&2
                show_usage
                exit 1
            fi
            ;;
    esac
    shift
done

if [ ${#INPUT_PATHS[@]} -eq 0 ]; then
    INPUT_PATHS=("$configs_dir/udev")
fi

# Function to copy a single udev rule file
copy_udev_rule() {
    local source_file=$1
    local filename=$(basename "$source_file")
    local destination_file="/etc/udev/rules.d/$filename"

    # Check if source file exists and is a regular file
    if [ ! -f "$source_file" ]; then
        echo "Warning: $source_file is not a regular file, skipping."
        return 0
    fi

    # Check if file has .rules extension
    if [[ ! "$filename" =~ \.rules$ ]]; then
        echo "Warning: $source_file does not have .rules extension, skipping."
        return 0
    fi

    # Check if destination file already exists
    if [ -f "$destination_file" ]; then
        echo "Note: $filename already exists in /etc/udev/rules.d/"
    fi

    echo "Copying $source_file to $destination_file"
    sudo cp "$source_file" "$destination_file"
}

# Collect all rule files to copy
declare -a FILES_TO_COPY

for INPUT_PATH in "${INPUT_PATHS[@]}"; do
    # Verify the input path exists
    if [ ! -e "$INPUT_PATH" ]; then
        echo "Error: Input path $INPUT_PATH does not exist." >&2
        exit 1
    fi

    if [ -d "$INPUT_PATH" ]; then
        # Input is a directory, find all .rules files
        FOUND_FILES=($(find "$INPUT_PATH" -name "*.rules" -type f 2>/dev/null))

        # Check if directory has any .rules files
        if [ ${#FOUND_FILES[@]} -eq 0 ]; then
            echo "Warning: No .rules files found in $INPUT_PATH, skipping." >&2
            continue
        fi

        # Add found files to the list
        FILES_TO_COPY+=("${FOUND_FILES[@]}")
    else
        # Input is a file, add it to the list
        FILES_TO_COPY+=("$INPUT_PATH")
    fi
done

# Check if we found any files to copy
if [ ${#FILES_TO_COPY[@]} -eq 0 ]; then
    echo "Error: No valid udev rule files found to copy." >&2
    exit 1
fi

# Confirm before copying
echo "The following files will be copied to /etc/udev/rules.d/:"
for file in "${FILES_TO_COPY[@]}"; do
    echo "  $file"
done

read -p "Do you want to continue? (y/n): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 0
fi

# Copy each file
for file in "${FILES_TO_COPY[@]}"; do
    copy_udev_rule "$file"
done

# Reload udev rules
echo "Reloading udev rules..."
sudo udevadm control --reload-rules
sudo udevadm trigger

echo "Udev rules have been updated successfully."
