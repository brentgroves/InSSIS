VToolItems.sql
USE [Cribmaster]
GO

/****** Object:  View [dbo].[VToolItems]    Script Date: 4/19/2018 11:54:51 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create VIEW [dbo].[VToolItems] 
AS
select inv.ItemNumber,
case 
when inv.Description1 is null then cast('none' as varchar(50)) 
else inv.Description1 
end as Description1,
case 
when inv.ItemClass is null then cast('none' as varchar(15)) 
else inv.ItemClass 
end as ItemClass, 
case 
when inv.UDFGLOBALTOOL is null then cast('NO' as varchar(20)) 
else inv.UDFGLOBALTOOL 
end as UDFGLOBALTOOL, 
case 
when ip.COST is null then cast(0.0 as decimal(18,2)) 
else ip.COST 
end as Cost
from inventry inv
inner join
VItemPrice ip
on inv.ItemNumber = ip.ItemNumber
where inv.ItemNumber <> '.'


GO