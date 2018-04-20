bfActiveJobNoToolList.sql

USE [m2mdata01]
GO

/****** Object:  UserDefinedFunction [dbo].[bfActiveJobNoToolList]    Script Date: 4/20/2018 7:19:54 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create function [dbo].[bfActiveJobNoToolList](
@startDateParam DATETIME, 
@endDateParam DATETIME 
)
RETURNS table
AS
return
	select maxJobNumber as jobNumber, partNumber,m2mDescription, pcsProduced 
	from bfWorkSumLv2NTL(@startDateParam,@endDateParam)

GO

