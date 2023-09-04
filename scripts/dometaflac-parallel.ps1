#requires -modules PSJobLogger
[CmdletBinding()]
param(
    [Parameter(Mandatory)][String]$Directory = $PWD
)
Import-Module PSJobLogger -Force
Write-Debug "Directory: ${Directory}"
$flacFiles = @()
Get-ChildItem -Path $Directory -Attributes Directory | ForEach-Object {
    Get-ChildItem -Path $_ -Attributes !Directory -Recurse -Filter "*.flac" | ForEach-Object {
        $flacFiles += $_
    }
}
Write-Output "Found $($flacFiles.Length) FLAC files"
# create process hashtable
$ctr = 0
$fileIds = @{}
$flacFiles | ForEach-Object {
    $fileIds.($_.FullName) = $ctr
    $ctr++
}
# create logger
$jobLog = Initialize-PSJobLogger -Name 'dometaflac-parallel'
# start jobs
Write-Output 'starting jobs'
$job = $flacFiles | ForEach-Object -ThrottleLimit 3 -AsJob -Parallel {
    $log = $using:jobLog
    $ids = $using:fileIds
    $flacFile = $_

    $log.Progress($flacFile.FullName, @{ Id = $ids.$($flacFile.FullName); Activity = $flacFile.Name; Status = 'Processing'; PercentComplete = -1 })

    $log.Debug("metaflac --add-replay-gain `"$($flacFile.FullName)`"")
    metaflac --add-replay-gain $flacFile.FullName

    $log.Progress($flacFile.FullName, @{ Completed = $true })
}
# monitor jobs
Write-Output 'monitoring jobs'
while ($job.State -eq 'Running') {
    # flush logs
    $jobLog.FlushStreams()
    # small sleep to not "overload the gui"
    Start-Sleep -Seconds 0.1
}
# flush any remaining logs
$jobLog.FlushStreams()
# all done.
Write-Output 'done.'
