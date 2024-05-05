<#
Test-NestedFunctions.ps1
#>
param(
    [Parameter(Mandatory,Position=0)][string]$Foo
)

function Get-ListOfItems {
    [OutputType([System.Collections.Generic.List[PSCustomObject]])]
    param()
    $narf = [System.Collections.Generic.List[PSCustomObject]]::new()
    $narf.Add([PSCustomObject]@{ Bar = 'Baz' })
    Write-Host 'added baz'
    $narf.Add([PSCustomObject]@{ Zot = 'Qux' })
    Write-Host 'added qux'
    return $narf
}

$listOfItems = Get-ListOfItems
Write-Output "count: $($listOfItems.Count), Foo=${Foo}"
foreach ($oneItem in $listOfItems) {
    Write-Output "item: $($oneItem | Out-String)"
}
