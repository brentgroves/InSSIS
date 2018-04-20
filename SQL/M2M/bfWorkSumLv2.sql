bfWorkSumLv2.sql

USE [m2mdata01]
GO

/****** Object:  UserDefinedFunction [dbo].[bfWorkSumLv2]    Script Date: 4/20/2018 7:35:58 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create FUNCTION [dbo].[bfWorkSumLv2]
(  
@startDateParam DATETIME,
@endDateParam DATETIME
)
RETURNS TABLE 
AS
RETURN
-- use this function to sum all parts made in a specified time period
select partNumber, partRev, maxJobNumber,maxOperNo,fpro_id,fdept,
m2mDescription, tlDescription as descript, valueAddedSales,budgetedToolAllowance,
NTLFlag,PartRevInItemMaster,
sum(fcompqty) as pcsProduced  
from bfWorkSumLv1(@startDateParam,@endDateParam)
group by partNumber, partRev, maxJobNumber,maxOperNo,fpro_id,fdept,
	m2mDescription,tldescription,valueAddedSales,budgetedToolAllowance,NTLFlag, 
	PartRevInItemMaster

GO


