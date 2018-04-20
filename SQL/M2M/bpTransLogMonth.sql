bpTransLogMonth.sql
USE [m2mdata01]
GO

/****** Object:  StoredProcedure [dbo].[bpTransLogMonth]    Script Date: 4/19/2018 2:22:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--///////////////////////////////////////////////////////////////////////////////////
-- Inserts only transactions occuring within the last month into 
-- the btTransLogMonth table
--///////////////////////////////////////////////////////////////////////////////////
create PROCEDURE [dbo].[bpTransLogMonth] 
AS
BEGIN
	SET NOCOUNT ON
	Declare @startDateParam DATETIME
	Declare @endDateParam DATETIME
	set @startDateParam = DATEADD (month ,-1, GETDATE())
	set @endDateParam = GETDATE()
	IF
	OBJECT_ID('btTransLogMonth') IS NOT NULL
		DROP TABLE btTransLogMonth
	select * 
	into btTransLogMonth
	from toolingtranslog
	where transtartdatetime >= @startDateParam
	and transtartdatetime <= @endDateParam
end

GO


