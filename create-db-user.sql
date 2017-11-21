-- in master
create login [avandelay] with password = 'P@ssword!'
create user [avandelay] from login [avandelay];
-- in db
create user [avandelay] from login [avandelay];
exec sp_addRoleMember 'db_owner', 'avandelay';
