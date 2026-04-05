using namespace System.Net.Sockets

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
        [Parameter(Position=0)][String]$Start = "${PWD}",
        [Parameter(Mandatory)][String]$Directory
    )
    Write-Debug "Start=${Start}, Directory=${Directory}"
    Write-Debug "PS> Get-Item ${Start} -ErrorAction SilentlyContinue"
    $currentDir = Get-Item $Start -ErrorAction SilentlyContinue
    while ($null -ne $currentDir) {
        Write-Debug "PS> Get-ChildItem ${currentDir} -Attribute Directory,Hidden -Filter ${Directory} -ErrorAction SilentlyContinue"
        $desiredDir = Get-ChildItem ${currentDir} -Attribute Directory,Hidden -Filter $Directory -ErrorAction SilentlyContinue
        if (-not($?)) {
            $err = $Error[0]
            Write-Error "error getting items in ${currentDir}: ${err}"
            return $null
        }
        if ($null -ne $desiredDir) {
            Write-Verbose "found directory at $($desiredDir.FullName)"
            return $desiredDir
        }
        $currentDir = $currentDir.Parent
    }
    Write-Error "could not find directory ${Directory} in parent path hierarchy from ${Start}"
    return $null
}

function Remove-DirectoryWithRecurseForce {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position=0, Mandatory, ValueFromRemainingArguments=$true)]
        [string[]] $Directory
    )
    foreach ($dir in $Directory) {
        $directoryLocation = Get-Item -Path $dir -ErrorAction SilentlyContinue
        if (-not($?) -or $null -eq $directoryLocation) {
            $err = $Error[0]
            Write-Error "invalid directory ${dir}: ${err}"
            continue
        }
        Write-Debug "directory: $($directoryLocation.FullName)"
        if ($PSCmdlet.ShouldProcess($directoryLocation.FullName)) {
            Remove-Item -Path $directoryLocation.FullName -Recurse -Force -ErrorAction SilentlyContinue
            if (-not($?)) {
                $err = $Error[0]
                Write-Error "failed to remove directory $($directoryLocation.FullName): ${err}"
                continue
            }
            Write-Debug "removed directory $($directoryLocation.FullName)"
        }
    }
}

function Get-ChildItemWide {
    param(
        [Parameter(Position=0)][string]$Directory = $PWD
    )
    Get-ChildItem $Directory -Attributes Normal,Directory,Hidden | Format-Wide -AutoSize
}

function Get-ChildItemLong {
    param(
        [Parameter(Position=0)][string]$Directory = $PWD
    )
    Get-ChildItem $Directory -Attributes Normal,Directory,Hidden | Format-Table -AutoSize -Wrap
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

function Build-JabbaPs1 {
    param(
        [Parameter(Mandatory)][string]$JabbaHome
    )
    <# /home/linuxbrew/.linuxbrew/opt/jabba #>

    if (-not(Test-Path $JabbaHome))
    {
        throw "Jabba home path '${JabbaHome}' is invalid"
    }

    $jabbaPs1Path = Join-Path $JabbaHome 'jabba.ps1'
    $jabbaBinPath = Join-Path $JabbaHome 'bin' 'jabba'
    if ($IsWindows)
    {
        $jabbaBinPath += '.exe'
    }

    $jabbaPs1 = @"
`$env:JABBA_HOME="${JabbaHome}"

function jabba
{
    `$fd3=`$([System.IO.Path]::GetTempFileName())
    `$command="& '${jabbaBinPath}' `$args --fd3 ```"`$fd3```""
    & { `$env:JABBA_SHELL_INTEGRATION="ON"; Invoke-Expression `$command }
    `$fd3content=`$(Get-Content `$fd3)
    if (`$fd3content) {
        `$expression=`$fd3content.replace("export ","```$env:").replace("unset ","Remove-Item env:") -join "``n"
        if (-not `$expression -eq "") { Invoke-Expression `$expression }
    }
    Remove-Item -Force `$fd3
}
"@
    Set-Content -Path $jabbaPs1Path -Value $jabbaPs1 -Force
    Write-Host "Wrote ${jabbaPs1Path} successfully"
}

function Start-VSDevShell {
    if (-not($IsWindows)) {
        return
    }
    Import-Module "C:\Program Files (x86)\Microsoft Visual Studio\18\BuildTools\Common7\Tools\Microsoft.VisualStudio.DevShell.dll"
    Enter-VsDevShell c31061fe -SkipAutomaticLocation -DevCmdArguments "-arch=x64 -host_arch=x64"
}

function Invoke-JinjanateNamedPipe {
    [OutputType([string])]
    param(
        [Parameter(Mandatory,Position=0)][string]$Pipe,
        [Parameter(Mandatory)][string]$TemplateFile,
        [Parameter(Mandatory)][string]$Data,
        [string]$FormatName,
        [string]$OutputFile
    )
    if (-not (Test-Path $Pipe)) {
        Write-Error "Named pipe file ${Pipe} does not exist"
        return
    }
    $request = @{
        jsonrpc = '2.0'
        method = 'jinjanate'
        template = $TemplateFile
        data = $Data
        options = @{}
    }
    if (-not([string]::IsNullOrEmpty($FormatName))) {
        $request.options.format = $FormatName
    }
    if (-not ([string]::IsNullOrEmpty($OutputFile))) {
        $request.options['output-file'] = $OutputFile
    }
    $requestJson =  ConvertTo-Json $request -Compress
    $rpcRequest = "${requestJson}`n"
    Write-Debug "request = ${requestJson}"
    $requestBytes = [System.Text.Encoding]::UTF8.GetBytes($rpcRequest)

    # connect to socket
    $socket = [Socket]::new([AddressFamily]::Unix, [SocketType]::Stream, [ProtocolType]::Unspecified)
    $socket.Connect([UnixDomainSocketEndPoint]::new($Pipe))
    $socketStream = [NetworkStream]::new($socket)
    if (-not ($socketStream.CanWrite)) {
        Write-Error 'Socket stream is not writable'
        return
    }

    # send request
    Write-Host 'send request'
    $socketStream.Write($requestBytes, 0, $requestBytes.Length)

    # receive response
    $buf = [byte[]]::new(1024)
    $sb = [System.Text.StringBuilder]::new()
    Write-Host 'receive response'
    while ($true) {
        Write-Debug "receive up to $($buf.Length) bytes"
        $bytesRead = $socketStream.Read($buf, 0, $buf.Length)
        Write-Debug "received ${bytesRead} bytes"
        if ($bytesRead -eq 0) {
            Write-Debug 'end-of-stream reached'
            break
        }
        $null = $sb.Append([System.Text.Encoding]::UTF8.GetString($buf, 0, $bytesRead))
    }
    $response = $sb.ToString()
    Write-Host "response = ${response}"

    # close socket
    $socketStream.Dispose()
    $socket.Dispose()
}

Export-ModuleMember -Function @(
    'Find-DirectoryFromParent','Remove-DirectoryWithRecurseForce','Get-ChildItemWide', 'Get-ChildItemLong',
    'Invoke-ConsoleTextEditor','Invoke-GraphicalTextEditor','Invoke-Docker','Invoke-DockerCompose',
    'Invoke-Timetracker','Invoke-NuGet','Get-LastWeekTimesheet','Update-SvnRepo',
    'New-DirectoryAndSetLocation','Set-DockerContext','Build-JabbaPs1', 'Start-VSDevShell',
    'Invoke-JinjanateNamedPipe'
)
