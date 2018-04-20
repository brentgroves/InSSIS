bpToolListPartItems.sql
USE [Busche ToolList]
GO

/****** Object:  StoredProcedure [dbo].[bpToolListPartItems]    Script Date: 4/19/2018 2:28:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--///////////////////////////////////////////////////////////////////////////////////
-- all toolops and the itemsPerPart multiplier for distinct partnumber,itemnumber pairs
--///////////////////////////////////////////////////////////////////////////////////
create PROCEDURE [dbo].[bpToolListPartItems] 
AS
BEGIN
	SET NOCOUNT ON
	IF
	OBJECT_ID('tempdb.dbo.#btToolOps') IS NOT NULL
		DROP TABLE #btToolOps
	IF
	OBJECT_ID('btToolListPartItems') IS NOT NULL
		DROP TABLE btToolListPartItems

	DECLARE
		  @allToolOps VARCHAR(max)

	select
		partNumber,
		itemNumber,
		itemsPerPart, 
		'<br>' +  tlDescription + ', ' + OpDescription + ', ' + tooldescription + 
		'<br>Quantity Per Tool:' + cast(Quantity as varchar(10)) +
		', Quantity Per Cutting Edge:' + cast(QuantityPerCuttingEdge as varchar(10)) +
		', Number Of Cutting Edges:' + cast(NumberOfCuttingEdges as varchar(10)) +
		'<br>Items Per Part:' + cast(cast(itemsPerPartPerTool as numeric(19,8)) as varchar(50)) as ToolOp
		, RowNum = ROW_NUMBER() OVER (PARTITION BY partNumber,itemNumber ORDER BY 1/0)
		, allToolOps = CAST(NULL AS VARCHAR(max))
	INTO #btToolOps
	from 
	(
		select tid.partNumber,tid.itemnumber,tid.itemsPerPart as itemsPerPartPerTool,
		tis.itemsPerPart,tlDescription,
		opDescription,tooldescription,monthlyUsage,
		itemType,Quantity,AnnualVolume,QuantityPerCuttingEdge,NumberOfCuttingEdges,
		tid.Consumable,PartSpecific,AdjustedVolume
		from 
		(
			select * from bvToolListItemsLv1
			where consumable = 1
			--8407
		)tid
		--32571
		inner join
		(
			--distinct partNumber,itemNumber
			select partNumber, itemNumber,consumable,
			sum(itemsPerPart) as itemsPerPart
			from bvToolListItemsLv1
			group by 
			partNumber, itemNumber,consumable
			having Consumable = 1 
			-- 7050
		) tis
		on
		tid.partNumber=tis.partNumber and
		tid.itemNumber=tis.itemNumber
		--8407
	) tops

	UPDATE #btToolOps
	SET 
		  @allToolOps = allToolOps =
			CASE WHEN RowNum = 1 
				THEN toolOp
				ELSE @allToolOps + '<br>' + toolOp 
			END

	select partNumber,itemNumber,itemsPerPart, 
		max(allToolOps) as toolOps
	into btToolListPartItems
	from #btToolOps
	group by partNumber,itemNumber,itemsPerPart
	-- 7050
end
GO

