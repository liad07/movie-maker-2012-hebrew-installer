class InstallProgress {
    static [string] $ProgressPath = [System.IO.Path]::Combine($env:TEMP, 'MovieMaker2012-Hebrew-Setup.progress')

    static [void] SetStatus([string] $status) {
        Set-Content -Path [InstallProgress]::ProgressPath -Value $status -Encoding UTF8
    }

    static [void] Clear() {
        if (Test-Path [InstallProgress]::ProgressPath) {
            Remove-Item [InstallProgress]::ProgressPath -Force
        }
    }
}
