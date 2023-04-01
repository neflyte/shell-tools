function Invoke-ConsoleTextEditor {
    $editor = "notepad.exe"
    if ($PSVersionTable.Platform -eq "Unix") {
        $editor = "vim"
    }
    if ($env:EDITOR -ne "") {
        $editor = $env:EDITOR
    }
    . "${editor}" $args
}
