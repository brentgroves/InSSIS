USE [m2mdata01]
GO
/****** Object:  User [admin]    Script Date: 4/24/2018 7:58:06 AM ******/
CREATE USER [admin] FOR LOGIN [admin] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [Administrator]    Script Date: 4/24/2018 7:58:06 AM ******/
CREATE USER [Administrator] FOR LOGIN [BUSCHE\Administrator] WITH DEFAULT_SCHEMA=[Administrator]
GO
/****** Object:  User [BUSCHE\rrecker]    Script Date: 4/24/2018 7:58:06 AM ******/
CREATE USER [BUSCHE\rrecker] FOR LOGIN [BUSCHE\rrecker] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [admin]
GO
ALTER ROLE [db_accessadmin] ADD MEMBER [admin]
GO
ALTER ROLE [db_owner] ADD MEMBER [Administrator]
GO
ALTER ROLE [db_accessadmin] ADD MEMBER [Administrator]
GO
ALTER ROLE [db_securityadmin] ADD MEMBER [Administrator]
GO
ALTER ROLE [db_ddladmin] ADD MEMBER [Administrator]
GO
ALTER ROLE [db_backupoperator] ADD MEMBER [Administrator]
GO
ALTER ROLE [db_datareader] ADD MEMBER [Administrator]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [Administrator]
GO
ALTER ROLE [db_denydatareader] ADD MEMBER [Administrator]
GO
ALTER ROLE [db_denydatawriter] ADD MEMBER [Administrator]
GO
