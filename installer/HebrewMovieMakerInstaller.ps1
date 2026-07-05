. "$PSScriptRoot\InstallLogger.ps1"
. "$PSScriptRoot\InstallProgress.ps1"
. "$PSScriptRoot\ProcessGuard.ps1"
. "$PSScriptRoot\InstallBackupManager.ps1"
. "$PSScriptRoot\LocalizationValidator.ps1"
. "$PSScriptRoot\VendorInstaller.ps1"

class MovieMakerHebrewInstaller {
    static [string] $InstallerVersion = '1.1.0'
    static [string] $BaseInstallDirectory = "${env:ProgramFiles(x86)}\Windows Movie Maker"
    static [string] $BaseSetupArguments = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-'

    [string] $PackageRoot
    [string] $InstallLanguage = 'Hebrew'
    [bool] $SkipSetup = $false
    [string] $HebrewPackRelative = 'hebrew-pack\Windows Live'
    [InstallBackupManager] $BackupManager
    [string[]] $WindowsLiveCandidates = @(
        "${env:ProgramFiles(x86)}\Windows Live",
        "$env:ProgramFiles\Windows Live"
    )
    [string[]] $HebrewFolders = @(
        'Photo Gallery\he',
        'Shared\he',
        'Installer\he'
    )

    MovieMakerHebrewInstaller([string] $packageRoot, [string] $installLanguage, [bool] $skipSetup) {
        $this.PackageRoot = $packageRoot
        $this.InstallLanguage = $installLanguage
        $this.SkipSetup = $skipSetup
        $this.BackupManager = [InstallBackupManager]::new([InstallLogger]::SessionId)
    }

    [void] WriteLog([string] $message, [string] $step) {
        [InstallLogger]::Info($message, $step)
    }

    [string] FindWindowsLivePath() {
        foreach ($candidate in $this.WindowsLiveCandidates) {
            if (Test-Path (Join-Path $candidate 'Photo Gallery\MovieMaker.exe')) {
                return $candidate
            }
        }

        return $null
    }

    [string] ResolveSetupPath() {
        $bundledPath = Join-Path $this.PackageRoot $script:BundledBaseInstallerName
        if (Test-Path $bundledPath) {
            return $bundledPath
        }

        return $null
    }

    [void] InstallMovieMaker() {
        $setupPath = $this.ResolveSetupPath()
        if (-not $setupPath) {
            throw 'Bundled Movie Maker 2012 base installer was not found.'
        }

        $setupHash = (Get-FileHash $setupPath -Algorithm SHA256).Hash
        $this.WriteLog("Running verified base installer: $setupPath", 'base-install')
        $this.WriteLog("Base installer SHA-256: $setupHash", 'base-install')
        [InstallProgress]::SetStatus('מתקין את Movie Maker...')

        $arguments = @(
            '/VERYSILENT',
            '/SUPPRESSMSGBOXES',
            '/NORESTART',
            '/SP-',
            "/DIR=`"$([MovieMakerHebrewInstaller]::BaseInstallDirectory)`""
        )

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

    [void] ApplyHebrewLocalization([string] $windowsLivePath) {
        [InstallProgress]::SetStatus('מגבה קבצי שפה קיימים...')
        foreach ($folder in $this.HebrewFolders) {
            $sourcePath = $this.ResolveHebrewSourcePath($folder)
            $targetPath = Join-Path $windowsLivePath $folder

            if (-not $sourcePath) {
                throw "Hebrew pack folder not found for: $folder"
            }

            if (-not (Test-Path $targetPath)) {
                New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
            }

            foreach ($file in Get-ChildItem -Path $sourcePath -File) {
                $targetFile = Join-Path $targetPath $file.Name
                $backupKey = Join-Path $folder $file.Name
                $this.BackupManager.BackupFile($targetFile, $backupKey)
            }
        }

        $this.BackupManager.SaveManifest()
        [InstallProgress]::SetStatus('מחיל קבצי עברית...')

        foreach ($folder in $this.HebrewFolders) {
            $sourcePath = $this.ResolveHebrewSourcePath($folder)
            $targetPath = Join-Path $windowsLivePath $folder
            Copy-Item -Path (Join-Path $sourcePath '*') -Destination $targetPath -Recurse -Force
            $this.WriteLog("Applied Hebrew localization: $targetPath", 'localization')
        }

        [InstallProgress]::SetStatus('מאמת התקנה...')
        [LocalizationValidator]::ValidateInstalledFiles($windowsLivePath, $this.PackageRoot)
        $this.WriteLog('Post-install validation passed.', 'validation')
    }

    [void] SkipHebrewLocalization([string] $windowsLivePath) {
        $this.WriteLog('English selected. Existing localization folders were not modified.', 'localization')
        if (-not (Test-Path (Join-Path $windowsLivePath 'Photo Gallery\MovieMaker.exe'))) {
            throw 'MovieMaker.exe was not found after installation.'
        }
    }

    [void] Install() {
        [ProcessGuard]::EnsureNotRunning()
        [InstallProgress]::Clear()

        try {
            if (-not $this.SkipSetup) {
                [InstallProgress]::SetStatus('מתחיל התקנת בסיס...')
                $this.InstallMovieMaker()
            }

            [InstallProgress]::SetStatus('ממתין ל-Windows Live...')
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

            $this.SkipHebrewLocalization($windowsLivePath)
        }
        catch {
            [InstallProgress]::SetStatus('משחזר גיבוי...')
            $this.BackupManager.RestoreAll()
            throw
        }
        finally {
            [InstallProgress]::Clear()
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
        [switch] $LocalizationOnly,
        [switch] $NoPrompt
    )

    if (-not $NoPrompt -and -not (Test-Administrator)) {
        $entryScript = Join-Path $PSScriptRoot 'Install-HebrewMovieMaker.ps1'
        $arguments = '-NoProfile -ExecutionPolicy Bypass -File "{0}" -PackageRoot "{1}" -Language {2}' -f $entryScript, $PackageRoot, $Language
        if ($LocalizationOnly.IsPresent) {
            $arguments += ' -LocalizationOnly'
        }
        Start-Process powershell.exe -Verb RunAs -ArgumentList $arguments -Wait
        return
    }

    try {
        [InstallLogger]::Initialize([MovieMakerHebrewInstaller]::InstallerVersion)
        [InstallLogger]::Info('Starting Movie Maker 2012 community installer', 'startup')

        $installer = [MovieMakerHebrewInstaller]::new($PackageRoot, $Language, $LocalizationOnly.IsPresent)
        $installer.Install()

        if (-not $NoPrompt) {
            Add-Type -AssemblyName System.Windows.Forms
            if ($Language -eq 'Hebrew') {
                $message = 'Movie Maker 2012 הותקן בהצלחה בעברית.'
                $title = 'ההתקנה הושלמה'
            } else {
                $message = 'Movie Maker 2012 installed successfully in English.'
                $title = 'Installation Complete'
            }

            [System.Windows.Forms.MessageBox]::Show(
                $message,
                $title,
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Information
            ) | Out-Null
        }
    }
    catch {
        [InstallLogger]::WriteException($_.Exception, 'failure')
        if (-not $NoPrompt) {
            Add-Type -AssemblyName System.Windows.Forms
            $title = if ($Language -eq 'Hebrew') { 'ההתקנה נכשלה' } else { 'Installation Failed' }
            [System.Windows.Forms.MessageBox]::Show(
                $_.Exception.Message,
                $title,
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error
            ) | Out-Null
        }
        exit 1
    }
}
