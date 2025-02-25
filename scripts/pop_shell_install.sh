#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to display usage information
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Install Pop Shell tiling window manager on Ubuntu."
    echo ""
    echo "Options:"
    echo "  -h, --help      Display this help message and exit"
}

# Function for git-based installation
install_from_git() {
    echo "Using git-based installation method..."

    # Install dependencies
    echo "Installing build dependencies..."
    sudo apt-get update
    sudo apt-get install -y git node-typescript make gnome-shell-extensions gnome-shell-extension-prefs

    # Clone the repository
    echo "Cloning Pop Shell repository..."
    git_dir="$HOME/.local/share/gnome-shell/extensions/pop-shell@system76.com"

    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$git_dir")"

    # Clone if directory doesn't exist, otherwise pull latest changes
    if [ ! -d "$git_dir" ]; then
        git clone https://github.com/pop-os/shell.git "$git_dir"
    else
        echo "Repository already exists. Pulling latest changes..."
        cd "$git_dir"
        git pull
    fi

    # Build the extension
    echo "Building Pop Shell..."
    cd "$git_dir"
    make

    echo "Git installation completed."
}

# Function to enable Pop Shell
enable_pop_shell() {
    echo "Enabling Pop Shell..."

    # Enable the extension
    gnome-extensions enable pop-shell@system76.com || {
        echo "WARNING: Could not enable Pop Shell automatically."
        echo "Please log out and log back in, then enable the extension manually using GNOME Extensions app."
    }

    # Restart GNOME Shell if running in X11 (not Wayland)
    if [ "$XDG_SESSION_TYPE" != "wayland" ]; then
        echo "Restarting GNOME Shell..."
        busctl --user call org.gnome.Shell /org/gnome/Shell org.gnome.Shell Eval s 'Meta.restart("Restarting GNOME Shell...")' > /dev/null || {
            echo "WARNING: Could not restart GNOME Shell automatically."
            echo "You may need to press Alt+F2, type 'r' and press Enter to restart GNOME Shell."
        }
    else
        echo "NOTE: You're running Wayland. You'll need to log out and log back in for changes to take effect."
    fi
}

# Parse command line arguments
USE_GIT=false

while [ $# -gt 0 ]; do
    case "$1" in
        --ppa)
            USE_GIT=false
            shift
            ;;
        --git)
            USE_GIT=true
            shift
            ;;
        --help|-h)
            show_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
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

# Install Pop Shell using the selected method
if [ "$USE_GIT" = true ]; then
    install_from_git
else
    install_from_ppa
fi

# Enable Pop Shell
enable_pop_shell

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
