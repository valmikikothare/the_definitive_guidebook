# Utility functions
get_parent_dir() {
    # Check for exactly 2 arguments
    if [ $# -ne 2 ]; then
        echo "Error: get_parent_dir requires exactly 2 arguments" >&2
        echo "Usage: get_parent_dir <path> <number_of_levels>" >&2
        return 1
    fi
    local path=$1
    local n=$2

    # If path is a file, start from its directory
    if [ -f "$path" ]; then
        path=$(dirname $(readlink -f $path))
    fi

    # Get absolute path
    local abs_path=$(readlink -f $path)

    # Move up n directories
    for ((i=0; i<n; i++)); do
        abs_path=$(dirname $abs_path)
    done

    echo $abs_path
}

print_status() {
    echo -e "\033[1;34m$1\033[0m"
}

print_error() {
    echo -e "\033[1;31m$1\033[0m"
}

print_warning() {
    echo -e "\033[1;33m$1\033[0m"
}

backup_and_copy() {
    files=()
    while [ $# -gt 0 ]; do
        case "$1" in
            -s|--sudo)
                use_sudo=true
                ;;
            -*)
                echo "Error: Invalid option: $1"
                return 1
                ;;
            *)
                files+=("$1")
                ;;
        esac
        shift
    done

    if [ ${#files[@]} -ne 2 ]; then
        echo "Error: Expected 2 files, got ${#files[@]}."
        return 1
    fi

    source_file="${files[0]}"
    dest_file="${files[1]}"

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
    if [ "$use_sudo" = "true" ]; then
        sudo cp "$source_file" "$dest_file"
    else
        cp "$source_file" "$dest_file"
    fi
}

# Automatically detect platform
case "$(uname -s)" in
    Linux*)     
        export platform="linux" 
        ;;
    Darwin*)    
        export platform="mac"
        ;;
    CYGWIN*|MINGW*|MSYS*) 
        export platform="windows" 
        ;;
    *)   
        echo "Error: Unsupported platform: $(uname -s)"
        exit 1
        ;;
esac
echo "Detected platform: $platform"
