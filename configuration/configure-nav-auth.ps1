#!/usr/bin/env pwsh
# https://community.dynamics.com/nav/b/dynamicsnavcloudfronts/archive/2017/08/16/deploy-a-microsoft-dynamics-nav-database-to-azure-sql-database
# https://docs.microsoft.com/en-us/azure/sql-database/sql-database-aad-authentication-configure
# https://msdn.microsoft.com/en-us/library/dn414569(v=nav.90).aspx
### azure configuration ###
$rgname = 'aad-dynamics-rg'
$sqlsrv = 'vandelaysql.database.windows.net'
$navemail = 'ssadadmin@vandelayindustries.com'

# log in to azure
Add-AzureRmAccount

# set the active directory administrator for the sql server
Set-AzureRmSqlServerActiveDirectoryAdministrator -ResourceGroupName $rgname -ServerName $sqlsrv -DisplayName $navemail

### microsoft dynamics nav server configuration ###
Import-Module 'C:\Program Files\Microsoft Dynamics NAV\100\Service\NavAdminTool.ps1'
$navinst = 'nav100-live'
$navsrv = 'MicrosoftDynamicsNavServer$nav100-live'

# generate a new nav encryption key
$keylocation = 'C:\nav.key'
$keycreds = (Get-Credential -Message 'Please provide the NAV Encryption Key password').Password
New-NAVEncryptionKey -KeyPath $keylocation -Password $keycreds

