New-Variable -Name ShellToolsPredefinedLocations -Scope Global -Option 'AllScope','ReadOnly' -Force -Value @{
    src = Join-Path $HOME 'src'
}
