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
        [Parameter(Position=0)][String]$Start = "$PWD",
        [Parameter(Mandatory)][String]$Directory
    )
    Write-Debug "Start=${Start}, Directory=${Directory}"
    $startingDir = $PWD
    try {
        $currentDir = Get-Item $Start
        while ($null -ne $currentDir) {
            Write-Debug "PS> Set-Location ${currentDir}"
            Set-Location $currentDir
            Write-Debug "PS> Get-ChildItem -Attribute 'Directory','Hidden' -Filter ${Directory} -ErrorAction SilentlyContinue"
            $desiredDir = Get-ChildItem -Attribute 'Directory','Hidden' -Filter $Directory -ErrorAction SilentlyContinue
            if (-not($?)) {
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
        [Parameter(Position=0, Mandatory, ValueFromRemainingArguments=$true)]
        [string[]] $Directory
    )
    foreach ($dir in $Directory) {
        $directoryLocation = Get-Item -Path $dir -ErrorAction SilentlyContinue
        if (-not($?)) {
            Write-Error "invalid directory ${dir}"
            continue
        }
        $directoryLoc = $directoryLocation.FullName
        Write-Debug "directory: ${directoryLoc}"
        if ($PSCmdlet.ShouldProcess($directoryLoc)) {
            Remove-Item -Path $directoryLoc -Recurse -Force
            Write-Debug "removed directory ${directoryLoc}"
        }
    }
}

Function Get-ChildItemWide {
    Get-ChildItem $args | Format-Wide -AutoSize
}

function Invoke-ConsoleTextEditor {
    $editor = 'notepad.exe'
    if ($IsLinux) {
        $editor = 'vim'
    }
    if ($env:EDITOR -ne '') {
        $editor = $env:EDITOR
    }
    if ([string]::IsNullOrEmpty($editor)) {
        throw 'could not determine an editor to run'
    }
    # & "${editor}" $args
    Start-Process -FilePath $editor -ArgumentList $args -NoNewWindow -Wait
}

function Invoke-GraphicalTextEditor {
    $editor = 'notepad.exe'
    if ($IsLinux) {
        $editor = 'gvim'
    }
    if ($env:VISUAL -ne '') {
        $editor = $env:VISUAL
    }
    if ([string]::IsNullOrEmpty($editor)) {
        throw 'could not determine a graphical editor to run'
    }
    Start-Process -FilePath $editor -ArgumentList $args -NoNewWindow
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
    if ($IsLinux) {
        mono "$(Join-Path $HOME 'bin' 'nuget.exe')" $args
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
    if (-not(Test-Path $Path)) {
        $null = New-Item $Path -Type Directory -Force
    }
    Set-Location $Path
}

function Clear-CsProjOutput {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)][string]$Path = $PWD
    )
    foreach ($csProjFile in (Get-ChildItem $Path -File -Filter '*.csproj' -Recurse)) {
        foreach ($outputDirectory in 'bin','obj') {
            $targetDirectory = Join-Path $csProjFile.Directory $outputDirectory
            if (-not(Test-Path $targetDirectory)) {
                continue
            }
            Remove-DirectoryWithRecurseForce $targetDirectory
        }
    }
}

function Set-DockerContext {
    param(
        [Parameter(Mandatory, Position = 0)][string]$Context
    )
    docker context use "${Context}"
}

Export-ModuleMember -Function 'Find-DirectoryFromParent','Remove-DirectoryWithRecurseForce','Get-ChildItemWide','Invoke-ConsoleTextEditor','Invoke-GraphicalTextEditor','Invoke-Docker','Invoke-DockerCompose','Invoke-Timetracker','Invoke-NuGet','Get-LastWeekTimesheet','Update-SvnRepo','New-DirectoryAndSetLocation','Set-DockerContext'
