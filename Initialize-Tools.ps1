<#
.SYNOPSIS
    Initialize the tools system
.PARAMETER HomePath
    The path to the tools directory
#>
param(
    [Parameter(Mandatory,Position=0)][String]$HomePath
)
if ([string]::IsNullOrEmpty($HomePath) -or -not(Test-Path $HomePath)) {
    Write-Error 'invalid directory specified'
    exit 1
}
$env:TOOLS_HOME = $HomePath
#
# Load PSStyle for Windows PowerShell 5.1
if ($PSVersionTable.PSVersion.Major -eq 5) {
    Import-Module PSStyle -Force -ErrorAction SilentlyContinue
    if (-not($?)) {
        Write-Error 'Could not load PSStyle module; install it for PSStyle support'
    }
}
#
# Functions
$env:TOOLS_FUNCTIONS_PATH = Join-Path $env:TOOLS_HOME 'functions'
if (Test-Path $env:TOOLS_FUNCTIONS_PATH) {
    foreach ($functionScript in (Get-ChildItem $env:TOOLS_FUNCTIONS_PATH -Filter '*.inc.ps1')) {
        . $functionScript
    }
}
#
# Modules
$modulesPath = Join-Path $env:TOOLS_HOME 'modules'
if (-not([string]::IsNullOrEmpty($env:PSModulePath))) {
    $modulesPath += [System.IO.Path]::PathSeparator + $env:PSModulePath
}
$env:PSModulePath = $modulesPath
#
# Aliases
$env:TOOLS_ALIASES_FILE = 'aliases.ps1'
$env:TOOLS_ALIASES_PATH = Join-Path (Join-Path $env:TOOLS_HOME 'aliases') $env:TOOLS_ALIASES_FILE
if (Test-Path -PathType Leaf $env:TOOLS_ALIASES_PATH) {
    . "${env:TOOLS_ALIASES_PATH}"
}
