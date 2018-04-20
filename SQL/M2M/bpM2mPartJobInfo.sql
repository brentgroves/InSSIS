bpM2mPartJobInfo.sql
USE [m2mdata01]
GO

/****** Object:  StoredProcedure [dbo].[bpM2mPartJobInfo]    Script Date: 4/19/2018 2:33:08 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--/////////////////////////////////////////////////////////////////////////
-- Generates the btM2mPartJobInfo table
--////////////////////////////////////////////////////////////////////////
create PROCEDURE [dbo].[bpM2mPartJobInfo] 
AS
BEGIN
IF
OBJECT_ID('btM2mPartJobInfo') IS NOT NULL
	DROP TABLE btM2mPartJobInfo
select 	
partNumber,partRev,maxJobNumber,maxOperNo,fpro_id,fdept,description, 
case 
	when isnumeric(valueAddedSales)<>1 then 0.00
	else cast(valueAddedSales as decimal(18,2))
end
as valueAddedSales,
case
	when isnumeric(budgetedToolAllowance)<>1 then 0.00
	else cast(budgetedToolAllowance as decimal(18,2))
end
as budgetedToolAllowance,
NTLFlag, --No ToolList Needed flag
PartRevInItemMaster,	-- Was the part rev in the invcur table in the inmastx table
fstatus 
into btM2mPartJobInfo
from
(
	select k.partNumber,
	case
		when m.frev is not null then m.frev
		else n.frev
	end
	as partRev,
	k.maxJobNumber,k.maxOperNo,k.fpro_id,k.fdept,
	case
		when m.frev is not null then m.FCUSRCHR2
		else n.FCUSRCHR2 
	end
	as description, 
	case
		when m.frev is not null then m.FCUSRCHR1
		else n.FCUSRCHR1 
	end
	as valueAddedSales, 
	case
		when m.frev is not null then m.FNUSRCUR1
		else n.FNUSRCUR1 
	end
	as budgetedToolAllowance,
	case
		when m.frev is not null then m.fnusrqty1
		else n.fnusrqty1 
	end
	as NTLFlag, --No ToolList Needed flag
	case
		when m.frev is not null then 1
		else 0
	end
	-- Was the part rev in the invcur table in the inmastx table
	as PartRevInItemMaster,
	k.fstatus 
	from
	(
		select jd.partNumber,jd.maxJobNumber,maxOp.maxOperNo,rtg.fpro_id,inw.fdept,jom.fitype,jom.fstatus
		from
		(
			--max job number with an jodrtg and inwork record attached
			select partNumber,max(fjobno) maxJobNumber
			from
			(
				select jom.fpartno partNumber,maxOp.fjobno,maxOp.maxOperNo,rtg.fpro_id,inw.fdept
				from
				(
					--> This is a list of job/operation numbers which we need to tally 
					--> pieces produced. If a labor detail has an operation besides these
					--> ones that means it was for a secondary operation.  We should only 
					--> total the max operation quantities to arrive at the pieces produced.
					--> It has been verified that lower operation ladetail records can have
					--> fcompqty > 0 so this step is needed.
					-->Get rid of lower operation numbers
					select fjobno, max(foperno) as maxOperNo 
					from jodrtg 
					group by fjobno
					having fjobno <> '' 
					--19792
				) maxOp 
				inner join jodrtg rtg
				on maxOp.fjobno = rtg.fjobno and maxOp.maxOperno=rtg.foperno
				--19792
				inner join inwork inw
				on rtg.fpro_id = inw.fcpro_id
				inner join jomast jom
				on maxOp.fjobno = jom.fjobno
				where rtg.fpro_id not like '%TOOLGRD%' 
				and fdept <> '' and fitype = 1
				--16171 
			) dpt
			group by partNumber
			--988
		)jd -- job with dept
		inner join
		(
			--> This is a list of job/operation numbers which we need to tally 
			--> pieces produced. If a labor detail has an operation besides these
			--> ones that means it was for a secondary operation.  We should only 
			--> total the max operation quantities to arrive at the pieces produced.
			--> It has been verified that lower operation ladetail records can have
			--> fcompqty > 0 so this step is needed.
			-->Get rid of lower operation numbers
			select fjobno, max(foperno) as maxOperNo 
			from jodrtg 
			group by fjobno
			having fjobno <> ''
			--19792
		)maxOp -- find maxOp again
		on jd.maxJobNumber=maxOp.fjobno
		inner join jodrtg rtg
		on maxOp.fjobno = rtg.fjobno and maxOp.maxOperno=rtg.foperno
		inner join inwork inw
		on rtg.fpro_id = inw.fcpro_id
		inner join jomast jom
		on jd.maxJobNumber = jom.fjobno
		--988
	) k
	left outer join
	(
		-- some duplicates spotted
		select fcpartno,max(fcpartrev) fcpartrev 
		from invcur 
		group by fcpartno
		having fcpartno <> '' and fcpartno <> '#'
		--8795
	) l
	on
	k.partNumber = l.fcpartno
	left outer join inmastx m
	on
	l.fcpartno = m.fpartno
	and l.fcpartrev = m.frev
	left outer join 
	( 
		-- when the item master record with invcur rev has been deleted
		-- we will pick the max rev for the part number in the item master 
		select aa.fpartno,aa.frev,
			aa.FCUSRCHR1,
			aa.FCUSRCHR2, 
			aa.FNUSRCUR1,
			aa.fnusrqty1
		from inmastx aa
		inner join
		(
			select fpartno,max(frev) frev
			from 
			dbo.INMASTX 
			group by fpartno
		) bb
		on aa.fpartno = bb.fpartno and aa.frev = bb.frev
	) n	
	on k.partNumber=n.fpartno
	--988
) cnv

end


GO
