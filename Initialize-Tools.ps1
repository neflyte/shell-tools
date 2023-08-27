using namespace System.IO

<#
.SYNOPSIS
    Initialize the tools system
.PARAMETER HomePath
    The path to the tools directory
#>
param(
    [Parameter(Mandatory=$true)][String]$HomePath
)
if (-not(Test-Path $HomePath)) {
    Write-Error 'invalid directory specified'
    exit 1
}
$env:TOOLS_HOME = $HomePath
#
# Functions
if ($null -eq $env:TOOLS_FUNCTIONS_PATH -or -not(Test-Path $env:TOOLS_FUNCTIONS_PATH)) {
    $env:TOOLS_FUNCTIONS_PATH = Join-Path $env:TOOLS_HOME 'functions'
}
if (Test-Path $env:TOOLS_FUNCTIONS_PATH) {
    $functionScripts = Get-ChildItem $env:TOOLS_FUNCTIONS_PATH -Filter *.inc.ps1
    foreach ($functionScript in $functionScripts) {
        . $functionScript
    }
}
#
# Modules
$modulesPath = Join-Path $env:TOOLS_HOME 'modules'
$env:PSModulePath = $modulesPath + [Path]::PathSeparator + $env:PSModulePath
Import-Module GitFunctions -Force
Import-Module UtilityFunctions -Force
#
# Aliases
if ($null -eq $env:TOOLS_ALIASES_FILE -or -not(Test-Path $env:TOOLS_ALIASES_FILE)) {
    $env:TOOLS_ALIASES_FILE = 'aliases.ps1'
}
if ($null -eq $env:TOOLS_ALIASES_PATH -or -not(Test-Path $env:TOOLS_ALIASES_PATH)) {
    $env:TOOLS_ALIASES_PATH = Join-Path $env:TOOLS_HOME 'aliases' $env:TOOLS_ALIASES_FILE
}
if (Test-Path -PathType Leaf $env:TOOLS_ALIASES_PATH) {
    . $env:TOOLS_ALIASES_PATH
}
