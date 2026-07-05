param(
    [string] $PackageRoot = $PSScriptRoot,
    [ValidateSet('Hebrew', 'English')]
    [string] $Language = 'Hebrew',
    [switch] $LocalizationOnly,
    [switch] $NoPrompt
)

. "$PSScriptRoot\HebrewMovieMakerInstaller.ps1"
Start-HebrewMovieMakerInstall -PackageRoot $PackageRoot -Language $Language -LocalizationOnly:$LocalizationOnly -NoPrompt:$NoPrompt
