# Add server names here
$servers = @("SRV01")

# Add workstations here
$workstations = @("WS01", "WS02")

# Put domain groups/users you want to be local/server admins here
$localAdmins = @("dumpster\Domain Admins", "dumpster\IT")

# Put domain groups/users you want to be in RDP users for workstations here
$rdpUsers = @("dumpster\Sales CA", "dumpster\Sales US")

# Don't forget to modify this if you're using a different domain, OU, etc.
$DomainFqdn     = "dumpster.fire"
$DomainDN       = "DC=dumpster,DC=fire"
$UsersOU = "OU=People,$DomainDN"
$GpoName        = "User Drive Mapping (GPP)"

# This uses SRV01 as the file server by default, but you can change it here
$FileServer     = "SRV01"

Write-Output "Downloading PSExec"
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest https://download.sysinternals.com/files/PSTools.zip -OutFile PSTools.zip
Expand-Archive .\PSTools.zip -Force

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

Write-Output "Creating shared folders on primary server..."
Invoke-Command -ComputerName $servers[0] -ScriptBlock {
	$Folder1 = "C:\SharedData"
	$Folder2 = "C:\SharedAdminData"
	$Folder3 = "C:\SharedSalesData"
	New-Item -Path $Folder1 -ItemType Directory -Force
	New-Item -Path $Folder2 -ItemType Directory -Force
	New-Item -Path $Folder3 -ItemType Directory -Force
	New-Item -Path "$Folder1\EmployeeDirectory.txt" -ItemType File -Force -Value "This is the employee directory"
	New-Item -Path "$Folder2\AdminSecrets.txt" -ItemType File -Force -Value "This is top secret admin data"
	New-Item -Path "$Folder3\SalesReportUS.txt" -ItemType File -Force -Value "This is the US sales report"
	New-Item -Path "$Folder3\SalesReportCA.txt" -ItemType File -Force -Value "This is the CA sales report"
	$Share1 = "InternalPublicData"
	$Share2 = "InternalAdminData"
	$Share3 = "InternalSalesData"
	New-SmbShare -Name $Share1 -Path $Folder1 -FullAccess "Everyone"
	New-SmbShare -Name $Share2 -Path $Folder2 -FullAccess "dumpster\IT", "dumpster\Domain Admins"
	New-SmbShare -Name $Share3 -Path $Folder3 -FullAccess "dumpster\Sales CA", "dumpster\Sales US", "dumpster\Domain Admins" -ReadAccess "dumpster\IT"
}
Write-Output "Shared folders created."

# Creating logon script to map drives for users
Write-Output "Creating logon script to map drives for users..."
$LogonScript = @'
# Logon-MapDrives.ps1

# File server
$FileServer = "SRV01"

# Get current username and groups
$user = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object System.Security.Principal.WindowsPrincipal($user)

$groups = $user.Groups |
    ForEach-Object {
        try {
            $_.Translate([System.Security.Principal.NTAccount]).Value
        } catch {
            $null
        }
    } |
    Where-Object { $_ } |
    ForEach-Object { ($_ -split '\\')[-1] }


# Map Public Data for all users
$public = "\\$FileServer\InternalPublicData"
if (-not (Test-Path "P:\")) { New-PSDrive -Name P -PSProvider FileSystem -Root $public -Persist }

# Map Sales Data for Sales users
$salesGroups = @("Sales US","Sales CA")
if ($groups | Where-Object { $salesGroups -contains $_ }) {
    $sales = "\\$FileServer\InternalSalesData"
    if (-not (Test-Path "S:\")) { New-PSDrive -Name S -PSProvider FileSystem -Root $sales -Persist }
}

# Map Admin Data for IT/Admin users
$adminGroups = @("IT","Domain Admins")
if ($groups | Where-Object { $adminGroups -contains $_ }) {
    $admin = "\\$FileServer\InternalAdminData"
    if (-not (Test-Path "A:\")) { New-PSDrive -Name A -PSProvider FileSystem -Root $admin -Persist }
}

'@
$ScriptPath = "\\$DomainFqdn\SYSVOL\$DomainFqdn\scripts"
New-Item -Path $ScriptPath -ItemType Directory -Force
$LogonScript | Out-File "$ScriptPath\Logon-MapDrives.ps1" -Encoding UTF8 -Force
$CmdPath = "$ScriptPath\Logon-MapDrives.cmd"
$CmdContent = @"
@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Logon-MapDrives.ps1"
exit /b 0
"@
$CmdContent | Out-File $CmdPath -Encoding ASCII -Force
Get-ADUser -Filter * -SearchBase "OU=People,DC=dumpster,DC=fire" | 
    ForEach-Object {
        Set-ADUser $_ -ScriptPath "Logon-MapDrives.cmd"
    }

# Cleanup
Write-Output "Removing PSExec tools"
Remove-Item -Force -Recurse .\PSTools*
Write-Output "`n`nDone, have a nice day`n"