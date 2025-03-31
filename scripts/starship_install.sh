#!/usr/bin/env bash

# TODO: Add loading/saving of starship config
set -e

# Install Starship
curl -sS https://starship.rs/install.sh | sh -s -- --yes

# Add Starship to PATH
echo 'eval "$(starship init bash)"' >> ~/.bashrc

