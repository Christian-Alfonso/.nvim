#
# InstallDependencies.ps1
#
# Script for automatically installing all basic dependencies that are needed by Neovim
# to enable basic functionality for every plugin used in the configuration.
#

#Requires -RunAsAdministrator

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

# Base paths to look for the installed programs
$RipGrepPath = "$Env:LOCALAPPDATA\Microsoft\WinGet\Packages\BurntSushi.ripgrep.MSVC_Microsoft.Winget.Source_8wekyb3d8bbwe"
$FdPath = "$Env:LOCALAPPDATA\Microsoft\WinGet\Packages\sharkdp.fd_Microsoft.Winget.Source_8wekyb3d8bbwe\fd-v10.3.0-x86_64-pc-windows-msvc"
$LLVMPath = "C:\Program Files\LLVM\bin"

# Take the first subdirectory of these base paths, which will contain the
# version of the installed program, and therefore must be found dynamically
$RipGrepVersionPath = Get-ChildItem -Path $RipGrepPath -Directory | Select-Object -First 1
$FdVersionPath = Get-ChildItem -Path $FdPath -Directory | Select-Object -First 1

# All of these packages do not seem to do a great job of adding
# themselves to the PATH variable after installation, so it needs
# to be done manually to ensure they are accessible from terminal
#
# The normal "SetEnvironmentVariable" command does not seem to play
# very well with the PATH variable for some reason, so we use this
# registry hack to add them instead. Taken from this comment:
# https://www.reddit.com/r/PowerShell/comments/1c4ds4x/comment/kzn7au6/
#
# Check whether the PATH variables have been written before, and skip
# writing them if they are already on the PATH

$PATHValuesToAdd = @(
    ";$LLVMPath"
    ";$RipGrepVersionPath"
    ";$FdVersionPath"
)

# Get the existing PATH contents to see if the variables are already in there
$Key = Get-Item "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
$ExistingPATH = $Key.GetValue("PATH", "", "DoNotExpandEnvironmentNames")

$NewPath = $ExistingPATH
$PATHChanged = $false

foreach ($Value in $PATHValuesToAdd) {
    if (-not $ExistingPATH.Contains($Value)) {
        $NewPath += $Value
        $PATHChanged = $true
    }
    else {
        Write-Warning "Skipping adding to PATH: $($Value.TrimStart(";"))"
    }
}

if ($PATHChanged) {
    if ($NewPath -eq $ExistingPATH) {
        throw "PATH should have changed, but new and existing PATH strings are the same"
    }

    # Write the new PATH to the registry
    New-ItemProperty                                                               `
        -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" `
        -Name PATH                                                                 `
        -Value $NewPath                                                            `
        -PropertyType ExpandString                                                 `
        -Force
}
else {
    Write-Warning "All variables already in PATH; skip writing"
}
