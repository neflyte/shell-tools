function Invoke-GraphicalTextEditor {
    $editor = "notepad.exe"
    if ($PSVersionTable.Platform -eq "Unix") {
        $editor = "gvim"
    }
    if ($env:VISUAL -ne "") {
        $editor = $env:VISUAL
    }
    Start-Process $editor -ArgumentList @($args) -NoNewWindow
}
