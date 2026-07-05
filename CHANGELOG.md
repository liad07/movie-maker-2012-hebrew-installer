# Changelog

## 1.1.0 — 2026-07-05

### Added
- Single verified base installer policy (`Movie Maker 2012.exe` + mandatory SHA-256)
- Localization manifest with post-install validation (19 files)
- Backup manager under `%ProgramData%` with rollback on failure
- `scripts/Restore-LocalizationBackup.ps1`
- Process guard for open Movie Maker / Photo Gallery
- Live install status in wizard (progress file polling)
- Session-based unified logging (session ID, Windows version, step)
- Known limitations, FAQ, and size guidance in README

### Changed
- Replaced misleading destination picker with informational location screen
- English selection no longer deletes existing `he` folders
- Reapply prompt wording when Movie Maker is already installed
- Version bumped to 1.1.0

### Fixed
- Backup rollback on localization failure
- Build copies all PowerShell install modules and manifest into payload

## 1.0.0 — 2026-07-05

### Added
- Hebrew RTL setup wizard
- Unified install engine (PowerShell only; C# UI wrapper)
- GitHub Actions build verification
- Screenshots, GIF, payload integrity verification
