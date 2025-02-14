$computers = 'DF-WS01-WIN10', 'DF-WS02-WIN11', 'DF-SRV01-Win2019.dumpster.fire'

Write-Output "Downloading PSExec"
$ProgressPreference = 'SilentlyContinue'
iwr https://download.sysinternals.com/files/PSTools.zip -OutFile PSTools.zip
Expand-Archive .\PSTools.zip

foreach ($computer in $computers) {
    Write-Output "Configuring $computer"
    Write-Output "Making sure WinRM is configured..."
    .\PSTools\PsExec64.exe -accepteula \\$computer -s winrm.cmd quickconfig -q 2> $null

    Write-Output "Configuring RDP and Local Admins..."
	Invoke-Command -ComputerName $computer -ScriptBlock {
		Add-LocalGroupMember -Group "Remote Desktop Users" -Member "dumpster\Sales CA"
		Add-LocalGroupMember -Group "Remote Desktop Users" -Member "dumpster\Sales US"
        Add-LocalGroupMember -Group "Administrators" -Member "dumpster\IT"
	}
    
    Write-Output "Done with $computer `n"
}

Write-Output "Removing PSExec tools"
Remove-Item -Force -Recurse .\PSTools
Write-Output "`n`nDone, have a nice day`n"