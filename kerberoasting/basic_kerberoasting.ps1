Install-WindowsFeature -Name "RSAT-AD-PowerShell" -IncludeAllSubFeature
Install-WindowsFeature Web-FTP-Server -IncludeAllSubFeature
Install-WindowsFeature Web-Server -IncludeManagementTools
Start-Process "setspn.exe" -ArgumentList "-a FTP/DF-SRV01-win2019.dumpster.fire dumpster\ftpsvc"
Start-Process "setspn.exe" -ArgumentList "-a HTTP/DF-SRV01-win2019.dumpster.fire dumpster\iissvc"