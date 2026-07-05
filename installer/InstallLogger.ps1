class InstallLogger {
    static [string] $SessionId = [guid]::NewGuid().ToString('N')
    static [string] $LogPath = [System.IO.Path]::Combine($env:TEMP, 'MovieMaker2012-Hebrew-Setup.log')
    static [bool] $Initialized = $false

    static [void] Initialize([string] $installerVersion) {
        if ([InstallLogger]::Initialized) {
            return
        }

        [InstallLogger]::Initialized = $true
        $header = @(
            "SessionId=$([InstallLogger]::SessionId)",
            "InstallerVersion=$installerVersion",
            "WindowsVersion=$([System.Environment]::OSVersion.VersionString)",
            "Machine=$([System.Environment]::MachineName)"
        )

        foreach ($line in $header) {
            [InstallLogger]::Write('INFO', $line, 'startup')
        }
    }

    static [void] Info([string] $message, [string] $step) {
        [InstallLogger]::Write('INFO', $message, $step)
    }

    static [void] Error([string] $message, [string] $step) {
        [InstallLogger]::Write('ERROR', $message, $step)
    }

    static [void] Write([string] $level, [string] $message, [string] $step) {
        $stepPart = if ([string]::IsNullOrWhiteSpace($step)) { '-' } else { $step }
        $line = ('{0:yyyy-MM-dd HH:mm:ss} [{1}] [session:{2}] [step:{3}] {4}' -f (Get-Date), $level, [InstallLogger]::SessionId, $stepPart, $message)
        Add-Content -Path [InstallLogger]::LogPath -Value $line
    }

    static [void] WriteException([System.Exception] $exception, [string] $step) {
        [InstallLogger]::Error($exception.Message, $step)
        if ($exception.InnerException) {
            [InstallLogger]::Error('Inner: ' + $exception.InnerException.Message, $step)
        }
        if ($exception.StackTrace) {
            [InstallLogger]::Error('Stack: ' + $exception.StackTrace, $step)
        }
    }
}
