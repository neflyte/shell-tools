<#
.SYNOPSIS
    Given a starting directory and a desired directory name, find the desired directory by
    following the parent directories up to the root.
.PARAMETER Start
    The starting directory; if unspecified, the current directory is used.
.PARAMETER Directory
    Name of the directory to search for.
.OUTPUTS
    [System.IO.DirectoryInfo] The desired directory, if it exists; $null otherwise.
#>
function Find-DirectoryFromParent {
    [CmdletBinding()]
    [OutputType([System.IO.DirectoryInfo])]
    param(
        [String]$Start = $PWD.ToString(),
        [Parameter(Mandatory=$true)][String]$Directory
    )
    Write-Debug "Start=${Start}, Directory=${Directory}"
    $startingDir = $PWD
    try {
        $currentDir = Get-Item $Start
        while ($null -ne $currentDir) {
            Write-Debug "Set-Location $currentDir"
            Set-Location $currentDir
            Write-Debug "Get-ChildItem -Attribute 'Directory','Hidden' -Filter ${Directory} -ErrorAction SilentlyContinue -ErrorVariable getItemError"
            $desiredDir = Get-ChildItem -Attribute 'Directory','Hidden' -Filter $Directory -ErrorAction SilentlyContinue -ErrorVariable getItemError
            if ($getItemError) {
                Write-Error -ErrorRecord $getItemError
                return $null
                exit 1
            }
            if ($null -ne $desiredDir) {
                Write-Debug "found directory at $($desiredDir.FullName)"
                return $desiredDir
                exit 0
            }
            $currentDir = $currentDir.Parent
        }
        Write-Error "could not find directory ${Directory} in parent path hierarchy from ${Start}"
        return $null
        exit 1
    } finally {
        Set-Location $startingDir
    }
}
