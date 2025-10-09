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