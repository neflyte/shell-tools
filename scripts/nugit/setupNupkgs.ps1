# create temp dir
if ($null -eq $env:TEMP) {
    if ($PSVersionTable.Platform -eq 'Unix') {
        $env:TEMP = '/tmp'
    } else {
        $env:TEMP = 'C:\Windows\Temp'
    }
}
$tempDirName = Join-Path $env:TEMP ('ng-' + (New-Guid))
$tempDir = New-Item $tempDirName -Type Directory -Force
Write-Debug "Temp dir: $($tempDir.FullName)"
# restore nupkgs
Write-Output 'Restore nupkgs'
ng install -OutputDirectory $tempDir.FullName
if ($LASTEXITCODE -ne 0) {
    throw 'error restoring nupkgs'
}
# determine library and native binary paths
$libDir = ''
$nativeDir = ''
Get-ChildItem $tempDir -Attributes Directory | ForEach-Object {
    if ($_.Name -match 'LibGit2Sharp.NativeBinaries.[0-9]+.*' -and $nativeDir -eq '') {
        $nativeDir = $_.FullName
        Write-Debug "nativeDir=${nativeDir}"
        return
    }
    if ($_.Name -match 'LibGit2Sharp.[0-9]+.*' -and $libDir -eq '') {
        $libDir = $_.FullName
        Write-Debug "libDir=${libDir}"
        return
    }
}
if ($libDir -eq '' -or $nativeDir -eq '') {
    throw 'cannot find library or native binary directories'
}
# support Windows x64, Linux x64, and macOS x64 for native binaries
$runtime = 'win-x64'
if ($PSVersionTable.Platform -eq 'Unix') {
    $runtime = 'linux-x64'
    if ($PSVersionTable.OS -like 'Darwin*') {
        $runtime = 'osx-x64'
    }
}
$libFilesDir = Join-Path $libDir 'lib' 'net6.0'
if (-not(Test-Path $libFilesDir)) {
    throw "cannot find library path ${libFilesDir}"
}
$nativeFilesDir = Join-Path $nativeDir 'runtimes' $runtime 'native'
if (-not(Test-Path $nativeFilesDir)) {
    throw "cannot find native binaries path ${nativeFilesDir}"
}
Write-Debug "runtime=${runtime}, libFilesDir=${libFilesDir}, nativeFilesDir=${nativeFilesDir}"
Write-Output 'Assemble dependencies'
# copy files to current directory
Copy-Item -Path (Join-Path $libFilesDir '*'),(Join-Path $nativeFilesDir '*') -Destination $PWD -Force
Write-Output 'Clean up'
# remove temp directory
Remove-Item $tempDir -Recurse -Force
Write-Output 'done.'
