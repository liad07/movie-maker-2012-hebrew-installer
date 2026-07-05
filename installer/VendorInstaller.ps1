function Get-VendorInstallerPath {
    param(
        [string] $Root
    )

    $names = @(
        'Movie Maker 2012.exe',
        'Move Maker 2012.exe',
        'wlsetup-all.exe'
    )

    foreach ($name in $names) {
        $path = Join-Path $Root (Join-Path 'vendor' $name)
        if (Test-Path $path) {
            return $path
        }
    }

    return $null
}

function Test-VendorInstallerHash {
    param(
        [string] $InstallerPath,
        [string] $HashFile
    )

    if (-not (Test-Path $HashFile)) {
        return
    }

    $expected = (Get-Content $HashFile -TotalCount 1).Trim().ToUpperInvariant()
    $actual = (Get-FileHash $InstallerPath -Algorithm SHA256).Hash.ToUpperInvariant()

    if ($actual -ne $expected) {
        throw 'Unsupported or modified Windows Essentials installer. SHA-256 mismatch.'
    }
}

function Write-ReleaseHash {
    param(
        [string] $FilePath,
        [string] $OutputPath
    )

    $hash = (Get-FileHash $FilePath -Algorithm SHA256).Hash
    @(
        "File: $(Split-Path $FilePath -Leaf)",
        "SHA-256: $hash"
    ) | Set-Content $OutputPath -Encoding ASCII

    return $hash
}
