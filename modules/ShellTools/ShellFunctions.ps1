function Build-PredefinedLocationFunctions {
    param()
    $locationAliases = $ShellToolsPredefinedLocations | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
    foreach ($locationAlias in $locationAliases) {
        Write-Debug "locationAlias=${locationAlias}"
        $funcName = "Set-PredefinedLocationTo${locationAlias}"
        $scriptblockString = "& { Set-PredefinedLocation '${locationAlias}' }"
        $null = New-Item -Path Function:\ -Name global:$funcName -Value ([scriptblock]::Create($scriptblockString)) -Options 'ReadOnly','AllScope' -Force
    }
}

function Clear-PredefinedLocationFunctions {
    param()
    Get-ChildItem -Path Function:\ | Where-Object Name -Like 'Set-PredefinedLocationTo*' | Remove-Item -Force
}

function Build-PredefinedLocationAliases {
    param()
    $locationAliases = $ShellToolsPredefinedLocations | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
    foreach ($locationAlias in $locationAliases) {
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
    if (-not($LocationAlias -in ($ShellToolsPredefinedLocations | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name))) {
        throw "Predefined location ${LocationAlias} is not defined"
    }
    Write-Debug "PS> Set-Location $($ShellToolsPredefinedLocations.$LocationAlias)"
    Set-Location $ShellToolsPredefinedLocations.$LocationAlias
}

Export-ModuleMember -Function @(
    'Set-PredefinedLocation',
    'Build-PredefinedLocationFunctions',
    'Clear-PredefinedLocationFunctions',
    'Build-PredefinedLocationAliases',
    'Clear-PredefinedLocationAliases'
)
