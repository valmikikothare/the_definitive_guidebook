#!/usr/bin/env bash

mkdir -p ~/miniconda3

# Determine Cursor config directory based on OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    curl https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh -o ~/miniconda3/miniconda.sh
    bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o ~/miniconda3/miniconda.sh
    bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
elif [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "cygwin"* || "$OSTYPE" == "win32" ]]; then
    # Windows
    # TODO: Check if this works
    curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe -o ./miniconda.exe
    ./miniconda.exe /S
    rm ./miniconda.exe
else
    echo "Error: Unsupported operating system: $OSTYPE" >&2
    exit 1
fi

rm ~/miniconda3/miniconda.sh