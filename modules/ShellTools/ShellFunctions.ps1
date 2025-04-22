function Build-PredefinedLocationFunctions {
    param()
    foreach ($locationAlias in $ShellToolsPredefinedLocations.Keys) {
        $funcName = "Set-PredefinedLocationTo${locationAlias}"
        $scriptblockString = "& { Set-Location '${locationAlias}' }"
        $null = New-Item -Path Function:\ -Name global:$funcName -Value ([scriptblock]::Create($scriptblockString)) -Options 'ReadOnly','AllScope' -Force
    }
}

function Clear-PredefinedLocationFunctions {
    param()
    Get-ChildItem -Path Function:\ | Where-Object Name -Like 'Set-PredefinedLocationTo*' | Remove-Item -Force
}

function Build-PredefinedLocationAliases {
    param()
    foreach ($locationAlias in $ShellToolsPredefinedLocations.Keys){
        Set-Alias -Name "cd${locationAlias}" -Value "Set-PredefinedLocationTo${locationAlias}" -Option 'AllScope','ReadOnly' -Scope Global -Force
    }
}

function Clear-PredefinedLocationAliases {
    param()
    Get-Alias | Where-Object Definition -Like 'Set-PredefinedLocationTo*' | Remove-Alias -Force
}

function Set-PredefinedLocation {
    param(
        [Parameter(Mandatory,Position=0)][String]$LocationAlias
    )
    if (-not($LocationAlias -in $ShellToolsPredefinedLocations.Keys)) {
        throw "Predefined location ${LocationAlias} is not defined"
    }
    Set-Location $ShellToolsPredefinedLocations.$LocationAlias
}

Export-ModuleMember -Function @(
    'Set-PredefinedLocation',
    'Build-PredefinedLocationFunctions',
    'Clear-PredefinedLocationFunctions',
    'Build-PredefinedLocationAliases',
    'Clear-PredefinedLocationAliases'
)
