#
# InstallDependencies.ps1
#
# Script for automatically installing all basic dependencies that are needed by Neovim
# to enable basic functionality for every plugin used in the configuration.
#

#Requires -RunAsAdministrator

# Idempotent Visual Studio Build Tools 2022 installer/updater
# Installs or updates MSVC v143 toolset + Windows 11 SDK (22000)
function InstallVisualStudioBuildTools() {
    $BuildToolsPath = "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools"

    Write-Host "Checking for existing Visual Studio Build Tools installation..."

    $VSBuildToolsInstaller = "$TempFolder\vs_buildtools.exe"

    # Always download the latest VS Build Tools installer in case it is stale
    Write-Host "Downloading Visual Studio Build Tools bootstrapper..."
    Invoke-WebRequest `
        -Uri "https://aka.ms/vs/17/release/vs_BuildTools.exe" `
        -OutFile $VSBuildToolsInstaller

    # Add required components for Rust + Tree-sitter
    $Arguments = @(
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

    if (Test-Path $BuildToolsPath) {
        Write-Host "Existing Build Tools installation found. Updating components..."
    }
    else {
        Write-Host "No Build Tools installation found. Installing fresh..."
    }

    # Install or update VS Build Tools
    Start-Process -FilePath $VSBuildToolsInstaller -ArgumentList $Arguments -Wait -NoNewWindow

    Write-Host "Visual Studio Build Tools installation/update complete."
}

# Idempotent Rust installer/updater
# Installs or updates Rustup + Cargo
function InstallRust() {
    # Install or update Rust via rustup
    if (Get-Command "rustup" -ErrorAction SilentlyContinue) {
        Write-Host "rustup found. Updating Rust toolchain..."
        & rustup update
    }
    else {
        Write-Host "rustup not found. Downloading and installing Rust..."
        $RustupInstaller = "$TempFolder\rustup-init.exe"
        Invoke-WebRequest -Uri "https://win.rustup.rs/x86_64" -OutFile $RustupInstaller
        & $RustupInstaller -y
        # rustup modifies the user PATH but the change won't be reflected in the
        # current session, so add cargo's bin directory manually for the steps below
        $Env:PATH = "$Env:USERPROFILE\.cargo\bin;$Env:PATH"
    }

    # Install Tree-sitter CLI
    if (Get-Command "cargo" -ErrorAction SilentlyContinue) {
        # Build from source, requires MSVC compiler installed
        # from Visual Studio Build Tools in Neovim DSC file
        & cargo install --locked tree-sitter-cli
    }
    else {
        throw "cargo not found after Rust installation. Please restart your terminal and re-run the script."
    }
}

# Create a temp folder for downloading the installer, if it does not exist
$TempFolder = New-Item -ItemType Directory -Force -Path "$PSScriptRoot\temp"

# Enable WinGet DSC before any winget configure calls below. This is required
# for winget configure to work and only needs to run once (subsequent runs are
# a no-op).
winget configure --enable

# Install Neovim and its dependencies (Windows SDK, ripgrep, fd, CMake) via DSC.
# .nvim/InstallDependencies.ps1 is still called below to add those tools to
# the system PATH, since WinGet does not always do this automatically.
$NeovimConfig = "$PSScriptRoot\neovim.dsc.yaml"
winget configure $NeovimConfig

InstallVisualStudioBuildTools

# Base paths to look for the installed programs
$RipGrepPath = "$Env:LOCALAPPDATA\Microsoft\WinGet\Packages\BurntSushi.ripgrep.MSVC_Microsoft.Winget.Source_8wekyb3d8bbwe"
$FdPath = "$Env:LOCALAPPDATA\Microsoft\WinGet\Packages\sharkdp.fd_Microsoft.Winget.Source_8wekyb3d8bbwe"
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

InstallRust

# Clean up by removing all temporary files now that they are no longer needed
# (always download new ones on next script execution so these are not stale)
Remove-Item -Recurse -Force $TempFolder

Write-Host "Neovim configuration complete!"