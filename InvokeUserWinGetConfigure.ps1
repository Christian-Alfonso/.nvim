<#
.SYNOPSIS
Runs a WinGet DSC configuration in the current user's non-elevated context.

.PARAMETER ConfigurationPath
Absolute path to a WinGet DSC YAML configuration file.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string] $ConfigurationPath
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $ConfigurationPath)) {
    throw "WinGet DSC configuration not found: $ConfigurationPath"
}

& winget.exe configure --enable
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

& winget.exe configure $ConfigurationPath
exit $LASTEXITCODE
