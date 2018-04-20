bvObsToolListItemsLv1.sql
USE [Busche ToolList]
GO

/****** Object:  View [dbo].[bvObsToolListItemsLv1]    Script Date: 4/19/2018 2:19:42 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-------------------------------------------------
-- Obsolete ToolList items,misc,and fixture detail
-------------------------------------------------
create View [dbo].[bvObsToolListItemsLv1] 
AS
	SELECT tm.OriginalProcessID, tm.processid,CribToolID as itemNumber, (tm.Customer + ' / ' + tm.PartFamily + ' / ' + tm.OperationDescription) tlDescription,
	tt.ToolID, tt.processid as ttpid, tt.toolNumber,tt.OpDescription, 
	ti.itemid,ti.tooltype,ti.tooldescription,  
	 case 
		when tt.PartSpecific = 0 and ti.Consumable = 1 then (ti.Quantity * (tm.AnnualVolume/12.0)) / (ti.QuantityPerCuttingEdge * ti.NumberOfCuttingEdges) 
		when tt.PartSpecific = 1 and ti.Consumable = 1  then (ti.Quantity * (tt.AdjustedVolume/12)) / (ti.QuantityPerCuttingEdge * ti.NumberOfCuttingEdges) 
		when ti.Consumable = 0 then ti.Quantity
	  end MonthlyUsage  
	FROM [TOOLLIST ITEM] as ti 
	-- when a tool gets deleted the toollist item remains sometimes?
	inner join [TOOLLIST TOOL] as tt on ti.toolid=tt.toolid
	INNER JOIN 
	(
		-- these are obsolete toollists
		select * 
		from
		[ToolList Master] tm
		where Obsolete = 1
		--43
	) as tm 
	ON tt.PROCESSID = tm.PROCESSID 
	--1925
union
	SELECT tm.originalprocessid, tm.processid,CribToolID as itemNumber, (tm.Customer + ' / ' + tm.PartFamily + ' / ' + tm.OperationDescription) tlDescription,
	0 as ToolID, 0 as ttpid, 0 as toolNumber,'Fixture' as OpDescription, 
	tf.itemid,tf.tooltype,tf.tooldescription,  
	0 as MonthlyUsage  
	FROM [TOOLLIST Fixture] as tf 
	INNER JOIN 
	(
		-- these are obsolete toollists
		select * 
		from
		[ToolList Master] tm
		where Obsolete = 1
		--43
	) as tm 
	ON tf.PROCESSID = tm.PROCESSID 
	--48
union
	SELECT tm.OriginalProcessID, tm.processid,CribToolID as itemNumber, (tm.Customer + ' / ' + tm.PartFamily + ' / ' + tm.OperationDescription) tlDescription,
	0 as ToolID, 0 as ttpid, 0 as toolNumber,'Misc' as OpDescription, 
	m.itemid,m.tooltype,m.tooldescription,  
	 case 
		when m.Consumable = 1 then (m.Quantity * (tm.AnnualVolume/12.0)) / (m.QuantityPerCuttingEdge * m.NumberOfCuttingEdges) 
		else m.Quantity
	  end MonthlyUsage  
	FROM [ToolList Misc] as m 
	INNER JOIN 
	(
		-- these are obsolete toollists
		select * 
		from
		[ToolList Master] tm
		where Obsolete = 1
		--43
	)  
	as tm 
	ON m.PROCESSID = tm.PROCESSID 
	--370
--1983


GO