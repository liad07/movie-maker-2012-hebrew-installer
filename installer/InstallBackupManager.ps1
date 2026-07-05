class InstallBackupManager {
    [string] $SessionId
    [string] $BackupRoot
    [string] $ManifestPath
    [System.Collections.Generic.List[object]] $Entries

    InstallBackupManager([string] $sessionId) {
        $this.SessionId = $sessionId
        $this.BackupRoot = Join-Path (Join-Path $env:ProgramData 'MovieMaker2012CommunityInstaller\backups') $sessionId
        $this.ManifestPath = Join-Path $this.BackupRoot 'manifest.json'
        $this.Entries = New-Object System.Collections.Generic.List[object]
    }

    [void] BackupFile([string] $sourcePath, [string] $relativeKey) {
        if (-not (Test-Path $sourcePath)) {
            return
        }

        $destination = Join-Path $this.BackupRoot $relativeKey
        $destinationDirectory = Split-Path $destination -Parent
        if (-not (Test-Path $destinationDirectory)) {
            New-Item -ItemType Directory -Path $destinationDirectory -Force | Out-Null
        }

        Copy-Item -Path $sourcePath -Destination $destination -Force
        $this.Entries.Add([pscustomobject]@{
            key = $relativeKey
            originalPath = $sourcePath
            backupPath = $destination
        }) | Out-Null
    }

    [void] SaveManifest() {
        if (-not (Test-Path $this.BackupRoot)) {
            New-Item -ItemType Directory -Path $this.BackupRoot -Force | Out-Null
        }

        $payload = @{
            sessionId = $this.SessionId
            createdUtc = (Get-Date).ToUniversalTime().ToString('o')
            entries = $this.Entries
        }
        $payload | ConvertTo-Json -Depth 5 | Set-Content -Path $this.ManifestPath -Encoding UTF8
    }

    [void] RestoreAll() {
        if (-not (Test-Path $this.ManifestPath)) {
            return
        }

        $manifest = Get-Content $this.ManifestPath -Raw | ConvertFrom-Json
        foreach ($entry in $manifest.entries) {
            if (-not (Test-Path $entry.backupPath)) {
                continue
            }

            $originalDirectory = Split-Path $entry.originalPath -Parent
            if (-not (Test-Path $originalDirectory)) {
                New-Item -ItemType Directory -Path $originalDirectory -Force | Out-Null
            }

            Copy-Item -Path $entry.backupPath -Destination $entry.originalPath -Force
        }
    }

    static [string] GetLatestBackupRoot() {
        $root = Join-Path $env:ProgramData 'MovieMaker2012CommunityInstaller\backups'
        if (-not (Test-Path $root)) {
            return $null
        }

        $latest = Get-ChildItem -Path $root -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if (-not $latest) {
            return $null
        }

        return $latest.FullName
    }
}
