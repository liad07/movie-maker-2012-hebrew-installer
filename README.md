# Windows Movie Maker 2012 Community Installer
### Hebrew and English Setup for Modern Windows

**COMMUNITY INSTALLER BY LIAD KADOSH · LK07**  
[github.com/liad07](https://github.com/liad07)

> **עברית:** מתקין קהילתי מאוחד ל־Windows Movie Maker 2012 — התקנה בעברית או באנגלית עבור Windows 10 ו־Windows 11, בלי העתקות ידניות.

---

## Overview

A community-maintained installer wrapper that restores **Windows Movie Maker 2012** on modern Windows with a **classic Windows setup wizard flow** and automatic **Hebrew or English** UI configuration.

This project is **not affiliated with Microsoft**.

---

## The Problem

Microsoft discontinued Windows Movie Maker in 2017. Since then, Hebrew-speaking users often had to:

| Issue | Impact |
|-------|--------|
| Use archived offline installers | No official Microsoft download |
| Install in English first | No built-in Hebrew setup path |
| Manually copy `.mui` folders | Error-prone and confusing |
| Follow video guides | Fragile, unprofessional experience |
| Mix EXE + folders + scripts | Not a unified installer |

The old workaround worked — but it was manual, inconsistent, and hard to trust.

---

## Our Solution

This project provides a **single community installer** that:

1. Shows a **classic Windows setup wizard flow**
2. Lets the user choose **Hebrew or English**
3. Runs the legacy base installer silently
4. Automatically deploys the selected language pack
5. Writes an installation log to `%TEMP%\MovieMaker2012-Hebrew-Setup.log`

```
┌──────────────────┐    ┌─────────────────────┐    ┌────────────────────────┐
│ Community Wizard │ → │ Legacy base install  │ → │ Language pack deployment│
│   (WinForms)     │    │ (user-provided EXE) │    │ he/ folders → Windows Live│
└──────────────────┘    └─────────────────────┘    └────────────────────────┘
```

---

## Features

- Single release EXE for end users
- Hebrew / English language selection
- Classic Windows installer-style UI
- Existing-install detection with repair prompt
- Localization backup before overwrite
- SHA-256 release verification support
- Build-time hash validation for the base installer
- Install logging
- Clear legal separation from Microsoft binaries

---

## Compatibility

| OS | Status |
|----|--------|
| Windows 11 64-bit | Tested |
| Windows 10 64-bit | Tested |
| Windows 8.1 | Not tested |
| Windows 7 | Experimental |

Requires **Administrator** privileges and about **85 MB** free disk space.

---

## SmartScreen Notice

Because the release EXE is currently **not code-signed**, Windows SmartScreen may show an **Unknown publisher** warning.

This is expected for unsigned community tools that request administrator access. Verify the SHA-256 hash from the release notes before running.

---

## Quick Start

### End users

1. Download `MovieMaker2012-Hebrew-Setup.exe` from [Releases](../../releases)
2. Verify SHA-256 using `MovieMaker2012-Hebrew-Setup.sha256`
3. Run as Administrator
4. Complete the wizard:
   - Welcome
   - Destination
   - Language
   - Ready to Install
   - Installing
   - Finish

### Developers

```powershell
git clone https://github.com/liad07/movie-maker-2012-hebrew.git
cd movie-maker-2012-hebrew

# Place your legally obtained base installer in vendor/
# Accepted names: Movie Maker 2012.exe / Move Maker 2012.exe

powershell -ExecutionPolicy Bypass -File installer\Build-HebrewSetup.ps1
```

Output:

```text
dist\MovieMaker2012-Hebrew-Setup.exe
dist\MovieMaker2012-Hebrew-Setup.sha256
```

---

## Installation Flow

| Step | Screen | What happens |
|------|--------|--------------|
| 1 | Welcome | Introduction and existing-install check |
| 2 | Select Destination | Base installer target folder |
| 3 | Select Program Language | Hebrew or English |
| 4 | Ready to Install | Summary of bundled components |
| 5 | Installing | Silent base install + localization |
| 6 | Finish | Done |

### Important behavior notes

- **Destination folder** controls the legacy base installer location (`Program Files (x86)\Windows Movie Maker` by default).
- **Program runtime files** are also deployed under `Program Files (x86)\Windows Live`.
- The **Ready to Install** screen is informational. The bundled Movie Maker package installs its required dependencies together.
- The wizard does **not** expose fake per-component toggles.

---

## Project Structure

```text
movie-maker-2012-hebrew/
├── README.md
├── LICENSE
├── SECURITY.md
├── THIRD_PARTY_NOTICES.md
├── assets/localization/
├── vendor/
├── installer/
│   ├── Build-HebrewSetup.ps1
│   ├── VendorInstaller.ps1
│   ├── HebrewMovieMakerInstaller.ps1
│   └── SetupLauncher/
├── scripts/
└── dist/
```

---

## Build Integrity

Optional base-installer validation:

```powershell
(Get-FileHash "vendor\Movie Maker 2012.exe" -Algorithm SHA256).Hash | Set-Content vendor\installer.sha256
```

If `vendor/installer.sha256` exists, the build fails on mismatch.

Each release should publish:

```text
MovieMaker2012-Hebrew-Setup.exe
MovieMaker2012-Hebrew-Setup.sha256
```

---

## Troubleshooting

| Problem | What to try |
|---------|-------------|
| SmartScreen warning | Verify SHA-256, click **More info → Run anyway** |
| Access denied | Run as Administrator |
| Movie Maker still in English | Re-run installer and choose Hebrew |
| Setup failed | Open `%TEMP%\MovieMaker2012-Hebrew-Setup.log` |
| Already installed | Choose **Yes** on the repair/update prompt |

---

## Legal Notice

- The **installer wrapper and scripts** in this repository are licensed under MIT.
- **Microsoft Windows Movie Maker**, Windows Live components, and related binaries remain the property of **Microsoft Corporation**.
- This repository does **not** redistribute Microsoft installers in source control.
- Release packages may bundle a user-provided legacy installer for convenience. You are responsible for ensuring you have the right to use and distribute any third-party binaries you include in a release.

See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

---

## Author

**Liad Kadosh (LK07)**  
GitHub: [github.com/liad07](https://github.com/liad07)

---

## License

MIT for community wrapper code — see [LICENSE](LICENSE)
