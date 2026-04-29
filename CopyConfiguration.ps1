#
# CopyConfiguration.ps1
#
# Script for copying the Neovim configuration from this repo to its
# corresponding location in Windows (%LocalAppData%\nvim)
#

Copy-Item -Path (Join-Path $PSScriptRoot *) -Destination "$env:LOCALAPPDATA\nvim" -Recurse -Force -Exclude .*
