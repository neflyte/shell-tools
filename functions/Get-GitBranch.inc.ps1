Function Get-GitBranch {
    $ref = git symbolic-ref --short HEAD 2>$null
    if (-not($?) -or $ref -eq "") {
        $ref = git describe --tags --always 2>$null
    }
    return $ref
}
