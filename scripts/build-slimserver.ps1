<#
.SYNOPSIS
    Builds and optionally installs Squeezebox Server from sources
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$RootDir = "${PWD}"
)

<# Define a set of 'constants' #>
$slimDir = Join-Path $RootDir 'src' 'slimserver'
$slimVendorDir = Join-Path $RootDir 'src' 'slimserver-vendor','CPAN'
$slimVendorBuildDir = Join-Path $slimVendorDir 'build'
$slimDBDir = '/var/db/squeezeboxserver'
$slimCacheDir = Join-Path $slimDBDir 'cache'
$slimPlaylistsDir = Join-Path $slimDBDir 'playlists'
$slimPrefsDir = Join-Path $slimDBDir 'prefs'
$slimLogDir = '/var/log/squeezeboxserver'
$destDir = '/opt/squeezeboxserver'
$destCPANDir = Join-Path $destDir 'CPAN'
$destCacheDir = Join-Path $destDir 'Cache'
$destPlaylistsDir = Join-Path $destDir 'playlists'
$destPrefsDir = Join-Path $destDir 'prefs'
$destLogDir = Join-Path $destDir 'Logs'
$symlinkDirs = @{
    $slimCacheDir = $destCacheDir
    $slimPlaylistsDir = $destPlaylistsDir
    $slimPrefsDir = $destPrefsDir
    $slimLogDir = $destLogDir
}
$slimservUser = 'slimserv'
$slimservGroup = 'slimserv'

function ensureSourcePaths {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-Host 'Ensure source paths exist'
    $paths = @($slimDBDir, $slimCacheDir, $slimPlaylistsDir, $slimPrefsDir, $slimLogDir)
    foreach ($path in $paths) {
        if (-not(Test-Path $path)) {
            $null = New-Item $path -ItemType Directory -Force -ErrorAction Continue
            if ($PSCmdlet.ShouldProcess($path, 'Set Owner and Group')) {
                chown -R "${slimservUser}:${slimservGroup}" "${path}"
            }
        }
    }
}

function buildVendor {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    if (Test-Path $slimVendorDir) {
        if (Test-Path $slimVendorBuildDir) {
            Write-Host 'Remove existing build output directory'
            Remove-Item $slimVendorBuildDir -Recurse -Force
        }
        Write-Host 'Build vendor libraries'
        if ($PSCmdlet.ShouldProcess('Vendor libraries', 'Build')) {
            Push-Location $slimVendorDir
            try {
                bash buildme.sh -t
            } finally {
                Pop-Location
            }
        }
    }
}

function copyServer {
    if (Test-Path $slimDir) {
        Write-Host 'Copy squeezeboxserver'
        Copy-Item -Path "${slimDir}/*" -Destination $destDir -Exclude '.git','.github' -Recurse -Force
    }
}

function perlVersion {
    [OutputType([string])]
    param()
    $versionNumber = ''
    $versionText = perl -v | Select-Object -First 2 | Select-Object -Last 1
    if ($versionText -match '.*\(v(.*)\).*') {
        $versionNumber = $Matches[1]
    }
    if ($versionNumber -match '([0-9]+)\.([0-9]+)\.[0-9]+') {
        return "$($Matches[1]).$($Matches[2])"
    }
    throw 'could not determine version of perl'
}

function copyVendor {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    if (Test-Path $slimVendorBuildDir) {
        Write-Host 'Copy vendor libraries'
        Copy-Item (Join-Path $slimVendorBuildDir 'arch') $destCPANDir -Recurse -Force
        Write-Host 'Determine perl version'
        $perlVersionNumber = perlVersion
        $perlLibDir = Join-Path $slimVendorBuildDir $perlVersionNumber 'lib','perl5'
        if (Test-Path $perlLibDir) {
            Write-Host 'Copy version-specific perl libraries'
            $destCPANLibDir = Join-Path $destCPANDir 'arch' $perlVersionNumber
            if (-not(Test-Path $destCPANLibDir)) {
                $null = New-Item $destCPANLibDir -ItemType Directory -Force
            }
            Copy-Item "${perlLibDir}/*" $destCPANLibDir -Recurse -Force
        }
    }
}

function removeSymlinks {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-Host 'Remove existing symlinks'
    foreach ($sourceDir in $symlinkDirs.Keys) {
        if (Test-Path $symlinkDirs.$sourceDir) {
            $dirItem = Get-Item $symlinkDirs.$sourceDir
            if ($null -eq $dirItem.LinkTarget) {
                throw "link target ${dirItem} is not a symlink but should be"
            }
            $resolvedTarget = $dirItem.ResolveLinkTarget($true)
            if (-not($resolvedTarget.Equals($(Get-Item $sourceDir)))) {
                throw "link target ${dirItem} doesn't point to ${sourceDir} but should"
            }
            Write-Host "Remove symlink target dir ${dirItem}"
            Remove-Item $dirItem -Force
        }
    }
}

function createSymlinks {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-Host 'Create symlinks'
    foreach ($sourceDir in $symlinkDirs.Keys) {
        if (-not(Test-Path $sourceDir) -and -not($WhatIfPreference)) {
            throw "link source ${sourceDir} doesn't exist"
        }
        if (Test-Path $symlinkDirs.$sourceDir) {
            throw "link target $($symlinkDirs.$sourceDir) exists but shouldn't"
        }
        Write-Host "Symlink ${sourceDir} to $($symlinkDirs.$sourceDir)"
        $null = New-Item -Path $symlinkDirs.$sourceDir -ItemType SymbolicLink -Value $sourceDir
    }
}

function setOwnership {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-Host "Set ownership of ${destDir} to ${slimservUser}:${slimservGroup}"
    if ($PSCmdlet.ShouldProcess($destDir, 'Set Owner and Group')) {
        chown -R "${slimservUser}:${slimservGroup}" "${destDir}"
    }
}

ensureSourcePaths
buildVendor
removeSymlinks
copyServer
copyVendor
createSymlinks
setOwnership
Write-Host 'done.'
