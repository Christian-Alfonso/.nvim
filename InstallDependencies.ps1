# Install Ripgrep and FD, which are both used by
# Telescope and possibly other plugins
winget install --id BurntSushi.ripgrep.MSVC --source winget
winget install --id sharkdp.fd --source winget

# Install LLVM, as Treesitter needs a compiler for
# each of the parsers that it installs
#
# Other compilers are available, can use gcc from
# MSYS2 on Windows, but this is the quickest and
# easiest install to deal with for Windows
winget install --id LLVM.LLVM --source winget
