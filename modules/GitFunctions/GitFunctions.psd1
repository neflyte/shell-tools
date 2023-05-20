@{
    ModuleVersion = '0.0.1'
    GUID = 'f6b128ba-87da-4814-9caa-899671a40bfe'
    Author = 'alan'
    RootModule = 'GitFunctions.psm1'
    FunctionsToExport = @(
        'Get-GitBranch',
        'Get-GitBranches',
        'Get-GitRepoStatus',
        'Get-GitTags',
        'Reset-GitBranch',
        'Set-GitBranch',
        'Test-GitRepo',
        'Update-GitOriginRepo',
        'Update-GitRepo'
    )
}
