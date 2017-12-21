-- in master
CREATE LOGIN [avandelay] WITH PASSWORD = 'P@ssword!';
CREATE USER [avandelay] FROM LOGIN [avandelay];
-- in dynav database
CREATE USER [avandelay] FROM LOGIN [avandelay];
-- https://docs.microsoft.com/en-us/sql/relational-databases/security/authentication-access/database-level-roles
ALTER ROLE db_owner ADD MEMBER [avandelay]; -- all permissions
ALTER ROLE db_backupoperator ADD MEMBER [avandelay]; -- BACKUP
ALTER ROLE db_accessadmin ADD MEMBER [avandelay]; -- ALTER ANY USER
ALTER ROLE db_securityadmin ADD MEMBER [avandelay]; -- ALTER ANY ROLE
ALTER ROLE db_ddladmin ADD MEMBER [avandelay]; -- CREATE ALTER DROP
ALTER ROLE db_datawriter ADD MEMBER [avandelay]; -- INSERT UPDATE DELETE
ALTER ROLE db_datareader ADD MEMBER [avandelay]; -- SELECT
