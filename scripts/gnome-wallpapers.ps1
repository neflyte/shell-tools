<#
Generate an XML file describing Gnome background wallpapers
#>
param(
    [float]$Delay = 300.0,
    [float]$TransitionTime = 2.0
)
$outFile = "$HOME/.local/share/gnome-background-properties/backgrounds.xml"
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
[string]$pubid = $null
[string]$sysid = 'gnome-wp-list.dtd'
[string]$subset = $null
$xmlw.WriteDocType('wallpapers', $pubid, $sysid, $subset)
$xmlw.WriteStartElement('wallpapers')
foreach ($file in $files) {
    $xmlw.WriteStartElement('wallpaper')
    $fileName = $file.Name.Substring(0, $file.Name.IndexOf('.'))
    $xmlw.WriteElementString('_name', $fileName)
    $xmlw.WriteElementString('filename', $file.FullName)
    $xmlw.WriteElementString('options', 'zoom')
    $xmlw.WriteElementString('pcolor', '#000000')
    $xmlw.WriteElementString('scolor', '#000000')
    $xmlw.WriteElementString('shade_type', 'solid')
    $xmlw.WriteEndElement()  # <wallpaper>
}
$xmlw.WriteEndElement()  # <wallpapers>
$xmlw.WriteEndDocument()
$xmlw.Flush()
$xmlw.Close()
Write-Output 'done.'
