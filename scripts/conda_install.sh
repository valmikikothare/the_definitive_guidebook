#!/usr/bin/env bash

set -e

script_dir=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
source "$script_dir/utils.sh"

# Make sure curl is installed
sudo apt-get install curl

# Remove previous miniconda install and create new directory
rm -rf ~/miniconda3
mkdir -p ~/miniconda3

# Determine conda install commands based on OS
case "$platform" in
    "mac")
        curl https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh -o ~/miniconda3/miniconda.sh
        bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
        rm ~/miniconda3/miniconda.sh
        ;;
    "linux")
        curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o ~/miniconda3/miniconda.sh
        bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
        rm ~/miniconda3/miniconda.sh
        ;;
    "windows")
        # TODO: Check if this works
        curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe -o ./miniconda.exe
        ./miniconda.exe /S
        rm ./miniconda.exe
        ;;
    *)
        echo "Error: Unsupported operating system: $platform" >&2
        exit 1
        ;;
esac

source ~/miniconda3/bin/activate
conda init --all
