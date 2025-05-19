#!/usr/bin/env bash

set -e

script_dir=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
source "$script_dir/utils.sh"
configs_dir=$(get_parent_dir $scripts_dir 1)/cursor


if [ "$#" -ne 1 ]; then
    print_error "Usage: cursor_install.sh <path-to-cursor-appimage>"
    exit 1
fi

install_dir="/opt/cursor/"
sudo mkdir -p $install_dir
sudo chown $USER:$USER $install_dir
cp $1 $install_dir
cp 
