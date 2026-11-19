#
# CopyConfiguration.ps1
#
# Script for copying the Neovim configuration from this repo to its
# corresponding location in Windows (%LocalAppData%\nvim)
#

$Destination = Join-Path $env:LOCALAPPDATA "nvim"

New-Item -ItemType Directory -Path $Destination -Force | Out-Null
Copy-Item -Path (Join-Path $PSScriptRoot *) -Destination $Destination -Recurse -Force -Exclude .*
