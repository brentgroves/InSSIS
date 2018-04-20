bvToolItems.sql
USE [Cribmaster]
GO

/****** Object:  View [dbo].[bvToolItems]    Script Date: 4/19/2018 2:08:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--///////////////////////////////////////////////////////////////////////////////////
-- Used to generate the btToolItems which contains Cribmaster item info needed for reports
--///////////////////////////////////////////////////////////////////////////////////
Create VIEW [dbo].[bvToolItems] 
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
when ic.DefaultBuyerGroupID is null then cast('none' as varchar(15)) 
else ic.DefaultBuyerGroupID 
end as DefaultBuyerGroupID, 
case 
when inv.UDFGLOBALTOOL is null then cast('NO' as varchar(20)) 
else inv.UDFGLOBALTOOL 
end as UDFGLOBALTOOL, 
case 
when ip.COST is null then cast(0.0 as decimal(18,2)) 
else ip.COST 
end as Cost
from inventry inv
--14951
inner join
VItemPrice ip
on inv.ItemNumber = ip.ItemNumber
--14951
left outer join
itemclass ic
on inv.ItemClass = ic.ItemClass
--14919 need outer join
where inv.ItemNumber <> '.' and inv.ItemNumber <> ''

GO
