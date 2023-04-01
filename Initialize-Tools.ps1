<#
Initialize-Tools.ps1 -- Scripts/Tools Environment Init
#>
if ($args.Count -eq 0 -or $args[0] -eq "") {
    Write-Error "this script should not be invoked manually"
    exit 1
}
if (-not(Test-Path $args[0])) {
    Write-Error "invalid directory specified"
    exit 1
}
$env:TOOLS_HOME = $args[0]
#
# Functions
if (-not(Test-Path env:TOOLS_FUNCTIONS_PATH)) {
    $env:TOOLS_FUNCTIONS_PATH = "${env:TOOLS_HOME}\functions"
}
if (Test-Path $env:TOOLS_FUNCTIONS_PATH) {
    $functionScripts = Get-ChildItem $env:TOOLS_FUNCTIONS_PATH -Filter *.inc.ps1
    foreach ($functionScript in $functionScripts) {
        . $functionScript
    }
}
#
# Modules
Import-Module "${env:TOOLS_HOME}/modules/GitFunctions/GitFunctions.psm1" -Scope Global -Force
#
# Aliases
if (-not(Test-Path env:TOOLS_ALIASES_FILE)) {
    $env:TOOLS_ALIASES_FILE = "aliases.ps1"
}
if (-not(Test-Path env:TOOLS_ALIASES_PATH)) {
    $env:TOOLS_ALIASES_PATH = "${env:TOOLS_HOME}\aliases\${env:TOOLS_ALIASES_FILE}"
}
if (Test-Path -PathType Leaf $env:TOOLS_ALIASES_PATH) {
    . $env:TOOLS_ALIASES_PATH
}
#
# Scripts (TBD)
