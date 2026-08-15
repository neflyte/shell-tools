[CmdletBinding()]
param(
    [string]$Path = "${PWD}",
    [int]$ThrottleLimit = 4
)
if ($Path -eq '' -or -not(Test-Path $Path)) {
    throw 'must specify a valid directory'
}
if ($ThrottleLimit -lt 1) {
    $ThrottleLimit = 1
}
Write-Output "Collecting MP3 files in ${Path}"
$mp3Files = Get-ChildItem -Path $Path -Attributes !Directory -Recurse -Filter '*.mp3'
Write-Output "Process $($mp3Files.Count) files using ${ThrottleLimit} threads"
$job = $mp3Files | ForEach-Object -ThrottleLimit $ThrottleLimit -AsJob -Parallel {
    $mp3File = $_
    $fullName = $mp3File.FullName
    $startingPath = $using:Path
    if (-not($startingPath.EndsWith('/'))) {
        $startingPath += '/'
    }
    $shortName = $fullName -replace "^${startingPath}", ''
    Write-Output ">> Process ${shortName}"
    $mp3gainArgs = @('-e','-r','-c','-k',$fullName)
    Write-Debug "PS> mp3gain ${mp3gainArgs} 2>&1"
    try {
        & mp3gain $mp3gainArgs *>$null
        $exitCode = $LASTEXITCODE
        if ($exitCode -ne 0) {
            throw "mp3gain exited with code ${exitCode} for ${shortName}"
        }
    } catch {
        Write-Error "* Exception processing ${shortName}: $_"
        throw
    }
}
while ($job.State -eq 'Running') {
    Receive-Job $job
    Start-Sleep -Seconds 0.5
}
# Flush the last job output
Receive-Job $job
# Wait for all jobs to complete and clean up
Write-Output "Wait for jobs to finish"
$null = $job | Wait-Job | Remove-Job -Force
# all done.
Write-Output 'done.'
