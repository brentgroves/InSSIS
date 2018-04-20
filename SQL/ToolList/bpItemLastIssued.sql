bpItemLastIssued.sql
USE [m2mdata01]
GO

/****** Object:  StoredProcedure [dbo].[bpItemLastIssued]    Script Date: 4/19/2018 2:37:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--///////////////////////////////////////////////////////////////////////////////////
-- Searches the toolingtranslog for the last issue date for all items
--///////////////////////////////////////////////////////////////////////////////////
create PROCEDURE [dbo].[bpItemLastIssued] 
AS
BEGIN
	SET NOCOUNT ON
	IF
	OBJECT_ID('btItemLastIssued') IS NOT NULL
		DROP TABLE btItemLastIssued

	select itemNumber,max(transtartdatetime) lastIssued 
	into btItemLastIssued
	from toolingtranslog
	group by itemNumber
	having (itemNumber <> '') and (itemNumber is not null) and (substring(itemNumber,1,1)in ('0','1','2','3','4','5','6','7','8','9'))
	--3658
end

GO


