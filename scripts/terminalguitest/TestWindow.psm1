using namespace Terminal.Gui
using module ./TestDialog.psm1

class TestWindow : Window {
    [Button]$showDialogButton

    TestWindow() {
        $this.Title = 'Hello, World! (CTRL-Q to quit)'
        $this.InitUI()
    }

    [void] InitUI() {
        $this.showDialogButton = [Button]@{
            X = [Pos]::Center()
            Y = [Pos]::Center()
            IsDefault = $true
            Text = '_Show Dialog'
        }
        $this.showDialogButton.add_Clicked({
            param($s, $e)
            $dlg = [TestDialog]::new()
            [Application]::Run($dlg)
            $dlg.Dispose()
        })
        $this.Add($this.showDialogButton)
    }
}
