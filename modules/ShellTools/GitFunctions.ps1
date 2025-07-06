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
    if ($IsWindows) { $env:GIT_REDIRECT_STDERR = '2>&1' }
    git branch $args
}

Function Get-GitRepoStatus {
    if ($IsWindows) { $env:GIT_REDIRECT_STDERR = '2>&1' }
    git status
}

Function Get-GitTags {
    if ($IsWindows) { $env:GIT_REDIRECT_STDERR = '2>&1' }
    git tag $args
}

Function Reset-GitBranch {
    $gitBranch = Get-GitBranch
    if ($gitBranch -eq '') {
        throw 'cannot determine the current branch'
    }
    Write-Host "hard resetting to ${gitBranch}"
    if ($IsWindows) { $env:GIT_REDIRECT_STDERR = '2>&1' }
    git reset --hard "${gitBranch}"
}

Function Set-GitBranch {
    if ($IsWindows) { $env:GIT_REDIRECT_STDERR = '2>&1' }
    git checkout $args
}

Function Update-GitOriginRepo {
    if ($IsWindows) { $env:GIT_REDIRECT_STDERR = '2>&1' }
    git fetch origin $args
}

Function Update-GitRepo {
    if ($IsWindows) { $env:GIT_REDIRECT_STDERR = '2>&1' }
    git pull $args
}

function Test-GitRepo {
    [OutputType([Boolean])]
    param(
        [Parameter(Position=0)][String]$Directory = $PWD
    )
    $repoDir = Find-DirectoryFromParent -Start $Directory -Directory '.git'
    if ($null -eq $repoDir) {
        return $false
    }
    return $true
}

Export-ModuleMember -Function 'Get-GitBranch','Get-GitBranches','Get-GitRepoStatus','Get-GitTags','Reset-GitBranch','Set-GitBranch','Update-GitOriginRepo','Update-GitRepo','Test-GitRepo'
