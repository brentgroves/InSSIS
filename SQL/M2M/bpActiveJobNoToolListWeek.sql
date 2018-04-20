bpActiveJobNoToolListWeek.sql
USE [m2mdata01]
GO

/****** Object:  StoredProcedure [dbo].[bpActiveJobNoToolListWeek]    Script Date: 4/19/2018 2:55:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[bpActiveJobNoToolListWeek]
AS
	SET NOCOUNT ON
	IF
	OBJECT_ID('btActiveJobNoToolListWeek') IS NOT NULL
		DROP TABLE btActiveJobNoToolListWeek

	select * 
	into btActiveJobNoToolListWeek
	from 
	bvActiveJobNoToolListWeek


GO

