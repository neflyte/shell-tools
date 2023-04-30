if ($PSVersionTable.PSVersion.Major -gt 5) {
    & powershell -NoLogo -NoProfile -File "${PSCommandPath}"
    return
}

[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
[Windows.UI.Notifications.ToastNotification, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null

$APP_ID = "Timetracker"
$template = @"
<toast activationType="protocol" launch="timetracker:main" duration="short" displayTimestamp="2017-04-15T12:45:00-07:00">
    <visual>
        <binding template="ToastGeneric">
            <image placement="appLogoOverride" src="C:\Users\alan\src\timetracker\assets\icons\icon-v2.png" />
            <text><![CDATA[Task xxxxx started]]></text>
            <text><![CDATA[Started at xxxxx]]></text>
        </binding>
    </visual>
    <audio src="ms-winsoundevent:Notification.Default" loop="false" />
    <actions>
        <action activationType="protocol" content="Dismiss" arguments="action=dismiss" hint-toolTip="Click to dismiss"/>
    </actions>
</toast>
"@

$xml = New-Object Windows.Data.Xml.Dom.XmlDocument
$xml.LoadXml($template)
$toast = New-Object Windows.UI.Notifications.ToastNotification $xml
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($APP_ID).Show($toast)
