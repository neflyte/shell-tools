if (-not(Get-ChildItem variable:ShellToolsPredefinedLocations -ErrorAction Ignore)) {
    $locations = [PSCustomObject]@{
        srchome = Join-Path $HOME 'src'
    }
    $configFile = Join-Path $HOME '.config' 'ShellTools' 'locations.json'
    if (Test-Path $configFile) {
        Write-Verbose "Load predefined locations from ${configFile}"
        $locations = Get-Content $configFile -Raw | ConvertFrom-Json
    }
    if ($null -ne $locations) {
        Write-Verbose "Set locations to: $($locations | ConvertTo-Json -Compress)"
        Write-Debug "PS> New-Variable -Name ShellToolsPredefinedLocations -Scope Global -Option 'AllScope','ReadOnly' -Force -Value `$locations"
        New-Variable -Name ShellToolsPredefinedLocations -Scope Global -Option 'AllScope','ReadOnly' -Force -Value $locations
    }
}
