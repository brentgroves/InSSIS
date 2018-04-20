bfWorkSumLv1.sql

USE [m2mdata01]
GO

/****** Object:  UserDefinedFunction [dbo].[bfWorkSumLv1]    Script Date: 4/20/2018 7:38:14 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create FUNCTION [dbo].[bfWorkSumLv1]
(  
@startDateParam DATETIME,
@endDateParam DATETIME
)
RETURNS TABLE 
AS
RETURN
select 
partNumber, partRev, maxJobNumber,maxOperNo,fpro_id,fdept,
m2mDescription,tlDescription, valueAddedSales,budgetedToolAllowance,
NTLFlag,PartRevInItemMaster,fdate,fedatetime,fempno,fcompqty,fstatus 
from 
(
	select 
	p.partNumber, partRev, maxJobNumber,maxOperNo,fpro_id,fdept,
	m2mDescription,
	case
		when q.maxPartFamily is not null then q.maxPartFamily
		else p.m2mDescription 
	end
	as tlDescription, 
	valueAddedSales,budgetedToolAllowance,
	NTLFlag,PartRevInItemMaster,fdate,fedatetime,fempno,fcompqty,fstatus 
	from 
	(
		select 
		c.partNumber, mpi.partRev, mpi.maxJobNumber,mpi.maxOperNo,mpi.fpro_id,mpi.fdept,
		mpi.description as m2mDescription,
		valueAddedSales,budgetedToolAllowance,NTLFlag, 
		PartRevInItemMaster,fdate,fedatetime,fempno,fcompqty,c.fstatus  
		from
		(
			-- switch to part number because we will determine what job number to use later
			-- and never will want to use the one straight from the ladetail records
			select b.fpartno partNumber,a.fdate,a.fedatetime,a.fempno,a.fcompqty,a.fstatus
			from 
			(
				select lv3.fjobno,lv3.foperno,lv4.fdate,lv4.fedatetime,
					lv4.fempno,lv4.fcompqty,lv4.fstatus
				from
				(
					--> This is a list of job/operation numbers which we need to tally 
					--> pieces produced. If a labor detail has an operation besides these
					--> ones that means it was for a secondary operation.  We should only 
					--> total the max operation quantities to arrive at the pieces produced.
					--> It has been verified that lower operation ladetail records can have
					--> fcompqty > 0 so this step is needed.
					-->Get rid of lower operation numbers
					select fjobno, max(foperno) as foperno 
					from jodrtg 
					group by fjobno
					having fjobno <> ''
					-- 19792
				) lv3
				inner join
				(
					select fjobno,foperno,DATEADD(dd, 0 , DATEDIFF(DD, 0,  fedatetime)) as fdate,fedatetime,
					fempno,fcompqty,fstatus
					from ladetail 
					-- status = P is posted H is Hold
					where fstatus = 'P' 
					and fedatetime >= @startDateParam and fedatetime <= @endDateParam 
					and fcompqty <> 0.0
					-- 15951
				) lv4
				on lv3.fjobno = lv4.fjobno 
				and lv3.foperno = lv4.foperno
				--162328
				--15100
			) a
			inner join
			jomast b
			on a.fjobno = b.fjobno
			-- 15100
			--162328
		) c
		-- drop some tool grinding ladetail records
		inner join (
			select * from btM2mPartJobInfo
			--988
			where NTLFlag <> 999 
			--875
		) mpi
		on c.partNumber=mpi.partNumber
		-- we don't want labor details that do not have a dept attached to the max job op
		--159340 --dropped 3000 records 1 month because of found no max job op with a dept with that job.
		--14928  --dropped 180 records 1 month because of found no max job op with a dept with that job.  
	) p
	inner join 
	(
		select partNumber,max(custPartFamily) maxPartFamily from btDistinctToolLists
		group by partNumber
		--529
	) q
	on p.partNumber=q.partNumber
	-- we don't want labor details for part numbers with no tool list.
	--125483
	--14928
) r
--> delete duplicate records. Don't know why there are a few duplicates, but there are
group by 
partNumber, partRev, maxJobNumber,maxOperNo,fpro_id,fdept,
m2mDescription,tlDescription, valueAddedSales,budgetedToolAllowance,
NTLFlag,PartRevInItemMaster,fdate,fedatetime,fempno,fcompqty,fstatus 
--125427 
--14925

GO

