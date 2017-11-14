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
$navinst = 'DynamicsNAV101'
$navsrv = 'MicrosoftDynamicsNavServer$DynamicsNAV101'

# generate a new nav encryption key
$keylocation = 'C:\nav.key'
$keycreds = (Get-Credential).Password # enter a new password for securing the encryption key here
New-NAVEncryptionKey -KeyPath $keylocation -Password $keycreds

# import the nav encryption key
$sqldb = 'Demo Database NAV (10-0)'
$sqldbcreds = (Get-Credential) # enter sql db admin credentials here
Import-NAVEncryptionKey -ServerInstance $navinst -KeyPath $keylocation -ApplicationDatabaseServer $sqlsrv `
-ApplicationDatabaseName $sqldb -ApplicationDatabaseCredentials $sqldbcreds -Password $keycreds

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

# set client services credential type
$key = 'ClientServicesCredentialType'
$csct = 'AccessControlService'
Set-NAVServerConfiguration -ServerInstance $navinst -keyname $key -keyvalue $csct

# set azure app id uri
$key = 'AppIdUri'
$adtenant = 'vandelayindustries.onmicrosoft.com'
$appiduri = "https://$adtenant/36-character-string-from-azure"
Set-NAVServerConfiguration -ServerInstance $navinst -keyname $key -keyvalue $appiduri

# set federation metadata location
$key = 'ClientServicesFederationMetadataLocation'
$value = "https://login.windows.net/$adtenant/FederationMetadata/2007-06/FederationMetadata.xml"
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
$dnsidentity = 'nav.vandelayindustries.com'
$websrv = "https://$dnsidentity/$navinst/WebClient"

# microsoft dynamics nav web server
$iisconfig = "C:\inetpub\wwwroot\$navinst\web.config"
$doc = (Get-Content $iisconfig) -as [Xml]
$obj1 = $doc.configuration.DynamicsNAVSettings.add | where-object {$_.Key -eq 'ServerInstance'}
$obj1.value = $navinst
$obj2 = $doc.configuration.DynamicsNAVSettings.add | where-object {$_.Key -eq 'ClientServicesCredentialType'}
$obj2.value = $csct
$obj3 = $doc.configuration.DynamicsNAVSettings.add | where-object {$_.Key -eq 'DnsIdentity'}
$obj3.value = $dnsidentity
$obj4 = $doc.configuration.DynamicsNAVSettings.add | where-object {$_.Key -eq 'ACSUri'}
$obj4.value = "https://login.windows.net/$adtenant/wsfed?wa=wsignin1.0%26wtrealm=$appiduri"
$doc.Save($iisconfig)
iisreset

# microsoft dynamics nav windows client
$clientconfig = "$env:appdata\Microsoft\Microsoft Dynamics NAV\100\ClientUserSettings.config"
$doc = (Get-Content $clientconfig) -as [Xml]
$obj1 = $doc.configuration.appsettings.add | where-object {$_.Key -eq 'ServerInstance'}
$obj1.value = $navinst
$obj2 = $doc.configuration.appsettings.add | where-object {$_.Key -eq 'ClientServicesCredentialType'}
$obj2.value = $csct
$obj3 = $doc.configuration.appsettings.add | where-object {$_.Key -eq 'ACSUri'}
$obj3.value = "https://login.windows.net/$adtenant/wsfed?wa=wsignin1.0%26wtrealm=$appiduri%26wreply=$websrv"
$obj4 = $doc.configuration.appsettings.add | where-object {$_.Key -eq 'DnsIdentity'}
$obj4.value = $dnsidentity
$doc.Save($clientconfig)
