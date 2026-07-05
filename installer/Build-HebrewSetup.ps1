$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\VendorInstaller.ps1"

function Get-DotNetExecutable {
    $userDotNet = Join-Path $env:USERPROFILE '.dotnet\dotnet.exe'
    if (Test-Path $userDotNet) {
        return $userDotNet
    }

    return 'dotnet'
}

$dotnet = Get-DotNetExecutable
$root = Split-Path $PSScriptRoot -Parent
$launcherRoot = Join-Path $PSScriptRoot 'SetupLauncher'
$staging = Join-Path $env:TEMP 'MovieMaker2012Payload'
$zipPath = Join-Path $launcherRoot 'payload.zip'
$hebrewSource = Join-Path $root 'assets\localization\Windows Live'
$manifestSource = Join-Path $root 'assets\localization\manifest.json'
$outputDir = Join-Path $root 'dist'
$hashFile = Join-Path $root 'vendor\installer.sha256'
$canonicalVendorPath = Get-SupportedVendorInstallerPath -Root $root
$legacyTypoPath = Join-Path $root 'vendor\Move Maker 2012.exe'

if (-not (Test-Path $canonicalVendorPath) -and (Test-Path $legacyTypoPath)) {
    Copy-Item $legacyTypoPath $canonicalVendorPath -Force
    Write-Warning 'Renamed legacy vendor file to Movie Maker 2012.exe for this build.'
}

$setupSource = Get-VendorInstallerPath -Root $root
if (-not $setupSource) {
    throw 'Missing vendor\Movie Maker 2012.exe. Place the verified Windows Movie Maker 2012 offline installer at that exact path.'
}

if (-not (Test-Path $hashFile)) {
    (Get-FileHash $setupSource -Algorithm SHA256).Hash | Set-Content $hashFile -Encoding ASCII
    Write-Warning 'Created vendor\installer.sha256 from the supplied base installer.'
}

Test-VendorInstallerHash -InstallerPath $setupSource -HashFile $hashFile

if (-not (Test-Path $hebrewSource)) {
    throw 'Missing Hebrew localization: assets\localization\Windows Live'
}

if (-not (Test-Path $manifestSource)) {
    throw 'Missing localization manifest: assets\localization\manifest.json'
}

if (Test-Path $staging) {
    Remove-Item $staging -Recurse -Force
}

New-Item -ItemType Directory -Path $staging -Force | Out-Null
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null

Copy-Item $setupSource (Join-Path $staging 'MovieMaker2012-Base.exe')

$moduleFiles = @(
    'HebrewMovieMakerInstaller.ps1',
    'Install-HebrewMovieMaker.ps1',
    'VendorInstaller.ps1',
    'InstallLogger.ps1',
    'InstallProgress.ps1',
    'ProcessGuard.ps1',
    'InstallBackupManager.ps1',
    'LocalizationValidator.ps1'
)

foreach ($moduleFile in $moduleFiles) {
    Copy-Item (Join-Path $PSScriptRoot $moduleFile) (Join-Path $staging $moduleFile)
}

New-Item -ItemType Directory -Path (Join-Path $staging 'hebrew-pack') -Force | Out-Null
Copy-Item $manifestSource (Join-Path $staging 'hebrew-pack\manifest.json')

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

$payloadHash = (Get-FileHash $zipPath -Algorithm SHA256).Hash
$generatedIntegrityFile = Join-Path $launcherRoot 'PayloadIntegrity.generated.cs'
@(
    'namespace SetupLauncher',
    '{',
    '    internal static partial class PayloadIntegrity',
    '    {',
    ('        public const string ExpectedPayloadSha256 = "{0}";' -f $payloadHash),
    '    }',
    '}'
) | Set-Content $generatedIntegrityFile -Encoding UTF8

$publishOutput = Join-Path $launcherRoot 'publish'
if (Test-Path $publishOutput) {
    Remove-Item $publishOutput -Recurse -Force
}

& $dotnet publish $launcherRoot -c Release -o $publishOutput

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
Write-Output ('Version: 1.1.0')
Write-Output ('SHA-256: {0}' -f $releaseHash)
Write-Output ('Size MB: {0}' -f $sizeMb)
