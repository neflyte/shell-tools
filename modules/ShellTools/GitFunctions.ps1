Function Get-GitBranch {
    [OutputType([string])]
    param()
    $ref = git symbolic-ref --short HEAD 2>$null
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrEmpty($ref)) {
        $ref = git describe --tags --always 2>$null
    }
    return $ref
}

function Get-GitBranches {
    param()
    git branch $args
}

function Get-GitRepoStatus {
    param()
    git status $args
}

function Get-GitTags {
    param()
    git tag $args
}

function Reset-GitBranch {
    param()
    $gitBranch = Get-GitBranch
    if ([string]::IsNullOrEmpty($gitBranch)) {
        Write-Error 'cannot determine the current branch'
        return
    }
    Write-Host "hard resetting to ${gitBranch}"
    git reset --hard "${gitBranch}"
}

function Set-GitBranch {
    param()
    git checkout $args
}

function Update-GitOriginRepo {
    param()
    git fetch origin $args
}

function Update-GitRepo {
    param()
    git pull $args
}

function Test-GitRepo {
    [OutputType([Boolean])]
    param(
        [Parameter(Position=0)][String]$Directory = $PWD
    )
    $repoDir = Find-DirectoryFromParent -Start $Directory -Directory '.git' -ErrorAction SilentlyContinue
    if (-not($?) -or $null -eq $repoDir) {
        return $false
    }
    return $true
}

function Set-LocationToGitWorktree {
    [OutputType([void])]
    param(
        [Parameter(Mandatory,Position=0)][String]$Directory
    )
    if (-not(Test-Path $Directory)) {
        Write-Error "directory ${Directory} does not exist"
        return
    }
    $wtSelect = Join-Path $env:TOOLS_HOME 'apps' 'wtselect' 'wtselect'
    if ($IsWindows) {
        $wtSelect += '.exe'
    }
    if (-not(Test-Path $wtSelect)) {
        Write-Error "app wtselect could not be found at ${wtSelect}"
        return
    }
    $tempFile = [System.IO.Path]::GetTempFileName()
    try {
        & "${wtSelect}" "${Directory}" 2>"${tempFile}"
        if ($LASTEXITCODE -ne 0) {
            Write-Error "wtselect failed with exit code ${LASTEXITCODE}"
            return
        }
        $desiredDir = Get-Content $tempFile -Raw -ErrorAction SilentlyContinue
        if ([string]::IsNullOrEmpty($desiredDir)) {
            Write-Verbose 'no directory selected; nothing to do'
            return
        }
        Set-Location $desiredDir.Trim()
    } finally {
        Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
    }
}

Export-ModuleMember -Function @(
    'Get-GitBranch','Get-GitBranches','Get-GitRepoStatus','Get-GitTags',
    'Reset-GitBranch','Set-GitBranch','Update-GitOriginRepo','Update-GitRepo','Test-GitRepo',
    'Set-LocationToGitWorktree'
)
