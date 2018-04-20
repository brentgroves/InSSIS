bfNoValueAddSales.sql

USE [m2mdata01]
GO

/****** Object:  UserDefinedFunction [dbo].[bfNoValueAddSales]    Script Date: 4/20/2018 7:33:53 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create FUNCTION [dbo].[bfNoValueAddSales] (@startDateParam DATETIME,@endDateParam DATETIME) 
  RETURNS Table 
AS 
RETURN
select lv3.jobNumber, lv3.partNumber, lv3.partRev, lv3.Description, 
lv3.pcsProduced,lv3.valueAddedSales 
from
(
	select maxJobNumber jobNumber, partNumber, partRev, left(Descript,40) description, cast(pcsProduced as int) pcsProduced,valueAddedSales
	from bfWorkSumLv2(@startDateParam,@endDateParam)
		where valueAddedSales = 0
) lv3
inner join
(
	select distinct PartNumber from toolingtranslog 
	where (TranStartDateTime >= @startDateParam) and (TranStartDateTime <= @endDateParam)
) ttl
on lv3.partNumber = ttl.partNumber


GO

