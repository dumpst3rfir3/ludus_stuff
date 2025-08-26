# Add server names here
$servers = @("SRV01")

# Add workstations here
$workstations = @("WS01", "WS02")

# Put domain groups/users you want to be local/server admins here
$localAdmins = @("dumpster\Domain Admins", "dumpster\IT")

# Put domain groups/users you want to be in RDP users for workstations here
$rdpUsers = @("dumpster\Sales CA", "dumpster\Sales US")

Write-Output "Downloading PSExec"
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest https://download.sysinternals.com/files/PSTools.zip -OutFile PSTools.zip
Expand-Archive .\PSTools.zip

foreach ($server in $servers) {
    Write-Output "Configuring server $server..."
    Write-Output "Making sure WinRM is configured..."
    .\PSTools\PsExec64.exe -accepteula \\$server -s winrm.cmd quickconfig -q 2> $null

    Write-Output "Configuring Local Admins..."
	Invoke-Command -ComputerName $server -ScriptBlock {
		$currentMembers = Get-LocalGroupMember -Group "Administrators" | Select-Object -ExpandProperty Name
		foreach ($localAdmin in $Using:localAdmins) {
			Write-Output "Adding $localAdmin to Local Admins"
			if ($currentMembers -contains $localAdmin) {
				Write-Output "...already in Local Admins"
				continue
			}
			Add-LocalGroupMember -Group "Administrators" -Member "$localAdmin"	
		}
	}
    
    Write-Output "Done with $server `n"
}

foreach ($workstation in $workstations) {
    Write-Output "Configuring workstation $workstation..."
    Write-Output "Making sure WinRM is configured..."
    .\PSTools\PsExec64.exe -accepteula \\$workstation -s winrm.cmd quickconfig -q 2> $null

    Write-Output "Configuring RDP and Local Admins..."
	Invoke-Command -ComputerName $workstation -ScriptBlock {
		$currentMembers = Get-LocalGroupMember -Group "Remote Desktop Users" | Select-Object -ExpandProperty Name
		foreach ($rdpUser in $Using:rdpUsers) {
			Write-Output "Adding $rdpUser to RDP Users"
			if ($currentMembers -contains $rdpUser) {
				Write-Output "...already in RDP Users"
				continue
			}
			Add-LocalGroupMember -Group "Remote Desktop Users" -Member $rdpUser
		}
		
		$currentMembers = Get-LocalGroupMember -Group "Administrators" | Select-Object -ExpandProperty Name
		foreach ($localAdmin in $Using:localAdmins) {
			Write-Output "Adding $localAdmin to Local Admins"
			if ($currentMembers -contains $localAdmin) {
				Write-Output "...already in Local Admins"
				continue
			}
			Add-LocalGroupMember -Group "Administrators" -Member $localAdmin
		}
        	
	}
    
    Write-Output "Done with $workstation `n"
}


Write-Output "Removing PSExec tools"
Remove-Item -Force -Recurse .\PSTools*
Write-Output "`n`nDone, have a nice day`n"