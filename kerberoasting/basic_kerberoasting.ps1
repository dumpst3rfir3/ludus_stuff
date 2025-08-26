# Update with your server and domain names if different
$iisServer = "SRV01"
$rangeDomain = "dumpster.fire"
Write-Output "Configuring IIS for Kerberos Authentication on $iisServer.$rangeDomain"

Invoke-Command -ComputerName "$iisServer.$rangeDomain" -ScriptBlock {
    Install-WindowsFeature RSAT-AD-PowerShell -IncludeAllSubFeature
    Install-WindowsFeature Web-Windows-Auth
    Install-WindowsFeature Web-Server -IncludeManagementTools
    Import-Module WebAdministration
    Set-WebConfigurationProperty -filter /system.WebServer/security/authentication/AnonymousAuthentication -name enabled -value false -location "IIS:\Sites\Default Web Site"
    Set-WebConfigurationProperty -filter /system.WebServer/security/authentication/WindowsAuthentication -name enabled -value true -location "IIS:\Sites\Default Web Site"
}
setspn.exe /s "HTTP/$iisServer" "$rangeDomain\iissvc"
setspn.exe /s "HTTP/$iisServer.$rangeDomain" "$rangeDomain\iissvc"
setspn.exe /l iissvc
Invoke-Command -ComputerName "$iisServer.$rangeDomain" -ScriptBlock {
    Import-Module WebAdministration
    $appPoolName = "DefaultAppPool"
    $newIdentity = "SpecificUser"

    # Change user name and password if you used a different config
    $userName = "$rangeDomain\iissvc"
    $password = 'P@$$w0rd'

    Set-ItemProperty "IIS:\AppPools\$appPoolName" -name "processModel.identityType" -value $newIdentity
    Set-ItemProperty "IIS:\AppPools\$appPoolName" -name "processModel.userName" -value $userName
    Set-ItemProperty "IIS:\AppPools\$appPoolName" -name "processModel.password" -value $password
    Set-WebConfigurationProperty -filter /system.WebServer/security/authentication/WindowsAuthentication -name useAppPoolCredentials -value true -location "IIS:\Sites\Default Web Site"
    iisreset
}

# Shout-out to this great blog post:
# https://woshub.com/configuring-kerberos-authentication-on-iis-website/
