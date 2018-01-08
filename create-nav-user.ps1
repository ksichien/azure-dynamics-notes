#!/usr/bin/env pwsh
import-module 'C:\Program Files\Microsoft Dynamics NAV\100\Service\NavAdminTool.ps1'
$navinstances = @('DynamicsNAV100')
$domain = 'vandelayindustries.com'
$users = @('art','ssadadmin')
$permissions = 'SUPER'

foreach ($user in $users) {
    foreach ($navinst in $navinstances) {
        New-NAVServerUser -ServerInstance $navinst -UserName $user -AuthenticationEmail "$user@$domain" -LicenseType Full -State Enabled
        New-NAVServerUserPermissionSet -PermissionSetId $permissions -ServerInstance $navinst -UserName $user
    }
}
