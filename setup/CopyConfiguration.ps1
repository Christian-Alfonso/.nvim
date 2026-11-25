#
# CopyConfiguration.ps1
#
# Script for copying the Neovim configuration from this repo to its
# corresponding location in Windows (%LocalAppData%\nvim)
#

$Destination = Join-Path $env:LOCALAPPDATA "nvim"
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

New-Item -ItemType Directory -Path $Destination -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $RepoRoot "init.lua") -Destination $Destination -Force
Copy-Item -LiteralPath (Join-Path $RepoRoot "lua") -Destination $Destination -Recurse -Force
