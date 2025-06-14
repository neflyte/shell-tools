Function Get-GitBranch {
    [OutputType([string])]
    param()
    $ref = git symbolic-ref --short HEAD 2>$null
    if (-not($?) -or $ref -eq '') {
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
    if ($GITBR -eq '') {
        throw 'cannot determine the current branch'
    }
    Write-Host "hard resetting to ${GITBR}"
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

function Test-GitRepo {
    [OutputType([Boolean])]
    param(
        [Parameter(Position=0)][String]$Directory = $PWD
    )
    $repoDir = Find-DirectoryFromParent -Start $Directory -Directory ".git" -ErrorAction SilentlyContinue
    if (-not($?) -or $null -eq $repoDir) {
        return $false
    }
    return $true
}

Export-ModuleMember -Function 'Get-GitBranch','Get-GitBranches','Get-GitRepoStatus','Get-GitTags','Reset-GitBranch','Set-GitBranch','Update-GitOriginRepo','Update-GitRepo','Test-GitRepo'
