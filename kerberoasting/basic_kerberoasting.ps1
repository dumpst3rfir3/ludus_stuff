Invoke-Command -ComputerName DF-SRV01-win2019.dumpster.fire -ScriptBlock {
    Install-WindowsFeature RSAT-AD-PowerShell -IncludeAllSubFeature
    Install-WindowsFeature Web-Windows-Auth
    Install-WindowsFeature Web-Server -IncludeManagementTools
    Import-Module WebAdministration
    Set-WebConfigurationProperty -filter /system.WebServer/security/authentication/AnonymousAuthentication -name enabled -value false -location "IIS:\Sites\Default Web Site"
    Set-WebConfigurationProperty -filter /system.WebServer/security/authentication/WindowsAuthentication -name enabled -value true -location "IIS:\Sites\Default Web Site"
}
setspn.exe /s HTTP/DF-SRV01-win2019 dumpster.fire\iissvc
setspn.exe /s HTTP/DF-SRV01-win2019.dumpster.fire dumpster.fire\iissvc
setspn.exe /l iissvc
Invoke-Command -ComputerName DF-SRV01-win2019.dumpster.fire -ScriptBlock {
    Import-Module WebAdministration
    $appPoolName = "DefaultAppPool"
    $newIdentity = "SpecificUser"
    $userName = "dumpster.fire\iissvc"
    $password = 'P@$$w0rd'
    Set-ItemProperty "IIS:\AppPools\$appPoolName" -name "processModel.identityType" -value $newIdentity
    Set-ItemProperty "IIS:\AppPools\$appPoolName" -name "processModel.userName" -value $userName
    Set-ItemProperty "IIS:\AppPools\$appPoolName" -name "processModel.password" -value $password
    Set-WebConfigurationProperty -filter /system.WebServer/security/authentication/WindowsAuthentication -name useAppPoolCredentials -value true -location "IIS:\Sites\Default Web Site"
    iisreset
}
