#
# InstallDependencies.ps1
#
# Script for automatically installing all basic dependencies that are needed by Neovim
# to enable basic functionality for every plugin used in the configuration.
#

#Requires -RunAsAdministrator

function InstallVisualStudioBuildTools() {
    # Idempotent Visual Studio Build Tools 2022 installer/updater
    # Installs or updates MSVC v143 toolset + Windows 11 SDK (22000)

    $buildToolsPath = "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools"

    Write-Host "Checking for existing Visual Studio Build Tools installation..."

    # 1. Download bootstrapper if needed
    $installer = "$env:TEMP\vs_buildtools.exe"
    if (-not (Test-Path $installer)) {
        Write-Host "Downloading Visual Studio Build Tools bootstrapper..."
        Invoke-WebRequest `
            -Uri "https://aka.ms/vs/17/release/vs_BuildTools.exe" `
            -OutFile $installer
    }

    # 2. Required components for Rust + Tree-sitter
    $arguments = @(
        "--quiet",
        "--wait",
        "--norestart",
        "--nocache",

        # Workload: C++ Build Tools
        "--add", "Microsoft.VisualStudio.Workload.VCTools",

        # MSVC compiler + linker
        "--add", "Microsoft.VisualStudio.Component.VC.Tools.x86.x64",
        "--add", "Microsoft.VisualStudio.Component.VC.CoreIde"
    )

    # 3. Install or update
    if (Test-Path $buildToolsPath) {
        Write-Host "Existing Build Tools installation found. Updating components..."
    }
    else {
        Write-Host "No Build Tools installation found. Installing fresh..."
    }

    Start-Process -FilePath $installer -ArgumentList $arguments -Wait -NoNewWindow

    Write-Host "Visual Studio Build Tools installation/update complete."
}

# Enable WinGet DSC before any winget configure calls below. This is required
# for winget configure to work and only needs to run once (subsequent runs are
# a no-op).
winget configure --enable

# Install Neovim and its dependencies (ripgrep, fd, LLVM) via DSC.
# .nvim/InstallDependencies.ps1 is still called below to add those tools to
# the system PATH, since WinGet does not always do this automatically.
$NeovimConfig = "$PSScriptRoot\neovim.dsc.yaml"
winget configure $NeovimConfig

InstallVisualStudioBuildTools

# Base paths to look for the installed programs
$RipGrepPath = "$Env:LOCALAPPDATA\Microsoft\WinGet\Packages\BurntSushi.ripgrep.MSVC_Microsoft.Winget.Source_8wekyb3d8bbwe"
$FdPath = "$Env:LOCALAPPDATA\Microsoft\WinGet\Packages\sharkdp.fd_Microsoft.Winget.Source_8wekyb3d8bbwe\fd-v10.3.0-x86_64-pc-windows-msvc"
# $LLVMPath = "C:\Program Files\LLVM\bin"
$VSBuildToolsPath = "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC"

# Take the first subdirectory of these base paths, which will contain the
# version of the installed program, and therefore must be found dynamically
$RipGrepVersionPath = Get-ChildItem -Path $RipGrepPath -Directory | Select-Object -First 1
$FdVersionPath = Get-ChildItem -Path $FdPath -Directory | Select-Object -First 1
$VSBuildToolsVersionPath = Get-ChildItem -Path $VSBuildToolsPath -Directory | Select-Object -First 1

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
    ";$VSBuildToolsVersionPath\bin\Hostx64\x64"
    ";$RipGrepVersionPath"
    ";$FdVersionPath"
)

# Get the existing PATH contents to see if the variables are already in there
$Key = Get-Item "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
$ExistingPATH = $Key.GetValue("PATH", "", "DoNotExpandEnvironmentNames")

$NewPATH = $ExistingPATH
$PATHChanged = $false

foreach ($Value in $PATHValuesToAdd) {
    if (-not $ExistingPATH.Contains($Value)) {
        $NewPATH += $Value
        $PATHChanged = $true
    }
    else {
        Write-Warning "Skipping adding to PATH: $($Value.TrimStart(";"))"
    }
}

if ($PATHChanged) {
    if ($NewPATH -eq $ExistingPATH) {
        throw "PATH should have changed, but new and existing PATH strings are the same"
    }

    # Write the new PATH to the registry
    New-ItemProperty                                                               `
        -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" `
        -Name PATH                                                                 `
        -Value $NewPATH                                                            `
        -PropertyType ExpandString                                                 `
        -Force
}
else {
    Write-Warning "All variables already in PATH; skip writing"
}

# Reload PATH
$Env:PATH = "$NewPATH;$ExistingPATH;$Env:PATH"

# Install Tree-sitter CLI
if (Get-Command "cargo" -ErrorAction SilentlyContinue) {
    # Build from source, requires MSVC compiler installed
    # from Visual Studio Build Tools in Neovim DSC file
    & cargo install --locked tree-sitter-cli
}
else {
    Write-Host "Executable not found in PATH."
}
