param()
$powerMizerModeValue = '0'
$connectedDisplaysMatches = nvidia-settings -d -q '[gpu:0]/ConnectedDisplays' 2>&1 | Select-String "ConnectedDisplays. \(.*\):(.*)"
$connectedDisplays = $connectedDisplaysMatches.Matches[0].Groups[1].ToString().Trim()
if ($null -ne $connectedDisplays -and -not($connectedDisplays.Equals('.')) -and -not($connectedDisplays.Equals(''))) {
    $powerMizerModeValue = '1'
}
$powerMizerModeSetting = "[gpu:0]/GpuPowerMizerMode=${powerMizerModeValue}"
Write-Verbose "PS> nvidia-settings -a `"${powerMizerModeSetting}`""
$output = nvidia-settings -a "${powerMizerModeSetting}"
if (-not($?)) {
    Write-Error "could not set nvidia setting ${powerMizerModeSetting}"
    exit 1
}
Write-Verbose "set powermizer mode successfully; output: ${output}"
