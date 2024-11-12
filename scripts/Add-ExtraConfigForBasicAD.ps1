$creds = Get-Credential -Message "Enter domain admin creds"
$DCs = Get-ADDomainController | select -ExpandProperty hostname
$computers = Get-ADComputer -Filter * | Where-Object { $DCs -notcontains $_.dnshostname }
foreach ($computer in $computers) {
	$ip = Test-Connection $computer.dnshostname -Count 1 | select -ExpandProperty IPV4Address | select -ExpandProperty IPAddressToString
    Write-Host "$ip"
    Set-Item WSMan:\localhost\Client\TrustedHosts -Value "$ip" -Force -Concatenate
	Invoke-Command -ComputerName "$ip" -Credential $creds -ScriptBlock {
		Add-LocalGroupMember -Group "Remote Desktop Users" -Member "dumpster\Sales CA"
		Add-LocalGroupMember -Group "Remote Desktop Users" -Member "dumpster\Sales US"
        Add-LocalGroupMember -Group "Administrators" -Member "dumpster\IT"
	}
}

Clear-Item WSMan:\localhost\Client\TrustedHosts -Force