-- in master
create login [avandelay] with password = 'P@ssword!'
create user [avandelay] from login [avandelay];
-- in db
create user [avandelay] from login [avandelay];
alter role db_owner add member [avandelay]; -- debugging
alter role db_ddladmin add member [avandelay]; -- alter create drop
alter role db_datawriter add member [avandelay]; -- insert update delete
alter role db_datareader add member [avandelay]; -- select
