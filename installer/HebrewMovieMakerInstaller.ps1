class MovieMakerHebrewInstaller {
    [string] $PackageRoot
    [string] $InstallLanguage = 'Hebrew'
    [bool] $SkipSetup = $false
    [string] $HebrewPackRelative = 'hebrew-pack\Windows Live'
    [string[]] $WindowsLiveCandidates = @(
        "${env:ProgramFiles(x86)}\Windows Live",
        "$env:ProgramFiles\Windows Live"
    )
    [string[]] $HebrewFolders = @(
        'Photo Gallery\he',
        'Shared\he',
        'Installer\he'
    )
    [string[]] $SetupCandidates = @(
        'MovieMaker2012-Base.exe',
        'Movie Maker 2012.exe',
        'Move Maker 2012.exe',
        'vendor\Movie Maker 2012.exe',
        'vendor\Move Maker 2012.exe'
    )

    MovieMakerHebrewInstaller([string] $packageRoot, [string] $installLanguage, [bool] $skipSetup) {
        $this.PackageRoot = $packageRoot
        $this.InstallLanguage = $installLanguage
        $this.SkipSetup = $skipSetup
    }

    [string] GetLogPath() {
        return Join-Path $env:TEMP 'MovieMaker2012-Hebrew-Setup.log'
    }

    [void] WriteLog([string] $message) {
        $line = ('{0:yyyy-MM-dd HH:mm:ss} {1}' -f (Get-Date), $message)
        Add-Content -Path $this.GetLogPath() -Value $line
    }

    [string] FindWindowsLivePath() {
        foreach ($candidate in $this.WindowsLiveCandidates) {
            if (Test-Path (Join-Path $candidate 'Photo Gallery\MovieMaker.exe')) {
                return $candidate
            }
        }

        return $null
    }

    [bool] IsMovieMakerInstalled() {
        return [bool]$this.FindWindowsLivePath()
    }

    [string] ResolveSetupPath() {
        foreach ($relativePath in $this.SetupCandidates) {
            $candidate = Join-Path $this.PackageRoot $relativePath
            if (Test-Path $candidate) {
                return $candidate
            }
        }

        return $null
    }

    [void] InstallMovieMaker([string] $installDirectory) {
        $setupPath = $this.ResolveSetupPath()
        if (-not $setupPath) {
            throw 'Base installer was not found.'
        }

        $this.WriteLog("Running base installer: $setupPath")
        $arguments = @('/VERYSILENT', '/SUPPRESSMSGBOXES', '/NORESTART', '/SP-', "/DIR=`"$installDirectory`"")
        $process = Start-Process -FilePath $setupPath -ArgumentList $arguments -Wait -PassThru

        if ($process.ExitCode -ne 0) {
            throw "Movie Maker setup failed with exit code $($process.ExitCode)"
        }
    }

    [string] ResolveHebrewSourcePath([string] $folder) {
        $candidates = @(
            Join-Path $this.PackageRoot (Join-Path $this.HebrewPackRelative $folder),
            Join-Path $this.PackageRoot (Join-Path 'assets\localization\Windows Live' $folder)
        )

        foreach ($candidate in $candidates) {
            if (Test-Path $candidate) {
                return $candidate
            }
        }

        return $null
    }

    [void] BackupLocalizationFolder([string] $targetPath) {
        if (-not (Test-Path $targetPath)) {
            return
        }

        $backupRoot = Join-Path $env:TEMP ('MovieMaker2012-he-backup-' + [Guid]::NewGuid().ToString('N'))
        $backupPath = Join-Path $backupRoot (Split-Path $targetPath -Leaf)
        New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
        Copy-Item -Path (Join-Path $targetPath '*') -Destination $backupPath -Recurse -Force
        $this.WriteLog("Backed up localization folder to: $backupPath")
    }

    [void] ApplyHebrewLocalization([string] $windowsLivePath) {
        foreach ($folder in $this.HebrewFolders) {
            $sourcePath = $this.ResolveHebrewSourcePath($folder)
            $targetPath = Join-Path $windowsLivePath $folder

            if (-not $sourcePath) {
                throw "Hebrew pack folder not found for: $folder"
            }

            $this.BackupLocalizationFolder($targetPath)

            if (-not (Test-Path $targetPath)) {
                New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
            }

            Copy-Item -Path (Join-Path $sourcePath '*') -Destination $targetPath -Recurse -Force
            $this.WriteLog("Applied Hebrew localization: $targetPath")
        }
    }

    [void] RemoveHebrewLocalization([string] $windowsLivePath) {
        foreach ($folder in $this.HebrewFolders) {
            $targetPath = Join-Path $windowsLivePath $folder
            if (Test-Path $targetPath) {
                $this.BackupLocalizationFolder($targetPath)
                Remove-Item -Path $targetPath -Recurse -Force
                $this.WriteLog("Removed Hebrew localization: $targetPath")
            }
        }
    }

    [void] Install([string] $installDirectory) {
        if (-not $this.SkipSetup) {
            $this.InstallMovieMaker($installDirectory)
        }

        $deadline = (Get-Date).AddMinutes(10)
        $windowsLivePath = $null

        while ((Get-Date) -lt $deadline) {
            $windowsLivePath = $this.FindWindowsLivePath()
            if ($windowsLivePath) {
                break
            }
            Start-Sleep -Seconds 2
        }

        if (-not $windowsLivePath) {
            throw 'Windows Live installation folder was not found after setup'
        }

        if ($this.InstallLanguage -eq 'Hebrew') {
            $this.ApplyHebrewLocalization($windowsLivePath)
            return
        }

        if ($this.InstallLanguage -eq 'English') {
            $this.RemoveHebrewLocalization($windowsLivePath)
        }
    }
}

function Test-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Start-HebrewMovieMakerInstall {
    param(
        [string] $PackageRoot = $PSScriptRoot,
        [ValidateSet('Hebrew', 'English')]
        [string] $Language = 'Hebrew',
        [string] $InstallDirectory = "${env:ProgramFiles(x86)}\Windows Movie Maker",
        [switch] $LocalizationOnly,
        [switch] $NoPrompt
    )

    if (-not $NoPrompt -and -not (Test-Administrator)) {
        $entryScript = Join-Path $PSScriptRoot 'Install-HebrewMovieMaker.ps1'
        $arguments = '-NoProfile -ExecutionPolicy Bypass -File "{0}" -PackageRoot "{1}" -Language {2} -InstallDirectory "{3}"' -f $entryScript, $PackageRoot, $Language, $InstallDirectory
        if ($LocalizationOnly.IsPresent) {
            $arguments += ' -LocalizationOnly'
        }
        Start-Process powershell.exe -Verb RunAs -ArgumentList $arguments -Wait
        return
    }

    try {
        $installer = [MovieMakerHebrewInstaller]::new($PackageRoot, $Language, $LocalizationOnly.IsPresent)
        $installer.WriteLog('Starting Movie Maker 2012 community installer')
        $installer.Install($InstallDirectory)

        if (-not $NoPrompt) {
            Add-Type -AssemblyName System.Windows.Forms
            $message = if ($Language -eq 'Hebrew') {
                'Movie Maker 2012 installed successfully in Hebrew.'
            } else {
                'Movie Maker 2012 installed successfully in English.'
            }

            [System.Windows.Forms.MessageBox]::Show(
                $message,
                'Installation Complete',
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Information
            ) | Out-Null
        }
    }
    catch {
        if (-not $NoPrompt) {
            Add-Type -AssemblyName System.Windows.Forms
            [System.Windows.Forms.MessageBox]::Show(
                $_.Exception.Message,
                'Installation Failed',
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error
            ) | Out-Null
        }
        throw
    }
}
