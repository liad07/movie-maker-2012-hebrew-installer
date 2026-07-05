param(
    [string] $BackupRoot = ''
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\..\installer\InstallBackupManager.ps1"
. "$PSScriptRoot\..\installer\InstallLogger.ps1"

if ([string]::IsNullOrWhiteSpace($BackupRoot)) {
    $BackupRoot = [InstallBackupManager]::GetLatestBackupRoot()
}

if (-not $BackupRoot -or -not (Test-Path $BackupRoot)) {
    throw 'No localization backup was found under ProgramData.'
}

$manager = [InstallBackupManager]::new((Split-Path $BackupRoot -Leaf))
$manager.BackupRoot = $BackupRoot
$manager.ManifestPath = Join-Path $BackupRoot 'manifest.json'
$manager.RestoreAll()

Write-Output "Restored localization backup from: $BackupRoot"
Write-Output "Log: $([InstallLogger]::LogPath)"
