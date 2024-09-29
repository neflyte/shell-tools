param()
@('TestWindow','EditParameterDialog').ForEach{
    Remove-Module $_ -Force -ErrorAction SilentlyContinue
}
$consoleGuiTools = 'Microsoft.PowerShell.ConsoleGuiTools'
Import-Module $consoleGuiTools
$module = (Get-Module $consoleGuiTools -List).ModuleBase
@('Terminal.Gui.dll','NStack.dll').ForEach{
    Add-Type -Path (Join-Path $module $_)
}
& (Join-Path $PSScriptRoot 'Run.ps1')
