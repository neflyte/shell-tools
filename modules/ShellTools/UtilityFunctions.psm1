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
            }
            if ($null -ne $desiredDir) {
                Write-Debug "found directory at $($desiredDir.FullName)"
                return $desiredDir
            }
            $currentDir = $currentDir.Parent
        }
        Write-Error "could not find directory ${Directory} in parent path hierarchy from ${Start}"
        return $null
    } finally {
        Set-Location $startingDir
    }
}

function Remove-DirectoryWithRecurseForce {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Directory
    )
    $directoryLocation = Get-Item -Path $Directory -ErrorAction SilentlyContinue -ErrorVariable locationError
    if ($locationError) {
        throw "invalid directory ${Directory}: ${locationError}"
    }
    $directoryLoc = $directoryLocation.FullName
    Write-Debug "directory: ${directoryLoc}"
    if ($PSCmdlet.ShouldProcess($directoryLoc)) {
        Remove-Item -Path $directoryLoc -Recurse -Force
        Write-Debug "removed directory ${directoryLoc}"
    }
}

Function Get-ChildItemWide {
    Get-ChildItem $args | Format-Wide -AutoSize
}

function Invoke-ConsoleTextEditor {
    $editor = 'notepad.exe'
    if ($PSVersionTable.Platform -eq 'Unix') {
        $editor = 'vim'
    }
    if ($null -ne $env:EDITOR) {
        $editor = $env:EDITOR
    }
    & $editor $args
}

function Invoke-GraphicalTextEditor {
    $editor = 'notepad.exe'
    if ($PSVersionTable.Platform -eq 'Unix') {
        $editor = 'gvim'
    }
    if ($null -ne $env:VISUAL) {
        $editor = $env:VISUAL
    }
    Start-Process $editor -ArgumentList @($args) -NoNewWindow
}

function Invoke-Docker {
    docker $args
}

function Invoke-DockerCompose {
    docker-compose $args
}

function Invoke-Timetracker {
    timetracker $args
}

Function Invoke-NuGet {
    if ($PSVersionTable.OS -like 'Linux*') {
        mono $(Join-Path $HOME 'bin' 'nuget.exe') $args
    } else {
        nuget $args
    }
}

function Get-LastWeekTimesheet {
    $calendar = (Get-Culture).Calendar
    $today = Get-Date
    $lastWeek = $calendar.AddWeeks($today, -1)
    $dayOfLastWeek = [int]$lastWeek.DayOfWeek
    $startOfLastWeek = $lastWeek
    if ($dayOfLastWeek -gt 0) {
        $startOfLastWeek = $calendar.AddDays($lastWeek, -1 * $dayOfLastWeek)
    }
    $endOfLastWeek = $lastWeek
    if ($dayOfLastWeek -lt 6) {
        $endOfLastWeek = $calendar.AddDays($lastWeek, 6 - $dayOfLastWeek)
    }
    $tempOutput = New-TemporaryFile
    try {
        $startDate = $startOfLastWeek.ToString('yyyy-MM-dd')
        $endDate = $endOfLastWeek.ToString('yyyy-MM-dd')
        $ttArgs = @(
            '--logLevel warning',
            "--startDate $startDate",
            "--endDate $endDate",
            "--exportCSV $($tempOutput.FullName)"
        )
        Write-Debug "timetracker timesheet report ${ttArgs}"
        timetracker timesheet report $ttArgs
        $report = Get-Content $tempOutput | ConvertFrom-Csv
        return $report
    } finally {
        $tempOutput.Delete()
    }
}

Function Update-SvnRepo {
    svn update
}

function New-DirectoryAndSetLocation {
    param(
        [Parameter(Mandatory,Position=0)][string]$Path
    )
    $null = New-Item $Path -Type Directory -Force
    Set-Location $Path
}
