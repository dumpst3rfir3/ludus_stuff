Install-WindowsFeature -Name "RSAT-AD-PowerShell" -IncludeAllSubFeature
Install-WindowsFeature Web-Server -IncludeManagementTools
Start-Process "setspn.exe" -ArgumentList "-a HTTP/DF-SRV01-win2019.ludus.domain ludus\victim"
Start-Process "setspn.exe" -ArgumentList "-a HTTP/DF-SRV01-win2019.ludus.domain ludus\stabby"