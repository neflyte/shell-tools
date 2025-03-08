$POWERLINE_GIT = 1 # git branch + status
$POWERLINE_SVN = 1 # svn revision + status
$POWERLINE_TT = 1 # timetracker status

$SYMBOL_GIT_BRANCH = ''
$SYMBOL_GIT_MODIFIED = '*'
$SYMBOL_GIT_PUSH = '↑'
$SYMBOL_GIT_PULL = '↓'

$SYMBOL_POWERLINE_DARWIN=''
$SYMBOL_PRIVILEGED = '#'
$SYMBOL_UNIX = '$'
$SYMBOL_WINDOWS = '>'

$COLOR_GIT = $PSStyle.Foreground.Cyan
$COLOR_SVN = $PSStyle.Foreground.Magenta
$COLOR_USERHOST = $PSStyle.Foreground.BrightBlack
$COLOR_CWD = $PSStyle.Foreground.BrightBlue
$COLOR_TEXT = $PSStyle.Foreground.White
$COLOR_RESET = $PSStyle.Reset

function Get-PowerlineSymbol {
    [OutputType([string])]
    param()
    # Unix (Linux, macOS)
    if ($IsLinux -or $IsMacOS) {
        if ($env:EUID -eq '0') {
            return $SYMBOL_PRIVILEGED
        }
        if ($IsMacOS) {
            return $SYMBOL_POWERLINE_DARWIN
        }
        return $SYMBOL_UNIX
    }
    # Windows
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal] $identity
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    $symbol = $SYMBOL_WINDOWS
    if ($principal.IsInRole($adminRole)) {
        $symbol = $SYMBOL_PRIVILEGED
    }
    return $symbol
}

function Get-GitInfo {
    [CmdletBinding()]
    [OutputType([string])]
    param()
    if ($POWERLINE_GIT -ne 1) {
        Write-Debug 'git disabled'
        return ''
    }
    if ($null -eq $(Find-DirectoryFromParent -Directory .git)) {
        Write-Debug 'no git repo in this directory'
        return ''
    }
    if ($null -eq $(Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Debug 'did not find git command'
        return ''
    }
    # get current branch name
    $ref = git symbolic-ref --short HEAD
    if ($LASTEXITCODE -eq 0 -and $ref -ne '') {
        # prepend branch symbol
        $ref = $SYMBOL_GIT_BRANCH + $ref
    } else {
        # get tag name or short unique hash
        $ref = git describe --tags --always
        if ($LASTEXITCODE -ne 0) {
            $ref = ''
        }
    }
    if ($ref -eq '') {
        return '' # not a git repo
    }
    $marks = ''
    $gitStatus = git status --porcelain --branch
    if ($LASTEXITCODE -eq 0) {
        # scan first two lines of output from `git status`
        foreach ($line in $gitStatus) {
            if ($line -match '^##') {
                if ($line -match 'ahead ([0-9]+)') {
                    $marks += " ${SYMBOL_GIT_PUSH}" # + match...
                }
                if ($line -match 'behind ([0-9]+)') {
                    $marks += " ${SYMBOL_GIT_PULL}" # + match...
                }
            } else { # branch is modified if output contains more lines after the header line
                $marks = $SYMBOL_GIT_MODIFIED + $marks
                break
            }
        }
    }
    return $ref + $marks
}

function Get-SvnInfo {
    [CmdletBinding()]
    [OutputType([string])]
    param()
    if ($POWERLINE_SVN -ne 1) {
        Write-Debug 'svn disabled'
        return ''
    }
    if ($null -eq $(Find-DirectoryFromParent -Directory '.svn')) {
        Write-Debug 'no svn repo in this directory'
        return ''
    }
    if ($null -eq $(Get-Command svn -ErrorAction SilentlyContinue)) {
        Write-Debug 'did not find svn command'
        return ''
    }
    $svnInfo = ''
    $relativeUrl = svn info --show-item relative-url
    if ($LASTEXITCODE -eq 0 -and $relativeUrl -ne '') {
        Write-Debug "relativeUrl=${relativeUrl}"
        $svnInfo += $relativeUrl
        $rev = svn info --show-item revision
        if ($LASTEXITCODE -eq 0 -and $rev -ne '') {
            Write-Debug "rev=${rev}"
            $svnInfo += "@${rev}"
        }
        # look for changes
        $changeCtr = 0
        $svnStatus = svn status -q
        if ($LASTEXITCODE -eq 0) {
            Write-Debug "svnStatus=${svnStatus}"
            foreach ($line in $svnStatus) {
                $trimmed = $line.Trim()
                Write-Debug "trimmed=${trimmed}"
                if ($trimmed.Length -eq 0) {
                    continue
                }
                Write-Debug "trimmed[0]=$($trimmed[0])"
                if ($trimmed[0] -in 'A', 'C', 'D', 'M', 'R') {
                    $changeCtr++
                }
            }
            if ($changeCtr -gt 0) {
                $svnInfo += " ${SYMBOL_GIT_MODIFIED}${changeCtr}"
            }
        }
    }
    return $svnInfo
}

function Get-TimetrackerInfo {
    [OutputType([string])]
    param()
    if ($POWERLINE_TT -ne 1) {
        return '' # disabled
    }
    $ttExec = 'timetracker'
    if ($IsWindows) {
        $ttExec += '.exe'
    }
    if ($null -eq $(Get-Command $ttExec -ErrorAction SilentlyContinue)) {
        return '' # timetracker not found
    }
    return $(& $ttExec s -s)
}

function Get-UserAndHost {
    [OutputType([string])]
    param()
    if ($IsLinux -or $IsMacOS) {
        return "${env:USER}@$(hostname -s)"
    }
    # Windows
    return "${env:USERNAME}@${env:COMPUTERNAME}"
}

function prompt {
    # check for previous error and change prompt colour accordingly
    $prev_err = $?
    $symbol = $PSStyle.Foreground.Red
    if ($prev_err) {
        $symbol = $PSStyle.Foreground.Green
    }
    $symbol += "$(Get-PowerlineSymbol)${COLOR_RESET}"

    $git = Get-GitInfo
    $svn = Get-SvnInfo
    $ttstatus = Get-TimetrackerInfo

    $cwd = "${COLOR_CWD}$(Get-Location)${COLOR_RESET}"
    $userhost = "${COLOR_USERHOST}$(Get-UserAndHost)${COLOR_RESET}"

    $lineone = ''
    if ($ttstatus -ne '') {
        $lineone += "${COLOR_TEXT}T:${ttstatus}${COLOR_RESET} "
    }
    if ($git -ne '') {
        $lineone += "${COLOR_GIT}G:${git}${COLOR_RESET} "
    }
    if ($svn -ne '') {
        $lineone += "${COLOR_SVN}S:${svn}${COLOR_RESET} "
    }
    if ($lineone -ne '') {
        $lineone += "`n"
    }

    # If we're on Unix prepend a "PS" string to the last prompt line so
    # we know we're in PowerShell; the prompt symbol will be the same in those cases.
    $psPrefix = ''
    if ($IsLinux -or $IsMacOS) {
        $psPrefix = 'PS '
    }

    # return the new prompt string
    Write-Host -NoNewLine "${COLOR_RESET}${lineone}${psPrefix}${userhost} ${cwd}"
    return " ${symbol} "
}
