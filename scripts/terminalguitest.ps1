using namespace Terminal.Gui

Import-Module Microsoft.PowerShell.ConsoleGuiTools
$module = (Get-Module Microsoft.PowerShell.ConsoleGuiTools -List).ModuleBase
Add-Type -Path (Join-path $module Terminal.Gui.dll)
Add-Type -Path (Join-path $module NStack.dll)

class TestDialog : Dialog {
    [Label]$parameterNameLabel
    [Label]$parameterNameTextLabel
    [Label]$parameterValueLabel
    [TextField]$parameterValueTextField
    [Button]$okButton
    [Button]$cancelButton

    TestDialog() {
        $this.Title = 'Test dialog'
        $this.InitUI()
    }

    [void] InitUI() {
        $this.parameterNameLabel = [Label] @{
            Text = 'Parameter:'
            X = 1
            Y = 1
        }
        $this.parameterNameTextLabel = [Label] @{
            Text = 'AZURE_DEVOPS_EXT_PAT'
            X = [Pos]::Right($this.parameterNameLabel) + 1
            Width = [Dim]::Fill()
        }
        $this.parameterValueLabel = [Label] @{
            Text = 'Value:'
            X = 1
            Y = 3
        }
        $this.parameterValueTextField = [TextField] @{
            X = [Pos]::Right($this.parameterValueLabel) + 1
            Width = [Dim]::Fill()
        }
        $this.okButton = [Button] @{
            X = [Pos]::Center()
            Y = [Pos]::Center() - 1
            Text = 'OK'
            IsDefault = $true
        }
        $this.okButton.add_Clicked({
            param($s, $e)
            [Application]::RequestStop()
        })
        $this.cancelButton = [Button] @{
            X = [Pos]::Center()
            Y = [Pos]::Center() - 2
            Text = 'CANCEL'
            IsDefault = $false
        }
        $this.cancelButton.add_Clicked({
            param($s, $e)
            [Application]::RequestStop()
        })
        $this.Add(
            $this.parameterNameLabel,
            $this.parameterNameTextLabel,
            $this.parameterValueLabel,
            $this.parameterValueTextField,
            $this.okButton,
            $this.cancelButton
        )
    }
}

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

[Application]::Init()
$Window = [TestWindow]::new()
[Application]::Run($Window)
$Window.Dispose()
[Application]::ShutDown()
