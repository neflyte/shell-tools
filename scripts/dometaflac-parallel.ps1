# dometaflac-parallel.ps1
param(
    [Parameter(Mandatory)][String]$Directory = $PWD
)
Write-Host "Directory: ${Directory}"
$flacFiles = @()
Get-ChildItem -Path $Directory -Attributes Directory | ForEach-Object {
    Get-ChildItem -Path $_ -Attributes !Directory -Recurse -Filter "*.flac" | ForEach-Object {
        $flacFiles += $_
    }
}
Write-Host "Found $($flacFiles.Length) FLAC files"
# create process hashtable
$ctr = 0
$fileIds = @{}
$origin = @{}
$flacFiles | ForEach-Object {
    $fileIds.($_.FullName) = $ctr
    $origin.($_.FullName) = @{}
    $ctr++
}
# create synchronized hashtable from process hashtable
$syncOrigin = [System.Collections.Hashtable]::Synchronized($origin)
# start jobs
Write-Host 'starting jobs'
$job = $flacFiles | ForEach-Object -ThrottleLimit 3 -AsJob -Parallel {
    $sync = $using:syncOrigin
    $ids = $using:fileIds
    $process = $sync.($_.FullName)
    $process.Id = $ids.($_.FullName)
    $process.Activity = $_.Name
    $process.Status = 'Processing'
    $process.PercentComplete = -1

    metaflac --add-replay-gain "$($_.FullName)"

    $process.Completed = $true
}
# monitor jobs
Write-Host 'monitoring jobs'
while ($job.State -eq 'Running') {
    $syncOrigin.Keys | ForEach-Object {
        if (![string]::IsNullOrEmpty($syncOrigin.$_.Keys)) {
            if (-not($null -eq $syncOrigin.$_.Id)) {
                $progressParams = $syncOrigin.$_
                Write-Progress @progressParams
            }
        }
    }
    # small sleep to not "overload the gui"
    Start-Sleep -Seconds 0.1
}
Write-Host 'done.'
