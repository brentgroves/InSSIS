bfNoVendorCost.sql

USE [m2mdata01]
GO

/****** Object:  UserDefinedFunction [dbo].[bfNoVendorCost]    Script Date: 4/20/2018 7:44:34 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create function [dbo].[bfNoVendorCost](
@startDateParam DATETIME, 
@endDateParam DATETIME 
)
RETURNS table
AS
return
select ttl.itemnumber,description1
from 
(
select distinct itemnumber 
from toolingtranslog 
where unitcost = 0 
and (transtartdatetime >= @startDateParam) and (transtartdatetime <= @endDateParam)
) ttl
left outer join
toolitems ti
on ttl.itemnumber=ti.itemnumber

GO

