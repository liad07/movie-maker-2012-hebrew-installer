class ProcessGuard {
    static [string[]] $ProcessNames = @('MovieMaker', 'WLXPhotoGallery', 'PhotoGallery')

    static [string[]] GetRunningProcessNames() {
        $running = New-Object System.Collections.Generic.List[string]
        foreach ($name in [ProcessGuard]::ProcessNames) {
            if (Get-Process -Name $name -ErrorAction SilentlyContinue) {
                $running.Add($name) | Out-Null
            }
        }
        return $running.ToArray()
    }

    static [void] EnsureNotRunning() {
        $running = [ProcessGuard]::GetRunningProcessNames()
        if ($running.Count -eq 0) {
            return
        }

        throw ('Close these applications before continuing: {0}' -f ($running -join ', '))
    }
}
