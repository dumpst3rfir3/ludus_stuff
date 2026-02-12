# This can be used to verify that updates were installed on domain machines

### RUN FROM DC AS DOMAINADMIN ###

$all = Get-ADComputer -Filter * | Select-Object -ExpandProperty DNSHostName
$dc  = "$env:COMPUTERNAME" + ".$env:USERDNSDOMAIN"
$clients = $all | Where-Object { $_ -ne $dc }

Invoke-Command -ComputerName $clients -ScriptBlock {
    Import-Module PSWindowsUpdate
    Get-WUHistory | Select -First 5
}