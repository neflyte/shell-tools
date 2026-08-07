SET shellObj = CreateObject("WScript.Shell")
shellObj.Run "C:\Windows\system32\taskmgr.exe", 7, false
SET shellObj = Nothing
