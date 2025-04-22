@{
    ModuleVersion = '0.0.4'
    GUID = '4e438b63-08a5-437e-80e6-7d7a7bbc88e1'
    Author = 'alan'
    RootModule = 'ShellTools.ps1'
    NestedModules = @(
        'GitFunctions.ps1',
        'ShellFunctions.ps1',
        'UtilityFunctions.ps1'
    )
    VariablesToExport = @('ShellToolsPredefinedLocations')
}
