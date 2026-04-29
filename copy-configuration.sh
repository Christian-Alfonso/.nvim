#!/bin/bash
set -euo pipefail

#
# copy-configuration.sh
#
# Script for copying the Neovim configuration from this repo to its
# corresponding location on Ubuntu/WSL (~/.config/nvim)
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="$HOME/.config/nvim"

mkdir -p "$DEST"

# Copy all non-hidden files and directories (glob * excludes dotfiles by default)
for item in "$SCRIPT_DIR"/*; do
    cp -r "$item" "$DEST/"
done

echo "Neovim configuration copied to $DEST"
