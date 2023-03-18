Function Get-GitBranch {
    $ref = git symbolic-ref --short HEAD 2>$null
    if (-not($?) -or $ref -eq "") {
        $ref = git describe --tags --always 2>$null
    }
    return $ref
}

Function Get-GitBranches {
    git branch $args
}

Function Get-GitRepoStatus {
    git status
}

Function Get-GitTags {
    git tag $args
}

Function Reset-GitBranch {
    $GITBR = Get-GitBranch
    if ($GITBR -eq "") {
        throw "can't figure out the current branch"
    }
    Write-Output "hard resetting to ${GITBR}"
    git reset --hard $GITBR
}

Function Set-GitBranch {
    git checkout $args
}

Function Update-GitOriginRepo {
    git fetch origin $args
}

Function Update-GitRepo {
    git pull $args
}
