$FileServer = "SRV01"
$user = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object System.Security.Principal.WindowsPrincipal($user)
$groups = $user.Groups |
    ForEach-Object {
        try { $_.Translate([System.Security.Principal.NTAccount]).Value } catch { $null }
    } |
    Where-Object { $_ } |
    ForEach-Object { ($_ -split '\\')[-1] }

$public = "\\$FileServer\InternalPublicData"
if (-not (Test-Path "P:\")) { New-PSDrive -Name P -PSProvider FileSystem -Root $public -Persist }

$salesGroups = @("Sales US","Sales CA")
if ($groups | Where-Object { $salesGroups -contains $_ }) {
    $sales = "\\$FileServer\InternalSalesData"
    if (-not (Test-Path "S:\")) { New-PSDrive -Name S -PSProvider FileSystem -Root $sales -Persist }
}

$adminGroups = @("IT","Domain Admins")
if ($groups | Where-Object { $adminGroups -contains $_ }) {
    $admin = "\\$FileServer\InternalAdminData"
    if (-not (Test-Path "A:\")) { New-PSDrive -Name A -PSProvider FileSystem -Root $admin -Persist }
}