# Install-Package -Name dotnetCampus.DirectShowLib -ProviderName NuGet -Scope CurrentUser -RequiredVersion 2.1.0.1 -Destination . -Force
$dsPath = Resolve-Path ".\dotnetCampus.DirectShowLib.2.1.0.1\lib\netcoreapp3.1\DirectShowLib.dll"
[System.Reflection.Assembly]::LoadFrom($dsPath)
$dsDevices = [DirectShowLib.DsDevice]::GetDevicesOfCat([DirectShowLib.FilterCategory]::VideoInputDevice)
$dsCam = $null
foreach ($dsdev in $dsDevices) {
  if ($dsdev.Name.StartsWith("Microsoft")) {
    $dsCam = $dsdev
    break
  }
}
if ($null -eq $dsCam) {
  Write-Output "unable to find cam"
  exit 1
}
New-Variable bf
$graphBuilder = New-Object -TypeName DirectShowLib.FilterGraph
$hr = [DirectShowLib.IFilterGraph2].GetMethod("AddSourceFilterForMoniker").Invoke($graphBuilder, @($dsCam.Mon, $null, $dsCam.Name, [ref]$bf))
[DirectShowLib.DsError]::ThrowExceptionForHR($hr)
$icc = [DirectShowLib.IAMCameraControl]$bf
$focusval = 0
$focusflags = $null
$hr = $icc.Get([DirectShowLib.CameraControlProperty]::Focus, ([ref]$focusval), ([ref]$focusflags))
[DirectShowLib.DsError]::ThrowExceptionForHR($hr)
Write-Output "focus value: " + $focusval
