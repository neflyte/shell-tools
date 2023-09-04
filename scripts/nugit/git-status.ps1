param(
    [Parameter(Mandatory)][String]$Directory = $PWD
)
Import-Module "./LibGit2Sharp.dll"
$repo = [LibGit2Sharp.Repository]::new($Directory)
Write-Output "HEAD: $($repo.Head)"
$opts = [LibGit2Sharp.StatusOptions]::new()
$repo.RetrieveStatus($opts)
