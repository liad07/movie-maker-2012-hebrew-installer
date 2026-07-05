# Security Policy

## Supported versions

| Version | Supported |
|---------|-----------|
| Latest GitHub Release | Yes |
| Source builds from `main` | Best effort |

## Reporting a vulnerability

If you believe you found a security issue in the community installer wrapper, please report it privately:

- GitHub: [github.com/liad07](https://github.com/liad07)

Please include:

- Windows version
- Installer version or commit hash
- Steps to reproduce
- Log file from `%TEMP%\MovieMaker2012-Hebrew-Setup.log`

## SmartScreen and code signing

Release builds are currently **unsigned**. Windows SmartScreen may show an "Unknown publisher" warning. This is expected until a code-signing certificate is added.

## Integrity verification

Each release should include a SHA-256 file:

```text
dist/MovieMaker2012-Hebrew-Setup.sha256
```

Verify before running:

```powershell
Get-FileHash .\MovieMaker2012-Hebrew-Setup.exe -Algorithm SHA256
```

## Scope

Security reports related to the discontinued Microsoft Movie Maker product itself are outside the scope of this repository.
