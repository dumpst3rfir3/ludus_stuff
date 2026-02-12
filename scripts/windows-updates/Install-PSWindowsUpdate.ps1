# Enables WinRM, then installs NuGet Package Provider and PSWindowsUpdate 
# Module to make Windows Update installation via PowerShell easy

### RUN FROM THE DC AS DOMAINADMIN ###

Write-Output "Downloading PSExec"
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest https://download.sysinternals.com/files/PSTools.zip -OutFile PSTools.zip
Expand-Archive .\PSTools.zip -Force

# Ignore the DC
$all = Get-ADComputer -Filter * | Select-Object -ExpandProperty DNSHostName
$dc  = "$env:COMPUTERNAME" + ".$env:USERDNSDOMAIN"
$clients = $all | Where-Object { $_ -ne $dc }

foreach ($client in $clients) {
    Write-Output "Making sure WinRM is configured..."
    .\PSTools\PsExec64.exe -accepteula \\$client -s winrm.cmd quickconfig -q 2> $null
}

Invoke-Command -ComputerName $clients -ScriptBlock {
    Write-Output "Installing NuGet and PSWindowsUpdate..."
    Install-PackageProvider -Name NuGet -Force
    Install-Module PSWindowsUpdate -Force
}

Write-Output "Removing PSExec tools"
Remove-Item -Force -Recurse .\PSTools*