# import the nav encryption key
$sqldb = 'Demo Database NAV (10-0)'
$sqldbcreds = (Get-Credential -Message 'Please provide the Azure SQL Server Admin username and password')
Import-NAVEncryptionKey -ServerInstance $navinst -KeyPath $keylocation -ApplicationDatabaseServer $sqlsrv `
-ApplicationDatabaseName $sqldb -ApplicationDatabaseCredentials $sqldbcreds -Password $keycreds -Force

# configure sql server authentication
Set-NAVServerConfiguration -ServerInstance $navinst -DatabaseCredentials $sqldbcreds

# enable sql connection encryption
$key = 'EnableSqlConnectionEncryption'
$value = 'True'
Set-NAVServerConfiguration -ServerInstance $navinst -keyname $key -keyvalue $value

# disable sql server certificate trust
$key = 'TrustSQLServerCertificate'
$value = 'False'
Set-NAVServerConfiguration -ServerInstance $navinst -keyname $key -keyvalue $value

# enable ssl for soap services
$key = 'SOAPServicesSSLEnabled'
$value = 'True'
Set-NAVServerConfiguration -ServerInstance $navinst -keyname $key -keyvalue $value

# enable ssl for odata services
$key = 'ODataServicesSSLEnabled'
$value = 'True'
Set-NAVServerConfiguration -ServerInstance $navinst -keyname $key -keyvalue $value

# set client services credential type
$key = 'ClientServicesCredentialType'
$csct = 'AccessControlService'
Set-NAVServerConfiguration -ServerInstance $navinst -keyname $key -keyvalue $csct

# set azure app id uri
$key = 'AppIdUri'
$adtenant = 'vandelayindustries.onmicrosoft.com'
$appiduri = "https://${adtenant}/36-character-string-from-azure"
Set-NAVServerConfiguration -ServerInstance $navinst -keyname $key -keyvalue $appiduri

# set azure ws federation login endpoint
$key = 'WSFederationLoginEndpoint'
$acsuri = "https://login.windows.net/${adtenant}/wsfed?wa=wsignin1.0%26wtrealm=${appiduri}"
$dnsidentity = 'nav.vandelayindustries.com'
$wsfed = "${acsuri}%26wreply=https://${dnsidentity}/${navinst}/WebClient/SignIn.aspx"
Set-NAVServerConfiguration -ServerInstance $navinst -keyname $key -keyvalue $wsfed

# set azure federation metadata location
$key = 'ClientServicesFederationMetadataLocation'
$value = "https://login.windows.net/${adtenant}/FederationMetadata/2007-06/FederationMetadata.xml"
Set-NAVServerConfiguration -ServerInstance $navinst -keyname $key -keyvalue $value

# restart the nav server instance
Set-NavServerInstance $navsrv -restart

# import the license file
$license = 'C:\nav\dvd\SQLDemoDatabase\CommonAppData\Microsoft\Microsoft Dynamics NAV\100\Database\Cronus.flf'
Import-NAVServerLicense -ServerInstance $navinst -LicenseFile $license -Database NavDatabase -Force

# add nav user
$navusr = 'ssadadmin'
New-NAVServerUser -ServerInstance $navinst -UserName $navusr -AuthenticationEmail $navemail -LicenseType Full -State Enabled
New-NAVServerUserPermissionSet -PermissionSetId 'SUPER' -ServerInstance $navinst -UserName $navusr

### client configuration ###
$csp = '7046'
$srv = 'localhost'
$spn = "(net.tcp://${srv}:${csp}/${navinst}/Service)=NoSpn"

##### NOTE: when using a management services port other than 7045, a new key will need to be added to the IIS web.config file #####
#$msp = 7045
#$obj8 = $doc.configuration.DynamicsNAVSettings.add | where-object {$_.Key -eq 'ManagementServicesPort'}
#$obj8.value = $msp

# microsoft dynamics nav web server components
$iisconfig = "C:\inetpub\wwwroot\${navinst}\web.config"
$doc = (Get-Content $iisconfig) -as [Xml]
$obj1 = $doc.configuration.DynamicsNAVSettings.add | where-object {$_.Key -eq 'Server'}
$obj1.value = $srv
$obj2 = $doc.configuration.DynamicsNAVSettings.add | where-object {$_.Key -eq 'ServerInstance'}
$obj2.value = $navinst
$obj3 = $doc.configuration.DynamicsNAVSettings.add | where-object {$_.Key -eq 'ClientServicesPort'}
$obj3.value = $csp
$obj4 = $doc.configuration.DynamicsNAVSettings.add | where-object {$_.Key -eq 'ClientServicesCredentialType'}
$obj4.value = $csct
$obj5 = $doc.configuration.DynamicsNAVSettings.add | where-object {$_.Key -eq 'UnknownSpnHint'}
$obj5.value = $spn
$obj6 = $doc.configuration.DynamicsNAVSettings.add | where-object {$_.Key -eq 'DnsIdentity'}
$obj6.value = $dnsidentity
$obj7 = $doc.configuration.DynamicsNAVSettings.add | where-object {$_.Key -eq 'HelpServer'}
$obj7.value = $srv
$doc.Save($iisconfig)
iisreset

# microsoft dynamics nav windows client
$clientconfig = "${env:appdata}\Microsoft\Microsoft Dynamics NAV\100\ClientUserSettings.config"
$doc = (Get-Content $clientconfig) -as [Xml]
$obj1 = $doc.configuration.appsettings.add | where-object {$_.Key -eq 'Server'}
$obj1.value = $srv
$obj2 = $doc.configuration.appsettings.add | where-object {$_.Key -eq 'ServerInstance'}
$obj2.value = $navinst
$obj3 = $doc.configuration.appsettings.add | where-object {$_.Key -eq 'ClientServicesPort'}
$obj3.value = $csp
$obj4 = $doc.configuration.appsettings.add | where-object {$_.Key -eq 'ClientServicesCredentialType'}
$obj4.value = $csct
$obj5 = $doc.configuration.appsettings.add | where-object {$_.Key -eq 'UnknownSpnHint'}
$obj5.value = $spn
$obj6 = $doc.configuration.appsettings.add | where-object {$_.Key -eq 'DnsIdentity'}
$obj6.value = $dnsidentity
$obj7 = $doc.configuration.appsettings.add | where-object {$_.Key -eq 'ACSUri'}
$obj7.value = $wsfed
$obj8 = $doc.configuration.appsettings.add | where-object {$_.Key -eq 'HelpServer'}
$obj8.value = $srv
$doc.Save($clientconfig)
