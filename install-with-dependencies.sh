#!/bin/bash
set -euo pipefail

#
# install-with-dependencies.sh
#
# Script for automatically setting up a new Neovim installation (assumes Ubuntu)
# along with installing all dependencies needed for plugins to work
#

# Script needs to be run as root, exit otherwise
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# Install Neovim from their example in documentation:
# https://github.com/neovim/neovim/blob/master/INSTALL.md#pre-built-archives-1
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
sudo rm -f nvim-linux-x86_64.tar.gz

# Install Ripgrep and FD, which are both used by
# Telescope and possibly other plugins
apt install fd-find -y
apt install ripgrep -y

# Install build-essential metapackage, as Treesitter
# needs a compiler for each of the parsers that it installs
#
# Other compilers are available, but having build-essential
# is good to have installed regardless for building any other
# packages that do not have precompiled releases. Replace
# with any other compatible compiler as needed.
#
# Clang is needed as well, since it is a dependency for building
# and installing Treesitter CLI in the next steps from Cargo
apt install build-essential -y
apt install clang -y

# Rust is required for installing the Treesitter CLI, make
# sure that it is installed:
# https://rust-lang.org/tools/install/
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Source the .cargo environment variable as recommended by
# Rustup to configure the shell right away for the next command
# to install a package from Cargo
. "$HOME/.cargo/env"

# Once Rust is installed, Treesitter CLI can be compiled
# from source since we also have a compiler from build-essential.
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
sudo "$CMAKE_INSTALLER" --skip-license --prefix=/usr/local --verbose
rm -f "$CMAKE_INSTALLER"

echo "Neovim installation complete!"
