# Third-Party Notices

## Microsoft components

This community installer may work with legacy Microsoft software and localization resources, including but not limited to:

- Windows Movie Maker
- Windows Live Photo Gallery
- Windows Live shared components
- Microsoft `.mui` localization files

These components remain the property of **Microsoft Corporation** and are **not** licensed under the MIT License of this repository.

Do not redistribute Microsoft binaries unless you have the legal right to do so.

## Hebrew localization resources (`assets/localization/`)

The `.mui` and `.resources.dll` files under `assets/localization/Windows Live/` are **Microsoft localization binaries** intended for Hebrew UI in Windows Live / Movie Maker 2012.

- **Origin:** Extracted from legitimate Windows Essentials / Windows Movie Maker 2012 installations.
- **Purpose:** Deployed automatically by this installer after a valid base install.
- **License:** Not MIT. Remains subject to Microsoft's terms for the original product.
- **Maintenance:** Paths and file names are curated by the community wrapper; the binary content is not re-authored.

You must obtain the base Movie Maker installer legally and ensure you have the right to use these localization files in your jurisdiction.

## Community installer wrapper

The installer wizard, PowerShell scripts, build pipeline, and packaging logic in this repository are authored by **Liad Kadosh (LK07)** and are licensed under the MIT License.

## .NET runtime

Release builds may bundle the **Microsoft .NET Desktop Runtime** as part of a self-contained publish. .NET is licensed separately under Microsoft's .NET license terms.
