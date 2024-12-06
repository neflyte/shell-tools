using namespace Terminal.Gui
using namespace System.Data
using module ./EditParameterDialog.psm1

class TestWindow : Terminal.Gui.Window {
    [Button]$showDialogButton
    [TableView]$tableView
    [DataTable]$dataTable
    [Dialog]$editDialog

    [Hashtable]$testData = @{
        LIBRARY_BRANCH = 'fury'
        PIPELINE_BRANCH = 'fury'
        GIT_TOPIC = 'fury'
        AZURE_DEVOPS_EXT_PAT = ''
    }

    TestWindow() {
        $this.Title = 'Hello, World! (CTRL-Q to quit)'
        $this.InitDataTable()
        $this.InitUI()
    }

    [void] InitDataTable() {
        $this.dataTable = [DataTable]::new('JobParameters')
        $this.dataTable.Columns.Add('Parameter')
        $this.dataTable.Columns.Add('Value')
        $this.testData.Keys.ForEach{
            $this.dataTable.Rows.Add(@($_, $this.testData[$_]))
        }
    }

    [void] InitUI() {
        $this.tableView = [TableView]@{
            X = 0
            Y = 0
            Width = [Dim]::Fill()
            Height = [Dim]::Fill()
            FullRowSelect = $true
        }
        $this.tableView.Table = $this.dataTable
        $this.tableView.add_CellActivated({
            param([TableView+CellActivatedEventArgs]$s, $e)
            $dlg = [EditParameterDialog]::new()
            $dlg.InitUI(
                $s.Table.Rows[$s.Row].Parameter,
                $s.Table.Rows[$s.Row].Value
            )
            [Terminal.Gui.Application]::Run($dlg)
            $dlg.Dispose()
        })
        $this.Add($this.tableView)
    }

    [Terminal.Gui.Dialog] InitEditDialog() {
        $dlg = [Terminal.Gui.Dialog]::new()
        $parameterNameLabel = [Label] @{
            Text = 'Parameter:'
            X = 1
            Y = 1
            Height = 1
        }
        $parameterNameTextLabel = [Label] @{
            Text = 'PARAMETER_NAME'
            X = [Pos]::Right($parameterNameLabel) + 1
            Y = 1
            Height = 1
            Width = [Dim]::Fill()
        }
        $parameterValueLabel = [Label] @{
            Text = 'Value:'
            X = 1
            Y = 3
            Height = 1
        }
        $parameterValueTextField = [TextField] @{
            Text = 'value'
            X = [Pos]::Right($parameterValueLabel) + 1
            Y = 3
            Width = [Dim]::Fill()
            Height = 1
        }
        $okButton = [Button] @{
            X = [Pos]::Center()
            Y = 5
            Text = 'OK'
            IsDefault = $true
        }
        $okButton.add_Clicked({
            param($s, $e)
            [Terminal.Gui.Application]::RequestStop()
        })
        $cancelButton = [Button] @{
            X = [Pos]::Right($okButton) + 1
            Y = 5
            Text = 'CANCEL'
            IsDefault = $false
        }
        $cancelButton.add_Clicked({
            param($s, $e)
            [Terminal.Gui.Application]::RequestStop()
        })
        $dlg.Add(
            $parameterNameLabel,
            $parameterNameTextLabel,
            $parameterValueLabel,
            $parameterValueTextField
        )
        $dlg.Buttons.Add($okButton, $cancelButton)
        return $dlg
    }
}
