bvItemIssued.sql
USE [m2mdata01]
GO

/****** Object:  View [dbo].[bvItemIssued]    Script Date: 4/19/2018 2:42:03 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--///////////////////////////////////////////////////////////////////////////////////
-- For each translog items create a record containing newIssuedTotQty,newIssuedTotCost,
-- rwkIssuedTotQty,rwkIssuedTotCost, issuedTotQty,issuedTotCost
--///////////////////////////////////////////////////////////////////////////////////
create view [dbo].[bvItemIssued] 
AS
	select 
	case 
		when new.PartNumber is null then rwk.PartNumber
		else new.PartNumber
	end partNumber,
	case 
		when new.ItemNumber is null then SUBSTRING(rwk.ItemNumber,1,len(rwk.ItemNumber)-1)
		else new.ItemNumber
	end newItemNumber,
	case 
		when rwk.ItemNumber is null then new.ItemNumber + 'R'
		else rwk.ItemNumber 
	end rwkItemNumber,
	case
		when new.newIssuedTotQty is null then 0
		else new.newIssuedTotQty
	end newIssuedTotQty,
	case
		when new.newIssuedTotCost is null then 0.0
		else new.newIssuedTotCost
	end newIssuedTotCost,
	case
		when rwk.rwkIssuedTotQty is null then 0
		else rwk.rwkIssuedTotQty
	end rwkIssuedTotQty,
	case
		when rwk.rwkIssuedTotCost is null then 0.0
		else rwk.rwkIssuedTotCost
	end rwkIssuedTotCost
	from
	(
		select partNumber,itemNumber,
		sum(qty) newIssuedTotQty, sum(qty*unitCost) newIssuedTotCost 
		from btTransLogMonth
		group by partNumber,ItemNumber
		having ItemNumber <> '' and ItemNumber <> '.'
		and itemNumber not like '%R'
		--2613
	)new
	full join
	(
		select partNumber,itemNumber,
		sum(qty) rwkIssuedTotQty, sum(qty*unitCost) rwkIssuedTotCost 
		from btTransLogMonth
		group by partNumber,ItemNumber
		having ItemNumber <> '' and ItemNumber <> '.'
		and itemNumber like '%R'
		--80
	)rwk
	--2693
	on
	new.PartNumber=rwk.partNumber and
	new.ItemNumber=SUBSTRING(rwk.ItemNumber,1,len(rwk.ItemNumber)-1)
	--2672


GO

