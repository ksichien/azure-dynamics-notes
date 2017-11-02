import-module 'C:\Program Files\Microsoft Dynamics NAV\100\Service\NavAdminTool.ps1'
$navinst = 'DynamicsNAV101'
$domain = 'vandelayindustries.com'
$users = get-content "C:\users.txt"
$permissions = 'SUPER'
foreach ($user in $users) {
    New-NAVServerUser -ServerInstance $navinst -WindowsAccount "$user@$domain" -LicenseType Full -State Enabled
    New-NAVServerUserPermissionSet -PermissionSetId $permissions -ServerInstance $navinst -WindowsAccount "$user@$domain"
}
