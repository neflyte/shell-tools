param(
    [Parameter(Mandatory)][String]$Directory = $PWD
)
# Requires "LibGit2Sharp.dll" and "libgit2-xxxxx.so|dylib|dll"
Import-Module "./LibGit2Sharp.dll"
$repo = [LibGit2Sharp.Repository]::new($Directory)
Write-Output "HEAD: $($repo.Head)"
$opts = [LibGit2Sharp.StatusOptions]::new()
$repo.RetrieveStatus($opts)
