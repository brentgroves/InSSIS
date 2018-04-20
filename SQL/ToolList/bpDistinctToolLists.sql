bpDistinctToolLists.sql
USE [Busche ToolList]
GO

/****** Object:  StoredProcedure [dbo].[bpDistinctToolLists]    Script Date: 4/19/2018 12:27:21 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--///////////////////////////////////////////////////////////////////////////////////
-- Generate Distinct ToolList table
--///////////////////////////////////////////////////////////////////////////////////
create PROCEDURE [dbo].[bpDistinctToolLists] 
AS
BEGIN
	IF
	OBJECT_ID('btDistinctToolLists') IS NOT NULL
		DROP TABLE btDistinctToolLists
	select * 
	into btDistinctToolLists
	from bvDistinctToollists
end

GO