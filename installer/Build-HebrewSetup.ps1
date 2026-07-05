$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\VendorInstaller.ps1"

$root = Split-Path $PSScriptRoot -Parent
$launcherRoot = Join-Path $PSScriptRoot 'SetupLauncher'
$staging = Join-Path $env:TEMP 'MovieMaker2012Payload'
$zipPath = Join-Path $launcherRoot 'payload.zip'
$hebrewSource = Join-Path $root 'assets\localization\Windows Live'
$outputDir = Join-Path $root 'dist'
$hashFile = Join-Path $root 'vendor\installer.sha256'

$setupSource = Get-VendorInstallerPath -Root $root
if (-not $setupSource) {
    throw 'Missing base installer in vendor\. Expected Movie Maker 2012.exe or Move Maker 2012.exe'
}

Test-VendorInstallerHash -InstallerPath $setupSource -HashFile $hashFile

if (-not (Test-Path $hebrewSource)) {
    throw 'Missing Hebrew localization: assets\localization\Windows Live'
}

if (Test-Path $staging) {
    Remove-Item $staging -Recurse -Force
}

New-Item -ItemType Directory -Path $staging -Force | Out-Null
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null

Copy-Item $setupSource (Join-Path $staging 'MovieMaker2012-Base.exe')
Copy-Item (Join-Path $PSScriptRoot 'HebrewMovieMakerInstaller.ps1') $staging
Copy-Item (Join-Path $PSScriptRoot 'Install-HebrewMovieMaker.ps1') $staging
Copy-Item (Join-Path $PSScriptRoot 'VendorInstaller.ps1') $staging

$hebrewFolders = @('Photo Gallery\he', 'Shared\he', 'Installer\he')
foreach ($folder in $hebrewFolders) {
    $sourceFolder = Join-Path $hebrewSource $folder
    if (-not (Test-Path $sourceFolder)) {
        throw ('Missing Hebrew folder: {0}' -f $sourceFolder)
    }

    $targetFolder = Join-Path $staging (Join-Path 'hebrew-pack\Windows Live' $folder)
    Copy-Item $sourceFolder $targetFolder -Recurse
}

if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}

Compress-Archive -Path (Join-Path $staging '*') -DestinationPath $zipPath -Force

$publishOutput = Join-Path $launcherRoot 'publish'
if (Test-Path $publishOutput) {
    Remove-Item $publishOutput -Recurse -Force
}

dotnet publish $launcherRoot -c Release -o $publishOutput

$builtExe = Join-Path $publishOutput 'MovieMaker2012-Hebrew-Setup.exe'
$rootOutput = Join-Path $outputDir 'MovieMaker2012-Hebrew-Setup.exe'
$hashOutput = Join-Path $outputDir 'MovieMaker2012-Hebrew-Setup.sha256'

if (-not (Test-Path $builtExe)) {
    throw 'Setup EXE was not created by dotnet publish'
}

Copy-Item $builtExe $rootOutput -Force
$releaseHash = Write-ReleaseHash -FilePath $rootOutput -OutputPath $hashOutput

$sizeMb = [math]::Round((Get-Item $rootOutput).Length / 1MB, 2)
Write-Output ('Created: {0}' -f $rootOutput)
Write-Output ('SHA-256: {0}' -f $releaseHash)
Write-Output ('Size MB: {0}' -f $sizeMb)
