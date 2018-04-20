bvActiveJobNoToolListWeek.sql

USE [m2mdata01]
GO

/****** Object:  View [dbo].[bvActiveJobNoToolListWeek]    Script Date: 4/20/2018 7:17:50 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[bvActiveJobNoToolListWeek]   
AS
select * from dbo.bfActiveJobNoToolListWeek()

GO


