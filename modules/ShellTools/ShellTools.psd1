@{
    ModuleVersion = '0.0.3'
    GUID = '4e438b63-08a5-437e-80e6-7d7a7bbc88e1'
    Author = 'alan'
    RootModule = 'ShellTools.psm1'
    NestedModules = @(
        'GitFunctions.psm1',
        'UtilityFunctions.psm1'
    )
    FunctionsToExport = @(
        <# Git functions #>
        'Get-GitBranch',
        'Get-GitBranches',
        'Get-GitRepoStatus',
        'Get-GitTags',
        'Reset-GitBranch',
        'Set-GitBranch',
        'Test-GitRepo',
        'Update-GitOriginRepo',
        'Update-GitRepo',
        <# Utility functions #>
        'Find-DirectoryFromParent',
        'Get-ChildItemWide',
        'Get-LastWeekTimesheet',
        'Invoke-ConsoleTextEditor',
        'Invoke-GraphicalTextEditor',
        'Invoke-Docker',
        'Invoke-DockerCompose',
        'Invoke-Timetracker',
        'Invoke-NuGet',
        'New-DirectoryAndSetLocation',
        'Remove-DirectoryWithRecurseForce',
        'Update-SvnRepo'
    )
}
