$ErrorActionPreference = 'Stop'

function Get-DotNetExecutable {
    $userDotNet = Join-Path $env:USERPROFILE '.dotnet\dotnet.exe'
    if (Test-Path $userDotNet) {
        return $userDotNet
    }

    return 'dotnet'
}

$root = Split-Path $PSScriptRoot -Parent
$buildScript = Join-Path $root 'installer\Build-HebrewSetup.ps1'
$captureScript = Join-Path $PSScriptRoot 'Capture-WizardScreenshots.ps1'
$dotnet = Get-DotNetExecutable

Write-Host '=== Step 1/3: Build release ==='
& $buildScript

Write-Host '=== Step 2/3: Capture screenshots + GIF ==='
& $captureScript

Write-Host '=== Step 3/3: Verify release hash ==='
$releaseExe = Join-Path $root 'dist\MovieMaker2012-Hebrew-Setup.exe'
$hashFile = Join-Path $root 'dist\MovieMaker2012-Hebrew-Setup.sha256'

if (-not (Test-Path $releaseExe)) {
    throw "Release EXE missing: $releaseExe"
}

$actualHash = (Get-FileHash $releaseExe -Algorithm SHA256).Hash
$expectedLine = Get-Content $hashFile | Where-Object { $_ -like 'SHA-256:*' } | Select-Object -First 1
$expectedHash = ($expectedLine -split ':', 2)[1].Trim()

if ($actualHash -ne $expectedHash) {
    throw "Release hash mismatch. Expected $expectedHash but got $actualHash"
}

Write-Host 'Build-All completed successfully.'
Write-Host "Release: $releaseExe"
Write-Host "SHA-256: $actualHash"
Write-Host "Screenshots: $(Join-Path $root 'docs\screenshots')"
Write-Host "GIF: $(Join-Path $root 'docs\wizard-demo.gif')"
