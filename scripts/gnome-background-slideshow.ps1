<#
Generate an XML file describing a Gnome background slideshow
#>
param(
    [Parameter(Mandatory)][string]$ImageDir,
    [Parameter(Mandatory)][string]$OutFile,
    [int]$Delay = 300
)
$files = Get-ChildItem $ImageDir
Write-Output "$($files.Size) images -> ${OutFile}"
$xmlw = [System.Xml.XmlTextWriter]::new($OutFile, $null)
$xmlw.Formatting = 'Indented'
$xmlw.Indentation = 1
$xmlw.IndentChar = "`t"
$xmlw.WriteStartDocument()
$xmlw.WriteStartElement('background')
for ([int]$x = 0; $x -lt $files.Count; $x++) {
    $file = $files[$x]
    if ($x + 1 -lt $files.Count) {
        $nextFile = $files[$($x + 1)]
    } else {
        $nextFile = $files[0]
    }
    $xmlw.WriteStartElement('static')
    $xmlw.WriteElementString('duration', "${Delay}")
    $xmlw.WriteElementString('file', $file.FullName)
    $xmlw.WriteEndElement()  # <static>
    $xmlw.WriteStartElement('transition')
    $xmlw.WriteElementString('from', $file.FullName)
    $xmlw.WriteElementString('to', $nextFile.FullName)
    $xmlw.WriteEndElement()  # <transition>
}
$xmlw.WriteEndElement()  # <background>
$xmlw.Flush()
$xmlw.Close()
Write-Output 'done.'
