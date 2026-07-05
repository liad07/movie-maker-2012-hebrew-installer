param(
    [string] $PackageRoot = $PSScriptRoot,
    [ValidateSet('Hebrew', 'English')]
    [string] $Language = 'Hebrew',
    [string] $InstallDirectory = "${env:ProgramFiles(x86)}\Windows Movie Maker",
    [switch] $LocalizationOnly,
    [switch] $NoPrompt
)

. "$PSScriptRoot\HebrewMovieMakerInstaller.ps1"
Start-HebrewMovieMakerInstall -PackageRoot $PackageRoot -Language $Language -InstallDirectory $InstallDirectory -LocalizationOnly:$LocalizationOnly -NoPrompt:$NoPrompt
