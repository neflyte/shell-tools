using namespace Terminal.Gui

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
            Y = 1
            Width = [Dim]::Fill()
        }
        $this.parameterValueLabel = [Label] @{
            Text = 'Value:'
            X = 1
            Y = 3
        }
        $this.parameterValueTextField = [TextField] @{
            X = [Pos]::Right($this.parameterValueLabel) + 1
            Y = 3
            Width = [Dim]::Fill()
        }
        $this.okButton = [Button] @{
            X = [Pos]::Center()
            Y = 5
            Text = 'OK'
            IsDefault = $true
        }
        $this.okButton.add_Clicked({
            param($s, $e)
            [Application]::RequestStop()
        })
        $this.cancelButton = [Button] @{
            X = [Pos]::Right($this.okButton) + 1
            Y = 5
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
            $this.parameterValueTextField
        )
        $this.Buttons.Add($this.okButton, $this.cancelButton)
    }
}
