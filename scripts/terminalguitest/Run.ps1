using namespace Terminal.Gui
using module ./TestWindow.psm1

[Application]::Init()
$testWindow = [TestWindow]::new()
[Application]::Run($testWindow)
$testWindow.Dispose()
[Application]::ShutDown()
