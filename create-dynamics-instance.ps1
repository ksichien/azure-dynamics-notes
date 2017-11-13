Import-Module 'C:\Program Files\Microsoft Dynamics NAV\100\Service\NavAdminTool.ps1'

$navinst = 'DynamicsNAV101'
$navsrv = 'MicrosoftDynamicsNavServer$DynamicsNAV101'
$webinst = 'DynamicsNAV101'
$mgmtsvc = 7145
$clientsvc = 7146
$soapsvc = 7147
$odatasvc = 7148
$dbcreds = (Get-Credential) # sql server administrator credentials
$dbinst = ''
$dbname = 'Demo Database NAV (10-0)'
$dbsrv = 'vandelaysql.database.windows.net'
$svcacc = 'User'
$svccreds = (Get-Credential) # dynamics nav service user credentials
$svcct = '40-character-string-from-the-certificate-used-with-IIS-to-enable-SSL-on-the-webclient'

# create new nav server instance
New-NAVServerInstance -ServerInstance $navinst -ManagementServicesPort $mgmtsvc -ClientServicesPort $clientsvc -SOAPServicesPort $soapsvc -ODataServicesPort $odatasvc `
-DatabaseCredentials $dbcreds -DatabaseInstance $dbinst -DatabaseName $dbname -DatabaseServer $dbsrv -ServiceAccount $svcacc -ServiceAccountCredential $svccreds `
-ServicesCertificateThumbprint $svcct

# create new web server instance
New-NAVWebServerInstance -WebServerInstance $webinst -Server $navsrv -ServerInstance $navinst
