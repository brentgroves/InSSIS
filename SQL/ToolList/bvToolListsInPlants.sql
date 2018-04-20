bvToolListsInPlants.sql
USE [Busche ToolList]
GO

/****** Object:  View [dbo].[bvToolListsInPlants]    Script Date: 4/19/2018 12:32:10 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create VIEW [dbo].[bvToolListsInPlants]
AS
	select lv1.Originalprocessid,lv1.processid, 
		lv1.customer,lv1.partfamily,lv1.OperationDescription,
		lv1.descript,lv1.descr,	
		lv1.subDescript,lv1.subDescr,
		lv1.partNumber,tp.Plant 

	from
	( 
		select * from bvToolListsAssignedPN
		--732
	) lv1
	INNER JOIN
	[ToolList Plant] AS tp 
	ON lv1.ProcessID = tp.ProcessID

GO

