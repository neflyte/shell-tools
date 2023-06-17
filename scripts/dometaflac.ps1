# dometaflac.ps1
param(
    [Parameter(Mandatory)][String]$Directory = $PWD
)
Write-Host "Directory: ${Directory}"
Get-ChildItem -Path $Directory -Attributes Directory | ForEach-Object {
    Get-ChildItem -Path $_ -Attributes !Directory -Recurse -Filter "*.flac" | ForEach-Object {
        Write-Host "    File: $($_.Name)"
        metaflac --add-replay-gain "$($_.FullName)"
    }
}
