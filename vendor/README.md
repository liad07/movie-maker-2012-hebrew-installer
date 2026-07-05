# Base Windows Essentials / Movie Maker installer

Place **your own legally obtained copy** of the legacy Windows Movie Maker 2012 offline installer in this folder.

## Accepted file names

```
Movie Maker 2012.exe
Move Maker 2012.exe
wlsetup-all.exe
```

The build script renames the file internally to `MovieMaker2012-Base.exe`.

## Optional integrity check

To verify the base installer before building, create `vendor/installer.sha256` containing a single SHA-256 line:

```powershell
(Get-FileHash "vendor\Movie Maker 2012.exe" -Algorithm SHA256).Hash
```

If `installer.sha256` exists, the build fails when the hash does not match.

## Important

This repository does **not** distribute Microsoft binaries.
You must supply the base installer yourself for local builds.
