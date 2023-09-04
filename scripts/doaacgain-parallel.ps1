#requires -modules PSJobLogger
[CmdletBinding()]
param(
    [String]$Directory = $PWD
)
Import-Module PSJobLogger -Force
if ($Directory -eq '' -or -not(Test-Path $Directory)) {
    Write-Error "must specify a directory"
    exit
}
Write-Debug "Directory: ${Directory}"
$aacFiles = Get-ChildItem -Path $Directory -Attributes !Directory -Recurse -Filter '*.m4a'
Write-Output "Found $($aacFiles.Length) AAC files"
$filesToProcess = @()
$counter = 0
$aacFiles | ForEach-Object {
    $filesToProcess += @{
        Id = $counter
        File = $_
    }
    $counter++
}
Write-Output "Processing $($filesToProcess.Count) files using 4 threads"
$jobLog = Initialize-PSJobLogger -Name 'doaacgain-parallel'
$job = $filesToProcess | ForEach-Object -ThrottleLimit 4 -AsJob -Parallel {
    $log = $using:jobLog

    $id = $_.Id
    $file = $_.File
    $name = $file.Name
    $fullName = $file.FullName

    #$log.Progress($fullName, @{ Id = $id; Activity = $name; Status = 'Processing'; PercentComplete = -1 })
    $log.Output($name)
    Write-Output $name
    $aacgainArgs = @('-e','-r','-c','-k', $fullName)
    $log.Output("aacgain ${aacgainArgs} 2>&1")
    aacgain $aacgainArgs 2>&1 | ForEach-Object {
        $log.Output($_)
        #if ($_ -match "([0-9]+)% of ([0-9]+) bytes analyzed") {
        #    $log.Progress($fullName, @{ PercentComplete = [int]$Matches[1]; Status = "Analyzing $($Matches[2]) bytes"; Activity = $name })
        #}
    }
    #$log.Progress($file.FullName, @{ Completed = $true; Activity = $name })
    $log.Output("done ${fullName}")
    Write-Output("+++ done ${fullname}")
}
while ($job.State -eq 'Running') {
    # flush logs
    $jobLog.FlushStreams()
    # small sleep to not "overload the gui"
    Start-Sleep -Seconds 0.1
}
Write-Debug 'waiting for job to finish'
$null = $job | Wait-Job | Remove-Job -Force
# flush any remaining logs
$jobLog.FlushStreams()
# all done.
Write-Output 'done.'
