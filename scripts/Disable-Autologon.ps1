$computers = Get-ADComputer -Filter * | Select-Object -ExpandProperty DNSHostName

foreach ($computer in $computers) {
    Invoke-Command -ComputerName $computer -ScriptBlock {
        $RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
        Set-ItemProperty $RegistryPath 'AutoAdminLogon' -Value '0'
        Remove-ItemProperty $RegistryPath 'DefaultPassword' -ErrorAction SilentlyContinue
        Remove-ItemProperty $RegistryPath 'DefaultUserName' -ErrorAction SilentlyContinue
        Remove-ItemProperty $RegistryPath 'DefaultDomainName' -ErrorAction SilentlyContinue
    }
    Write-Output "Automatic logon has been disabled on $computer`n"
}
