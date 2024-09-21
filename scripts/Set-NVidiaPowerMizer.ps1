param()
$screens = @(nvidia-settings -q screens)
if (-not($?)) {
    Write-Verbose 'could not get list of connected screens'
    exit 1
}
Write-Verbose "got list of connected screens; screens: ${screens}"
$powerMizerModeSetting = '[gpu:0]/GpuPowerMizerMode='
if ($screens.Length -le 1) {
    Write-Verbose 'no screens connected; set PowerMizer mode to adaptive'
    $powerMizerModeSetting += '0'
} else {
    Write-Verbose 'found connected screens; set PowerMizer to max performance'
    $powerMizerModeSetting += '1'
}
Write-Verbose "PS> nvidia-settings -a `"${powerMizerModeSetting}`""
$output = nvidia-settings -a "${powerMizerModeSetting}"
if (-not($?)) {
    Write-Verbose "could not set nvidia setting ${powerMizerModeSetting}"
    exit 1
}
Write-Verbose "set powermizer mode successfully; output: ${output}"
