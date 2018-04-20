bpItemIssued.sql
USE [m2mdata01]
GO

/****** Object:  StoredProcedure [dbo].[bpItemIssued]    Script Date: 4/19/2018 2:39:42 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--///////////////////////////////////////////////////////////////////////////////////
-- For each translog items create a record containing newIssuedTotQty,newIssuedTotCost,
-- rwkIssuedTotQty,rwkIssuedTotCost, issuedTotQty,issuedTotCost, and a list of 
-- part Item newIssuedTotQty,rwkIssuedTotQty fields
--///////////////////////////////////////////////////////////////////////////////////
create PROCEDURE [dbo].[bpItemIssued] 
AS
BEGIN
	SET NOCOUNT ON
	IF
	OBJECT_ID('tempdb.dbo.#btItemPartIssuedList1') IS NOT NULL
		DROP TABLE #btItemPartIssuedList1
	IF
	OBJECT_ID('tempdb.dbo.#btItemPartIssuedList2') IS NOT NULL
		DROP TABLE #btItemPartIssuedList2

	IF
	OBJECT_ID('btItemIssued') IS NOT NULL
		DROP TABLE btItemIssued

	Declare @itemPartIssuedList as varchar(max)

	select *,
	RowNum = ROW_NUMBER() OVER (PARTITION BY newItemNumber ORDER BY newItemNumber,partNumber),
	itemPartIssuedList = CAST(NULL AS VARCHAR(max))
	into #btItemPartIssuedList1
	from
	bvItemIssued

	update #btItemPartIssuedList1
	set @itemPartIssuedList = itemPartIssuedList =
	CASE WHEN RowNum = 1 
		THEN partNumber + newItemNumber + 
		', New Issued: ' + convert(varchar(4),newIssuedTotQty) +
		', Rwk Issued: ' + convert(varchar(4),rwkIssuedTotQty) 
		ELSE @itemPartIssuedList + '<br>' + partNumber + newItemNumber + 
		', New Issued: ' + convert(varchar(4),newIssuedTotQty) +
		', Rwk Issued: ' + convert(varchar(4),rwkIssuedTotQty) 
	END

	select newItemNumber,rwkItemNumber,max(itemPartIssuedList) itemPartIssuedList
	into #btItemPartIssuedList2
	from #btItemPartIssuedList1
	group by newItemNumber,rwkItemNumber
	--1235

	select ipi.newItemNumber,ipi.rwkItemNumber,
	iis.newIssuedTotQty,iis.newIssuedTotCost,
	iis.rwkIssuedTotQty,iis.rwkIssuedTotCost,
	iis.issuedTotQty,iis.issuedTotCost,
	ipi.itemPartIssuedList
	into btItemIssued
	from #btItemPartIssuedList2 ipi
	inner join 
	(
		select newItemNumber,
		sum(newIssuedTotQty) newIssuedTotQty,
		sum(newIssuedTotCost) newIssuedTotCost,
		sum(rwkIssuedTotQty) rwkIssuedTotQty,
		sum(rwkIssuedTotCost) rwkIssuedTotCost,
		sum(newIssuedTotQty) + sum(rwkIssuedTotQty) issuedTotQty,
		sum(newIssuedTotCost) + sum(rwkIssuedTotCost) issuedTotCost
		from bvItemIssued
		group by newItemNumber
		--1235
	)iis
	on
	ipi.newItemNumber=iis.newItemNumber
end

GO

