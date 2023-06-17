@{
    ModuleVersion = '0.0.1'
    GUID = 'a607c769-75fe-44b5-b564-ce6c7e830d48'
    Author = 'alan'
    RootModule = 'UtilityFunctions.psm1'
    FunctionsToExport = @(
        'Find-DirectoryFromParent',
        'Get-ChildItemWide',
        'Get-LastWeekTimesheet',
        'Invoke-ConsoleTextEditor',
        'Invoke-GraphicalTextEditor',
        'Invoke-Docker',
        'Invoke-DockerCompose',
        'Invoke-Timetracker',
        'Remove-DirectoryWithRecurseForce',
        'Update-SvnRepo'
    )
}
