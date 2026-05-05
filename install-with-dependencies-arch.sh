#!/bin/bash
set -euo pipefail

#
# install-with-dependencies-arch.sh
#
# Script for automatically setting up a new Neovim installation (Arch Linux)
# along with installing all dependencies needed for plugins to work
#

# Script needs to be run as root, exit otherwise
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# Always sync package databases and upgrade first
pacman -Syu --noconfirm

# Git does not come with Arch by default, so it needs to be installed first thing
pacman -S --noconfirm --needed git

# Install Neovim from their example in documentation:
# https://github.com/neovim/neovim/blob/master/INSTALL.md#pre-built-archives-1
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
rm -rf /opt/nvim-linux-x86_64
tar -C /opt -xzf nvim-linux-x86_64.tar.gz
rm -f nvim-linux-x86_64.tar.gz

# Install Ripgrep and FD, which are both used by
# Telescope and possibly other plugins
pacman -S --noconfirm --needed fd
pacman -S --noconfirm --needed ripgrep

# Install base-devel metapackage, as Treesitter
# needs a compiler for each of the parsers that it installs
#
# Other compilers are available, but having base-devel
# is good to have installed regardless for building any other
# packages that do not have precompiled releases. Replace
# with any other compatible compiler as needed.
#
# Clang is needed as well, since it is a dependency for building
# and installing Treesitter CLI in the next steps from Cargo
pacman -S --noconfirm --needed base-devel
pacman -S --noconfirm --needed clang

# Rust is required for installing the Treesitter CLI, make
# sure that it is installed:
# https://rust-lang.org/tools/install/
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Source the .cargo environment variable as recommended by
# Rustup to configure the shell right away for the next command
# to install a package from Cargo
. "$HOME/.cargo/env"

# Once Rust is installed, Treesitter CLI can be compiled
# from source since we also have a compiler from base-devel.
# Install to /usr/local so the binary is on PATH for all users,
# which is needed for Neovim to be able to find and use it.
cargo install --locked --root /usr/local tree-sitter-cli

# CMake needs to be installed for Telescope plugin to work properly,
# find the latest tagged version from GitHub releases and install that
echo "Installing CMake from sources..."

CMAKE_VERSION=$(curl -s https://api.github.com/repos/Kitware/CMake/releases/latest | grep '"tag_name"' | sed 's/.*"tag_name": "v\([^"]*\)".*/\1/')
CMAKE_INSTALLER=$(mktemp /tmp/cmake-installer-XXXXXX.sh)
curl -L "https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.sh" -o "$CMAKE_INSTALLER"
chmod +x "$CMAKE_INSTALLER"
"$CMAKE_INSTALLER" --skip-license --prefix=/usr/local --verbose
rm -f "$CMAKE_INSTALLER"

echo "Neovim installation complete!"
