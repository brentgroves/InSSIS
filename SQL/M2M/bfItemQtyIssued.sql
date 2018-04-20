bfItemQtyIssued.sql
USE [m2mdata01]
GO

/****** Object:  UserDefinedFunction [dbo].[bfItemQtyIssued]    Script Date: 4/19/2018 2:53:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--///////////////////////////////////////////////////////////////////////////////////
-- Total Item quantities that have been issued from the Cribs and ToolBosses
--///////////////////////////////////////////////////////////////////////////////////
create function [dbo].[bfItemQtyIssued]
( 
	@startDateParam DATETIME,
	@endDateParam DATETIME 
)
returns table
AS
return
	select itemNumber,lQtyIssued,rQtyIssued,
	lQtyIssued+rQtyIssued qtyIssued
	from 
	(
		select tll.itemNumber,tll.lQtyIssued,
		case
			when tlr.rQtyIssued is null then 0
			else tlr.rQtyIssued
		end rQtyIssued
		from 
		(
			select itemNumber,sum(qty) lQtyIssued 
			from 
			(
				select itemNumber,qty from toolingtranslog
				where transtartdatetime >= @startDateParam
				and transtartdatetime <= @endDateParam
				and itemNumber not like '%R'
				and itemNumber <> ''
			)tl1
			group by itemNumber
			--20 secs
			--1197
		)tll
		left outer join
		(
			select substring(itemNumber,0,len(itemNumber)) rItemNumber,sum(qty) rQtyIssued 
			from 
			(
				select itemNumber,qty from toolingtranslog
				where transtartdatetime >= @startDateParam
				and transtartdatetime <= @endDateParam
				and itemNumber like '%R'
				and itemNumber <> ''
			)tl1
			group by itemNumber
			--68
		)tlr
		on tll.itemNumber = ritemNumber
	)tlog

GO


