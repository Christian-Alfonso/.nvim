# Install Neovim from their example in documentation:
# https://github.com/neovim/neovim/blob/master/INSTALL.md#pre-built-archives-1
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
sudo rm -f nvim-linux-x86_64.tar.gz

# Install Ripgrep and FD, which are both used by
# Telescope and possibly other plugins
apt install fd-find
apt install ripgrep

# Install build-essential metapackage, as Treesitter
# needs a compiler for each of the parsers that it installs
#
# Other compilers are available, but having build-essential
# is good to have installed regardless for building any other
# packages that do not have precompiled releases. Replace
# with any other compatible compiler as needed.
apt install build-essential

# Rust is required for installing the Treesitter CLI, make
# sure that it is installed:
# https://rust-lang.org/tools/install/
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Once Rust is installed, Treesitter CLI can be compiled
# from source since we also have a compiler from build-essential
cargo install --locked tree-sitter-cli

# TODO: Add CMake installation to allow Telescope to work properly
# https://linuxcapable.com/how-to-install-cmake-on-ubuntu-linux/