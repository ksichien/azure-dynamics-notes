#!/usr/bin/env pwsh
Import-Module 'C:\Program Files\Microsoft Dynamics NAV\100\Service\NavAdminTool.ps1'

$navinst = 'DynamicsNAV100'
$navsrv = 'MicrosoftDynamicsNavServer$DynamicsNAV100'
$webinst = 'DynamicsNAV100'
$mgmtsvc = 7045
$clientsvc = 7046
$soapsvc = 7047
$odatasvc = 7048
$dbinst = ''
$dbname = 'Demo Database NAV (10-0)'
$dbsrv = 'vandelaysql.database.windows.net'
$svcacc = 'User'
$svccreds = (Get-Credential -Message 'Please provide the Service Account username and password') # dynamics nav service user credentials
$svcct = '40-character-string-from-the-certificate-used-with-IIS-to-enable-SSL-on-the-web-server'

# prerequisites
DISM /Online /Enable-Feature /FeatureName:NetFx3 /All # .NET Framework 3.5 Features
Install-WindowsFeature -Name Search-Service # Windows Search Service

# create new nav server instance
New-NAVServerInstance -ServerInstance $navinst -ManagementServicesPort $mgmtsvc -ClientServicesPort $clientsvc -SOAPServicesPort $soapsvc -ODataServicesPort $odatasvc `
-DatabaseInstance $dbinst -DatabaseName $dbname -DatabaseServer $dbsrv -ServiceAccount $svcacc -ServiceAccountCredential $svccreds `
-ServicesCertificateThumbprint $svcct

# create new web server instance
New-NAVWebServerInstance -WebServerInstance $webinst -Server $navsrv -ServerInstance $navinst
