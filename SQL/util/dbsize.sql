dbsize.sql
I put these queries together some time ago. Feel free to use them as you wish.

-- SQL Server 2000 only.
--
-- Author: Damon T. Wilson
-- Creation Date: 13-DEC-2006
-- 
-- Usage:
-- Display the Database ID, Database Name, Logical File Name,
-- MB Size on Disk, GB Size on Disk and Physical File Name
-- for all databases in this instance.
use master;
go

select
db.[dbid] as 'DB ID'
,db.[name] as 'Database Name'
,af.[name] as 'Logical Name'
--,af.[size] as 'File Size (in 8-kilobyte (KB) pages)'
,(((CAST(af.[size] as DECIMAL(18,4)) * 8192) /1024) /1024) as 'File Size (MB)'
,((((CAST(af.[size] as DECIMAL(18,4)) * 8192) /1024) /1024) /1024) as 'File Size (GB)'
,af.[filename] as 'Physical Name' 
from sysdatabases db
inner join sysaltfiles af
on db.dbid = af.dbid
where [fileid] in (1,2);


-- SQL Server 2005 only.
--
-- Author: Damon T. Wilson
-- Creation Date: 13-DEC-2006
-- 
-- Usage:
-- Display the Database ID, Database Name, Logical File Name,
-- MB Size on Disk, GB Size on Disk and Physical File Name
-- for all databases in this instance.
use master;
go

select
db.[dbid] as 'DB ID'
,db.[name] as 'Database Name'
,af.[name] as 'Logical Name'
--,af.[size] as 'File Size (in 8-kilobyte (KB) pages)'
,(((CAST(af.[size] as DECIMAL(18,4)) * 8192) /1024) /1024) as 'File Size (MB)'
,((((CAST(af.[size] as DECIMAL(18,4)) * 8192) /1024) /1024) /1024) as 'File Size (GB)'
,af.[filename] as 'Physical Name' 
from sys.sysdatabases db
inner join sys.sysaltfiles af
on db.dbid = af.dbid
where [fileid] in (1,2); 

"Key"
MCITP: DBA, MCSE, MCTS: SQL 2005, OCP