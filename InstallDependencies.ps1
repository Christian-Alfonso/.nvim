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

# LLVM does not seem to add itself to the PATH
# variable, so it needs to be done manually
[System.Environment]::SetEnvironmentVariable("Path", $Env:PATH + ";C:\Program Files\LLVM\bin", "User")
