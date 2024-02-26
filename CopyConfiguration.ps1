Copy-Item -Path (Join-Path $PSScriptRoot *) -Destination "$env:LOCALAPPDATA\nvim" -Recurse -Force -Exclude .*
