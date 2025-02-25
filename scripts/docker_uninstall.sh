#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to display usage information
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Uninstall Docker from Ubuntu."
    echo ""
    echo "Options:"
    echo "  --help    Display this help message and exit"
}

# Parse command line arguments
for arg in "$@"; do
    case $arg in
        --help|-h)
            show_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $arg"
            show_usage
            exit 1
            ;;
    esac
done

echo "Starting Docker uninstallation process..."

# Step 1: Uninstall Docker Engine, CLI, containerd, and Docker Compose packages
echo "Removing Docker packages..."
sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras

# Step 2: Delete all images, containers, and volumes
echo "Removing Docker data directories..."
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd

# Step 3: Remove Docker repository and keyring
echo "Removing Docker repository configuration..."
sudo rm -f /etc/apt/sources.list.d/docker.list
sudo rm -f /etc/apt/keyrings/docker.asc

# Step 4: Remove any conflicting packages that might have been installed
echo "Removing any conflicting packages..."
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker; do
    sudo apt-get purge -y $pkg
done

# Step 5: Update package lists
echo "Updating package lists..."
sudo apt-get update

echo "Docker uninstallation completed successfully."
echo "Note: Any manually edited Docker configuration files may need to be deleted separately."
