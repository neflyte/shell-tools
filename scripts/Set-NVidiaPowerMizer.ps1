param()
$powerMizerModeValue = '0'
$connectedDisplaysMatches = nvidia-settings -d -q '[gpu:0]/ConnectedDisplays' 2>&1 | Select-String "ConnectedDisplays. \(.*\):(.*)"
if ($connectedDisplaysMatches.Matches[0].Groups[1].ToString().Trim() -ne '') {
    $powerMizerModeValue = '1'
}
$powerMizerModeSetting = "[gpu:0]/GpuPowerMizerMode=${powerMizerModeValue}"
Write-Verbose "PS> nvidia-settings -a `"${powerMizerModeSetting}`""
$output = nvidia-settings -a "${powerMizerModeSetting}"
if (-not($?)) {
    Write-Verbose "could not set nvidia setting ${powerMizerModeSetting}"
    exit 1
}
Write-Verbose "set powermizer mode successfully; output: ${output}"
