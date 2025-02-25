#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Default installation directory
install_dir="$HOME/opt"

# Function to display usage information
show_usage() {
    echo "Usage: $0 [OPTIONS] [INSTALL_DIR]"
    echo "Install Pop Shell tiling window manager on Ubuntu."
    echo ""
    echo "Options:"
    echo "  -i, --install-dir DIR    Specify installation directory (default: $install_dir)"
    echo "  -h, --help              Display this help message and exit"
}

# Parse command line arguments
install_dir_set=false
while [ $# -gt 0 ]; do
    case "$1" in
        -i|--install-dir)
            shift
            if $install_dir_set; then
                echo "Error: --install-dir option already specified"
                show_usage
                exit 1
            fi
            install_dir="$1"
            install_dir_set=true
            ;;
        --help|-h)
            show_usage
            exit 0
            ;;
        *)
            if $install_dir_set; then
                echo "Error: --install-dir option already specified"
                show_usage
                exit 1
            fi
            install_dir="$1"
            install_dir_set=true
            ;;
    esac
    shift
done

echo "Starting Pop Shell installation process..."

# Check if we're running GNOME Shell
if ! which gnome-shell > /dev/null; then
    echo "ERROR: GNOME Shell is not installed. Pop Shell requires GNOME Shell to function."
    exit 1
fi

# Install dependencies
echo "Installing build dependencies..."
sudo apt-get update
sudo apt-get install -y git node-typescript make gnome-shell-extensions gnome-shell-extension-prefs

# Create install directory if it doesn't exist
mkdir -p "$install_dir"

# Clone the repository if it doesn't exist, otherwise pull latest changes
echo "Cloning Pop Shell repository..."
repo_dir="$install_dir/shell"
if [ ! -d "$repo_dir" ]; then
    git clone https://github.com/pop-os/shell.git "$repo_dir"
else
    echo "Repository already exists. Pulling latest changes..."
    cd "$repo_dir"
    git pull
fi

# Build the extension
echo "Building Pop Shell..."
cd "$repo_dir"
make local-install

echo "Git installation completed."

# Install additional helpful packages
echo "Installing additional packages..."
sudo apt-get install -y gnome-tweaks

echo "Pop Shell installation complete!"
echo "You can configure Pop Shell using the keyboard shortcuts:"
echo "  Super+O        Toggle orientation (horizontal/vertical)"
echo "  Super+G        Toggle tiling mode"
echo "  Super+Enter    Toggle floating mode for current window"
echo "  Super+arrow    Move focus in direction"
echo "  Super+Shift+arrow  Move window in direction"
echo "  Super+Y        Toggle auto-tiling"

echo "You may need to log out and log back in for all changes to take effect."
