<#
Generate an XML file describing a Gnome background slideshow
#>
param(
    [float]$Delay = 300.0,
    [float]$TransitionTime = 2.0
)
$outFile = "$HOME/.local/share/backgrounds/walls.xml"
$files = Get-ChildItem "$HOME/Pictures/walls" | Where-Object {
    $_.Name.EndsWith('.gif') -or
        $_.Name.EndsWith('.jpg') -or
        $_.Name.EndsWith('.jpeg') -or
        $_.Name.EndsWith('.png') -or
        $_.Name.EndsWith('.webp')
}
Write-Output "$($files.Length) images -> ${outFile}"
$xmlw = [System.Xml.XmlTextWriter]::new($outFile, $null)
$xmlw.Formatting = 'Indented'
$xmlw.Indentation = 1
$xmlw.IndentChar = "`t"
$xmlw.WriteStartDocument()
$xmlw.WriteStartElement('background')
$xmlw.WriteStartElement('starttime')
$xmlw.WriteElementString('year', '2024')
$xmlw.WriteElementString('month', '3')
$xmlw.WriteElementString('day', '24')
$xmlw.WriteElementString('hour', '10')
$xmlw.WriteElementString('minute', '49')
$xmlw.WriteElementString('second', '0')
$xmlw.WriteEndElement()  # <starttime>
for ([int]$x = 0; $x -lt $files.Count; $x++) {
    $file = $files[$x]
    if ($x + 1 -lt $files.Count) {
        $nextFile = $files[$($x + 1)]
    } else {
        $nextFile = $files[0]
    }
    $xmlw.WriteStartElement('static')
    $xmlw.WriteElementString('duration', '{0:F1}' -f $Delay)
    $xmlw.WriteElementString('file', $file.FullName)
    $xmlw.WriteEndElement()  # <static>
    $xmlw.WriteStartElement('transition')
    $xmlw.WriteElementString('duration', '{0:F1}' -f $TransitionTime)
    $xmlw.WriteElementString('from', $file.FullName)
    $xmlw.WriteElementString('to', $nextFile.FullName)
    $xmlw.WriteEndElement()  # <transition>
}
$xmlw.WriteEndElement()  # <background>
$xmlw.WriteEndDocument()
$xmlw.Flush()
$xmlw.Close()
Write-Output 'done.'
