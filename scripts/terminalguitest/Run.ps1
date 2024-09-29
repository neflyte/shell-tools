using namespace Terminal.Gui
using module ./TestWindow.psm1

[Application]::Init()
$Window = [TestWindow]::new()
[Application]::Run($Window)
$Window.Dispose()
[Application]::ShutDown()
