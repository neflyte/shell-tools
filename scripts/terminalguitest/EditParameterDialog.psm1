using namespace Terminal.Gui

class EditParameterDialog : Terminal.Gui.Dialog {
    [Label]$parameterNameLabel
    [Label]$parameterNameTextLabel
    [Label]$parameterValueLabel
    [TextField]$parameterValueTextField
    [Button]$okButton
    [Button]$cancelButton
    [String]$parameterName
    [String]$parameterValue

    EditParameterDialog() {
        $this.Title = 'Edit Parameter'
        $this.Width = [Dim]::Percent(50)
        $this.Height = [Dim]::Percent(35)
    }

    [void] InitUI([String]$paramName, [String]$paramValue) {
        $this.parameterName = $paramName
        $this.parameterValue = $paramValue
        $this.parameterNameLabel = [Label] @{
            Text = 'Parameter:'
            X = 1
            Y = 1
            Height = 1
        }
        $this.parameterNameTextLabel = [Label] @{
            Text = $this.parameterName
            X = [Pos]::Right($this.parameterNameLabel) + 1
            Y = 1
            Height = 1
            Width = [Dim]::Fill()
        }
        $this.parameterValueLabel = [Label] @{
            Text = 'Value:'
            X = 1
            Y = 3
            Height = 1
        }
        $this.parameterValueTextField = [TextField] @{
            Text = $this.parameterValue
            X = [Pos]::Right($this.parameterValueLabel) + 1
            Y = 3
            Width = [Dim]::Fill()
            Height = 1
        }
        $this.okButton = [Button] @{
            X = [Pos]::Center() + 5
            Y = 6
            Text = 'OK'
            IsDefault = $true
        }
        $this.okButton.add_Clicked({
            param($s, $e)
            [Terminal.Gui.Application]::RequestStop()
        })
        $this.cancelButton = [Button] @{
            X = [Pos]::Center() - 10
            Y = 6
            Text = 'CANCEL'
            IsDefault = $false
        }
        $this.cancelButton.add_Clicked({
            param($s, $e)
            [Terminal.Gui.Application]::RequestStop()
        })
        $this.Add(
            $this.parameterNameLabel,
            $this.parameterNameTextLabel,
            $this.parameterValueLabel,
            $this.parameterValueTextField,
            $this.cancelButton,
            $this.okButton
        )
    }
}
