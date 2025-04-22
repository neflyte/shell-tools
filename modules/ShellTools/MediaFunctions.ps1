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

Export-ModuleMember -Function Get-WebVideo,Get-WebAudio,Get-WebAudioPlaylist,Get-MediaDump
