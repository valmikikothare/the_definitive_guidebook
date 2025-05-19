#!/usr/bin/env bash

set -e

pushd /tmp
curl -Lo jetbrainsmono_nf.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip
unzip -qd jetbrainsmono_nf jetbrainsmono_nf.zip
sudo mv jetbrainsmono_nf/* /usr/local/share/fonts
rm -rf jetbrainsmono_nf*
sudo fc-cache -f -v
popd
