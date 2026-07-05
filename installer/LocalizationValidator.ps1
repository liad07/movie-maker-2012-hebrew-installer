class LocalizationValidator {
    static [object] LoadManifest([string] $packageRoot) {
        $candidates = @(
            Join-Path $packageRoot 'hebrew-pack\manifest.json',
            Join-Path $packageRoot 'assets\localization\manifest.json'
        )

        foreach ($path in $candidates) {
            if (Test-Path $path) {
                return Get-Content $path -Raw | ConvertFrom-Json
            }
        }

        throw 'Localization manifest was not found.'
    }

    static [void] ValidateInstalledFiles([string] $windowsLivePath, [string] $packageRoot) {
        $manifest = [LocalizationValidator]::LoadManifest($packageRoot)
        $missing = New-Object System.Collections.Generic.List[string]

        foreach ($entry in $manifest.files) {
            $targetPath = Join-Path $windowsLivePath $entry.relativePath
            if (-not (Test-Path $targetPath)) {
                $missing.Add($entry.relativePath) | Out-Null
                continue
            }

            $actualSize = (Get-Item $targetPath).Length
            if ($actualSize -ne [int]$entry.sizeBytes) {
                throw ('Localization file size mismatch: {0}. Expected {1}, got {2}.' -f $entry.relativePath, $entry.sizeBytes, $actualSize)
            }
        }

        if ($missing.Count -gt 0) {
            throw ('Missing localization files after install: {0}' -f ($missing -join ', '))
        }

        $movieMakerExe = Join-Path $windowsLivePath 'Photo Gallery\MovieMaker.exe'
        if (-not (Test-Path $movieMakerExe)) {
            throw 'MovieMaker.exe was not found after installation.'
        }
    }
}
