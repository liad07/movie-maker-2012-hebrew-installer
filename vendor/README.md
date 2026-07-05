# Base Windows Movie Maker 2012 installer

Place **your own legally obtained copy** of the legacy Windows Movie Maker 2012 offline installer in this folder using this exact file name:

```text
Movie Maker 2012.exe
```

## Verified build requirement

Create `vendor/installer.sha256` containing one SHA-256 line for that file:

```powershell
(Get-FileHash "vendor\Movie Maker 2012.exe" -Algorithm SHA256).Hash | Set-Content vendor\installer.sha256
```

The build **fails** if:

* the file is missing
* the hash file is missing
* the hash does not match

During packaging the verified installer is renamed internally to `MovieMaker2012-Base.exe`.

## Supported silent switches

Only this verified base installer is executed, using tested Inno Setup switches:

```text
/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP- /DIR="..."
```

## Important

This repository does **not** distribute Microsoft binaries.
You must supply the base installer yourself for local builds and releases.
