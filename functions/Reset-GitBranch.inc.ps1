Function Reset-GitBranch {
    $GITBR = Get-GitBranch
    if ($GITBR -eq "") {
        throw "can't figure out the current branch"
    }
    Write-Output "hard resetting to ${GITBR}"
    git reset --hard $GITBR
}
