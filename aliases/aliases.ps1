#
# aliases.ps1 -- Command Aliases
#
# Subversion
Set-Alias sup Update-SvnRepo
# Git
Remove-Alias gp -Force -ErrorAction SilentlyContinue
Set-Alias gp Update-GitRepo
Set-Alias gfo Update-GitOriginRepo
Set-Alias gb Get-GitBranches
Set-Alias gs Get-GitRepoStatus
Set-Alias gt Get-GitTags
Set-Alias gbr Get-GitBranch
Set-Alias gco Set-GitBranch
Set-Alias grs Reset-GitBranch
# Shell commands
Set-Alias ll Get-ChildItem
Remove-Alias ls -Force -ErrorAction SilentlyContinue
Set-Alias ls Get-ChildItemWide
Set-Alias which Get-Command
Set-Alias rimraf Remove-DirectoryWithRecurseForce
# File editing
Set-Alias g Invoke-GraphicalTextEditor
Set-Alias e Invoke-ConsoleTextEditor
# Other tools
Set-Alias tt Invoke-Timetracker
Set-Alias dkr Invoke-Docker
Set-Alias dkc Invoke-DockerCompose
