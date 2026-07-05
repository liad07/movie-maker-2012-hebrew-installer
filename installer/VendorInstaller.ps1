$script:SupportedVendorInstallerName = 'Movie Maker 2012.exe'
$script:BundledBaseInstallerName = 'MovieMaker2012-Base.exe'

function Get-SupportedVendorInstallerPath {
    param(
        [string] $Root
    )

    return Join-Path $Root (Join-Path 'vendor' $script:SupportedVendorInstallerName)
}

function Get-VendorInstallerPath {
    param(
        [string] $Root
    )

    $path = Get-SupportedVendorInstallerPath -Root $Root
    if (Test-Path $path) {
        return $path
    }

    return $null
}

function Test-VendorInstallerHash {
    param(
        [string] $InstallerPath,
        [string] $HashFile
    )

    if (-not (Test-Path $HashFile)) {
        throw 'Missing vendor\installer.sha256. Create it from your verified Movie Maker 2012.exe before building.'
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
