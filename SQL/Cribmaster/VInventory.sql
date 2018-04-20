USE [Cribmaster]
GO

/****** Object:  View [dbo].[VInventory]    Script Date: 4/19/2018 10:37:03 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create VIEW [dbo].[VInventory] AS
select 
litemnumber,ldescription1,litemclass,lmanufacturer,lAltVendorNo,lCribBinList,lCost,lTotBinQty, 
(lcost * lTotBinQty) lTotCost,
ritemnumber,rAltVendorNo,rCribBinList,rCost,rTotBinQty,
(rcost * rTotBinQty) rTotCost,
TotBinQty, 
((lcost * lTotBinQty) + (rcost * rTotBinQty)) TotCost,
CribBinList,CribBinQtyList
from 
(
	select litemnumber,ldescription1,litemclass,lmanufacturer,lAltVendorNo,lCost, lCribBinList,lCribBinQtyList,lTotBinQty, 
	ritemnumber,rAltVendorNo,rCribBinList,rCribBinQtyList,
	case 
	when VItemPrice.COST is null then cast(0.0 as decimal(18,2)) 
	else VItemPrice.COST 
	end as rCost, 
	rTotBinQty,TotBinQty, 
	CribBinList,CribBinQtyList 
	from
	(
		select litemnumber,ldescription1,litemclass,lmanufacturer,lAltVendorNo,
		lCribBinList,lCribBinQtyList, 
		case 
		when VItemPrice.COST is null then cast(0.0 as decimal(18,2)) 
		else VItemPrice.COST 
		end as lCost, 
		lTotBinQty, 
		ritemnumber,rAltVendorNo,rCribBinList,rCribBinQtyList,rTotBinQty,TotBinQty, 
		CribBinList,CribBinQtyList
		from
		(
				select litemnumber,ldescription1,litemclass,
				ISNULL(lmanufacturer,'none') as lmanufacturer,
				case 
					when lAltVendorNo is null then cast(0 as int)
					else lAltVendorNo 
				end as lAltVendorNo, 
				ISNULL(lCribBinList,'none') as lCribBinList,
				ISNULL(lCribBinQtyList,'none') as lCribBinQtyList,
				case 
					when lTotBinQty is null then cast(0 as int) 
					else lTotBinQty 
				end as lTotBinQty, 
				ISNULL(ritemnumber,'none') as ritemnumber, 
				case 
					when rAltVendorNo is null then cast(0 as int) 
					else rAltVendorNo 
				end as rAltVendorNo, 
				ISNULL(rCribBinList,'none') as rCribBinList,
				ISNULL(rCribBinQtyList,'none') as rCribBinQtyList,
				case 
					when sum(st2.BinQuantity) is null then cast(0 as int) 
					else sum(st2.BinQuantity)  
				end as rTotBinQty, 
				case 
					when ((lTotBinQty is null) and (sum(st2.BinQuantity) is null)) then cast(0 as int) 
					when ((lTotBinQty is null) and (sum(st2.BinQuantity) is not null)) then sum(st2.BinQuantity) 
					when ((lTotBinQty is not null) and (sum(st2.BinQuantity) is null)) then lTotBinQty 
					when ((lTotBinQty is not null) and (sum(st2.BinQuantity) is not null)) then (lTotBinQty + sum(st2.BinQuantity)) 
				end as TotBinQty, 
				case 
					when ((lCribBinList is null) and (rCribBinList is null)) then 'none' 
					when ((lCribBinList is null) and (rCribBinList is not null)) then rCribBinList 
					when ((lCribBinList is not null) and (rCribBinList is null)) then lCribBinList 
					when ((lCribBinList is not null) and (lCribBinList is not null)) then lCribBinList + '<br>' + rCribBinList 
				end as CribBinList,
				case 
					when ((lCribBinQtyList is null) and (rCribBinQtyList is null)) then 'none' 
					when ((lCribBinQtyList is null) and (rCribBinQtyList is not null)) then rCribBinQtyList 
					when ((lCribBinQtyList is not null) and (rCribBinQtyList is null)) then lCribBinQtyList 
					when ((lCribBinQtyList is not null) and (lCribBinQtyList is not null)) then lCribBinQtyList + '<br>' + rCribBinQtyList 
				end as CribBinQtyList 
				 
				from
				(
					select litemnumber,ldescription1,litemclass,lmanufacturer,
					lAltVendorNo,       
					lCribBinList,lCribBinQtyList,lTotBinQty,
					ritemnumber,rAltVendorNo,
					SUBSTRING(
						list.xmlDoc.value('.', 'varchar(max)'),
						5, 10000
					) AS rCribBinList,
					SUBSTRING(
						cribBinQtylist.xmlDoc.value('.', 'varchar(max)'),
						5, 10000
					) AS rCribBinQtyList
					from
					(
						select litemnumber,ldescription1,litemclass,lmanufacturer,
						lCribBinList,lCribBinQtyList,sum(st1.BinQuantity) lTotBinQty,
						lAltVendorNo,ritemnumber,rAltVendorNo       
						from
						(
							select litemnumber,ldescription1,litemclass,lmanufacturer,
							SUBSTRING(
							   list.xmlDoc.value('.', 'varchar(max)'),
							   5, 10000
							) AS lCribBinList,
							SUBSTRING(
							   cribBinQtylist.xmlDoc.value('.', 'varchar(max)'),
							   5, 10000
							) AS lCribBinQtyList,
							lAltVendorNo,ritemnumber,rAltVendorNo       
							from
			/* st1.crib,st1.Bin lbin,st1.CribBin lCribBin, st1.BinQuantity lBinQuantity */
							(
								/* lv */
								select litemnumber,ldescription1,litemclass,lmanufacturer,
								lAltVendorNo lAltVendorNo, lReworkedItemNumber,
								rinv.ItemNumber ritemnumber,rinv.AltVendorNo rAltVendorNo
								from
								(
									select linv.itemnumber litemnumber,linv.description1 ldescription1,linv.ItemClass litemclass,linv.Manufacturer lmanufacturer,
									linv.AltVendorNo lAltVendorNo, 
									linv.ReworkedItemNumber lReworkedItemNumber
									from INVENTRY linv 
									where linv.ItemNumber not like '%R' and linv.InactiveItem = 0
										and linv.itemnumber <> '' and linv.itemnumber <> '.' 
								) linv
								left outer join
								inventry rinv
								on lReworkedItemNumber = rinv.ItemNumber  
								/* end lv1 */
			/* THIS IS THE final RECORD SET -- DON'T ADD ANY MORE RECORDS */
							) lv1
							cross apply(
							  select '<br>'+ lstn.CribBin as ListItem
							  from 
							  (
								select * from station where crib = '1' or crib = '11' or crib = '12'
							  ) lstn
							  where lv1.litemnumber=lstn.Item
							  order by lstn.CribBin
							  for xml path(''), type
							) as list(xmlDoc)
							cross apply(
							  select '<br>'+ lstn.CribBin + ', Qty: ' + cast(lstn.BinQuantity as varchar(4)) as ListItem
							  from 
							  (
								select * from station where crib = '1' or crib = '11' or crib = '12'
							  ) lstn
							  where lv1.litemnumber=lstn.Item
							  order by lstn.CribBin
							  for xml path(''), type
							) as cribBinQtyList(xmlDoc)
						) lv2
						left outer join
						(
							select * from station where crib = '1' or crib = '11' or crib = '12'
						) st1
						on lv2.lItemNumber = st1.Item
						group by litemnumber,ldescription1,litemclass,lmanufacturer,
							lCribBinList,lCribBinQtyList,
							lAltVendorNo,ritemnumber,rAltVendorNo       
					) lv3
					cross apply(
						select '<br>'+ rstn.CribBin as ListItem
						from 
						(
							select * from station where crib = '1' or crib = '11' or crib = '12'
						) rstn
						where lv3.ritemnumber=rstn.Item
						order by rstn.CribBin
						for xml path(''), type
					) as list(xmlDoc)
					cross apply(
						select '<br>'+ rstn.CribBin + ', Qty: ' + cast(rstn.BinQuantity as varchar(4)) as ListItem
						from 
						(
							select * from station where crib = '1' or crib = '11' or crib = '12'

						) rstn
						where lv3.ritemnumber=rstn.Item
						order by rstn.CribBin
						for xml path(''), type
					) as cribBinQtyList(xmlDoc)
				) lv4
				left outer join
				(
					select * from station where crib = '1' or crib = '11' or crib = '12'
				) st2
				on lv4.rItemNumber = st2.Item
				group by litemnumber,ldescription1,litemclass,lmanufacturer,
				lAltVendorNo,       
				lCribBinList,lCribBinQtyList,lTotBinQty,
				ritemnumber,rAltVendorNo,
				rCribBinList,rCribBinQtyList
		) lv5
		left outer join vitemprice
		on
		lv5.litemnumber=VItemPrice.ItemNumber
	) lv6
	left outer join vitemprice
	on
	lv6.ritemnumber=VItemPrice.ItemNumber
) lv7

GO