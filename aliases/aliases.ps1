#
# aliases.ps1 -- Command Aliases
#
<# Subversion #>
Set-Alias sup Update-SvnRepo
<# Git #>
Remove-Alias gp -Force -ErrorAction SilentlyContinue
Set-Alias gp Update-GitRepo
Set-Alias gfo Update-GitOriginRepo
Set-Alias gb Get-GitBranches
Set-Alias gs Get-GitRepoStatus
Set-Alias gt Get-GitTags
Set-Alias gbr Get-GitBranch
Set-Alias gco Set-GitBranch
Set-Alias grs Reset-GitBranch
<# Shell commands #>
Set-Alias ll Get-ChildItem
Remove-Alias ls -Force -ErrorAction SilentlyContinue
Set-Alias ls Get-ChildItemWide
Set-Alias which Get-Command
Set-Alias rimraf Remove-DirectoryWithRecurseForce
Set-Alias mdcd New-DirectoryAndSetLocation
<# File editing #>
Set-Alias g Invoke-GraphicalTextEditor
Set-Alias e Invoke-ConsoleTextEditor
<# Media functions #>
Set-Alias ytv Get-WebVideo
Set-Alias yta Get-WebAudio
Set-Alias ytapl Get-WebAudioPlaylist
Set-Alias ytdump Get-MediaDump
<# Other tools #>
Set-Alias tt Invoke-Timetracker
Set-Alias dkr Invoke-Docker
Set-Alias dkc Invoke-DockerCompose
Set-Alias sd Set-DockerContext
Set-Alias ng Invoke-NuGet
Set-Alias ib Invoke-Build
