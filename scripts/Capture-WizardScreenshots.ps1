param(
    [string] $ScreenshotsDir = (Join-Path (Split-Path $PSScriptRoot -Parent) 'docs\screenshots'),
    [string] $OutputGif = (Join-Path (Split-Path $PSScriptRoot -Parent) 'docs\wizard-demo.gif')
)

$ErrorActionPreference = 'Stop'

function Get-DotNetExecutable {
    $userDotNet = Join-Path $env:USERPROFILE '.dotnet\dotnet.exe'
    if (Test-Path $userDotNet) {
        return $userDotNet
    }

    return 'dotnet'
}

$root = Split-Path $PSScriptRoot -Parent
$launcherRoot = Join-Path $root 'installer\SetupLauncher'
$dotnet = Get-DotNetExecutable

New-Item -ItemType Directory -Path $ScreenshotsDir -Force | Out-Null

if (-not (Test-Path (Join-Path $launcherRoot 'payload.zip'))) {
    $stub = Join-Path $env:TEMP 'mm-screenshot-stub'
    if (Test-Path $stub) { Remove-Item $stub -Recurse -Force }
    New-Item -ItemType Directory -Path $stub -Force | Out-Null
    Set-Content -Path (Join-Path $stub 'readme.txt') -Value 'stub'
    Compress-Archive -Path (Join-Path $stub '*') -DestinationPath (Join-Path $launcherRoot 'payload.zip') -Force
}

$publishDir = Join-Path $launcherRoot 'publish-screenshots'
if (Test-Path $publishDir) {
    Remove-Item $publishDir -Recurse -Force
}

& $dotnet publish $launcherRoot -c Release -o $publishDir | Out-Host

$launcherExe = Join-Path $publishDir 'MovieMaker2012-Hebrew-Setup.exe'
if (-not (Test-Path $launcherExe)) {
    throw "Screenshot launcher was not built: $launcherExe"
}

Write-Host "Capturing wizard screenshots to $ScreenshotsDir"
& $launcherExe --capture-screenshots "$ScreenshotsDir"

$frames = Get-ChildItem -Path $ScreenshotsDir -Filter '0*.png' | Sort-Object Name
if ($frames.Count -eq 0) {
    throw 'No screenshots were captured.'
}

Write-Host "Creating GIF: $OutputGif"
$resolvedScreenshots = (Resolve-Path $ScreenshotsDir).Path
$resolvedGif = Join-Path (Resolve-Path (Split-Path $OutputGif -Parent)).Path (Split-Path $OutputGif -Leaf)
& $launcherExe --create-gif "$resolvedScreenshots" "$resolvedGif"

Write-Host "Created $($frames.Count) screenshots and GIF at $OutputGif"
