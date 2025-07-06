if (-not(Get-ChildItem variable:ShellToolsPredefinedLocations -ErrorAction SilentlyContinue)) {
    $locations = [PSCustomObject]@{
        src = Join-Path $HOME 'src'
    }
    $configDir = Join-Path $HOME '.config'
    if ($IsWindows) {
        $configDir = $env:APPDATA
    }
    $configFile = Join-Path $configDir 'ShellTools' 'locations.json'
    if (Test-Path $configFile) {
        $locations = Get-Content $configFile -Raw | ConvertFrom-Json
    }
    Write-Debug "Set locations to: $($locations | ConvertTo-Json -Compress)"
    New-Variable -Name ShellToolsPredefinedLocations -Scope Global -Option 'AllScope','ReadOnly' -Force -Value $locations
}
