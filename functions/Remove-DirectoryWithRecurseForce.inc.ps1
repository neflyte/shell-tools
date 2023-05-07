function Remove-DirectoryWithRecurseForce {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true)][string]$Directory
    )
    $directoryLocation = Get-Item -Path $Directory -ErrorAction SilentlyContinue -ErrorVariable locationError
    if ($locationError -ne '') {
        Write-Error "invalid directory ${Directory}: ${locationError}"
        return
    }
    Write-Debug "directory: $($directoryLocation.FullName)"
    if ($PSCmdlet.ShouldProcess($directoryLocation.FullName)) {
        $directoryLocation | Remove-Item -Recurse -Force
        Write-Debug "removed directory $($directoryLocation.FullName)"
    }
}
