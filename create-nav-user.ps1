#!/usr/bin/env pwsh
import-module 'C:\Program Files\Microsoft Dynamics NAV\100\Service\NavAdminTool.ps1'
$navinst = 'DynamicsNAV100'
$domain = 'vandelayindustries.com'
$users = @('art','ssadadmin')
$permissions = 'SUPER'
foreach ($user in $users) {
    New-NAVServerUser -ServerInstance $navinst -WindowsAccount "$user@$domain" -LicenseType Full -State Enabled
    New-NAVServerUserPermissionSet -PermissionSetId $permissions -ServerInstance $navinst -WindowsAccount "$user@$domain"
}
