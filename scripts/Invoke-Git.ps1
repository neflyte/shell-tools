param(
    [System.Management.Automation.Runspaces.PSSession]$session = $script:DEFAULTSESSION,
    [string[]]$Arguments
)
[string[]]$action = @('git')
$action += $Arguments
$action += '2>&1'
[ScriptBlock]$action = [ScriptBlock]::Create($action)
if ($null -eq $env:GIT_REDIRECT_STDERR) {
    $env:GIT_REDIRECT_STDERR = '2>&1'
}
if ($session) {
    $allOutput = Invoke-Command -Session $session -ScriptBlock $action
} else {
    $allOutput = & $action
}
$execErrors = $allOutput | Where-Object { $_ -is [System.Management.Automation.ErrorRecord] }
$result = $allOutput | Where-Object { $_ -isnot [System.Management.Automation.ErrorRecord] }
if ($execErrors) {
    $execErrors | Write-Error
    exit 1
}
$result
