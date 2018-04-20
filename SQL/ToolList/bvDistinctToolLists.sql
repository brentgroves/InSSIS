bvDistinctToolLists.sql
USE [Busche ToolList]
GO

/****** Object:  View [dbo].[bvDistinctToolLists]    Script Date: 4/19/2018 12:28:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[bvDistinctToolLists]
as
-- Remove duplicates only differing in plant
select OriginalProcessId,ProcessId,
Customer,PartFamily,OperationDescription,PartNumber,descript Description,descr CustPartFamily
from
bvToolListsInPlants
group by 
OriginalProcessId,ProcessId,
Customer,PartFamily,OperationDescription,PartNumber,Descript,descr


GO
