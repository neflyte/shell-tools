$POWERLINE_GIT = 1 # git branch + status
$POWERLINE_SVN = 1 # svn revision + status
$POWERLINE_TT = 1 # timetracker status

$SYMBOL_GIT_BRANCH = ''
$SYMBOL_GIT_MODIFIED = '*'
$SYMBOL_GIT_PUSH = '↑'
$SYMBOL_GIT_PULL = '↓'

$SYMBOL_POWERLINE_DARWIN=''

$COLOR_GIT = $PSStyle.Foreground.Cyan
$COLOR_SVN = $PSStyle.Foreground.Magenta
$COLOR_USERHOST = $PSStyle.Foreground.BrightBlack
$COLOR_CWD = $PSStyle.Foreground.BrightBlue
$COLOR_TEXT = $PSStyle.Foreground.White
$COLOR_RESET = $PSStyle.Reset

function Get-PowerlineSymbol {
    if ($PSVersionTable.Platform -eq "Unix") {
        if ($env:EUID -eq "0") {
            return "#"
        }
        if ($PSVersionTable.OS -Contains "Darwin") {
            return $SYMBOL_POWERLINE_DARWIN
        }
        return "$"
    }
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal] $identity
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    $symbol = ">"
    if ($principal.IsInRole($adminRole)) {
        $symbol = "#"
    }
    return $symbol
}

function Get-GitInfo {
    if ($POWERLINE_GIT -ne 1) {
        return "" # disabled
    }
    if (-not(Test-Path .git)) {
        return "" # no git repo in this directory
    }
    $null = Get-Command -ErrorVariable hasGitErr -ErrorAction SilentlyContinue git
    if ($hasGitErr -ne "") {
        return "" # git not found
    }
    # get current branch name
    $ref = git symbolic-ref --short HEAD 2>$null
    if ($? -and $ref -ne "") {
        # prepend branch symbol
        $ref = $SYMBOL_GIT_BRANCH + $ref
    } else {
        # get tag name or short unique hash
        $ref = git describe --tags --always 2>$null
    }
    if ($ref -eq "") {
        return "" # not a git repo
    }
    $marks = ""
    $git_status = git status --porcelain --branch 2>$null
    # scan first two lines of output from `git status`
    foreach ($line in $git_status) {
        if ($line -match "^##") {
            if ($line -match "ahead ([0-9]+)") {
                $marks += " ${SYMBOL_GIT_PUSH}" # + match...
            }
            if ($line -match "behind ([0-9]+)") {
                $marks += " ${SYMBOL_GIT_PULL}" # + match...
            }
        } else { # branch is modified if output contains more lines after the header line
            $marks = $SYMBOL_GIT_MODIFIED + $marks
            break
        }
    }
    return $ref + $marks
}

function Get-SvnInfo {
    if ($POWERLINE_SVN -ne 1) {
        return "" # disabled
    }
    if (-not(Test-Path .svn)) {
        return "" # no svn repo in this directory
    }
    $null = Get-Command -ErrorVariable hasSvnErr -ErrorAction SilentlyContinue svn
    if ($hasSvnErr -ne "") {
        return "" # svn not found
    }
    $svn_info = ""
    $relative_url = svn info --show-item relative-url 2>$null
    if ($? -and $relative_url -ne "") {
        $svn_info += $relative_url
        $rev = svn info --show-item revision 2>$null
        if ($? -and $rev -ne "") {
            $svn_info += "@${rev}"
        }
        # look for changes
        $change_ctr = 0
        $svn_status = svn status -q 2>$null
        foreach ($line in $svn_status) {
            $trimmed = $line.Trim()
            if ($trimmed.Length -eq 0) {
                continue
            }
            if ($trimmed[0] -in "A", "C", "D", "M", "R") {
                $change_ctr++
            }
        }
        if ($change_ctr -gt 0) {
            $svn_info += " ${SYMBOL_GIT_MODIFIED}${change_ctr}"
        }
    }
    return $svn_info
}

function Get-TimetrackerInfo {
    if ($POWERLINE_TT -ne 1) {
        return "" # disabled
    }
    $null = Get-Command -ErrorVariable hasTTErr -ErrorAction SilentlyContinue timetracker
    if ($hasTTErr -ne "") {
        return "" # timetracker not found
    }
    return $(timetracker s -s 2>$null)
}

function Get-UserAndHost {
    if ($PSVersionTable.Platform -eq "Unix") {
        return "${env:USER}@$(hostname)"
    }
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

    $lineone = ""
    if ($ttstatus -ne "") {
        $lineone += "${COLOR_TEXT}T:${ttstatus}${COLOR_RESET} "
    }
    if ($git -ne "") {
        $lineone += "${COLOR_GIT}G:${git}${COLOR_RESET} "
    }
    if ($svn -ne "") {
        $lineone += "${COLOR_SVN}S:${svn}${COLOR_RESET} "
    }
    if ($lineone -ne "") {
        $lineone += "`n"
    }

    # return the new prompt string
    "${COLOR_RESET}${lineone}${userhost} ${cwd} ${symbol} ${COLOR_TEXT}"
}
