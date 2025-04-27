function Get-WebVideo {
    yt-dlp --embed-metadata --embed-thumbnail --format 'bv+ba/b' -o '%(title)s.%(ext)s' $args
}

function Get-WebAudio {
    yt-dlp --embed-thumbnail --format 'ba[ext=wav]/ba[ext=m4a]/ba[ext=mp4]/ba[ext=mp3]/ba' -o '%(title)s.%(ext)s' $args
}

function Get-WebAudioPlaylist {
    yt-dlp --yes-playlist --embed-thumbnail --format 'ba[ext=wav]/ba[ext=m4a]/ba[ext=mp4]/ba[ext=mp3]/ba' -o '%(playlist_index)s_%(track_number)s_%(title)s.%(ext)s' $args
}

function Get-MediaDump {
    yt-dlp --no-playlist --embed-metadata --embed-thumbnail --write-thumbnail --all-formats --add-metadata --no-overwrites -o '%(id)s_%(format)s.%(ext)s' $args
}

function Convert-FlacToAlac {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)][String]$InFile,
        [switch]$Force
    )
    if (-not(Test-Path $InFile)) {
        throw "Input file ${InFile} does not exist"
    }
    $inFileItem = Get-Item $InFile
    $outFilePath = $inFileItem.Directory.FullName
    $outFile = Join-Path $outFilePath "$($inFileItem.BaseName).m4a"
    Write-Debug "outFilePath=${outFilePath}, outFile=${outFile}"
    if (Test-Path $outFile) {
        if (-not($Force)) {
            throw "Output file ${outFile} exists; use -Force to overwrite it"
        }
        Remove-Item $outFile -Force
    }
    $ffmpegArgs = @(
        '-v', 'warning',
        '-i', $InFile,
        '-vcodec', 'copy',
        '-acodec', 'alac',
        '-map_metadata', '0',
        $outFile
    )
    Write-Host "$($inFileItem.FullName)"
    Write-Verbose "Convert $($inFileItem.FullName) to ${outFile}"
    Write-Debug "PS> ffmpeg ${ffmpegArgs}"
    ffmpeg $ffmpegArgs
    $returnCode = $LASTEXITCODE
    if ($returnCode -ne 0) {
        throw "Error converting FLAC to ALAC; returnCode=${returnCode}"
    }
}

Export-ModuleMember -Function Get-WebVideo,Get-WebAudio,Get-WebAudioPlaylist,Get-MediaDump,Convert-FlacToAlac
