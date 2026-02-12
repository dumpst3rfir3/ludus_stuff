# Creates a scheduled task to import PSWindowsUpdate and use it to install
# Windows updates, and reboot if necessary

### RUN FROM DC AS DOMAINADMIN ###

# Remove the DC, otherwise a reboot will end the script
$all = Get-ADComputer -Filter * | Select-Object -ExpandProperty DNSHostName
$dc  = "$env:COMPUTERNAME" + ".$env:USERDNSDOMAIN"
$clients = $all | Where-Object { $_ -ne $dc }

Invoke-Command -ComputerName $clients -ScriptBlock {
    $action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
        -Argument "-NoProfile -Command `"Import-Module PSWindowsUpdate; Get-WindowsUpdate -Install -AcceptAll -AutoReboot`""

    $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1)

    Register-ScheduledTask -TaskName "RunWindowsUpdate" `
        -Action $action `
        -Trigger $trigger `
        -User "SYSTEM" `
        -RunLevel Highest `
        -Force
}

# After everything else finishes, update the DC itself  
Import-Module PSWindowsUpdate
Get-WindowsUpdate -Install -AcceptAll -AutoReboot