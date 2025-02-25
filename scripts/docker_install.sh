#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to display usage information
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Install Docker on Ubuntu."
    echo ""
    echo "Options:"
    echo "  -r, --repo    Use repository-based installation instead of convenience script"
    echo "  -h, --help    Display this help message and exit"
}

# Function for repository-based installation
install_docker_repo() {
    echo "Using repository-based installation method..."

    # Set up Docker's apt repository
    echo "Setting up Docker's apt repository..."
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources
    echo "Adding Docker repository to apt sources..."
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Update apt package index
    sudo apt-get update

    # Install Docker Engine, containerd, and Docker Compose
    echo "Installing Docker Engine, containerd, and Docker Compose..."
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

# Function for convenience script installation
install_docker_convenience() {
    echo "Using convenience script installation method..."

    # Download and run the Docker convenience script
    echo "Downloading and running Docker convenience script..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh

    # Clean up the installation script
    echo "Cleaning up..."
    rm -f get-docker.sh
}

# Parse command line arguments
USE_REPO=false
while [ $# -gt 0 ]; do
    case "$1" in
        --repo)
            USE_REPO=true
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

echo "Starting Docker installation process..."

# Uninstall old versions
echo "Removing old Docker packages if they exist..."
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
    sudo apt-get remove -y $pkg 2>/dev/null || true
done

# Install Docker using the selected method
if [ "$USE_REPO" = true ]; then
    install_docker_repo
else
    install_docker_convenience
fi

# Verify that Docker Engine is installed correctly
echo "Verifying Docker installation..."
sudo docker run hello-world

# Post-installation steps

# Create the docker group if it doesn't exist
echo "Setting up Docker to run without sudo..."
sudo groupadd docker 2>/dev/null || true

# Add your user to the docker group
echo "Adding current user to docker group..."
sudo usermod -aG docker $USER

# Configure Docker to start on boot with systemd
echo "Configuring Docker to start on boot..."
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

# Configure logging driver with log rotation
echo "Configuring Docker logging driver with log rotation..."
DOCKER_DAEMON_CONFIG="/etc/docker/daemon.json"

# Create the file if it doesn't exist
if [ ! -f "$DOCKER_DAEMON_CONFIG" ]; then
    sudo mkdir -p /etc/docker
    echo "{}" | sudo tee "$DOCKER_DAEMON_CONFIG" > /dev/null
fi

# Get current content and check if logging configuration exists
CURRENT_CONFIG=$(sudo cat "$DOCKER_DAEMON_CONFIG")
if ! echo "$CURRENT_CONFIG" | grep -q "log-driver"; then
    # Create configuration with logging settings if it doesn't exist
    CONFIG_CONTENT=$(echo "$CURRENT_CONFIG" | python3 -c "
import sys, json
config = json.load(sys.stdin) if sys.stdin.read().strip() else {}
config['log-driver'] = 'json-file'
config['log-opts'] = {'max-size': '10m', 'max-file': '3'}
print(json.dumps(config, indent=2))
")
    echo "$CONFIG_CONTENT" | sudo tee "$DOCKER_DAEMON_CONFIG" > /dev/null

    # Restart Docker to apply changes
    sudo systemctl restart docker
fi

echo "Docker installation and setup complete!"
echo "Log out and log back in (or run 'newgrp docker') for the docker group changes to take effect."
echo "You can then run Docker commands without sudo."
