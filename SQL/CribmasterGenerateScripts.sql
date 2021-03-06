USE [master]
GO
/****** Object:  Database [Cribmaster]    Script Date: 4/20/2018 11:41:38 AM ******/
CREATE DATABASE [Cribmaster]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'EmptyCM_Data', FILENAME = N'D:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\CribmasterBackup.mdf' , SIZE = 5461120KB , MAXSIZE = UNLIMITED, FILEGROWTH = 10%)
 LOG ON 
( NAME = N'EmptyCM_Log', FILENAME = N'D:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\CribmasterBackup_log.ldf' , SIZE = 164672KB , MAXSIZE = UNLIMITED, FILEGROWTH = 10%)
GO
ALTER DATABASE [Cribmaster] SET COMPATIBILITY_LEVEL = 90
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Cribmaster].[dbo].[sp_fulltext_database] @action = 'disable'
end
GO
ALTER DATABASE [Cribmaster] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Cribmaster] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Cribmaster] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Cribmaster] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Cribmaster] SET ARITHABORT OFF 
GO
ALTER DATABASE [Cribmaster] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [Cribmaster] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [Cribmaster] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Cribmaster] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Cribmaster] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Cribmaster] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Cribmaster] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Cribmaster] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Cribmaster] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Cribmaster] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Cribmaster] SET  DISABLE_BROKER 
GO
ALTER DATABASE [Cribmaster] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Cribmaster] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Cribmaster] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Cribmaster] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Cribmaster] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Cribmaster] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Cribmaster] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Cribmaster] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [Cribmaster] SET  MULTI_USER 
GO
ALTER DATABASE [Cribmaster] SET PAGE_VERIFY TORN_PAGE_DETECTION  
GO
ALTER DATABASE [Cribmaster] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Cribmaster] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Cribmaster] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [Cribmaster]
GO
/****** Object:  User [BUSCHE\Domain Users]    Script Date: 4/20/2018 11:41:38 AM ******/
CREATE USER [BUSCHE\Domain Users] FOR LOGIN [BUSCHE\Domain Users]
GO
/****** Object:  User [admin]    Script Date: 4/20/2018 11:41:38 AM ******/
CREATE USER [admin] FOR LOGIN [admin] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [BUSCHE\Domain Users]
GO
ALTER ROLE [db_owner] ADD MEMBER [admin]
GO
/****** Object:  Schema [Domain Users]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE SCHEMA [Domain Users]
GO
/****** Object:  Default [STATION_MonthlyUsage_D]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE DEFAULT [dbo].[STATION_MonthlyUsage_D] 
AS
1


GO
/****** Object:  Default [STATION_OrderPoint_D]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE DEFAULT [dbo].[STATION_OrderPoint_D] 
AS
1


GO
/****** Object:  Default [STATION_OrderQuantity_D]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE DEFAULT [dbo].[STATION_OrderQuantity_D] 
AS
1


GO
/****** Object:  Default [STATION_SafetyStock_D]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE DEFAULT [dbo].[STATION_SafetyStock_D] 
AS
1


GO
/****** Object:  Default [UW_ZeroDefault]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE DEFAULT [dbo].[UW_ZeroDefault] 
AS
0


GO
/****** Object:  UserDefinedDataType [dbo].[M2MFacility]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE TYPE [dbo].[M2MFacility] FROM [char](20) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[M2MMoney]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE TYPE [dbo].[M2MMoney] FROM [numeric](17, 5) NOT NULL
GO
/****** Object:  StoredProcedure [dbo].[bpActiveNoIssue]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[bpActiveNoIssue]
as
select lv1.ItemNumber,lv1.itmnum, 
tli.ToolLists, BinQuantity, Cost, CribBin, Description1,  
 Description2, OnOrder, PendingRework, DefaultBuyerGroupID, InactiveItem, 
 ItemClass, Crib, DateLastIssue
from
(
 SELECT stn.BinQuantity, alt.Cost, stn.CribBin, inv.Description1, 
 inv.ItemNumber,
 REPLACE(inv.itemnumber,'R','') itmnum, 
 inv.Description2, stn.OnOrder, stn.PendingRework, itc.DefaultBuyerGroupID, inv.InactiveItem, 
 inv.ItemClass, stn.Crib, stn.DateLastIssue
 FROM   
 STATION stn 
 INNER JOIN INVENTRY inv 
 ON stn.Item=inv.ItemNumber 
 INNER JOIN AltVendor alt 
 ON inv.AltVendorNo=alt.RecNumber 
 INNER JOIN ITEMCLASS itc 
 ON inv.ItemClass=itc.ItemClass
 WHERE
 stn.DateLastIssue is null  
 --inv.ItemClass='ABRASIVE WHEEL' 
 AND stn.Crib=1 
 AND (
 itc.DefaultBuyerGroupID='CER/EXPENSE' AND inv.InactiveItem=0 
 OR 
 itc.DefaultBuyerGroupID='INVENTORY' AND inv.InactiveItem=0
 )
 --879
)lv1
left outer join 
btToolListItems tli
on lv1.itmnum=tli.itemnumber
 order by lv1.itmnum
GO
/****** Object:  StoredProcedure [dbo].[bpCribBinQtyList]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--///////////////////////////////////////////////////////////////////////////////////
-- For each inventry item create a Crib Bin Quantity List
--///////////////////////////////////////////////////////////////////////////////////
create PROCEDURE [dbo].[bpCribBinQtyList] 
AS
BEGIN
	SET NOCOUNT ON
	IF
	OBJECT_ID('tempdb.dbo.#btCribBinQtyList1') IS NOT NULL
		DROP TABLE #btCribBinQtyList1

	IF
	OBJECT_ID('tempdb.dbo.#btCribBinQtyList2') IS NOT NULL
		DROP TABLE #btCribBinQtyList2

	IF
	OBJECT_ID('btCribBinQtyList') IS NOT NULL
		DROP TABLE btCribBinQtyList

	DECLARE
			@CribBinQtyList VARCHAR(max)

	select item, CribBin + ', Qty: ' + cast(BinQuantity as varchar(4)) as CribBinQty,
	RowNum = ROW_NUMBER() OVER (PARTITION BY item ORDER BY 1/0),
	CribBinQtyList = CAST(NULL AS VARCHAR(max))
	into #btCribBinQtyList1
	from
	station 
	where (crib = '1' or crib = '11') 
	and (item is not null) and (item <> '') and (item <> '.') 
	--11180

	update #btCribBinQtyList1
	set @CribBinQtyList = CribBinQtyList =
	CASE WHEN RowNum = 1 
		THEN CribBinQty
		ELSE @CribBinQtyList + '<br>' + CribBinQty 
	END

	select item,max(CribBinQtyList) CribBinQtyList
	into #btCribBinQtyList2
	from #btCribBinQtyList1
	group by item

	select *,
	case
		when rCribBinQtyList is null then lCribBinQtyList
		else lCribBinQtyList + ', ' + rCribBinQtyList
	end
	as CribBinQtyList
	into btCribBinQtyList
	from
	(
		select item as lItem, CribBinQtyList as lCribBinQtyList
		from
		#btCribBinQtyList2
		where item not like '%R'
	)a
	left outer join
	(
		select item as rItem, CribBinQtyList as rCribBinQtyList
		from
		#btCribBinQtyList2
		where item like '%R'
	)b
	on 
	lItem+'R'=rItem
	--8693
end

GO
/****** Object:  StoredProcedure [dbo].[bpDelPOMastAndPOItem]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--///////////////////////////////////////////
-- Delete all pomast and poitem records in range
--////////////////////////////////////////////////
create procedure [dbo].[bpDelPOMastAndPOItem] 
@postart char(6),
@poend char(6)
as
begin
	Declare @start int,@end int,
	@ret int
	set @start= CAST(@postart AS int)
	set @end= CAST(@poend AS int)
--select @start,@end
--select (@end-@start)
	set @ret =
	CASE
		WHEN ((@end-@start)<250) THEN 0
		else -1
	END
--select @ret
	IF (0=@ret)
	BEGIN
		delete from btpomast
		where fpono >=@postart and fpono <=@poend 
		delete from btpoitem
		where fpono >=@postart and fpono <=@poend
	END
end

GO
/****** Object:  StoredProcedure [dbo].[bpDelPOMastAndPOItemAndPOStatus]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--///////////////////////////////////////////
-- Delete all pomast and poitem records in range and 
-- change postatusno to open and update portlog
--////////////////////////////////////////////////
create procedure [dbo].[bpDelPOMastAndPOItemAndPOStatus] 
@postart char(6),
@poend char(6),
@logId int
as
begin
	Declare @start int,@end int,
	@ret int
	set @start= CAST(@postart AS int)
	set @end= CAST(@poend AS int)
--select @start,@end
--select (@end-@start)
	set @ret =
	CASE
		WHEN ((@end-@start)<250) THEN 0
		else -1
	END
--select @ret
	IF (0=@ret)
	BEGIN
	BEGIN TRANSACTION;
		delete from btpomast
		where fpono >=@postart and fpono <=@poend 

		delete from btpoitem
		where fpono >=@postart and fpono <=@poend

        update PO
        set POStatusNo = 0 
        WHERE POSTATUSNO = 3 and SITEID <> '90' 
		--and (BLANKETPO = '' or BLANKETPO is null)

		update [dbo].[btPORTLog]
		set fEnd=GETDATE()
		where id=@logId
	COMMIT;  
	END
end


GO
/****** Object:  StoredProcedure [dbo].[bpDevDelPOMastAndPOItem]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--///////////////////////////////////////////
-- Delete all pomast and poitem records in range
--////////////////////////////////////////////////
create procedure [dbo].[bpDevDelPOMastAndPOItem] 
@postart char(6),
@poend char(6)
as
begin
	Declare @start int,@end int,
	@ret int
	set @start= CAST(@postart AS int)
	set @end= CAST(@poend AS int)
--select @start,@end
--select (@end-@start)
	set @ret =
	CASE
		WHEN ((@end-@start)<250) THEN 0
		else -1
	END
--select @ret
	IF (0=@ret)
	BEGIN
		delete from btpomast
		where fpono >=@postart and fpono <=@poend 
		delete from btpoitem
		where fpono >=@postart and fpono <=@poend
	END
end

GO
/****** Object:  StoredProcedure [dbo].[bpDevDelPOMastAndPOItemAndPOStatus]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--///////////////////////////////////////////
-- Delete all pomast and poitem records in range and 
-- change postatusno to open and update portLog
--////////////////////////////////////////////////
create procedure [dbo].[bpDevDelPOMastAndPOItemAndPOStatus] 
@postart char(6),
@poend char(6),
@logId int
as
begin
	Declare @start int,@end int,
	@ret int
	set @start= CAST(@postart AS int)
	set @end= CAST(@poend AS int)
--select @start,@end
--select (@end-@start)
	set @ret =
	CASE
		WHEN ((@end-@start)<250) THEN 0
		else -1
	END
--select @ret
	IF (0=@ret)
	BEGIN
	BEGIN TRANSACTION;
		delete from btpomast
		where fpono >=@postart and fpono <=@poend 

		delete from btpoitem
		where fpono >=@postart and fpono <=@poend

        update btPO
        set POStatusNo = 0 
        WHERE POSTATUSNO = 3 and SITEID <> '90' 
		--and (BLANKETPO = '' or BLANKETPO is null)

		update [dbo].[btPORTLog]
		set fEnd=GETDATE()
		where id=@logId
	COMMIT;  
	END
end
GO
/****** Object:  StoredProcedure [dbo].[bpDevInsPORTLog]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpDevInsPORTLog]
@id int output
AS
BEGIN
 SET NOCOUNT ON
	INSERT INTO [dbo].[btPORTLog]
			   (fRollBack,fStart)
		 VALUES
			   (0,GETDATE())
	select @id=max(id) from btPORTLog
end


GO
/****** Object:  StoredProcedure [dbo].[bpDevPORT]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpDevPORT] 
	@currentPO as char(6)
AS
BEGIN
SET NOCOUNT ON
insert into btPOMast
(
fpono,cribpo,fcompany,fcshipto, forddate,fstatus,fvendno,fbuyer,
fchangeby,fshipvia, fcngdate, fcreate, ffob, fmethod, foldstatus, fordrevdt, 
fordtot,fpayterm,fpaytype,fporev,fprint,freqdate,freqsdt,freqsno, frevtot, 
fsalestax, ftax, fcsnaddrke, fnnextitem, fautoclose,fnusrqty1,fnusrcur1, fdusrdate1,fcfactor,
fdcurdate, fdeurodate, feurofctr, fctype, fmsnstreet, fpoclosing,fndbrmod, 
fcsncity, fcsnstate, fcsnzip, fcsncountr, fcsnphone,fcsnfax,fcshcompan,fcshcity,
fcshstate,fcshzip,fcshcountr,fcshphone,fcshfax,fmshstreet,
flpdate,fconfirm,fcontact,fcfname,fcshkey,fcshaddrke,fcusrchr1,fcusrchr2,fcusrchr3,
fccurid,fmpaytype,fmusrmemo1,freasoncng
)
select @currentPO -1 + row_number() over (order by PONumber)as fpono,PONumber cribpo,fccompany fcompany,
'SELF' fcshipto, PODate forddate,'OPEN' fstatus,UDFM2MVENDORNUMBER fvendno,'CM' fbuyer,
'CM' fchangeby,'UPS-OURS' fshipvia, PODate fcngdate,PODate fcreate,
'OUR PLANT' ffob,'1' fmethod,'STARTED' foldstatus,'1900-01-01 00:00:00.000' fordrevdt, 
0 fordtot,fcterms fpayterm,'3' fpaytype, '00' fporev,'N' fprint,'1900-01-01 00:00:00.000' freqdate,
PODate freqsdt,'' freqsno, 0 frevtot, 0 fsalestax, 'N' ftax, '0001' fcsnaddrke, 1 fnnextitem,
'Y' fautoclose,0 fnusrqty1,0 fnusrcur1,'1900-01-01 00:00:00.000' fdusrdate1,0 fcfactor,
'1900-01-01 00:00:00.000' fdcurdate,'1900-01-01 00:00:00.000' fdeurodate,0 feurofctr,'O' fctype,
fmstreet fmsnstreet,
'Please reference our purchase order number on all correspondence.  ' +
'Notification of changes regarding quantities to be shipped and changes in the delivery schedule are required.' + 
CHAR(13) + CHAR(13) + 
'PO APPROVALS:' + CHAR(13) + CHAR(13) +
'Requr. _______________________________________' + CHAR(13) + 
'Dept. Head ___________________________________' + CHAR(13) + CHAR(13) + 
'G.M. Only: All Items Over $500.00' + CHAR(13) + 
'G.M ________________________________________' + CHAR(13) + 
'VP/Group Controller. Only: All Assests/CER and ER Over $10,000.00' + CHAR(13) + 
'VP/Group Controller _____________________________________' + CHAR(13) + 
'Pres. Only: All Assets/CER/ER and/or PO''s Over $10,000.00' + CHAR(13) + 
'President _____________________________________' fpoclosing,0 fndbrmod,
fccity fcsncity,fcstate fcsnstate,fczip fcsnzip, fccountry fcsncountr,fcphone fcsnphone,fcfax fcsnfax,
'BUSCHE INDIANA' fcshcompan,'ALBION' fcshcity,'IN' fcshstate,'46701' fcshzip,'USA' fcshcountr,
'2606367030' fcshphone, '2606367031' fcshfax,'1563 E. State Road 8' fmshstreet,
'1900-01-01 00:00:00.000' flpdate,'' fconfirm,'' fcontact,'' fcfname,'' fcshkey,'' fcshaddrke,
'' fcusrchr1,'' fcusrchr2,'' fcusrchr3,'' fccurid,'' fmpaytype,'' fmusrmemo1,'Automatic closure.' freasoncng 
from 
(
	SELECT PONumber,Vendor,PODate 
	FROM [btPO]  
	WHERE POSTATUSNO = 3 and SITEID <> '90' and (BLANKETPO = '' or BLANKETPO is null)
)po1
inner join 
(
	select VendorNumber,UDFM2MVENDORNUMBER from vendor 
)vn1
on po1.Vendor = vn1.VendorNumber
inner join
(
	SELECT fvendno,fcterms,fccompany,fccity,fcstate,fczip,fccountry,fcphone,fcfax,fmstreet FROM btapvend  
)av1
on vn1.UDFM2MVENDORNUMBER=av1.fvendno

update btPO
set btPO.VendorPO = pom.fpono
--select po.ponumber,pom.cribpo,pom.fpono,po.vendorpo
from [btPO] po 
inner join
btpomast pom
on 
po.PONumber=pom.cribPO
WHERE POSTATUSNO = 3 and SITEID <> '90' and (BLANKETPO = '' or BLANKETPO is null)

insert into btpoitem
(
fpono, cribPO, fpartno,frev,fmeasure,fitemno,frelsno,
fcategory,fjoopno,flstcost,fstdcost,fleadtime,forgpdate,flstpdate,
fmultirls,fnextrels,fnqtydm,freqdate,fretqty,fordqty,fqtyutol,fqtyltol,
fbkordqty,flstsdate,frcpdate,frcpqty,fshpqty,finvqty,fdiscount,fstandard,
ftax,fsalestax,flcost,fucost,fprintmemo,fvlstcost,fvleadtime,fvmeasure,
fvptdes,fvordqty,fvconvfact,fvucost,fqtyshipr,fdateship,fnorgucost,
fnorgeurcost,fnorgtxncost,futxncost,fvueurocost,fvutxncost,fljrdif,
fucostonly,futxncston,fueurcston,fcomments,fdescript,fac,fndbrmod,
SchedDate,fsokey,fsoitm,fsorls,fjokey,fjoitm,frework,finspect,fvpartno,
fparentpo,frmano,fdebitmemo,finspcode,freceiver,fcorgcateg,fparentitm,fparentrls,frecvitm,
fueurocost,FCBIN,FCLOC,fcudrev,blanketPO,PlaceDate,DockTime,PurchBuf,Final,AvailDate
)
SELECT 
po.VendorPO fpono, po.PONumber cribPO, fpartno,frev,fmeasure,fitemno,frelsno,
fcategory,fjoopno,flstcost,fstdcost,fleadtime,forgpdate,flstpdate,
fmultirls,fnextrels,fnqtydm,freqdate,fretqty,fordqty,fqtyutol,fqtyltol,
fbkordqty,flstsdate,frcpdate,frcpqty,fshpqty,finvqty,fdiscount,fstandard,
ftax,fsalestax,flcost,fucost,fprintmemo,fvlstcost,fvleadtime,fvmeasure,
fvptdes,fvordqty,fvconvfact,fvucost,fqtyshipr,fdateship,fnorgucost,
fnorgeurcost,fnorgtxncost,futxncost,fvueurocost,fvutxncost,fljrdif,
fucostonly,futxncston,fueurcston,fcomments,fdescript,fac,fndbrmod,
SchedDate,fsokey,fsoitm,fsorls,fjokey,fjoitm,frework,finspect,fvpartno,
fparentpo,frmano,fdebitmemo,finspcode,freceiver,fcorgcateg,fparentitm,fparentrls,frecvitm,
fueurocost,FCBIN,FCLOC,fcudrev,blanketPO,PlaceDate,DockTime,PurchBuf,Final,AvailDate
FROM 
(
	SELECT PONumber,vendorPO
	FROM [btPO]  
	WHERE POSTATUSNO = 3 and SITEID <> '90' and (BLANKETPO = '' or BLANKETPO is null)

)po
inner join
(
	select
	'' fsokey,'' fsoitm,'' fsorls,'' fjokey,'' fjoitm,'' frework,'' finspect,'' fvpartno,'' fparentpo, 
	'' frmano,'' fdebitmemo,'' finspcode,'' freceiver,'' fcorgcateg,'' fparentitm,'' fparentrls,'' frecvitm,
	0.000 fueurocost,'' FCBIN,'' FCLOC,'' fcudrev,0 blanketPO,
	'1900-01-01 00:00:00.000' PlaceDate,0 DockTime,0 PurchBuf,0 Final,
	'1900-01-01 00:00:00.000' AvailDate,
	'1900-01-01 00:00:00.000' SchedDate,
	PONumber,left(ItemDescription,25) fpartno,'NS' frev, 'EA' fmeasure, 
	case 
	when (row_number() over (PARTITION BY PONumber order by ItemDescription )) > 99 then cast((row_number() over (PARTITION BY PONumber order by ItemDescription )) as char(3))
	when (row_number() over (PARTITION BY PONumber order by ItemDescription )) > 9 then ' ' + cast((row_number() over (PARTITION BY PONumber order by ItemDescription )) as char(3))
	else '  ' + cast((row_number() over (PARTITION BY PONumber order by ItemDescription )) as char(3))
	end	as fitemno, '  0' frelsno,
	UDF_POCATEGORY fcategory,
	0 fjoopno,
	Cost flstcost,
	cost fstdcost,
	0 fleadtime,
	case
		when RequiredDate is null then GETDATE()
		else RequiredDate
	end as forgpdate,
	case
	when RequiredDate is null then GETDATE()
	else RequiredDate
	end as flstpdate,
	'N' fmultirls,
	0 fnextrels,
	0 fnqtydm,
	'1900-01-01 00:00:00.000' freqdate,
	0 fretqty,
	quantity fordqty,
	0 fqtyutol,
	0 fqtyltol,
	0 fbkordqty,
	'1900-01-01 00:00:00.000' flstsdate,
	'1900-01-01 00:00:00.000' frcpdate,
	0 frcpqty,
	0 fshpqty,
	0 finvqty,
	0 fdiscount,
	0 fstandard,
	'N' ftax,
	0 fsalestax,
	cost flcost,
	cost fucost,
	'Y' fprintmemo,
	cost fvlstcost,
	0 fvleadtime,
	'EA' fvmeasure,
	case
		when ITEM is null then ' '
		else ITEM
	end as fvptdes,
	Quantity fvordqty,
	1 fvconvfact,
	cost fvucost,
	0 fqtyshipr,
	'1900-01-01 00:00:00.000' fdateship,
	0 fnorgucost,
	0 fnorgeurcost,
	0 fnorgtxncost,
	0 futxncost,
	0 fvueurocost,
	0 fvutxncost,
	0 fljrdif,
	cost fucostonly,
	0 futxncston,
	0 fueurcston,
	case
		when Comments is null then ' '
		else Comments 
	end fcomments,
	case
		when Description2 is null then ' ' 
		else Description2
	end fdescript,
	'Default' fac,
	0 fndbrmod
	from btPODETAIL
) pod
on po.PONumber = pod.PONumber

update btPODetail
set vendorPONumber = po.VendorPO
from
btPODetail pod
inner join
[btPO]  po
on
pod.ponumber=po.PONumber
WHERE POSTATUSNO = 3 and SITEID <> '90' and (po.BLANKETPO = '' or po.BLANKETPO is null)


end


GO
/****** Object:  StoredProcedure [dbo].[bpDevPORTPOMastRange]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpDevPORTPOMastRange]
@postart int output,
@poend int output
AS
BEGIN
 SET NOCOUNT ON
select @postart=min(fpono) from btpomast
select @poend=max(fpono) from btpomast
--set @postart=1
--set @poend=5
IF (@postart IS NULL)
 BEGIN
   set @postart = 0
 END
IF (@poend IS NULL)
 BEGIN
   set @poend = 0
 END

RETURN
END


GO
/****** Object:  StoredProcedure [dbo].[bpDevPOVendorUpdate]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--///////////////////////////////////////////////////////////////////////////////////
-- Update PO and PODetail vendor number
--///////////////////////////////////////////////////////////////////////////////////
create PROCEDURE [dbo].[bpDevPOVendorUpdate] 
 @poNumber int,
 @vendor varchar(12),
 @Address1 varchar(50),
 @Address2 varchar(50),
 @Address3 varchar(50),
 @Address4 varchar(50)
AS
BEGIN
	SET NOCOUNT ON
	update btPO
	set vendor = @vendor,
	Address1=@Address1,
	Address2=@Address2,
	Address3=@Address3,
	Address4=@Address4
	where 
	PONumber = @poNumber 

	update btPODETAIL
	set VendorNumber = @vendor
	where 
	PONumber = @poNumber 

end

GO
/****** Object:  StoredProcedure [dbo].[bpDevVendorUpdate]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--///////////////////////////////////////////////////////////////////////////////////
-- Update UDFM2MVENDORNUMBER field of btVendor
--///////////////////////////////////////////////////////////////////////////////////
create PROCEDURE [dbo].[bpDevVendorUpdate] 
 @vendorNumber varchar(12),
 @newM2mVendor varchar(6)
AS
BEGIN
	SET NOCOUNT ON
	update btVendor
	set UDFM2MVENDORNUMBER = @newM2mVendor
	where 
	VendorNumber = @vendorNumber 
end

GO
/****** Object:  StoredProcedure [dbo].[bpGRFinish]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--///////////////////////////////////////////////////////////
-- 1. If @delrc = 1 then Delete All btrcmast and btrcitem records
-- 2. process ending datetime in btGRLog and set fStep to @step
--//////////////////////////////////////////
create procedure [dbo].[bpGRFinish]
@delrc bit,
@step varchar(50)
as
if 1 = @delrc 
begin
delete from btrcitem
delete from btrcmast
end

Declare @maxId integer
select @maxId=max(id) from btGRLog 
update btGRLog
set fEnd = GETDATE(),
fStep = @step
where id = @maxId 


GO
/****** Object:  StoredProcedure [dbo].[bpGRGenRCItem]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpGRGenRCItem] 
AS
SET NOCOUNT ON
Declare @lastRun datetime
select @lastRun=flastrun from btgrvars
declare @thirtydaysago datetime
declare @now datetime
select @lastRun=flastrun from btgrvars
set @now = getdate()
set @thirtydaysago = dateadd(day,-30,@now)

INSERT INTO [dbo].[btrcitem]
           ([fitemno]
           ,[fpartno]
           ,[fpartrev]
           ,[finvcost]
           ,[fcategory]
           ,[fcstatus]
           ,[fiqtyinv]
           ,[fjokey]
           ,[fsokey]
           ,[fsoitem]
           ,[fsorelsno]
           ,[fvqtyrecv]
           ,[fqtyrecv]
           ,[freceiver]
           ,[frelsno]
           ,[fvendno]
           ,[fbinno]
           ,[fexpdate]
           ,[finspect]
           ,[finvqty]
           ,[flocation]
           ,[flot]
           ,[fmeasure]
           ,[fpoitemno]
           ,[fretcredit]
           ,[ftype]
           ,[fumvori]
           ,[fqtyinsp]
           ,[fauthorize]
           ,[fucost]
           ,[fllotreqd]
           ,[flexpreqd]
           ,[fctojoblot]
           ,[fdiscount]
           ,[fueurocost]
           ,[futxncost]
           ,[fucostonly]
           ,[futxncston]
           ,[fueurcston]
           ,[flconvovrd]
           ,[fcomments]
           ,[fdescript]
           ,[fac]
           ,[sfac]
           ,[FCORIGUM]
           ,[fcudrev]
           ,[FNORIGQTY]
           ,[Iso]
           ,[Ship_Link]
           ,[ShsrceLink]
           ,[fCINSTRUCT])
		   --------START HERE
--Declare @lastRun datetime
--select @lastRun=flastrun from btgrvars
--		Declare @lastRun datetime
--		set @lastRun = '2016-10-25'
--Declare @lastRun datetime
--select @lastRun=flastrun from btgrvars

select 
---start debug
--lv1.fpono,lv2.fpoitemno, lv1.freceiver,
---end debug
case 
when (row_number() over (PARTITION BY freceiver order by lv2.fpoitemno )) > 99 then cast((row_number() over (PARTITION BY freceiver order by lv2.fpoitemno )) as char(3))
when (row_number() over (PARTITION BY freceiver order by lv2.fpoitemno )) > 9 then '0' + cast((row_number() over (PARTITION BY freceiver order by lv2.fpoitemno )) as char(3))
else '00' + cast((row_number() over (PARTITION BY freceiver order by lv2.fpoitemno )) as char(3))
end	as fitemno,
-- start debug
--lv1.start,lv1.Received,
-- end debug
left(lv1.ItemDescription,25) fpartno,'NS' fpartrev,0.0 finvcost,
fcategory,'' fcstatus,0.0 fiqtyinv,'' fjokey,'' fsokey,'' fsoitem,'' fsorelsno,
podQuantity fvqtyrecv,podQuantity fqtyrecv, lv1.freceiver,'  0' frelsno,fvendno,'' fbinno,
'1900-01-01 00:00:00.000' fexpdate,'' finspect,0.0 finvqty,'' flocation,'' flot,'EA' fmeasure,
lv2.fpoitemno,'' fretcredit,'P' ftype,'I' fumvori,0.0 fqtyinsp,'' fauthorize, lv1.cost fucost,
0 fllotreqd,0 flexpreqd,'' fctojoblot,0.0 fdiscount,0.0 fueurocost,0.0 futxncost, 
lv1.Cost fucostonly,0.0 futxncston,0.0 fueurcston,0 flconvovrd,'' fcomments, 
case
when lv1.fdescript is null then ''
else fdescript
end as fdescript,
'Default' fac,'Default' sfac,'' FCORIGUM,'' fcudrev,0.0 FNORIGQTY,'' Iso,0 Ship_Link,
0 ShsrceLink,'' fCINSTRUCT
from
(
	-- Declare @lastRun datetime
	 --select @lastRun=flastrun from btgrvars
	-- we now have the receiver number for all items
	select rcm.fpono,rcm.freceiver,
	rcm.start,pod.Received,pod.ItemDescription,pod.fcategory,pod.Quantity podQuantity,
	pod.fvendno,pod.Cost,fdescript
	from(

		select fpono,start,freceiver from btrcmast 
	--423
	--order by fpono,start
	)rcm
	inner join 
	(

		--Declare @lastRun datetime
		--set @lastRun = '2016-10-25'
		--select @lastRun=flastrun from btgrvars

		-- select only the records not transfered yet
		-- multiple records with the same itemdescription is possible only not with the same received time.
		-- If an item was received at 10am another item could be received at 4pm with the same itemdescription and po.
		-- in this case there could be 2 rcmast records for the same itemdescription and the same vendorponumber,start id.
		select maxid,VendorPONumber,start, itemdescription,fdescript,Quantity,Cost,
		pod.VendorNumber, fvendno, received,UDF_POCATEGORY fcategory,comments
		from
		(

			select vendorponumber,DATEADD(DD, DATEDIFF(DD, 0, received), 0) start,ItemDescription,sum(quantity) Quantity,comments,
			description2 fdescript,max(received) received,UDF_POCATEGORY,Cost,VendorNumber,max(id) maxId
			from 
			( 
				--Declare @lastRun datetime
				--select @lastRun=flastrun from btgrvars
				select vendorponumber,received,ItemDescription,Quantity,pod.comments,description2,UDF_POCATEGORY,Cost,VendorNumber,
				id 
				from po inner join PODETAIL pod
				on po.ponumber = pod.ponumber 
				inner join btOpenGenPO ogpo -- transferred from m2m; only open purchase orders
				on po.VendorPO = ogpo.fpono
				where Received > @lastRun
		 		and pod.id not in
				(
					select podetailId from btGRTrans
				)
				and pod.Quantity is not null
				and pod.Quantity <> 0
				-- and po.postatusno <> 1 --closed
				and 
				(
					po.postatusno <> 1 --not closed
					or
					(
						po.postatusno = 1 --closed less than 30 days
						and postatusdate > @thirtydaysago
					)
				)
				--order by vendorponumber,itemdescription
				--30
--		and VendorPONumber = '121124',63210
			) pod
			group by vendorponumber,DATEADD(DD, DATEDIFF(DD, 0, received), 0),ItemDescription,comments,Description2,UDF_POCATEGORY,cost,VendorNumber
--			order by vendorponumber,itemdescription
			--having VendorPONumber = '121124'
			--30
		)pod
		inner join 	(
			select VendorNumber,UDFM2MVENDORNUMBER fvendno from vendor 
		)vn1
		on pod.VendorNumber = vn1.VendorNumber
		--30
		--642
--		and VendorPONumber = '121124',63210
--		order by VendorPONumber,start,ItemDescription
		--170
	) pod
	on rcm.fpono=pod.VendorPONumber
	and rcm.start=pod.start
	--order by VendorPONumber,start,ItemDescription
	--30
	--More because podetail can have multiple records with the same itemdescription because of partial shipments
)lv1
inner join
(
	-- get the fitemnumber we assigned to each item when creating the m2m poitem records
	-- for all the po(s) that have any items received since the last run of the gen rcv program
	-- we need retrieve all the podetail records and partion them to determine the fpoitem number
	-- generated from the bpPORT sproc.
	--Declare @lastRun datetime
	--select @lastRun=flastrun from btgrvars
--		Declare @lastRun datetime
--		set @lastRun = '2016-10-25'

	select lv1.VendorPONumber fpono, lv2.*
	from
	(
		--Declare @lastRun datetime
		--select @lastRun=flastrun from btgrvars
		select distinct vendorponumber 
				from po inner join PODETAIL pod
				on po.ponumber = pod.ponumber 
				inner join btOpenGenPO ogpo -- transferred from m2m; only open purchase orders
				on po.VendorPO = ogpo.fpono
		where Received > @lastRun
		and pod.id not in
		(
			select podetailId from btGRTrans
		)
		and pod.Quantity is not null
		and pod.Quantity <> 0
		-- and po.postatusno <> 1 --closed
		and 
		(
			po.postatusno <> 1 --not closed
			or
			(
				po.postatusno = 1 --closed less than 30 days
				and postatusdate > @thirtydaysago
			)
		)

		--13

	)lv1
	inner join
	(
		--Declare @lastRun datetime
		--select @lastRun=flastrun from btgrvars
		select VendorPONumber,
			case 
			when (row_number() over (PARTITION BY PONumber order by ItemDescription )) > 99 then cast((row_number() over (PARTITION BY PONumber order by ItemDescription )) as char(3))
			when (row_number() over (PARTITION BY PONumber order by ItemDescription )) > 9 then ' ' + cast((row_number() over (PARTITION BY PONumber order by ItemDescription )) as char(3))
			else '  ' + cast((row_number() over (PARTITION BY PONumber order by ItemDescription )) as char(3))
			end	as fpoitemno,
			ItemDescription 
		from 
		(
			-- there will be multiple podetail records with the same itemdescription when a partial shipment is received
			-- but when the poitem record was created in m2m only 1 record with the itemdescription was made
			-- we need to retrieve all of the podetail records for a po so we can accurately assign the same fpoitemno 
			-- that we did when bpPORT sproc created the poitem entries.
			select distinct ponumber,vendorponumber,itemdescription from PODETAIL
		)pod
	) lv2
	on 
	lv1.VendorPONumber=lv2.VendorPONumber
	--40
	--order by lv2.VendorPONumber,lv2.fpoitemno
)lv2
on 
lv1.fpono=lv2.fpono and
lv1.ItemDescription=lv2.ItemDescription
order by lv1.fpono,lv1.start,lv2.fpoitemno
--642 one for each distinct fpono,start,itemdescription 

select * 
from 
btrcitem
order by freceiver,fitemno


GO
/****** Object:  StoredProcedure [dbo].[bpGRGenRCItemDev]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
bpGRGenRCItemDev
Generate a rcitem record for each podetail received since the last run of the generate receiver program.
Link each record to the rcmast record with the same fpono and start fields.  There will be at most one
rcmast record with fpono/start field combination generated in a single run of the program.  Although
it is possible for another rcmast record with the same fpono/start fields to have been created in 
previous runs.  This would require Nancy to have received items for a fpono, generating receivers, and 
then receiving items and running the program again later in the day.
	on rcm.fpono=pod.VendorPONumber
	and rcm.start=pod.start
-- fmeasure - will be set to EA.  We could change bpPORT sproc to ask Nancy what unit of measure
-- she want's for each poitem created and make the process more complicated by creating the records
-- in m2m without an fmeasure field and link m2m.btrcitem to m2m.poitem and retrieve the unit of 
-- measure Nancy selected when the poitem was created.
-- select distinct fmeasure from poitem order by fmeasure
-- add to ssis create btMeasure

*/
create procedure [dbo].[bpGRGenRCItemDev] 
AS
SET NOCOUNT ON
Declare @lastRun datetime
select @lastRun=flastrun from btgrvars

INSERT INTO [dbo].[btrcitem]
           ([fitemno]
           ,[fpartno]
           ,[fpartrev]
           ,[finvcost]
           ,[fcategory]
           ,[fcstatus]
           ,[fiqtyinv]
           ,[fjokey]
           ,[fsokey]
           ,[fsoitem]
           ,[fsorelsno]
           ,[fvqtyrecv]
           ,[fqtyrecv]
           ,[freceiver]
           ,[frelsno]
           ,[fvendno]
           ,[fbinno]
           ,[fexpdate]
           ,[finspect]
           ,[finvqty]
           ,[flocation]
           ,[flot]
           ,[fmeasure]
           ,[fpoitemno]
           ,[fretcredit]
           ,[ftype]
           ,[fumvori]
           ,[fqtyinsp]
           ,[fauthorize]
           ,[fucost]
           ,[fllotreqd]
           ,[flexpreqd]
           ,[fctojoblot]
           ,[fdiscount]
           ,[fueurocost]
           ,[futxncost]
           ,[fucostonly]
           ,[futxncston]
           ,[fueurcston]
           ,[flconvovrd]
           ,[fcomments]
           ,[fdescript]
           ,[fac]
           ,[sfac]
           ,[FCORIGUM]
           ,[fcudrev]
           ,[FNORIGQTY]
           ,[Iso]
           ,[Ship_Link]
           ,[ShsrceLink]
           ,[fCINSTRUCT])
		   --------START HERE
--Declare @lastRun datetime
--select @lastRun=flastrun from btgrvars
select 
---start debug
--lv1.fpono,lv2.fpoitemno, lv1.freceiver,
---end debug
case 
when (row_number() over (PARTITION BY freceiver order by lv2.fpoitemno )) > 99 then cast((row_number() over (PARTITION BY freceiver order by lv2.fpoitemno )) as char(3))
when (row_number() over (PARTITION BY freceiver order by lv2.fpoitemno )) > 9 then '0' + cast((row_number() over (PARTITION BY freceiver order by lv2.fpoitemno )) as char(3))
else '00' + cast((row_number() over (PARTITION BY freceiver order by lv2.fpoitemno )) as char(3))
end	as fitemno,
-- start debug
--lv1.start,lv1.Received,
-- end debug
left(lv1.ItemDescription,25) fpartno,'NS' fpartrev,0.0 finvcost,
fcategory,'' fcstatus,0.0 fiqtyinv,'' fjokey,'' fsokey,'' fsoitem,'' fsorelsno,
podQuantity fvqtyrecv,podQuantity fqtyrecv, lv1.freceiver,'0' frelsno,fvendno,'' fbinno,
'1900-01-01 00:00:00.000' fexpdate,'' finspect,0.0 finvqty,'' flocation,'' flot,'EA' fmeasure,
lv2.fpoitemno,'' fretcredit,'P' ftype,'I' fumvori,0.0 fqtyinsp,'' fauthorize, lv1.cost fucost,
0 fllotreqd,0 flexpreqd,'' fctojoblot,0.0 fdiscount,0.0 fueurocost,0.0 futxncost, 
lv1.Cost fucostonly,0.0 futxncston,0.0 fueurcston,0 flconvovrd,'' fcomments, 
case
when lv1.fdescript is null then ''
else fdescript
end as fdescript,
'Default' fac,'Default' sfac,'' FCORIGUM,'' fcudrev,0.0 FNORIGQTY,'' Iso,0 Ship_Link,
0 ShsrceLink,'' fCINSTRUCT
from
(
	-- Declare @lastRun datetime
	-- select @lastRun=flastrun from btgrvars
	-- we now have the receiver number for all items
	select rcm.fpono,rcm.freceiver,
	rcm.start,pod.Received,pod.ItemDescription,pod.fcategory,pod.Quantity podQuantity,
	pod.fvendno,pod.Cost,fdescript
	from(

	select fpono,start,freceiver from btrcmast 
	--394
	--order by fpono,start
	)rcm
	inner join 
	(
		--Declare @lastRun datetime
		--set @lastRun = '2016-10-25'
		--select @lastRun=flastrun from btgrvars

		-- select only the records not transfered yet
		-- multiple records with the same itemdescription is possible only not with the same received time.
		-- If an item was received at 10am another item could be received at 4pm with the same itemdescription and po.
		-- in this case there could be 2 rcmast records for the same itemdescription and the same vendorponumber,start id.
		select maxid,VendorPONumber,start, itemdescription,fdescript,Quantity,Cost,
		pod.VendorNumber, fvendno, received,UDF_POCATEGORY fcategory,comments
		from
		(
			select vendorponumber,DATEADD(DD, DATEDIFF(DD, 0, received), 0) start,ItemDescription,sum(quantity) Quantity,comments,
			description2 fdescript,max(received) received,UDF_POCATEGORY,Cost,VendorNumber,max(id) maxId
			from btPODETAIL
			group by vendorponumber,DATEADD(DD, DATEDIFF(DD, 0, received), 0),ItemDescription,comments,Description2,UDF_POCATEGORY,cost,VendorNumber
			--having VendorPONumber = '121124'
		)pod
		inner join 	(
			select VendorNumber,UDFM2MVENDORNUMBER fvendno from vendor 
		)vn1
		on pod.VendorNumber = vn1.VendorNumber
		where Received > @lastRun
		and pod.maxId not in
		(
			select podetailId from btGRTrans
		)

		--610
--		and VendorPONumber = '121124',63210
		--order by VendorPONumber,ItemDescription
		--170
	) pod
	on rcm.fpono=pod.VendorPONumber
	and rcm.start=pod.start
	--order by VendorPONumber,ItemDescription
	--170
	--More because podetail can have multiple records with the same itemdescription because of partial shipments
)lv1
inner join
(
	-- get the fitemnumber we assigned to each item when creating the m2m poitem records
	-- for all the po(s) that have any items received since the last run of the gen rcv program
	-- we need retrieve all the podetail records and partion them to determine the fpoitem number
	-- generated from the bpPORT sproc.
--	Declare @lastRun datetime
--	select @lastRun=flastrun from btgrvars
	select lv1.VendorPONumber fpono, lv2.*
	from
	(
		--Declare @lastRun datetime
		--set @lastRun = '2016-10-25'
		select distinct vendorponumber from	btPODETAIL pod
		where Received > @lastRun
		and pod.id not in
		(
			select podetailId from btGRTrans
		)
		--317
	)lv1
	inner join
	(
		-- Declare @lastRun datetime
		-- select @lastRun=flastrun from btgrvars
		select VendorPONumber,
			case 
			when (row_number() over (PARTITION BY PONumber order by ItemDescription )) > 99 then cast((row_number() over (PARTITION BY PONumber order by ItemDescription )) as char(3))
			when (row_number() over (PARTITION BY PONumber order by ItemDescription )) > 9 then ' ' + cast((row_number() over (PARTITION BY PONumber order by ItemDescription )) as char(3))
			else '  ' + cast((row_number() over (PARTITION BY PONumber order by ItemDescription )) as char(3))
			end	as fpoitemno,
			ItemDescription 
		from 
		(
			-- there will be multiple podetail records with the same itemdescription when a partial shipment is received
			-- but when the poitem record was created in m2m only 1 record with the itemdescription was made
			-- we need to retrieve all of the podetail records for a po so we can accurately assign the same fpoitemno 
			-- that we did when bpPORT sproc created the poitem entries.
			select distinct ponumber,vendorponumber,itemdescription from btPODETAIL
		)pod
	) lv2
	on 
	lv1.VendorPONumber=lv2.VendorPONumber
	--235
	--order by lv2.VendorPONumber,lv2.fpoitemno
	--665
	--665
)lv2
on 
lv1.fpono=lv2.fpono and
lv1.ItemDescription=lv2.ItemDescription
order by lv1.fpono,lv1.start,lv2.fpoitemno
--605 one for each distinct fpono,start,itemdescription 

select * 
from 
btrcitem
order by freceiver,fitemno

GO
/****** Object:  StoredProcedure [dbo].[bpGRGenRCMast]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
bpGRGenRCMast
Generate one rcmast record for each vendorpo/date 
pair where items have been received since this sproc was last ran
*/
create procedure [dbo].[bpGRGenRCMast] 
	@currentReceiver as char(6)
AS
SET NOCOUNT ON
Declare @lastRun datetime
declare @thirtydaysago datetime
declare @now datetime
select @lastRun=flastrun from btgrvars
set @now = getdate()
set @thirtydaysago = dateadd(day,-30,@now)
--Declare @currentReceiver int
--set @currentReceiver='283343'
insert into btrcmast
(
fclandcost
,frmano
,fporev
,fcstatus
,fdaterecv
,fpono
,freceiver
,fvendno
,faccptby
,fbilllad
,fcompany
,ffrtcarr
,fpacklist
,fretship
,fshipwgt
,ftype
,start
,fprinted
,flothrupd
,fccurid
,fcfactor
,fdcurdate
,fdeurodate
,feurofctr
,flpremcv
,docstatus
,frmacreator
)
--Declare @lastRun datetime
--declare @thirtydaysago datetime
--declare @now datetime
--select @lastRun=flastrun from btgrvars
--set @now = getdate()
--set @thirtydaysago = dateadd(day,-30,@now)
--Declare @currentReceiver int
--set @currentReceiver='283343'
	select 
	'N' fclandcost
	,'' frmano
	,'00' fporev
	,'C' fcstatus
	,received fdaterecv
	,right(VendorPONumber,6) fpono
	,@currentReceiver -1 + row_number() over (order by VendorPONumber,start) as freceiver
	,UDFM2MVENDORNUMBER fvendno
	,'NS' faccptby
	,'' fbilllad
	, fcompany
	,'UPS-OURS' ffrtcarr
	,'' fpacklist
	,'' fretship
	,0.00 fshipwgt
	,'P' ftype
	, DATEADD(DD, DATEDIFF(DD, 0, received), 0) start
	,0 fprinted
	,1 flothrupd
	,'' fccurid
	,0.00 fcfactor
	,'1900-01-01 00:00:00.000' fdcurdate
	,'1900-01-01 00:00:00.000' fdeurodate
	,0.00 feurofctr
	,0 flpremcv
	,'RECEIVED' docstatus
	,'' frmacreator
	from 
	(
		-- add various fields to base rcmast record
		select VendorPONumber, start,received, pod3.VendorNumber,
		vn1.UDFM2MVENDORNUMBER,apv.fccompany fcompany
		from 
		(
			-- select distinct po/date(s) with only one received time for each po/date combo
			select vendorponumber,start,max(VendorNumber) VendorNumber,max(received) received
			from 
			(
				--Declare @lastRun datetime
				--select @lastRun=flastrun from btgrvars
				-- select only the records not transfered yet
				select VendorPONumber, VendorNumber, id,DATEADD(DD, DATEDIFF(DD, 0, received), 0) start, received
				from po inner join PODETAIL pod
				on po.ponumber = pod.ponumber 
				inner join btOpenGenPO ogpo -- transferred from m2m; only open purchase orders
				on po.VendorPO = ogpo.fpono
				where Received > @lastRun
				--33
				and pod.id not in
				(
					select podetailId from btGRTrans
				)
				and pod.Quantity is not null
				and pod.Quantity <> 0
				--and po.postatusno <> 1 --closed
				-- Not closed or Newly closed po
				and 
				(
					po.postatusno <> 1 --not closed
					or
					(
						po.postatusno = 1 --closed less than 30 days
						and postatusdate > @thirtydaysago
					)
				)
				--33
			) pod2
			group by VendorPONumber,start 
		) pod3
		inner join
		(
			select VendorNumber,UDFM2MVENDORNUMBER from vendor 
		)vn1
		on pod3.VendorNumber = vn1.VendorNumber
		inner join
		(
			select fvendno,fccompany from btapvend
		)apv
		on vn1.UDFM2MVENDORNUMBER=apv.fvendno
	)pd
	order by VendorPONumber asc,start asc

select LEFT(convert(varchar, start, 107),12) rcvdate,
'N' Remove, 
* 
from 
btrcmast
order by fpono,start


GO
/****** Object:  StoredProcedure [dbo].[bpGRGenRCMastDev]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
bpGRGenRCMastDev
Generate one rcmast record for each vendorpo/date 
pair where items have been received since this sproc was last ran
*/
create procedure [dbo].[bpGRGenRCMastDev] 
	@currentReceiver as char(6)
AS
SET NOCOUNT ON
Declare @lastRun datetime
select @lastRun=flastrun from btgrvars
--Declare @currentReceiver int
--set @currentReceiver='283343'
insert into btrcmast
(
fclandcost
,frmano
,fporev
,fcstatus
,fdaterecv
,fpono
,freceiver
,fvendno
,faccptby
,fbilllad
,fcompany
,ffrtcarr
,fpacklist
,fretship
,fshipwgt
,ftype
,start
,fprinted
,flothrupd
,fccurid
,fcfactor
,fdcurdate
,fdeurodate
,feurofctr
,flpremcv
,docstatus
,frmacreator
)
--Declare @currentReceiver int
--set @currentReceiver='283343'
--Declare @lastRun datetime
--select @lastRun=flastrun from btgrvars
	select 
	'N' fclandcost
	,'' frmano
	,'00' fporev
	,'C' fcstatus
	,received fdaterecv
	,right(VendorPONumber,6) fpono
	,@currentReceiver -1 + row_number() over (order by VendorPONumber,start) as freceiver
	,UDFM2MVENDORNUMBER fvendno
	,'NS' faccptby
	,'' fbilllad
	, fcompany
	,'' ffrtcarr
	,'' fpacklist
	,'' fretship
	,0.00 fshipwgt
	,'P' ftype
	, DATEADD(DD, DATEDIFF(DD, 0, received), 0) start
	,0 fprinted
	,1 flothrupd
	,'' fccurid
	,0.00 fcfactor
	,'1900-01-01 00:00:00.000' fdcurdate
	,'1900-01-01 00:00:00.000' fdeurodate
	,0.00 feurofctr
	,0 flpremcv
	,'RECEIVED' docstatus
	,'' frmacreator
	from 
	(
		-- add various fields to base rcmast record
		select VendorPONumber, start,received, pod3.VendorNumber,
		vn1.UDFM2MVENDORNUMBER,apv.fccompany fcompany
		from 
		(
			-- select distinct po/date(s) with only one received time for each po/date combo
			select vendorponumber,start,max(VendorNumber) VendorNumber,max(received) received
			from 
			(
				-- select only the records not transfered yet
				select VendorPONumber, VendorNumber, id,DATEADD(DD, DATEDIFF(DD, 0, received), 0) start, received
				from btPODetail pod
				where Received > @lastRun
				and pod.id not in
				(
					select podetailId from btGRTrans
				)
			) pod2
			group by VendorPONumber,start 
		) pod3
		inner join
		(
			select VendorNumber,UDFM2MVENDORNUMBER from vendor 
		)vn1
		on pod3.VendorNumber = vn1.VendorNumber
		inner join
		(
			select fvendno,fccompany from btapvend
		)apv
		on vn1.UDFM2MVENDORNUMBER=apv.fvendno
	)pd
	order by VendorPONumber asc,start asc

select LEFT(convert(varchar, start, 107),10) rcvdate,
* 
from 
btrcmast
order by fpono,start


GO
/****** Object:  StoredProcedure [dbo].[bpGRGenReceivers]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
bpGRGenReceivers
Calls bpGRGenRCMast and bpGRGenRCItem to create all Made2Manage records receiver records needed
since the last run of the Generate Receivers program
*/
create procedure [dbo].[bpGRGenReceivers] 
	@currentReceiver as char(6)
AS
exec bpGRLogStepSet 'STEP_10_GEN_RECEIVERS'
exec bpGRGenRCMast @currentReceiver
exec bpGRGenRCItem 

GO
/****** Object:  StoredProcedure [dbo].[bpGRGenReceiversDev]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
bpGRGenReceiversDev
Calls bpGRGenRCMast and bpGRGenRCItem to create all Made2Manage records receiver records needed
since the last run of the Generate Receivers program
*/
create procedure [dbo].[bpGRGenReceiversDev] 
	@currentReceiver as char(6)
AS
exec bpGRGenRCMastDev @currentReceiver
exec bpGRGenRCItemDev 
exec bpGRLogStepSet 'STEP_10_GEN_RECEIVERS'
GO
/****** Object:  StoredProcedure [dbo].[bpGRGetLogEntryLast]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
bpGRGetLogEntryLast
Retreive the latest log entry
*/
create procedure [dbo].[bpGRGetLogEntryLast] 
	@id as int output,
	@fStart as datetime output,
	@fStep as varchar(50) output,
	@rcvStart as char(6) output,
	@rcvEnd as char(6) output,
	@fEnd as datetime output
AS

Declare @maxId integer
select @maxId=max(id) from btGRLog 
select 
	@id=id,
	@fStart=fStart,
	@fStep=fStep,
	@rcvStart=rcvStart,
	@rcvEnd=rcvEnd,
	@fEnd=fEnd
from btGRLog
where id = @maxId 


GO
/****** Object:  StoredProcedure [dbo].[bpGRLogInsert]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpGRLogInsert]
@id int output
AS
BEGIN
 SET NOCOUNT ON
	INSERT INTO [dbo].[btGRLog]
			   (fStart,fStep)
		 VALUES
			   (GETDATE(),'STEP_0_START')
	select @id=max(id) from btGRLog
end

GO
/****** Object:  StoredProcedure [dbo].[bpGRLogStepSet]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
bpGRLogStepSet
Sets the current step of this run of the Generate Receivers process
*/
create procedure [dbo].[bpGRLogStepSet] 
	@step as varchar(50)
AS

Declare @maxId integer
select @maxId=max(id) from btGRLog 
update btGRLog
set fStep = @step
where id = @maxId 

GO
/****** Object:  StoredProcedure [dbo].[bpGRNoReceivers]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpGRNoReceivers]
@dtStart varchar(20),
@dtEnd varchar(20)
as
begin
SET NOCOUNT ON
--Declare @dtStart varchar(20)
--Declare @dtEnd varchar(20)
--set @dtStart = '06-01-2016 10:15:10'
--set @dtEnd =  '12-05-2016 10:15:10'
Declare @dateStart datetime
Declare @dateEnd datetime
set @dateStart = CONVERT(datetime, @dtStart)
set @dateEnd = CONVERT(datetime, @dtEnd)
select po.VendorPO,pos.POStatusDescription,ven.VendorName,po.podate,pod.itemdescription,pod.Description2, pod.cribbin,quantity,pod.Received
from po 
inner join PODETAIL pod
on po.PONumber = pod.PONumber
inner join VENDOR ven
on po.Vendor=ven.VendorNumber
inner join postatus pos
on po.POStatusNo=pos.POStatusNo
where podate >= @dateStart
and podate <= @dateEnd
and received is null
and pos.POStatusNo=3 or pos.POStatusNo=0
and po.SITEID <> '90'
and (po.BLANKETPO = '' or po.BLANKETPO is null)
order by pos.POStatusDescription desc, pod.PONumber desc, pod.ItemDescription

end

GO
/****** Object:  StoredProcedure [dbo].[bpGROpenPO]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpGROpenPO] 
AS
BEGIN
SET NOCOUNT ON
select VendorPO poNumber
from po
where ((po.POSTATUSNO = 0) or (po.POSTATUSNO = 2)) and po.SITEID <> '90' 
and po.PODate >= '2016-10-01'
and (po.BLANKETPO = '' or po.BLANKETPO is null)
order by PONumber desc
end

GO
/****** Object:  StoredProcedure [dbo].[bpGROpenPOVendorEmail]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpGROpenPOVendorEmail] 
@select as varchar(max),
@dateStart as datetime,
@dateEnd as datetime
AS
BEGIN
SET NOCOUNT ON
--Declare @select as varchar(max)
--Declare @dateStart as datetime
--Declare @dateEnd as datetime
--set @dateStart = '01-01-2017'
--set @dateEnd = '01-05-2017'
--set @select = '122934,122933,122932'

select page,selected,visible,poDate,poNumber,vendorName,eMailAddress,itemDescription,
qtyOrd,qtyReceived,received
from
(
--select distinct vendorPO from po order by vendorpo desc

select 1 page,1 selected,0 visible,ord.poDate,ord.poNumber,
case
 when ven.VendorName is null then 'None'
 else ven.VendorName
end vendorName,
case
 when ven.EMailAddress is null then 'None'
 else ven.EMailAddress
end eMailAddress,
ord.item,
case
 when ord.ItemDescription is null then 'None'
 else ord.ItemDescription
end itemDescription,
ord.qtyOrd,
case
 when rcv.qtyReceived is null then 0
 else rcv.qtyReceived
end qtyReceived,
received
from
(
	select po.podate,po.VendorPO ponumber,po.Vendor,pod.item,sum(pod.Quantity) qtyOrd,max(pod.ItemDescription) ItemDescription
	from po
	inner join PODETAIL pod
	on po.ponumber=pod.PONumber
	group by po.PODate,po.PONumber, po.VendorPO, po.Vendor,po.SiteId,po.poStatusNo,po.BlanketPO,pod.item
	having ((po.POSTATUSNO = 0) or (po.POSTATUSNO = 2)) and po.SITEID <> '90' 
	and (po.BLANKETPO = '' or po.BLANKETPO is null) 
	and 
	po.VendorPO
	in
	(
	SELECT Item
	FROM dbo.SplitStrings_Moden(@select, ',')
	)
	--31
)ord
left outer join
--qtyReceived
(
	select VendorPO ponumber,item,sum(Quantity) qtyReceived,max(Received) Received
	from
	(
		select  po.PODate, po.VendorPO,po.SiteId,po.poStatusNo,po.BlanketPO,pod.item,Quantity,pod.Received
		from po
		inner join PODETAIL pod
		on po.ponumber=pod.PONumber
		where ((po.POSTATUSNO = 0) or (po.POSTATUSNO = 2)) and po.SITEID <> '90' 
		and (po.BLANKETPO = '' or po.BLANKETPO is null) 
		and (pod.Received is not null) 
		and 
		po.VendorPO
		in
		(
		SELECT Item
		FROM dbo.SplitStrings_Moden(@select, ',')
		)
		--15
	)lv1
	group by VendorPO,item
	--order by PONumber,item
	--14
)rcv
on ord.PONumber=rcv.PONumber
and ord.item=rcv.item
left outer join vendor ven
on ord.Vendor=ven.VendorNumber
--order by PONumber,item
union

--//////////////////////////////////////////////////////
-- Date Range
select 1 page,0 selected,0 visible,ord.poDate,ord.poNumber,
case
 when ven.VendorName is null then 'None'
 else ven.VendorName
end vendorName,
case
 when ven.EMailAddress is null then 'None'
 else ven.EMailAddress
end eMailAddress,
ord.item,
case
 when ord.ItemDescription is null then 'None'
 else ord.ItemDescription
end itemDescription,
ord.qtyOrd,
case
 when rcv.qtyReceived is null then 0
 else rcv.qtyReceived
end qtyReceived,
received
from
(
	select po.podate,po.VendorPO ponumber,po.Vendor,pod.item,sum(pod.Quantity) qtyOrd,max(pod.ItemDescription) ItemDescription
	from po
	inner join PODETAIL pod
	on po.ponumber=pod.PONumber
	group by po.PODate,po.ponumber,po.VendorPO,po.Vendor,po.SiteId,po.poStatusNo,po.BlanketPO,pod.item
	having ((po.POSTATUSNO = 0) or (po.POSTATUSNO = 2)) and po.SITEID <> '90' 
	and (po.BLANKETPO = '' or po.BLANKETPO is null)
	and po.PODate >= @dateStart
	and po.PODate <= @dateEnd
	and po.VendorPO
	not in
	(
		SELECT Item
		FROM dbo.SplitStrings_Moden(@select, ',')
	)
--	order by po.PONumber,pod.item
)ord
left outer join
--qtyReceived
(
	select ponumber,item,sum(Quantity) qtyReceived,max(Received) Received
	from
	(
		select  po.PODate,po.VendorPO ponumber,po.SiteId,po.poStatusNo,po.BlanketPO,pod.item,Quantity,pod.Received
		from po
		inner join PODETAIL pod
		on po.ponumber=pod.PONumber
		where ((po.POSTATUSNO = 0) or (po.POSTATUSNO = 2)) and po.SITEID <> '90' 
		and (po.BLANKETPO = '' or po.BLANKETPO is null) 
		and po.PODate >= @dateStart
		and po.PODate <= @dateEnd
		and (pod.Received is not null) 
		and po.VendorPO
		not in
		(
			SELECT Item
			FROM dbo.SplitStrings_Moden(@select, ',')
		)

		--15
	)lv1
	group by ponumber,item
--	order by PONumber,item
	--14
)rcv
on ord.PONumber=rcv.PONumber
and ord.item=rcv.item
left outer join vendor ven
on ord.Vendor=ven.VendorNumber
)lv1
order by PONumber,item
end

GO
/****** Object:  StoredProcedure [dbo].[bpGROpenPOVendorEmailReport]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpGROpenPOVendorEmailReport] 
@po varchar(12)
AS
BEGIN
SET NOCOUNT ON
--Declare @po varchar(12)
--set @po = '121556'
--select * from btapvend
--select ROW_NUMBER() ,VendorName,PurchaseAddress1,PurchaseCity,PurchaseState,PurchaseZip from vendor
select ROW_NUMBER() OVER(ORDER BY ord.PONumber,ord.item ) rowNumber,1 page,0 selected,0 visible,ord.poDate,ord.poNumber,
case
 when ven.VendorName is null then 'None'
 else ven.VendorName
end vendorName,
apv.fvendno,
apv.fcterms,
case
 when trm.description is null then 'None'
 else trm.description
end termsDesc,
apv.fccompany,
apv.fmstreet,
apv.fccity,
apv.fcstate,
apv.fczip,
apv.fccountry,
apv.fcphone,
apv.fcfax,
'UPS-OURS' fshipvia,
'OUR PLANT' ffob,
'NS' planner,
case
 when ven.EMailAddress is null then 'None'
 else ven.EMailAddress
end eMailAddress,
ord.item,
case
 when ord.ItemDescription is null then 'None'
 else ord.ItemDescription
end itemDescription,
ord.qtyOrd,
CAST(ord.cost AS DECIMAL(18,2)) cost,
CAST(ord.qtyOrd*ord.cost AS DECIMAL(18,2)) extCost,
case
 when rcv.qtyReceived is null then 0
 else rcv.qtyReceived
end qtyReceived,
received,
case
 when ord.pocategory is null then 'None'
 else ord.pocategory 
end pocategory
from
(
	select po.podate,po.VendorPO ponumber,po.Vendor,pod.item,
	sum(pod.Quantity) qtyOrd,max(pod.ItemDescription) ItemDescription,
	max(pod.Cost) cost,max(poc.UDF_POCATEGORYDescription) pocategory
	from po
	inner join PODETAIL pod
	on po.ponumber=pod.PONumber
	left outer join UDT_POCATEGORY poc
	on pod.UDF_POCATEGORY= poc.udf_pocategory
	group by po.PODate,po.ponumber,po.VendorPO, po.Vendor,po.SiteId,po.poStatusNo,po.BlanketPO,pod.item
	having po.VendorPO = @po
	--order by po.PONumber,pod.item
	--31
)ord
left outer join
--qtyReceived
(
	select ponumber,item,sum(Quantity) qtyReceived,max(Received) Received
	from
	(
		select  po.PODate,po.VendorPO ponumber,po.SiteId,po.poStatusNo,po.BlanketPO,pod.item,Quantity,pod.Received
		from po
		inner join PODETAIL pod
		on po.ponumber=pod.PONumber
		where po.VendorPO = @po
		and (pod.Received is not null) 
		--15
	)lv1
	group by ponumber,item
	--order by PONumber,item
	--14
)rcv
on ord.PONumber=rcv.PONumber
and ord.item=rcv.item
inner join vendor ven
on ord.Vendor=ven.VendorNumber
inner join btapvend apv
on ven.UDFM2MVENDORNUMBER=apv.fvendno
inner join btterms trm
on apv.fcterms = trm.fcterms
order by PONumber,item
end

GO
/****** Object:  StoredProcedure [dbo].[bpGRReceiverCount]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpGRReceiverCount]
@receiverCount int output
AS
BEGIN
	SET NOCOUNT ON
--	Declare @receiverCount int
	Declare @lastRun datetime
	select @lastRun=flastrun from btgrvars
	declare @thirtydaysago datetime
	declare @now datetime
	set @now = getdate()
	set @thirtydaysago = dateadd(day,-30,@now)
	--select * from  btGRTrans
	-- select distinct po/date(s) with only one received time for each po/date combo
	select @receiverCount=count(*) 
	--select count(*) 
	from
	(
		select VendorPONumber,start
		from 
		(
			--	declare @thirtydaysago datetime
			--	declare @now datetime
			--	set @now = getdate()
			--	set @thirtydaysago = dateadd(day,-30,@now)
			--	Declare @lastRun datetime
			--	select @lastRun=flastrun from btgrvars
			-- select only the records not transfered yet
			select VendorPONumber, VendorNumber, id,podetailid, start, received
			from (
				--Declare @lastRun datetime
				--select @lastRun=flastrun from btgrvars
				select postatusno,VendorPONumber, VendorNumber, id, DATEADD(DD, DATEDIFF(DD, 0, received), 0) start, received
				from po inner join PODETAIL pod
				on po.ponumber = pod.ponumber 
				inner join btOpenGenPO ogpo -- transferred from m2m; only open purchase orders
				on po.VendorPO = ogpo.fpono
				where Received > @lastRun
				and Quantity is not null
				and Quantity <> 0
				--67
				-- Not closed or Newly closed po
				and 
				(
					po.postatusno <> 1 --not closed
					or
					(
						po.postatusno = 1 --closed less than 30 days
						and postatusdate > @thirtydaysago
					)
				)
				--65
			
				/*
				If po has just been closed in Cribmaster we still want on list, but POs that
				have been closed a month or more we don't.
				*/
			) pod
			left outer join
			btGRTrans grt
			on pod.id = grt.podetailId
			where grt.podetailId is null
			--30
		) pod2
		group by VendorPONumber,start 
	)lv1
RETURN
END


GO
/****** Object:  StoredProcedure [dbo].[bpGRReceiverCountDev]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpGRReceiverCountDev]
@receiverCount int output
AS
BEGIN
	SET NOCOUNT ON
	Declare @lastRun datetime
	select @lastRun=flastrun from btgrvars

	-- select distinct po/date(s) with only one received time for each po/date combo
	select @receiverCount=count(*)
	from
	(
		select VendorPONumber,start
		from 
		(
			-- select only the records not transfered yet
			select VendorPONumber, VendorNumber, id,DATEADD(DD, DATEDIFF(DD, 0, received), 0) start, received
			from btPODETAIL
			where Received > @lastRun
		) pod2
		group by VendorPONumber,start 
	)lv1

RETURN
END
GO
/****** Object:  StoredProcedure [dbo].[bpGRReceiversCribDelete]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
bpGRReceiversCribDelete
Delete all rcmast/rcitem records
*/
create procedure [dbo].[bpGRReceiversCribDelete] 
AS
delete from btrcmast
delete from btrcitem

GO
/****** Object:  StoredProcedure [dbo].[bpGRTmpReceiverItems]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpGRTmpReceiverItems] 
AS
Declare @lastRun datetime
select @lastRun=flastrun from btgrvars

select 
---start debug
--lv1.fpono,lv2.fpoitemno, lv1.freceiver,
---end debug
case 
when (row_number() over (PARTITION BY freceiver order by lv2.fpoitemno )) > 99 then cast((row_number() over (PARTITION BY freceiver order by lv2.fpoitemno )) as char(3))
when (row_number() over (PARTITION BY freceiver order by lv2.fpoitemno )) > 9 then '0' + cast((row_number() over (PARTITION BY freceiver order by lv2.fpoitemno )) as char(3))
else '00' + cast((row_number() over (PARTITION BY freceiver order by lv2.fpoitemno )) as char(3))
end	as fitemno,
-- start debug
--lv1.start,lv1.Received,
-- end debug
left(lv1.ItemDescription,25) fpartno,'NS' fpartrev,0.0 finvcost,
fcategory,'' fcstatus,0.0 fiqtyinv,'' fjokey,'' fsokey,'' fsoitem,'' fsorelsno,
podQuantity fvqtyrecv,podQuantity fqtyrecv, lv1.freceiver,'  0' frelsno,fvendno,'' fbinno,
'1900-01-01 00:00:00.000' fexpdate,'' finspect,0.0 finvqty,'' flocation,'' flot,'EA' fmeasure,
lv2.fpoitemno,'' fretcredit,'P' ftype,'I' fumvori,0.0 fqtyinsp,'' fauthorize, lv1.cost fucost,
0 fllotreqd,0 flexpreqd,'' fctojoblot,0.0 fdiscount,0.0 fueurocost,0.0 futxncost, 
lv1.Cost fucostonly,0.0 futxncston,0.0 fueurcston,0 flconvovrd,'' fcomments, 
case
when lv1.fdescript is null then ''
else fdescript
end as fdescript,
'Default' fac,'Default' sfac,'' FCORIGUM,'' fcudrev,0.0 FNORIGQTY,'' Iso,0 Ship_Link,
0 ShsrceLink,'' fCINSTRUCT
from
(

	-- Declare @lastRun datetime
	 --select @lastRun=flastrun from btgrvars
	-- we now have the receiver number for all items

	select rcm.fpono,rcm.freceiver,
	rcm.start,pod.Received,pod.ItemDescription,pod.fcategory,pod.Quantity podQuantity,
	pod.fvendno,pod.Cost,fdescript
	from(

		select fpono,start,freceiver from btMPrcmast 
	--423
	--order by fpono,start
	)rcm
	inner join 
	(

		--Declare @lastRun datetime
		--set @lastRun = '2016-10-25'
		--select @lastRun=flastrun from btgrvars

		-- select only the records not transfered yet
		-- multiple records with the same itemdescription is possible only not with the same received time.
		-- If an item was received at 10am another item could be received at 4pm with the same itemdescription and po.
		-- in this case there could be 2 rcmast records for the same itemdescription and the same vendorponumber,start id.
		select maxid,VendorPONumber,start, itemdescription,fdescript,Quantity,Cost,
		pod.VendorNumber, fvendno, received,UDF_POCATEGORY fcategory,comments
		from
		(
			select vendorponumber,DATEADD(DD, DATEDIFF(DD, 0, received), 0) start,ItemDescription,sum(quantity) Quantity,comments,
			description2 fdescript,max(received) received,UDF_POCATEGORY,Cost,VendorNumber,max(id) maxId
			from 
			( 
				--Declare @lastRun datetime
				--select @lastRun=flastrun from btgrvars
				select vendorponumber,received,ItemDescription,Quantity,comments,description2,UDF_POCATEGORY,Cost,VendorNumber,
				id from PODETAIL pod
				where Received > @lastRun
		 		and pod.id not in
				(
					select podetailId from btGRTrans
				)
				and pod.Quantity is not null
				and pod.Quantity <> 0
				--order by vendorponumber,itemdescription
				--643
--		and VendorPONumber = '121124',63210
			) pod
			group by vendorponumber,DATEADD(DD, DATEDIFF(DD, 0, received), 0),ItemDescription,comments,Description2,UDF_POCATEGORY,cost,VendorNumber
--			order by vendorponumber,itemdescription
			--having VendorPONumber = '121124'
		)pod
		inner join 	(
			select VendorNumber,UDFM2MVENDORNUMBER fvendno from vendor 
		)vn1
		on pod.VendorNumber = vn1.VendorNumber
		--37
		--642
--		and VendorPONumber = '121124',63210
--		order by VendorPONumber,start,ItemDescription
		--170
	) pod
	on rcm.fpono=pod.VendorPONumber
	and rcm.start=pod.start
	--order by VendorPONumber,start,ItemDescription
	--170
	--More because podetail can have multiple records with the same itemdescription because of partial shipments
)lv1
inner join
(
	-- get the fitemnumber we assigned to each item when creating the m2m poitem records
	-- for all the po(s) that have any items received since the last run of the gen rcv program
	-- we need retrieve all the podetail records and partion them to determine the fpoitem number
	-- generated from the bpPORT sproc.
--	Declare @lastRun datetime
--	select @lastRun=flastrun from btgrvars
--		Declare @lastRun datetime
--		set @lastRun = '2016-10-25'

	select lv1.VendorPONumber fpono, lv2.*
	from
	(
	--Declare @lastRun datetime
	--select @lastRun=flastrun from btgrvars
		select distinct vendorponumber from	PODETAIL pod
		where Received > @lastRun
		and pod.id not in
		(
			select podetailId from btGRTrans
		)
		and pod.Quantity is not null
		and pod.Quantity <> 0
		--320
	)lv1
	inner join
	(
		-- Declare @lastRun datetime
		-- select @lastRun=flastrun from btgrvars
		select VendorPONumber,
			case 
			when (row_number() over (PARTITION BY PONumber order by ItemDescription )) > 99 then cast((row_number() over (PARTITION BY PONumber order by ItemDescription )) as char(3))
			when (row_number() over (PARTITION BY PONumber order by ItemDescription )) > 9 then ' ' + cast((row_number() over (PARTITION BY PONumber order by ItemDescription )) as char(3))
			else '  ' + cast((row_number() over (PARTITION BY PONumber order by ItemDescription )) as char(3))
			end	as fpoitemno,
			ItemDescription 
		from 
		(
			-- there will be multiple podetail records with the same itemdescription when a partial shipment is received
			-- but when the poitem record was created in m2m only 1 record with the itemdescription was made
			-- we need to retrieve all of the podetail records for a po so we can accurately assign the same fpoitemno 
			-- that we did when bpPORT sproc created the poitem entries.
			select distinct ponumber,vendorponumber,itemdescription from PODETAIL
		)pod
	) lv2
	on 
	lv1.VendorPONumber=lv2.VendorPONumber
	--694
	--235
	--order by lv2.VendorPONumber,lv2.fpoitemno
	--665
	--665
)lv2
on 
lv1.fpono=lv2.fpono and
lv1.ItemDescription=lv2.ItemDescription
order by lv1.fpono,lv1.start,lv2.fpoitemno
--642 one for each distinct fpono,start,itemdescription 

GO
/****** Object:  StoredProcedure [dbo].[bpGRTransAddRpt]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[bpGRTransAddRpt]
as
Declare @lastRun datetime
select @lastRun=flastrun from btgrvars
select DATEADD(DD, DATEDIFF(DD, 0, received), 0) start,VendorPONumber fpono,id as podetailId,'999999' freceiver,po.address1 fcompany,
left(ItemDescription,25) fpartno,item,pod.quantity fqtyrecv 
from po 
inner join PODETAIL pod
on po.ponumber = pod.ponumber 
inner join btOpenGenPO ogpo
on po.VendorPO = ogpo.fpono
where pod.Received > @lastRun
and pod.id not in
(
	select podetailId from btGRTrans
)
and pod.Quantity is not null
and pod.Quantity <> 0
--162
and po.postatusno <> 1 --closed
order by received

GO
/****** Object:  StoredProcedure [dbo].[bpGRTransDelete]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--/////////////////////////////////////////////////////////////////////////////////
--Delete all podetail ids to btGRTrans that were used to make up the receiver given
--/////////////////////////////////////////////////////////////////////////////////
create proc [dbo].[bpGRTransDelete]
@sessionId as int 
as
delete from btGRTrans where sessionId=@sessionId

GO
/****** Object:  StoredProcedure [dbo].[bpGRTransInsert]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--///////////////////////////////////////////////////////////////////
--Add all podetail ids to btGRTrans that were used to make up the receiver given
--///////////////////////////////////////////////////////////////////
create proc [dbo].[bpGRTransInsert]
@freceiver as char(6),
@sessionId as int,
@remove as char(1) 
as
	-- could have dup fpono,start,itemdescription records if item was received more 
	-- than once in a single day. such as 121124 --63163,63210,4C12H-1.2340 on 10/26
	-- only one rcitem record will be generated for ids 63163 and 63210 but both 
	-- podetail ids must be added to the btGRTransfered table.
--	select pod.VendorPONumber,pod.start,pod.fpartno,id,freceiver
--	Declare @freceiver char(6) 
--	set @freceiver = '285893'
--	Declare @sessionId int 
--	set @sessionId = 5
	insert into btGRTrans (podetailId,freceiver,sessionId,remove)
	select id as podetailId,freceiver, @sessionId as sessionId,@remove as remove
	from
	(
		-- select only podetails that have not been inserted previously.  If unlikely it is possible
		-- that a po,date,partno record could have been received and Ashley run previously in the day.
		-- which would have resulted in a podetail record of the same po,date, and partno already having
		-- been inserted into the transaction log.  If a po, partno was received at 7am and the receiver
		-- process was run at 10am for po,date,
		-- partno and podetail id x was inserted into the transaction log, 
		-- and it was ran again and 5pm and the
		-- same po,partno was received again at 12pm then the podetail item received at  7am will 
		-- not be included for the receiver generated in the 5pm run.
		select VendorPONumber,
		DATEADD(DD, DATEDIFF(DD, 0, received), 0) start,left(ItemDescription,25) fpartno,received,id
		from PODETAIL pod
		where pod.id not in
		(
			select podetailId from btGRTrans
		)

--		where VendorPONumber='121124'
	) pod
	inner join -- user does not have to generate a rcitem record for each podetail
	-- only add records to btGRTransfered that have a corresponding btrcitem record
	(


		select rcm.fpono,DATEADD(DD, DATEDIFF(DD, 0, rcm.fdaterecv),0) start,rci.fpartno,rci.freceiver from
		btrcmast rcm
		inner join
		btrcitem rci
		on rcm.freceiver=rci.freceiver
		--where rcm.fpono='121124'
	) rci
	 on pod.vendorponumber=rci.fpono
	 and pod.start=rci.start
	 and pod.fpartno=rci.fpartno
	 where freceiver = @freceiver
--	 where pod.Received > @lastRun and rci.fpono='121124'
--	 order by VendorPONumber,rci.start,rci.fpartno


GO
/****** Object:  StoredProcedure [dbo].[bpGRTransInsException]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--//////////////////////////////////////////////////////////////////
-- Remove PODETAIL ID from consideration by the Ashley Gen Receiver
-- program by inserting it into btGRTrans table
-- For whatever reason the MRO personnel has chosen not to generate
-- a receiver for this PODetail ID. 
-- Since we do not pass a session ID. These items will not be deleted
-- if a rollback of the session happens. 
--///////////////////////////////////////////////////////////////////
create procedure [dbo].[bpGRTransInsException]
@VendorPONumber as varchar(16),
@start as datetime
as
begin
Declare @lastRun datetime
select @lastRun=flastrun from btgrvars
--Declare @VendorPONumber varchar(16)
--set @VendorPONumber = '122272'
--Declare @start datetime
--'1900-01-01 00:00:00.000'
--set @start = '2017-01-20 00:00:00:000'

INSERT INTO [dbo].[btGRTrans]
           ([podetailId]
           ,[freceiver]
           ,[sessionId])
-- select only the records not transfered yet
--select VendorPONumber, VendorNumber, id,DATEADD(DD, DATEDIFF(DD, 0, received), 0) start, received
select id podetailid, '999999' freceiver,999 sessionId
from PODETAIL pod
where Received > @lastRun
and VendorPONumber = @VendorPONumber
and DATEADD(DD, DATEDIFF(DD, 0, received), 0) = @start
--33
and pod.id not in
(
	select podetailId from btGRTrans
)
end

GO
/****** Object:  StoredProcedure [dbo].[bpGRUpToDate]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--//////////////////////////////////////////
-- Update last btGRLog entry with uptodate  
-- for the state and process ending datetime
-- in both btGRLog and btGRVars
--//////////////////////////////////////////
create procedure [dbo].[bpGRUpToDate]
as
Declare @maxId integer
select @maxId=max(id) from btGRLog 
update btGRLog
set fEnd = GETDATE(),
fStep = 'STEP_5_UPTODATE'
where id = @maxId 

update btGRVars 
set fLastRun = getdate()

GO
/****** Object:  StoredProcedure [dbo].[bPIncrementPO]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bPIncrementPO] 
AS
BEGIN
	 SET NOCOUNT ON
	Declare @nextVal as char(6);
	select @nextVal =  (CAST(fcurrentpo AS int) + 1) from btvars
	update btVars 
	set fcurrentpo = @nextVal
end

GO
/****** Object:  StoredProcedure [dbo].[bpInsPORTLog]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpInsPORTLog]
@id int output
AS
BEGIN
 SET NOCOUNT ON
	INSERT INTO [dbo].[btPORTLog]
			   (fRollBack,fStart)
		 VALUES
			   (0,GETDATE())
	select @id=max(id) from btPORTLog
end

GO
/****** Object:  StoredProcedure [dbo].[bpitemPartIssuedList]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--///////////////////////////////////////////////////////////////////////////////////
-- For each translog items create a record containing newIssuedTotQty,newIssuedTotCost,
-- rwkIssuedTotQty,rwkIssuedTotCost, issuedTotQty,issuedTotCost, and a list of 
-- part Item newIssuedTotQty,rwkIssuedTotQty fields
--///////////////////////////////////////////////////////////////////////////////////
create PROCEDURE [dbo].[bpitemPartIssuedList] 
AS
BEGIN
	SET NOCOUNT ON
	IF
	OBJECT_ID('tempdb.dbo.#btItemPartIssuedList') IS NOT NULL
		DROP TABLE #btItemPartIssuedList
	IF
	OBJECT_ID('btItemPartIssuedList') IS NOT NULL
		DROP TABLE btItemPartIssuedList

	Declare @itemPartIssuedList as varchar(max)
	select
	partNumber,
	itemNumber,
	newIssuedTotQty,
	newIssuedTotCost,
	rwkIssuedTotQty,
	rwkIssuedTotCost,
	newIssuedTotQty+rwkIssuedTotQty as issuedTotQty,
	newIssuedTotCost+rwkIssuedTotCost as issuedTotCost,
	RowNum = ROW_NUMBER() OVER (PARTITION BY itemNumber ORDER BY itemNumber,partNumber),
	itemPartIssuedList = CAST(NULL AS VARCHAR(max))
	into #btItemPartIssuedList
	from
	(
		select 
		case 
			when new.PartNumber is null then SUBSTRING(rwk.PartNumber,1,len(rwk.partNumber)-1)
			else new.PartNumber
		end partNumber,
		case 
			when new.ItemNumber is null then SUBSTRING(rwk.ItemNumber,1,len(rwk.ItemNumber)-1)
			else new.ItemNumber
		end itemNumber,
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
			select partNumber,itemNumber,sum(qty) newIssuedTotQty, sum(qty*unitCost) newIssuedTotCost 
			from btTransLogMonth
			group by partNumber,ItemNumber
			having ItemNumber <> '' and ItemNumber <> '.'
			and itemNumber not like '%R'
			--2613
		)new
		full join
		(
			select partNumber,itemNumber,sum(qty) rwkIssuedTotQty, sum(qty*unitCost) rwkIssuedTotCost 
			from btTransLogMonth
			group by partNumber,ItemNumber
			having ItemNumber <> '' and ItemNumber <> '.'
			and itemNumber like '%R'
			--80
		)rwk
		on
		new.PartNumber=rwk.partNumber and
		new.ItemNumber=rwk.ItemNumber
		--2193
	)lv1

	update #btItemPartIssuedList
	set @itemPartIssuedList = itemPartIssuedList =
	CASE WHEN RowNum = 1 
		THEN partNumber + itemNumber + 
		', New Issued: ' + convert(varchar(4),newIssuedTotQty) +
		', Rwk Issued: ' + convert(varchar(4),rwkIssuedTotQty) 
	--	', Total Issued: ' + convert(varchar(4),issuedTotQty) 
		ELSE @itemPartIssuedList + '<br>' + partNumber + itemNumber + 
		', New Issued: ' + convert(varchar(4),newIssuedTotQty) +
		', Rwk Issued: ' + convert(varchar(4),rwkIssuedTotQty) 
	--	', Total Issued: ' + convert(varchar(4),issuedTotQty) 
	END

	select itemNumber,max(itemPartIssuedList) itemPartIssuedList
	into btItemPartIssuedList
	from #btItemPartIssuedList
	group by itemNumber
	--1235
end

GO
/****** Object:  StoredProcedure [dbo].[bpLocQtyList]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--///////////////////////////////////////////////////////////////////////////////////
-- For each inventry item create a list of  Location / Qty pairs
-- alse add ToolBoss quantity totals 
--///////////////////////////////////////////////////////////////////////////////////
create PROCEDURE [dbo].[bpLocQtyList] 
AS
BEGIN
	SET NOCOUNT ON
	IF
	OBJECT_ID('tempdb.dbo.#btTBLocQtyList1') IS NOT NULL
		DROP TABLE #btTBLocQtyList1

	IF
	OBJECT_ID('tempdb.dbo.#btAlbCribLocQtyList1') IS NOT NULL
		DROP TABLE #btAlbCribLocQtyList1

	IF
	OBJECT_ID('tempdb.dbo.#btAviCribLocQtyList1') IS NOT NULL
		DROP TABLE #btAviCribLocQtyList1

	IF
	OBJECT_ID('tempdb.dbo.#btTBLocQtyList2') IS NOT NULL
		DROP TABLE #btTBLocQtyList2

	IF
	OBJECT_ID('tempdb.dbo.#btAlbCribLocQtyList2') IS NOT NULL
		DROP TABLE #btAlbCribLocQtyList2

	IF
	OBJECT_ID('tempdb.dbo.#btAviCribLocQtyList2') IS NOT NULL
		DROP TABLE #btAviCribLocQtyList2

	IF
	OBJECT_ID('tempdb.dbo.#btAlbCribLocQtyList3') IS NOT NULL
		DROP TABLE #btAlbCribLocQtyList3

	IF
	OBJECT_ID('tempdb.dbo.#btAviCribLocQtyList3') IS NOT NULL
		DROP TABLE #btAviCribLocQtyList3

	IF
	OBJECT_ID('btLocQtyList') IS NOT NULL
		DROP TABLE btLocQtyList

	DECLARE
			@LocQtyList VARCHAR(max)

	select itemNumber,
	binLocList + ', Qty: ' + cast(convert(int,totqty) as varchar(15)) as TBLocQty,
	RowNum = ROW_NUMBER() OVER (PARTITION BY itemNumber ORDER BY 1/0),
	LocQtyList = CAST(NULL AS VARCHAR(max))
	into #btTBLocQtyList1
	from toolinv 	
	where plant <> 0
	order by itemnumber,plant asc

	select item, 
	CribBin + ', Qty: ' + cast(BinQuantity as varchar(4)) as AlbLocQty,
	'' as AviLocQty,
	albion=1,
	RowNum = ROW_NUMBER() OVER (PARTITION BY item ORDER BY 1/0),
	LocQtyList = CAST(NULL AS VARCHAR(max))
	into #btAlbCribLocQtyList1
	from
	station 
	where (crib = '1') 
	and (item is not null) and (item <> '') and (item <> '.') 
	--10768

	select item, 
	'' as AlbLocQty,
	CribBin + ', Qty: ' + cast(BinQuantity as varchar(4)) as AviLocQty,
	albion=0,
	RowNum = ROW_NUMBER() OVER (PARTITION BY item ORDER BY 1/0),
	LocQtyList = CAST(NULL AS VARCHAR(max))
	into #btAviCribLocQtyList1
	from
	station 
	where (crib = '11') 
	and (item is not null) and (item <> '') and (item <> '.') 
	--398

	update #btTBLocQtyList1
	set @LocQtyList = LocQtyList =
	CASE WHEN RowNum = 1 
		THEN TBLocQty
		ELSE @LocQtyList + '<br>' + TBLocQty 
	END

	update #btAlbCribLocQtyList1
	set @LocQtyList = LocQtyList =
	CASE WHEN RowNum = 1 
		THEN AlbLocQty
		ELSE @LocQtyList + '<br>' + AlbLocQty 
	END

	update #btAviCribLocQtyList1
	set @LocQtyList = LocQtyList =
	CASE WHEN RowNum = 1 
		THEN AviLocQty
		ELSE @LocQtyList + '<br>' + AviLocQty 
	END

	select itemNumber,max(LocQtyList) LocQtyList
	into #btTBLocQtyList2
	from #btTBLocQtyList1
	group by itemNumber

	select item,max(LocQtyList) LocQtyList
	into #btAlbCribLocQtyList2
	from #btAlbCribLocQtyList1
	group by item

	select item,max(LocQtyList) LocQtyList
	into #btAviCribLocQtyList2
	from #btAviCribLocQtyList1
	group by item

	select *,
	case
		when rLocQtyList is null then lLocQtyList
		else lLocQtyList + '<br>' + rLocQtyList
	end
	as LocQtyList
	into #btAlbCribLocQtyList3
	from
	(
		select item as lItem, LocQtyList as lLocQtyList
		from
		#btAlbCribLocQtyList2
		where item not like '%R'
	)a
	left outer join
	(
		select item as rItem, LocQtyList as rLocQtyList
		from
		#btAlbCribLocQtyList2
		where item like '%R'
	)b
	on 
	lItem+'R'=rItem
	--8693

	select *,
	case
		when rLocQtyList is null then lLocQtyList
		else lLocQtyList + '<br>' + rLocQtyList
	end
	as LocQtyList
	into #btAviCribLocQtyList3
	from
	(
		select item as lItem, LocQtyList as lLocQtyList
		from
		#btAviCribLocQtyList2
		where item not like '%R'
	)a
	left outer join
	(
		select item as rItem, LocQtyList as rLocQtyList
		from
		#btAviCribLocQtyList2
		where item like '%R'
	)b
	on 
	lItem+'R'=rItem
	--8693

	select crb.*,
	case
		when tb2TotQty is null then 0
		else tb2TotQty
	end TB2TotQty,
	case
		when tb3TotQty is null then 0
		else tb3TotQty
	end TB3TotQty,
	case
		when tb5TotQty is null then 0
		else tb5TotQty
	end TB5TotQty,
	case
		when tb6TotQty is null then 0
		else tb6TotQty
	end TB6TotQty,
	case
		when tb7TotQty is null then 0
		else tb7TotQty
	end TB7TotQty,
	case
		when tb8TotQty is null then 0
		else tb8TotQty
	end TB8TotQty,
	case
		when tb9TotQty is null then 0
		else tb9TotQty
	end TB9TotQty,
	case
		when tb11TotQty is null then 0
		else tb11TotQty
	end TB11TotQty,
	case
		when tb112TotQty is null then 0
		else tb112TotQty
	end TB112TotQty,
	case
		when tbTotQty is null then 0
		else tbTotQty
	end TBTotQty,
	case
		when tb.LocQtyList is null then 'None in ToolBosses'
		else tb.LocQtyList
	end TBLocQtyList,
	case
		when tb.LocQtyList is null then crb.CribLocQtyList
		else crb.CribLocQtyList + '<br>' + tb.LocQtyList
	end CribAndTBLocQtyList
	into btLocQtyList
	from
	(
		select alb.lItem albLItem,avi.lItem aviLItem,
		case
			when alb.lItem is not null then alb.lItem
			else avi.lItem
		end itemNumber,
		case
			when alb.LocQtyList is null then 'None in Albion Crib'
			else alb.LocQtyList
		end AlbLocQtyList,
		case
			when avi.LocQtyList is null then 'None in Avilla Crib'
			else avi.LocQtyList
		end AviLocQtyList,
		case
			when alb.LocQtyList is null then avi.LocQtyList
			when avi.LocQtyList is null then alb.LocQtyList
			else alb.LocQtyList + '<br>' + avi.LocQtyList
		end CribLocQtyList
		from #btAlbCribLocQtyList3 alb
		full join
		#btAviCribLocQtyList3 avi
		on alb.lItem = avi.lItem
	)crb
	left outer join
	#btTBLocQtyList2 tb
	on 
	crb.itemNumber=tb.itemNumber
	--8693
	left outer join
	(
		select itemnumber,sum(totqty) tb2TotQty
		from 
		toolinv
		group by plant,itemnumber
		having plant = 2 
	)tb2
	on crb.itemNumber=tb2.itemnumber
	left outer join
	(
		select itemnumber,sum(totqty) tb3TotQty
		from 
		toolinv
		group by plant,itemnumber
		having plant = 3 
	)tb3
	on crb.itemNumber=tb3.itemnumber
	left outer join
	(
		select itemnumber,sum(totqty) tb5TotQty
		from 
		toolinv
		group by plant,itemnumber
		having plant = 5 
	)tb5
	on crb.itemNumber=tb5.itemnumber
	left outer join
	(
		select itemnumber,sum(totqty) tb6TotQty
		from 
		toolinv
		group by plant,itemnumber
		having plant = 6 
	)tb6
	on crb.itemNumber=tb6.itemnumber
	left outer join
	(
		select itemnumber,sum(totqty) tb7TotQty
		from 
		toolinv
		group by plant,itemnumber
		having plant = 7 
	)tb7
	on crb.itemNumber=tb7.itemnumber
	left outer join
	(
		select itemnumber,sum(totqty) tb8TotQty
		from 
		toolinv
		group by plant,itemnumber
		having plant = 8 
	)tb8
	on crb.itemNumber=tb8.itemnumber
	left outer join
	(
		select itemnumber,sum(totqty) tb9TotQty
		from 
		toolinv
		group by plant,itemnumber
		having plant = 9 
	)tb9
	on crb.itemNumber=tb9.itemnumber
	left outer join
	(
		select itemnumber,sum(totqty) tb11TotQty
		from 
		toolinv
		group by plant,itemnumber
		having plant = 11 
	)tb11
	on crb.itemNumber=tb11.itemnumber
	left outer join
	(
		select itemnumber,sum(totqty) tb112TotQty
		from 
		toolinv
		group by plant,itemnumber
		having plant = 112 
	)tb112
	on crb.itemNumber=tb112.itemnumber
	left outer join
	(
		select itemnumber,sum(totqty) tbTotQty
		from 
		(
			select itemNumber,totqty from toolinv
			where plant <> 0
		)a
		group by itemnumber
		--1945
	)tbt
	on crb.itemNumber=tbt.itemnumber
end

GO
/****** Object:  StoredProcedure [dbo].[bpMonthInv]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--///////////////////////////////////////////////////////////////////////////////////
-- Writes bvInventory recordset to btMonthInv
--///////////////////////////////////////////////////////////////////////////////////
create PROCEDURE [dbo].[bpMonthInv] 
AS
BEGIN
	SET NOCOUNT ON
--	SET ANSI_WARNINGS OFF CAN'T USE CROSS-APPLY WHEN THIS IS OFF
	Declare @today DATETIME
	Declare @month int
	Declare @year int
	Declare @yearMonth as varchar(20)

	select @today = GETDATE(),
	@month = month(@today),
	@year = year(@today),
	@yearMonth=rtrim(ltrim(str(year(@today))))+'-'+rtrim(ltrim(DATENAME(month, GETDATE())))


	delete from btMonthInv
	where year=@year and month=@month

	insert 
	into btMonthInv
	select @year year,@month month,@yearMonth yearMonth,* 
	from bvInventory
end


GO
/****** Object:  StoredProcedure [dbo].[bpMonthInvClass]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpMonthInvClass]
 @yearMonth varchar(20)
AS
BEGIN
select * from bfMonthInvClass(@yearMonth)
end

GO
/****** Object:  StoredProcedure [dbo].[bpMonthInvClassDetails]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpMonthInvClassDetails]
 @LYearMonth varchar(20)
AS
BEGIN
	select * from bfMonthInvClassDetails(@LYearMonth)
END

GO
/****** Object:  StoredProcedure [dbo].[bpMonthInvClassDiff]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpMonthInvClassDiff]
 @LYearMonth varchar(20),
 @RYearMonth varchar(20)
AS
BEGIN
	select * from bfMonthInvClassDiff(@LYearMonth,@RYearMonth)
END

GO
/****** Object:  StoredProcedure [dbo].[bpPORT]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpPORT] 
	@currentPO as char(6)
AS
BEGIN
SET NOCOUNT ON
insert into btpomast
(
fpono,cribpo,fcompany,fcshipto, forddate,fstatus,fvendno,fbuyer,
fchangeby,fshipvia, fcngdate, fcreate, ffob, fmethod, foldstatus, fordrevdt, 
fordtot,fpayterm,fpaytype,fporev,fprint,freqdate,freqsdt,freqsno, frevtot, 
fsalestax, ftax, fcsnaddrke, fnnextitem, fautoclose,fnusrqty1,fnusrcur1, fdusrdate1,fcfactor,
fdcurdate, fdeurodate, feurofctr, fctype, fmsnstreet, fpoclosing,fndbrmod, 
fcsncity, fcsnstate, fcsnzip, fcsncountr, fcsnphone,fcsnfax,fcshcompan,fcshcity,
fcshstate,fcshzip,fcshcountr,fcshphone,fcshfax,fmshstreet,
flpdate,fconfirm,fcontact,fcfname,fcshkey,fcshaddrke,fcusrchr1,fcusrchr2,fcusrchr3,
fccurid,fmpaytype,fmusrmemo1,freasoncng
)
select @currentPO -1 + row_number() over (order by PONumber)as fpono,PONumber cribpo,fccompany fcompany,
'SELF' fcshipto, PODate forddate,'OPEN' fstatus,UDFM2MVENDORNUMBER fvendno,'CM' fbuyer,
'CM' fchangeby,'UPS-OURS' fshipvia, PODate fcngdate,PODate fcreate,
'OUR PLANT' ffob,'1' fmethod,'STARTED' foldstatus,'1900-01-01 00:00:00.000' fordrevdt, 
0 fordtot,fcterms fpayterm,'3' fpaytype, '00' fporev,'N' fprint,'1900-01-01 00:00:00.000' freqdate,
PODate freqsdt,'' freqsno, 0 frevtot, 0 fsalestax, 'N' ftax, '0001' fcsnaddrke, 1 fnnextitem,
'Y' fautoclose,0 fnusrqty1,0 fnusrcur1,'1900-01-01 00:00:00.000' fdusrdate1,0 fcfactor,
'1900-01-01 00:00:00.000' fdcurdate,'1900-01-01 00:00:00.000' fdeurodate,0 feurofctr,'O' fctype,
fmstreet fmsnstreet,
'Please reference our purchase order number on all correspondence.  ' +
'Notification of changes regarding quantities to be shipped and changes in the delivery schedule are required.' + 
CHAR(13) + CHAR(13) + 
'PO APPROVALS:' + CHAR(13) + CHAR(13) +
'Requr. _______________________________________________' + CHAR(13) + 
'Dept. Head ___________________________________________' + CHAR(13) + CHAR(13) + 
'G.M. or Exec. Asst.: For All P.O.''s Over $500.00' + CHAR(13) + 
'G.M. or E.A.: ________________________________________' + CHAR(13) + 
'Plant Controller Only: All Assests/CER and ER Over $10,000.00' + CHAR(13) + 
'Plant Controller______________________________________' + CHAR(13) + 
'Pres. Only: All Assets/CER/ER and/or PO''s Over $10,000.00' + CHAR(13) + 
'President ____________________________________________' fpoclosing,0 fndbrmod,
fccity fcsncity,fcstate fcsnstate,fczip fcsnzip, fccountry fcsncountr,fcphone fcsnphone,fcfax fcsnfax,
'BUSCHE INDIANA' fcshcompan,'ALBION' fcshcity,'IN' fcshstate,'46701' fcshzip,'USA' fcshcountr,
'2606367030' fcshphone, '2606367031' fcshfax,'1563 E. State Road 8' fmshstreet,
'1900-01-01 00:00:00.000' flpdate,'' fconfirm,'' fcontact,'' fcfname,'' fcshkey,'' fcshaddrke,
'' fcusrchr1,'' fcusrchr2,'' fcusrchr3,'' fccurid,'' fmpaytype,'' fmusrmemo1,'Automatic closure.' freasoncng 
from 
(
	SELECT PONumber,Vendor,PODate 
	FROM [PO]  
	WHERE POSTATUSNO = 3 and SITEID <> '90' and (BLANKETPO = '' or BLANKETPO is null)
)po1
inner join 
(
	select VendorNumber,UDFM2MVENDORNUMBER from vendor 
)vn1
on po1.Vendor = vn1.VendorNumber
inner join
(
	SELECT fvendno,fcterms,fccompany,fccity,fcstate,fczip,fccountry,fcphone,fcfax,fmstreet FROM btapvend  
)av1
on vn1.UDFM2MVENDORNUMBER=av1.fvendno

update PO
set PO.VendorPO = pom.fpono
--select po.ponumber,pom.cribpo,pom.fpono,po.vendorpo
from [PO] po 
inner join
btpomast pom
on 
po.PONumber=pom.cribPO
WHERE POSTATUSNO = 3 and SITEID <> '90' and (BLANKETPO = '' or BLANKETPO is null)

insert into btpoitem
(
fpono, cribPO, fpartno,frev,fmeasure,fitemno,frelsno,
fcategory,fjoopno,flstcost,fstdcost,fleadtime,forgpdate,flstpdate,
fmultirls,fnextrels,fnqtydm,freqdate,fretqty,fordqty,fqtyutol,fqtyltol,
fbkordqty,flstsdate,frcpdate,frcpqty,fshpqty,finvqty,fdiscount,fstandard,
ftax,fsalestax,flcost,fucost,fprintmemo,fvlstcost,fvleadtime,fvmeasure,
fvptdes,fvordqty,fvconvfact,fvucost,fqtyshipr,fdateship,fnorgucost,
fnorgeurcost,fnorgtxncost,futxncost,fvueurocost,fvutxncost,fljrdif,
fucostonly,futxncston,fueurcston,fcomments,fdescript,fac,fndbrmod,
SchedDate,fsokey,fsoitm,fsorls,fjokey,fjoitm,frework,finspect,fvpartno,
fparentpo,frmano,fdebitmemo,finspcode,freceiver,fcorgcateg,fparentitm,fparentrls,frecvitm,
fueurocost,FCBIN,FCLOC,fcudrev,blanketPO,PlaceDate,DockTime,PurchBuf,Final,AvailDate
)
SELECT 
po.VendorPO fpono, po.PONumber cribPO, fpartno,frev,fmeasure,fitemno,frelsno,
fcategory,fjoopno,flstcost,fstdcost,fleadtime,forgpdate,flstpdate,
fmultirls,fnextrels,fnqtydm,freqdate,fretqty,fordqty,fqtyutol,fqtyltol,
fbkordqty,flstsdate,frcpdate,frcpqty,fshpqty,finvqty,fdiscount,fstandard,
ftax,fsalestax,flcost,fucost,fprintmemo,fvlstcost,fvleadtime,fvmeasure,
fvptdes,fvordqty,fvconvfact,fvucost,fqtyshipr,fdateship,fnorgucost,
fnorgeurcost,fnorgtxncost,futxncost,fvueurocost,fvutxncost,fljrdif,
fucostonly,futxncston,fueurcston,fcomments,fdescript,fac,fndbrmod,
SchedDate,fsokey,fsoitm,fsorls,fjokey,fjoitm,frework,finspect,fvpartno,
fparentpo,frmano,fdebitmemo,finspcode,freceiver,fcorgcateg,fparentitm,fparentrls,frecvitm,
fueurocost,FCBIN,FCLOC,fcudrev,blanketPO,PlaceDate,DockTime,PurchBuf,Final,AvailDate
FROM 
(
	SELECT PONumber,vendorPO
	FROM [PO]  
	WHERE POSTATUSNO = 3 and SITEID <> '90' and (BLANKETPO = '' or BLANKETPO is null)

)po
inner join
(
	select
	'' fsokey,'' fsoitm,'' fsorls,'' fjokey,'' fjoitm,'' frework,'' finspect,'' fvpartno,'' fparentpo, 
	'' frmano,'' fdebitmemo,'' finspcode,'' freceiver,'' fcorgcateg,'' fparentitm,'' fparentrls,'' frecvitm,
	0.000 fueurocost,'' FCBIN,'' FCLOC,'' fcudrev,0 blanketPO,
	'1900-01-01 00:00:00.000' PlaceDate,0 DockTime,0 PurchBuf,0 Final,
	'1900-01-01 00:00:00.000' AvailDate,
	'1900-01-01 00:00:00.000' SchedDate,
	PONumber,left(ItemDescription,25) fpartno,'NS' frev, 'EA' fmeasure, 
	case 
	when (row_number() over (PARTITION BY PONumber order by ItemDescription )) > 99 then cast((row_number() over (PARTITION BY PONumber order by ItemDescription )) as char(3))
	when (row_number() over (PARTITION BY PONumber order by ItemDescription )) > 9 then ' ' + cast((row_number() over (PARTITION BY PONumber order by ItemDescription )) as char(3))
	else '  ' + cast((row_number() over (PARTITION BY PONumber order by ItemDescription )) as char(3))
	end	as fitemno, '  0' frelsno,
	UDF_POCATEGORY fcategory,
	0 fjoopno,
	Cost flstcost,
	cost fstdcost,
	0 fleadtime,
	case
		when RequiredDate is null then GETDATE()
		else RequiredDate
	end as forgpdate,
	case
	when RequiredDate is null then GETDATE()
	else RequiredDate
	end as flstpdate,
	'N' fmultirls,
	0 fnextrels,
	0 fnqtydm,
	'1900-01-01 00:00:00.000' freqdate,
	0 fretqty,
	quantity fordqty,
	0 fqtyutol,
	0 fqtyltol,
	0 fbkordqty,
	'1900-01-01 00:00:00.000' flstsdate,
	'1900-01-01 00:00:00.000' frcpdate,
	0 frcpqty,
	0 fshpqty,
	0 finvqty,
	0 fdiscount,
	0 fstandard,
	'N' ftax,
	0 fsalestax,
	cost flcost,
	cost fucost,
	'Y' fprintmemo,
	cost fvlstcost,
	0 fvleadtime,
	'EA' fvmeasure,
	case
		when ITEM is null then ' '
		else ITEM
	end as fvptdes,
	Quantity fvordqty,
	1 fvconvfact,
	cost fvucost,
	0 fqtyshipr,
	'1900-01-01 00:00:00.000' fdateship,
	0 fnorgucost,
	0 fnorgeurcost,
	0 fnorgtxncost,
	0 futxncost,
	0 fvueurocost,
	0 fvutxncost,
	0 fljrdif,
	cost fucostonly,
	0 futxncston,
	0 fueurcston,
	case
		when Comments is null then ' '
		else Comments 
	end fcomments,
	case
		when Description2 is null then ' ' 
		else Description2
	end fdescript,
	'Default' fac,
	0 fndbrmod
	from PODETAIL
) pod
on po.PONumber = pod.PONumber

update PODetail
set vendorPONumber = po.VendorPO
from
PODetail pod
inner join
[PO]  po
on
pod.ponumber=po.PONumber
WHERE POSTATUSNO = 3 and SITEID <> '90' and (po.BLANKETPO = '' or po.BLANKETPO is null)


end


GO
/****** Object:  StoredProcedure [dbo].[bpPORTold]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpPORTold] 
	@currentPO as char(6)
AS
BEGIN
SET NOCOUNT ON
insert into btpomast
(
fpono,cribpo,fcompany,fcshipto, forddate,fstatus,fvendno,fbuyer,
fchangeby,fshipvia, fcngdate, fcreate, ffob, fmethod, foldstatus, fordrevdt, 
fordtot,fpayterm,fpaytype,fporev,fprint,freqdate,freqsdt,freqsno, frevtot, 
fsalestax, ftax, fcsnaddrke, fnnextitem, fautoclose,fnusrqty1,fnusrcur1, fdusrdate1,fcfactor,
fdcurdate, fdeurodate, feurofctr, fctype, fmsnstreet, fpoclosing,fndbrmod, 
fcsncity, fcsnstate, fcsnzip, fcsncountr, fcsnphone,fcsnfax,fcshcompan,fcshcity,
fcshstate,fcshzip,fcshcountr,fcshphone,fcshfax,fmshstreet,
flpdate,fconfirm,fcontact,fcfname,fcshkey,fcshaddrke,fcusrchr1,fcusrchr2,fcusrchr3,
fccurid,fmpaytype,fmusrmemo1,freasoncng
)
select @currentPO -1 + row_number() over (order by PONumber)as fpono,PONumber cribpo,fccompany fcompany,
'SELF' fcshipto, PODate forddate,'OPEN' fstatus,UDFM2MVENDORNUMBER fvendno,'CM' fbuyer,
'CM' fchangeby,'UPS-OURS' fshipvia, PODate fcngdate,PODate fcreate,
'OUR PLANT' ffob,'1' fmethod,'STARTED' foldstatus,'1900-01-01 00:00:00.000' fordrevdt, 
0 fordtot,fcterms fpayterm,'3' fpaytype, '00' fporev,'N' fprint,'1900-01-01 00:00:00.000' freqdate,
PODate freqsdt,'' freqsno, 0 frevtot, 0 fsalestax, 'N' ftax, '0001' fcsnaddrke, 1 fnnextitem,
'Y' fautoclose,0 fnusrqty1,0 fnusrcur1,'1900-01-01 00:00:00.000' fdusrdate1,0 fcfactor,
'1900-01-01 00:00:00.000' fdcurdate,'1900-01-01 00:00:00.000' fdeurodate,0 feurofctr,'O' fctype,
fmstreet fmsnstreet,
'Please reference our purchase order number on all correspondence.  ' +
'Notification of changes regarding quantities to be shipped and changes in the delivery schedule are required.' + 
CHAR(13) + CHAR(13) + 
'PO APPROVALS:' + CHAR(13) + CHAR(13) +
'Requr. _______________________________________' + CHAR(13) + 
'Dept. Head ___________________________________' + CHAR(13) + CHAR(13) + 
'G.M. Only: All Items Over $500.00' + CHAR(13) + 
'G.M ________________________________________' + CHAR(13) + 
'VP/Group Controller. Only: All Assests/CER and ER Over $10,000.00' + CHAR(13) + 
'VP/Group Controller _____________________________________' + CHAR(13) + 
'Pres. Only: All Assets/CER/ER and/or PO''s Over $10,000.00' + CHAR(13) + 
'President _____________________________________' fpoclosing,0 fndbrmod,
fccity fcsncity,fcstate fcsnstate,fczip fcsnzip, fccountry fcsncountr,fcphone fcsnphone,fcfax fcsnfax,
'BUSCHE INDIANA' fcshcompan,'ALBION' fcshcity,'IN' fcshstate,'46701' fcshzip,'USA' fcshcountr,
'2606367030' fcshphone, '2606367031' fcshfax,'1563 E. State Road 8' fmshstreet,
'1900-01-01 00:00:00.000' flpdate,'' fconfirm,'' fcontact,'' fcfname,'' fcshkey,'' fcshaddrke,
'' fcusrchr1,'' fcusrchr2,'' fcusrchr3,'' fccurid,'' fmpaytype,'' fmusrmemo1,'Automatic closure.' freasoncng 
from 
(
	SELECT PONumber,Vendor,PODate 
	FROM [PO]  
	WHERE POSTATUSNO = 3 and SITEID <> '90' and (BLANKETPO = '' or BLANKETPO is null)
)po1
inner join 
(
	select VendorNumber,UDFM2MVENDORNUMBER from vendor 
)vn1
on po1.Vendor = vn1.VendorNumber
inner join
(
	SELECT fvendno,fcterms,fccompany,fccity,fcstate,fczip,fccountry,fcphone,fcfax,fmstreet FROM btapvend  
)av1
on vn1.UDFM2MVENDORNUMBER=av1.fvendno

update PO
set PO.VendorPO = pom.fpono
--select po.ponumber,pom.cribpo,pom.fpono,po.vendorpo
from [PO] po 
inner join
btpomast pom
on 
po.PONumber=pom.cribPO
WHERE POSTATUSNO = 3 and SITEID <> '90' and (BLANKETPO = '' or BLANKETPO is null)

insert into btpoitem
(
fpono, cribPO, fpartno,frev,fmeasure,fitemno,frelsno,
fcategory,fjoopno,flstcost,fstdcost,fleadtime,forgpdate,flstpdate,
fmultirls,fnextrels,fnqtydm,freqdate,fretqty,fordqty,fqtyutol,fqtyltol,
fbkordqty,flstsdate,frcpdate,frcpqty,fshpqty,finvqty,fdiscount,fstandard,
ftax,fsalestax,flcost,fucost,fprintmemo,fvlstcost,fvleadtime,fvmeasure,
fvptdes,fvordqty,fvconvfact,fvucost,fqtyshipr,fdateship,fnorgucost,
fnorgeurcost,fnorgtxncost,futxncost,fvueurocost,fvutxncost,fljrdif,
fucostonly,futxncston,fueurcston,fcomments,fdescript,fac,fndbrmod,
SchedDate,fsokey,fsoitm,fsorls,fjokey,fjoitm,frework,finspect,fvpartno,
fparentpo,frmano,fdebitmemo,finspcode,freceiver,fcorgcateg,fparentitm,fparentrls,frecvitm,
fueurocost,FCBIN,FCLOC,fcudrev,blanketPO,PlaceDate,DockTime,PurchBuf,Final,AvailDate
)
SELECT 
po.VendorPO fpono, po.PONumber cribPO, fpartno,frev,fmeasure,fitemno,frelsno,
fcategory,fjoopno,flstcost,fstdcost,fleadtime,forgpdate,flstpdate,
fmultirls,fnextrels,fnqtydm,freqdate,fretqty,fordqty,fqtyutol,fqtyltol,
fbkordqty,flstsdate,frcpdate,frcpqty,fshpqty,finvqty,fdiscount,fstandard,
ftax,fsalestax,flcost,fucost,fprintmemo,fvlstcost,fvleadtime,fvmeasure,
fvptdes,fvordqty,fvconvfact,fvucost,fqtyshipr,fdateship,fnorgucost,
fnorgeurcost,fnorgtxncost,futxncost,fvueurocost,fvutxncost,fljrdif,
fucostonly,futxncston,fueurcston,fcomments,fdescript,fac,fndbrmod,
SchedDate,fsokey,fsoitm,fsorls,fjokey,fjoitm,frework,finspect,fvpartno,
fparentpo,frmano,fdebitmemo,finspcode,freceiver,fcorgcateg,fparentitm,fparentrls,frecvitm,
fueurocost,FCBIN,FCLOC,fcudrev,blanketPO,PlaceDate,DockTime,PurchBuf,Final,AvailDate
FROM 
(
	SELECT PONumber,vendorPO
	FROM [PO]  
	WHERE POSTATUSNO = 3 and SITEID <> '90' and (BLANKETPO = '' or BLANKETPO is null)

)po
inner join
(
	select
	'' fsokey,'' fsoitm,'' fsorls,'' fjokey,'' fjoitm,'' frework,'' finspect,'' fvpartno,'' fparentpo, 
	'' frmano,'' fdebitmemo,'' finspcode,'' freceiver,'' fcorgcateg,'' fparentitm,'' fparentrls,'' frecvitm,
	0.000 fueurocost,'' FCBIN,'' FCLOC,'' fcudrev,0 blanketPO,
	'1900-01-01 00:00:00.000' PlaceDate,0 DockTime,0 PurchBuf,0 Final,
	'1900-01-01 00:00:00.000' AvailDate,
	'1900-01-01 00:00:00.000' SchedDate,
	PONumber,left(ItemDescription,25) fpartno,'NS' frev, 'EA' fmeasure, 
	case 
	when (row_number() over (PARTITION BY PONumber order by ItemDescription )) > 99 then cast((row_number() over (PARTITION BY PONumber order by ItemDescription )) as char(3))
	when (row_number() over (PARTITION BY PONumber order by ItemDescription )) > 9 then ' ' + cast((row_number() over (PARTITION BY PONumber order by ItemDescription )) as char(3))
	else '  ' + cast((row_number() over (PARTITION BY PONumber order by ItemDescription )) as char(3))
	end	as fitemno, '  0' frelsno,
	UDF_POCATEGORY fcategory,
	0 fjoopno,
	Cost flstcost,
	cost fstdcost,
	0 fleadtime,
	case
		when RequiredDate is null then GETDATE()
		else RequiredDate
	end as forgpdate,
	case
	when RequiredDate is null then GETDATE()
	else RequiredDate
	end as flstpdate,
	'N' fmultirls,
	0 fnextrels,
	0 fnqtydm,
	'1900-01-01 00:00:00.000' freqdate,
	0 fretqty,
	quantity fordqty,
	0 fqtyutol,
	0 fqtyltol,
	0 fbkordqty,
	'1900-01-01 00:00:00.000' flstsdate,
	'1900-01-01 00:00:00.000' frcpdate,
	0 frcpqty,
	0 fshpqty,
	0 finvqty,
	0 fdiscount,
	0 fstandard,
	'N' ftax,
	0 fsalestax,
	cost flcost,
	cost fucost,
	'Y' fprintmemo,
	cost fvlstcost,
	0 fvleadtime,
	'EA' fvmeasure,
	case
		when ITEM is null then ' '
		else ITEM
	end as fvptdes,
	Quantity fvordqty,
	1 fvconvfact,
	cost fvucost,
	0 fqtyshipr,
	'1900-01-01 00:00:00.000' fdateship,
	0 fnorgucost,
	0 fnorgeurcost,
	0 fnorgtxncost,
	0 futxncost,
	0 fvueurocost,
	0 fvutxncost,
	0 fljrdif,
	cost fucostonly,
	0 futxncston,
	0 fueurcston,
	case
		when Comments is null then ' '
		else Comments 
	end fcomments,
	case
		when Description2 is null then ' ' 
		else Description2
	end fdescript,
	'Default' fac,
	0 fndbrmod
	from PODETAIL
) pod
on po.PONumber = pod.PONumber

update PODetail
set vendorPONumber = po.VendorPO
from
PODetail pod
inner join
[PO]  po
on
pod.ponumber=po.PONumber
WHERE POSTATUSNO = 3 and SITEID <> '90' and (po.BLANKETPO = '' or po.BLANKETPO is null)


end


GO
/****** Object:  StoredProcedure [dbo].[bpPORTPOMastRange]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpPORTPOMastRange]
@postart int output,
@poend int output
AS
BEGIN
 SET NOCOUNT ON
select @postart=min(fpono) from btpomast
select @poend=max(fpono) from btpomast
IF (@postart IS NULL)
 BEGIN
   set @postart = 0
 END
IF (@poend IS NULL)
 BEGIN
   set @poend = 0
 END

RETURN
END


GO
/****** Object:  StoredProcedure [dbo].[bpPOVendorUpdate]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--///////////////////////////////////////////////////////////////////////////////////
-- Update PO and PODetail vendor number
--///////////////////////////////////////////////////////////////////////////////////
create PROCEDURE [dbo].[bpPOVendorUpdate] 
 @poNumber int,
 @vendor varchar(12),
 @Address1 varchar(50),
 @Address2 varchar(50),
 @Address3 varchar(50),
 @Address4 varchar(50)
AS
BEGIN
	SET NOCOUNT ON
	update PO
	set vendor = @vendor,
	Address1=@Address1,
	Address2=@Address2,
	Address3=@Address3,
	Address4=@Address4
	where 
	PONumber = @poNumber 

	update PODETAIL
	set VendorNumber = @vendor
	where 
	PONumber = @poNumber 

end

GO
/****** Object:  StoredProcedure [dbo].[bpRestockDetail]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpRestockDetail]
@itemNumber [nvarchar](32)
AS
	select  Plant,partNumber,itemnumber, TranStartDateTime as transTime, qty, 
	cast(unitCost as decimal(18,2)) as unitCost, cast(qty*unitCost as decimal(18,2)) as totCost, userName 
	from btTransLogMonth
	--12295
	where ItemNumber= @itemNumber or ItemNumber = @itemNumber + 'R'  
	order by partNumber, TranStartDateTime

GO
/****** Object:  StoredProcedure [dbo].[bpTest]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[bpTest] 
	@currentReceiver as char(6)
AS
Declare @lastRun datetime
select @lastRun=flastrun from btgrvars
--Declare @currentReceiver int
--set @currentReceiver='283343'
insert into btrcmast
(
fclandcost
,frmano
,fporev
,fcstatus
,fdaterecv
,fpono
,freceiver
,fvendno
,faccptby
,fbilllad
,fcompany
,ffrtcarr
,fpacklist
,fretship
,fshipwgt
,ftype
,start
,fprinted
,flothrupd
,fccurid
,fcfactor
,fdcurdate
,fdeurodate
,feurofctr
,flpremcv
,docstatus
,frmacreator
)
select 
'N' fclandcost
,'' frmano
,'00' fporev
,'C' fcstatus
,received fdaterecv
,right(VendorPONumber,6) fpono
,@currentReceiver -1 + row_number() over (order by PONumber) as freceiver
,UDFM2MVENDORNUMBER fvendno
,'NS' faccptby
,'' fbilllad
, fcompany
,'' ffrtcarr
,'' fpacklist
,'' fretship
,0.00 fshipwgt
,'P' ftype
, DATEADD(DD, DATEDIFF(DD, 0, GETDATE()), 0) start
,0 fprinted
,1 flothrupd
,'' fccurid
,0.00 fcfactor
,'1900-01-01 00:00:00.000' fdcurdate
,'1900-01-01 00:00:00.000' fdeurodate
,0.00 feurofctr
,0 flpremcv
,'RECEIVED' docstatus
,'' frmacreator
from 
(
	select pod.PONumber, VendorPONumber,vn1.UDFM2MVENDORNUMBER,apv.fccompany fcompany,Received 
	from btPODETAIL pod
	inner join 
	(
		select VendorNumber,UDFM2MVENDORNUMBER from vendor 
	)vn1
	on pod.VendorNumber = vn1.VendorNumber
	inner join
	(
	select fvendno,fccompany from btapvend
	)apv
	on vn1.UDFM2MVENDORNUMBER=apv.fvendno
	where Received > @lastRun
)pd
order by VendorPONumber desc

select * from btrcmast

GO
/****** Object:  StoredProcedure [dbo].[bpToolItems]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--///////////////////////////////////////////////////////////////////////////////////
-- Create btToolItems which contains Cribmaster item info needed for reports
--///////////////////////////////////////////////////////////////////////////////////
create PROCEDURE [dbo].[bpToolItems] 
AS
BEGIN
	SET NOCOUNT ON
	IF
	OBJECT_ID('btToolItems') IS NOT NULL
		DROP TABLE btToolItems

	select * 
	INTO btToolItems
	from bvToolItems
end
GO
/****** Object:  StoredProcedure [dbo].[bpVendorUpdate]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--///////////////////////////////////////////////////////////////////////////////////
-- Update UDFM2MVENDORNUMBER field of Vendor
--///////////////////////////////////////////////////////////////////////////////////
create PROCEDURE [dbo].[bpVendorUpdate] 
 @vendorNumber varchar(12),
 @newM2mVendor varchar(6)
AS
BEGIN
	SET NOCOUNT ON
	update Vendor
	set UDFM2MVENDORNUMBER = @newM2mVendor
	where 
	VendorNumber = @vendorNumber 
end

GO
/****** Object:  StoredProcedure [dbo].[BuildWOReservations]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	Create Procedure [dbo].[BuildWOReservations] 
As
    DECLARE @WONo int
	DECLARE @WODefScheduleNo int
	DECLARE @PartsCrib int
	DECLARE @PreferredCribBin VARCHAR(15) 
	DECLARE @TaskItemNumber VARCHAR(12)
	DECLARE @SumTaskQuantity int
	DECLARE @OvrOrderOption int
    DECLARE @get_WONeeds CURSOR 
    DECLARE @new_STATUS             int
    DECLARE @last_WONo              int
    DECLARE @last_WODefScheduleNo   int
    DECLARE @hold_ReservationNo     int
    DECLARE @hold_RUNDATE           DATETIME
	DECLARE @ReservationOrderOption int
	DECLARE @WONeedsAreAdditional int
	DECLARE @AdditionalLeadTimeDays int
	DECLARE @UserReservationNo int
	DECLARE @UserReservationType int
    -- Reservation Detail Merge Control
    DECLARE @get_Details CURSOR 
	DECLARE @ReservationDetailNo	int
	DECLARE @ReservationCrib	int
	DECLARE @ReservationItemNumber	VARCHAR(12)
	DECLARE @ReservationQuantity	int
	DECLARE @ReservationActualQuantity int
	DECLARE @RDOvrOrderOption		int
	DECLARE @nCompare				int
	DECLARE @Fetch1Status			int
	DECLARE @Fetch2Status			int
	DECLARE @ReservationChanged     int
	SELECT @ReservationOrderOption = INT FROM GLOBALSETTINGS WHERE KEYNAME = 'Purchasing_DefaultWOOrderOption'
	IF @ReservationOrderOption IS NULL 
	   SET @ReservationOrderOption = 0
	SELECT @AdditionalLeadTimeDays = INT FROM GLOBALSETTINGS WHERE KEYNAME = 'Purchasing_MoreLeadDays'
	IF @AdditionalLeadTimeDays IS NULL 
	   SET @AdditionalLeadTimeDays = 0
	-- NOTE: Must strip off milliseconds from time values
    SELECT @hold_RUNDATE =  cast( convert(varchar, GETDATE(),20) as datetime)
	-- Cursor for existing WO-based potential ordering needs
	SET @get_WONeeds  = CURSOR LOCAL FOR
	SELECT   WONo,
			 WODefScheduleNo,
			 partscrib,
			 preferredcribbin,
			 taskitemnumber,
			 SUM(effectivequantity) AS SUMTASKQUANTITY,
			 OvrOrderOption
		FROM VAllWOItemWithCribBin
	   WHERE PARTSCRIB IS NOT NULL
		 AND (NEXTWODATE < GETDATE() + ActualAvgLeadTime	+ @AdditionalLeadTimeDays
		     OR INTERVALTYPE = 5)
		 AND (ISNULL(OVRORDEROPTION, 0) IN(1, 2) OR ISSUEOPTION IN(1, 2))
	GROUP BY WONo,
			 WODefScheduleNo,
			 partscrib,
			 preferredcribbin,
			 taskitemnumber,
			 OvrOrderOption
	  HAVING SUM(effectivequantity) > 0
	ORDER BY WONo, WODefScheduleNo, TaskItemNumber, OvrOrderOption	
	OPEN @get_WONeeds
	FETCH NEXT FROM @get_WONeeds INTO @WONo, @WODefScheduleNo, @PartsCrib, @PreferredCribBin, 
		@TaskItemNumber, @SumTaskQuantity, @OvrOrderOption
	SET @Fetch1Status = @@FETCH_STATUS
	WHILE @Fetch1Status = 0
		BEGIN
         IF    @hold_ReservationNo IS NULL
            OR ISNULL(@last_WONo, 0) <> ISNULL(@WONo, 0)
            OR ISNULL(@last_WODefScheduleNo, 0) <> ISNULL(@WODefScheduleNo, 0) 
            BEGIN
               SELECT @last_WODefScheduleNo = ISNULL(@WODefScheduleNo, 0);
               SELECT @last_WONo = ISNULL(@WONo, 0);
			   SET @hold_ReservationNo = NULL
               SELECT @hold_ReservationNo = ReservationNo
                 FROM RESERVATION
                WHERE ReservationType = 2
				  AND RESERVATIONSTATUS <> 3
                  AND RESERVATIONWONO = @last_WONo
                  AND RESERVATIONWODEFSCHEDULENO = @last_WODefScheduleNo;
			   -- Don't reserve parts automatically if user has own reservation linked
			   -- to Work Order
			   IF @WONo IS NOT NULL
			      BEGIN
				  SET @UserReservationNo = NULL
				  SELECT @UserReservationNo = WO.ReservationNo, @UserReservationType = ReservationType
				     FROM WO LEFT JOIN RESERVATION ON WO.RESERVATIONNO = RESERVATION.RESERVATIONNO 
					 WHERE WONo = @WONo
				  IF @UserReservationNo IS NOT NULL AND ISNULL(@UserReservationType,0) <> 2
				     BEGIN
					 -- Don't do processing for this Work Order
					 if @hold_ReservationNo IS NOT NULL
					    BEGIN
						-- Clean up any existing records 
						DELETE FROM RESERVATIONDETAIL WHERE RESERVATIONNO = @hold_ReservationNo
						DELETE FROM RESERVATION WHERE RESERVATIONNO = @hold_ReservationNo
						END
					 END
				  ELSE
				     SET @UserReservationNo = NULL
				  END
			   IF @UserReservationNo IS NULL
				   BEGIN
				   IF @hold_ReservationNo IS NULL 
					  BEGIN
					  INSERT INTO RESERVATION
								  (DATECREATED, DATEREQUIRED,
								   RESERVATIONSTATUS, RESERVATIONTYPE,
								   RESERVATIONCOMMENTS,
								   RESERVATIONWONO, RESERVATIONWODEFSCHEDULENO,
								   RESERVEDFOREMPLOYEE, CREATEDBYEMPLOYEE,
								   APPROVEDBYEMPLOYEE, ReservationOrderOption)
						   VALUES (@hold_RUNDATE, @hold_RUNDATE,
								   1, 2,
								   'SYSTEM-GENERATED RESERVATION FOR PREDICTIVE WORK ORDER PURCHASING',
								   @last_WONo, @last_WODefScheduleNo,
								   'WORKORDER', 'SYSTEM',
								   'SYSTEM', @ReservationOrderOption);
					  SELECT @hold_ReservationNo = SCOPE_IDENTITY()
					  END
				  ELSE
   					  UPDATE RESERVATION
						  SET DATEREQUIRED = @hold_RUNDATE,
						  ReservationOrderOption=@ReservationOrderOption WHERE ReservationNo = @hold_ReservationNo;
				  -- Update WO to reference Reservation, if applicable
				  IF @last_WONo <> 0 
				     UPDATE WO SET RESERVATIONNO = @hold_ReservationNo WHERE WONo = @last_WONo
			      END
		     END
      -- If User-assigned reservation number, then just skip the rest of the needs for this Work Order
	  -- for now
      IF @UserReservationNo IS NOT NULL
		 BEGIN
		 FETCH NEXT FROM @get_WONeeds INTO @WONo, @WODefScheduleNo, @PartsCrib, @PreferredCribBin, 
			@TaskItemNumber, @SumTaskQuantity, @OvrOrderOption 
		 SET @Fetch1Status = @@FETCH_STATUS
		 CONTINUE;
		 END
	  -- Merge with the detail records
      SET @get_Details = CURSOR LOCAL FOR
         SELECT   ReservationDetailNo,
                  ReservationCrib,
                  ReservationItemNumber,
				  ISNULL(ReservationQuantity,0),
				  ISNULL(ReservationActualQuantity, 0),
				  OvrOrderOption
             FROM ReservationDetail where ReservationNo = @hold_ReservationNo
			 ORDER BY ReservationItemNumber, OvrOrderOption
	  SET @ReservationChanged = 0
	  OPEN @get_Details
	  FETCH @get_Details INTO @ReservationDetailNo, @ReservationCrib, @ReservationItemNumber,
	     @ReservationQuantity, @ReservationActualQuantity, @RDOvrOrderOption
	  SET @Fetch2Status = @@FETCH_STATUS
	  while (@ReservationChanged = 0 AND @Fetch1Status = 0) OR @Fetch2Status = 0
	     BEGIN
	  	 if @Fetch1Status <> 0 OR @ReservationChanged = 1 
		    Set @nCompare = 1
		 else if @Fetch2Status <> 0 
		    Set @nCompare = -1
		 else if @ReservationItemNumber < @TaskItemNumber 
		    Set @nCompare = 1 
		 else if @ReservationItemNumber > @TaskItemNumber
		    Set @nCompare = -1 
		 else if ISNULL(@RDOvrOrderOption, 0) < ISNULL(@OvrOrderOption, 0)
		    set @nCompare = 1
		 else if ISNULL(@RDOvrOrderOption, 0) > ISNULL(@OvrOrderOption, 0)
		    set @nCompare = -1
		 else
		    set @nCompare = 0
		   
		 -- Insert Reservation Detail Record as needed 
	     if @nCompare = -1 
			BEGIN
	         INSERT INTO RESERVATIONDETAIL
		                 (RESERVATIONNO, RESERVATIONCRIB,
			              RESERVATIONCRIBBIN, RESERVATIONITEMNUMBER,
				          RESERVATIONQUANTITY, RESERVATIONACTUALQUANTITY, OVRORDEROPTION)
				VALUES (@hold_ReservationNo, @partscrib,
					      @preferredcribbin, @taskitemnumber,
						  @SUMTASKQUANTITY, 0, @OvrOrderOption);
			END
		else if @nCompare = 1 
		    BEGIN
			DELETE FROM RESERVATIONDETAIL WHERE RESERVATIONDETAILNO = @ReservationDetailNo
			END
		else
			BEGIN
			-- Matched set of records
			IF @PartsCrib <> ISNULL(@ReservationCrib, 0) OR @SUMTASKQUANTITY <> @ReservationQuantity - @ReservationActualQuantity 
			   BEGIN
			   -- Update the record
			   UPDATE RESERVATIONDETAIL SET ReservationCrib = @PartsCrib,
					ReservationCribBin = @PreferredCribBin,
					ReservationQuantity = @ReservationActualQuantity + @SUMTASKQUANTITY
			   WHERE 
					ReservationDetailNo = @ReservationDetailNo
				END
			END
	    if @nCompare = 1 OR @nCompare = 0 
			BEGIN
			FETCH @get_Details INTO @ReservationDetailNo, @ReservationCrib, @ReservationItemNumber,
				@ReservationQuantity, @ReservationActualQuantity, @RDOvrOrderOption
				SET @Fetch2Status = @@FETCH_STATUS
			END
	    if @nCompare = -1 OR @nCompare = 0 
			BEGIN
			FETCH NEXT FROM @get_WONeeds INTO @WONo, @WODefScheduleNo, @PartsCrib, @PreferredCribBin, 
				@TaskItemNumber, @SumTaskQuantity, @OvrOrderOption 
			SET @Fetch1Status = @@FETCH_STATUS
        	IF    @Fetch1Status = 0 AND
				(ISNULL(@last_WONo, 0) <> ISNULL(@WONo, 0)
				OR ISNULL(@last_WODefScheduleNo, 0) <> ISNULL(@WODefScheduleNo, 0))
				SET @ReservationChanged = 1
			END
		END
		DEALLOCATE @get_Details
      END
      -- Purge anything that wasn't updated
      DELETE FROM RESERVATION
            WHERE RESERVATIONTYPE = 2  
			AND RESERVATIONSTATUS <> 3 AND 
			DATEREQUIRED < @hold_RUNDATE;
      DELETE FROM RESERVATIONDETAIL
            WHERE NOT EXISTS(
                         SELECT *
                           FROM RESERVATION
                          WHERE RESERVATION.RESERVATIONNO =
                                                           RESERVATIONDETAIL.RESERVATIONNO);
	  UPDATE WO SET RESERVATIONNO = NULL WHERE RESERVATIONNO IS NOT NULL AND NOT EXISTS
	     (SELECT * FROM RESERVATION WHERE RESERVATION.RESERVATIONNO = WO.RESERVATIONNO)
	return (0)
GO
/****** Object:  StoredProcedure [dbo].[GenerateDashboardSummaries]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GenerateDashboardSummaries]
AS
BEGIN
TRUNCATE TABLE XTransDay
INSERT INTO XTransDay
SELECT            DATEADD(dd, DATEDIFF(dd, 0, TRANS.Transdate), 0) AS TransMonth,
                  SiteID,
                  TRANS.Item,
                  Max(Description1) AS 'Item Description',
                  TypeDescription,
                  ItemClass,
                  INVENTRY.ItemType,
                  ItemTypeDesc,
                  SUM(ISNULL(Cost,0)) AS 'Sum Cost',
                  SUM(ISNULL(TRANS.Quantity,0)) AS 'Sum Qty',
                  COUNT(distinct TRANS.Item) as 'Distinct Item Count',
                  COUNT(TRANS.item) AS 'Item Count',
                  STATION.Consignment,
                  TRANS.Crib
FROM        TRANS (nolock)
INNER JOIN  INVENTRY (nolock) ON TRANS.Item = INVENTRY.ItemNumber
INNER JOIN	ItemType (nolock) ON INVENTRY.ItemType = ItemType.ItemType
INNER JOIN  Crib (nolock) ON TRANS.Crib = Crib.Crib
INNER JOIN	STATION (nolock) ON STATION.Cribbin = TRANS.cribbin
WHERE		UsageType = 1
GROUP BY    DATEADD(dd, DATEDIFF(dd, 0, TRANS.Transdate), 0), SiteID, TRANS.Item, ItemClass, INVENTRY.ItemType, ItemTypeDesc, TypeDescription, STATION.Consignment, TRANS.Crib

TRUNCATE TABLE XTransMonth
INSERT INTO XTransMonth
SELECT            DATEADD(m, DATEDIFF(m, 0, Transdate), 0) AS TransMonth,
                  SiteID,
                  Item,
                  Max(Description1) AS 'Item Description',
                  TypeDescription,
                  ItemClass,
                  ItemType,
                  ItemTypeDesc,
                  SUM(ISNULL(CostSum,0)) AS 'Sum Cost',
                  SUM(ISNULL(QtySum,0)) AS 'Sum Qty',
                  SUM(DistinctItemCount),
                  SUM(ItemCount),
                  Consignment,
                  Crib
FROM        XTransDay
GROUP BY    DATEADD(m, DATEDIFF(m, 0, Transdate), 0), SiteID, Item, ItemClass, ItemType, ItemTypeDesc, TypeDescription, Consignment, Crib

TRUNCATE TABLE XEmployeeDay
INSERT INTO XEmployeeDay
SELECT            DATEADD(dd, DATEDIFF(dd, 0, TRANS.Transdate), 0) AS TransMonth,
                  SiteID,
                  EMPLOYEE.ID,
                  Max(EMPLOYEE.Name),
                  ItemNumber,
                  Max(Description1) AS 'Item Description',
                  TypeDescription,
                  ItemClass,
                  INVENTRY.ItemType,
                  ItemTypeDesc,
                  SUM(ISNULL(Cost,0)) AS 'Sum Cost',
                  SUM(ISNULL(TRANS.Quantity,0)) AS 'Sum Qty',
                  COUNT(distinct TRANS.Item) as 'Distinct Item Count',
                  COUNT(TRANS.item) AS 'Item Count',
                  STATION.Consignment,
                  TRANS.Crib
FROM        TRANS (nolock)
INNER JOIN  INVENTRY (nolock) ON TRANS.Item = INVENTRY.ItemNumber
INNER JOIN	EMPLOYEE (nolock) ON TRANS.employee = EMPLOYEE.ID
INNER JOIN	ItemType (nolock) ON INVENTRY.ItemType = ItemType.ItemType
INNER JOIN  Crib (nolock) ON TRANS.Crib = Crib.Crib
INNER JOIN	STATION (nolock) ON STATION.Cribbin = TRANS.cribbin
WHERE UsageType = 1
GROUP BY    DATEADD(dd, DATEDIFF(dd, 0, TRANS.Transdate), 0), SiteID, EMPLOYEE.ID, ItemNumber, TRANS.Item, ItemClass, INVENTRY.ItemType, ItemTypeDesc, TypeDescription, STATION.Consignment, TRANS.Crib

TRUNCATE TABLE XEmployeeMonth
INSERT INTO XEmployeeMonth
SELECT            DATEADD(m, DATEDIFF(m, 0, Transdate), 0) AS TransMonth,
                  SiteID,
                  EmployeeID,
                  Max(EmployeeName),
                  Item,
                  Max(Description1) AS 'Item Description',
                  TypeDescription,
                  ItemClass,
                  ItemType,
                  ItemTypeDesc,
                  SUM(ISNULL(CostSum,0)),
                  SUM(ISNULL(QtySum,0)),
                  SUM(DistinctItemCount),
                  SUM(ItemCount),
                  Consignment,
                  Crib
FROM        XEmployeeDay (nolock)
GROUP BY    DATEADD(m, DATEDIFF(m, 0, Transdate), 0), SiteID, EmployeeID, EmployeeName, Item, ItemClass, ItemType, ItemTypeDesc, TypeDescription, Consignment, Crib

TRUNCATE TABLE XUDFDay
-- User1
INSERT INTO XUDFDay
SELECT            DATEADD(dd, DATEDIFF(dd, 0, TRANS.Transdate), 0) AS TransMonth,
                  SiteID,
                  'User1',
                  TRANS.User1,
                  ItemNumber,
                  Max(Description1) AS 'Item Description',
                  TypeDescription,
                  ItemClass,
                  INVENTRY.ItemType,
                  ItemTypeDesc,
                  SUM(ISNULL(Cost,0)) AS 'Sum Cost',
                  SUM(ISNULL(TRANS.Quantity,0)) AS 'Sum Qty',
                  COUNT(distinct TRANS.Item) as 'Distinct Item Count',
                  COUNT(TRANS.item) AS 'Item Count',
                  STATION.Consignment,
                  TRANS.Crib
FROM        TRANS (nolock)
INNER JOIN  INVENTRY (nolock) ON TRANS.Item = INVENTRY.ItemNumber
INNER JOIN	EMPLOYEE (nolock) ON TRANS.employee = EMPLOYEE.ID
INNER JOIN	ItemType (nolock) ON INVENTRY.ItemType = ItemType.ItemType
INNER JOIN  Crib (nolock) ON TRANS.Crib = Crib.Crib
INNER JOIN	STATION (nolock) ON STATION.Cribbin = TRANS.cribbin
WHERE UsageType = 1
GROUP BY    DATEADD(dd, DATEDIFF(dd, 0, TRANS.Transdate), 0), SiteID, TRANS.User1, ItemNumber, TRANS.Item, ItemClass, INVENTRY.ItemType, ItemTypeDesc, TypeDescription, STATION.Consignment, TRANS.Crib

-- User2
INSERT INTO XUDFDay
SELECT            DATEADD(dd, DATEDIFF(dd, 0, TRANS.Transdate), 0) AS TransMonth,
                  SiteID,
                  'User2',
                  TRANS.User2,
                  ItemNumber,
                  Max(Description1) AS 'Item Description',
                  TypeDescription,
                  ItemClass,
                  INVENTRY.ItemType,
                  ItemTypeDesc,
                  SUM(ISNULL(Cost,0)) AS 'Sum Cost',
                  SUM(ISNULL(TRANS.Quantity,0)) AS 'Sum Qty',
                  COUNT(distinct TRANS.Item) as 'Distinct Item Count',
                  COUNT(TRANS.item) AS 'Item Count',
                  STATION.Consignment,
                  TRANS.Crib
FROM        TRANS (nolock)
INNER JOIN  INVENTRY (nolock) ON TRANS.Item = INVENTRY.ItemNumber
INNER JOIN	EMPLOYEE (nolock) ON TRANS.employee = EMPLOYEE.ID
INNER JOIN	ItemType (nolock) ON INVENTRY.ItemType = ItemType.ItemType
INNER JOIN  Crib (nolock) ON TRANS.Crib = Crib.Crib
INNER JOIN	STATION (nolock) ON STATION.Cribbin = TRANS.cribbin
WHERE UsageType = 1
GROUP BY    DATEADD(dd, DATEDIFF(dd, 0, TRANS.Transdate), 0), SiteID, TRANS.User2, ItemNumber, TRANS.Item, ItemClass, INVENTRY.ItemType, ItemTypeDesc, TypeDescription, STATION.Consignment, TRANS.Crib

-- User3
INSERT INTO XUDFDay
SELECT            DATEADD(dd, DATEDIFF(dd, 0, TRANS.Transdate), 0) AS TransMonth,
                  SiteID,
                  'User3',
                  TRANS.User3,
                  ItemNumber,
                  Max(Description1) AS 'Item Description',
                  TypeDescription,
                  ItemClass,
                  INVENTRY.ItemType,
                  ItemTypeDesc,
                  SUM(ISNULL(Cost,0)) AS 'Sum Cost',
                  SUM(ISNULL(TRANS.Quantity,0)) AS 'Sum Qty',
                  COUNT(distinct TRANS.Item) as 'Distinct Item Count',
                  COUNT(TRANS.item) AS 'Item Count',
                  STATION.Consignment,
                  TRANS.Crib
FROM        TRANS (nolock)
INNER JOIN  INVENTRY (nolock) ON TRANS.Item = INVENTRY.ItemNumber
INNER JOIN	EMPLOYEE (nolock) ON TRANS.employee = EMPLOYEE.ID
INNER JOIN	ItemType (nolock) ON INVENTRY.ItemType = ItemType.ItemType
INNER JOIN  Crib (nolock) ON TRANS.Crib = Crib.Crib
INNER JOIN	STATION (nolock) ON STATION.Cribbin = TRANS.cribbin
WHERE UsageType = 1
GROUP BY    DATEADD(dd, DATEDIFF(dd, 0, TRANS.Transdate), 0), SiteID, TRANS.User3, ItemNumber, Description1, TRANS.Item, ItemClass, INVENTRY.ItemType, ItemTypeDesc, TypeDescription, STATION.Consignment, TRANS.Crib

-- User4
INSERT INTO XUDFDay
SELECT            DATEADD(dd, DATEDIFF(dd, 0, TRANS.Transdate), 0) AS TransMonth,
                  SiteID,
                  'User4',
                  TRANS.User4,
                  ItemNumber,
                  Max(Description1) AS 'Item Description',
                  TypeDescription,
                  ItemClass,
                  INVENTRY.ItemType,
                  ItemTypeDesc,
                  SUM(ISNULL(Cost,0)) AS 'Sum Cost',
                  SUM(ISNULL(TRANS.Quantity,0)) AS 'Sum Qty',
                  COUNT(distinct TRANS.Item) as 'Distinct Item Count',
                  COUNT(TRANS.item) AS 'Item Count',
                  STATION.Consignment,
                  TRANS.Crib
FROM        TRANS (nolock)
INNER JOIN  INVENTRY (nolock) ON TRANS.Item = INVENTRY.ItemNumber
INNER JOIN	EMPLOYEE (nolock) ON TRANS.employee = EMPLOYEE.ID
INNER JOIN	ItemType (nolock) ON INVENTRY.ItemType = ItemType.ItemType
INNER JOIN  Crib (nolock) ON TRANS.Crib = Crib.Crib
INNER JOIN	STATION (nolock) ON STATION.Cribbin = TRANS.cribbin
WHERE UsageType = 1
GROUP BY    DATEADD(dd, DATEDIFF(dd, 0, TRANS.Transdate), 0), SiteID, TRANS.User4, ItemNumber, Description1, TRANS.Item, ItemClass, INVENTRY.ItemType, ItemTypeDesc, TypeDescription, STATION.Consignment, TRANS.Crib

-- User5
INSERT INTO XUDFDay
SELECT            DATEADD(dd, DATEDIFF(dd, 0, TRANS.Transdate), 0) AS TransMonth,
                  SiteID,
                  'User5',
                  TRANS.User5,
                  ItemNumber,
                  Max(Description1) AS 'Item Description',
                  TypeDescription,
                  ItemClass,
                  INVENTRY.ItemType,
                  ItemTypeDesc,
                  SUM(ISNULL(Cost,0)) AS 'Sum Cost',
                  SUM(ISNULL(TRANS.Quantity,0)) AS 'Sum Qty',
                  COUNT(distinct TRANS.Item) as 'Distinct Item Count',
                  COUNT(TRANS.item) AS 'Item Count',
                  STATION.Consignment,
                  TRANS.Crib
FROM        TRANS (nolock)
INNER JOIN  INVENTRY (nolock) ON TRANS.Item = INVENTRY.ItemNumber
INNER JOIN	EMPLOYEE (nolock) ON TRANS.employee = EMPLOYEE.ID
INNER JOIN	ItemType (nolock) ON INVENTRY.ItemType = ItemType.ItemType
INNER JOIN  Crib (nolock) ON TRANS.Crib = Crib.Crib
INNER JOIN	STATION (nolock) ON STATION.Cribbin = TRANS.cribbin
WHERE UsageType = 1
GROUP BY    DATEADD(dd, DATEDIFF(dd, 0, TRANS.Transdate), 0), SiteID, TRANS.User5, ItemNumber, Description1, TRANS.Item, ItemClass, INVENTRY.ItemType, ItemTypeDesc, TypeDescription, STATION.Consignment, TRANS.Crib

-- User6
INSERT INTO XUDFDay
SELECT            DATEADD(dd, DATEDIFF(dd, 0, TRANS.Transdate), 0) AS TransMonth,
                  SiteID,
                  'User6',
                  TRANS.User6,
                  ItemNumber,
                  Max(Description1) AS 'Item Description',
                  TypeDescription,
                  ItemClass,
                  INVENTRY.ItemType,
                  ItemTypeDesc,
                  SUM(ISNULL(Cost,0)) AS 'Sum Cost',
                  SUM(ISNULL(TRANS.Quantity,0)) AS 'Sum Qty',
                  COUNT(distinct TRANS.Item) as 'Distinct Item Count',
                  COUNT(TRANS.item) AS 'Item Count',
                  STATION.Consignment,
                  TRANS.Crib
FROM        TRANS (nolock)
INNER JOIN  INVENTRY (nolock) ON TRANS.Item = INVENTRY.ItemNumber
INNER JOIN	EMPLOYEE (nolock) ON TRANS.employee = EMPLOYEE.ID
INNER JOIN	ItemType (nolock) ON INVENTRY.ItemType = ItemType.ItemType
INNER JOIN  Crib (nolock) ON TRANS.Crib = Crib.Crib
INNER JOIN	STATION (nolock) ON STATION.Cribbin = TRANS.cribbin
WHERE UsageType = 1
GROUP BY    DATEADD(dd, DATEDIFF(dd, 0, TRANS.Transdate), 0), SiteID, TRANS.User6, ItemNumber, TRANS.Item, Description1, ItemClass, INVENTRY.ItemType, ItemTypeDesc, TypeDescription, STATION.Consignment, TRANS.Crib

TRUNCATE TABLE XUDFMonth
INSERT INTO XUDFMonth
SELECT            DATEADD(m, DATEDIFF(m, 0, Transdate), 0) AS TransMonth,
                  SiteID,
                  UserField,
                  UDFValue,
                  Item,
                  Description1,
                  TypeDescription,
                  ItemClass,
                  ItemType,
                  ItemTypeDesc,
                  SUM(ISNULL(CostSum,0)),
                  SUM(ISNULL(QtySum,0)),
                  SUM(DistinctItemCount),
                  SUM(ItemCount),
                  Consignment,
                  Crib
FROM        XUDFDay (nolock)
GROUP BY    DATEADD(m, DATEDIFF(m, 0, Transdate), 0),
			SiteID,
			UserField,
			UDFValue,
			Item,
			Description1,
			ItemClass,
			ItemType,
			ItemTypeDesc,
			TypeDescription,
			Consignment, Crib
END

GO
/****** Object:  StoredProcedure [dbo].[InactiveNewDetail]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InactiveNewDetail] 
AS
BEGIN

 select *
from
(
select lv3.Crib,lv3.bin as Bin,lv3.ItemNumber,lv3.description1 as Description, lv3.ItemClass, lv3.BinQuantity,
 lv3.quantity,lv3.cost as Cost, lv3.BinQuantity*lv3.cost as TotalCost,lv3.InactiveItem,lv3.VendorNumber,vendor.VendorName,lv3.DefaultBuyerGroupID
from
(
select lv2.Crib,lv2.bin,lv2.ItemNumber,lv2.description1, lv2.ItemClass, lv2.BinQuantity,
lv2.quantity,altvendor.cost,lv2.InactiveItem,altvendor.VendorNumber,lv2.DefaultBuyerGroupID
from   
(
select lv1.bin,lv1.ItemNumber,lv1.description1, lv1.ItemClass, lv1.BinQuantity,lv1.quantity,
lv1.InactiveItem,lv1.Crib,lv1.AltVendorNo,itemclass.DefaultBuyerGroupID
from 
(
select station.bin,inventry.itemnumber, inventry.description1, station.quantity, inventry.ItemClass, 
station.BinQuantity,inventry.InactiveItem,station.Crib,inventry.AltVendorNo 
	from STATION left outer JOIN INVENTRY 
	ON STATION.Item=INVENTRY.ItemNumber
) as lv1 left outer join itemclass 
on lv1.itemclass = itemclass.itemclass
) as lv2 left outer join altvendor
on lv2.AltVendorNo = altvendor.RecNumber
) as lv3 left outer join vendor
on lv3.VendorNumber = vendor.VendorNumber
where cost is not null
) as lv4
where InactiveItem=1 AND
((DefaultBuyerGroupID='INVENTORY') OR
((DefaultBuyerGroupID='CER/EXPENSE') AND
((ItemClass='COLLET CHUCK') OR (ItemClass='END MILL HOLDER') OR (ItemClass='FACE MILL')
  OR (ItemClass='HOLDER') OR (ItemClass='HYDRAULIC CHUCK') OR (ItemClass='MILLING CHUCK')
  OR (ItemClass='SHELL MILL HLDR')))) 	
order by itemclass
end

GO
/****** Object:  StoredProcedure [dbo].[InactiveNewDetailRev1]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InactiveNewDetailRev1] 
AS
BEGIN

 select *
from
(
select lv3.Crib,lv3.bin as Bin,lv3.DateLastIssue,lv3.ItemNumber,lv3.description1 as Description, lv3.ItemClass, lv3.BinQuantity,
 lv3.quantity,lv3.cost as Cost, lv3.BinQuantity*lv3.cost as TotalCost,lv3.InactiveItem,lv3.VendorNumber,vendor.VendorName,lv3.DefaultBuyerGroupID
from
(
select lv2.Crib,lv2.bin,lv2.DateLastIssue,lv2.ItemNumber,lv2.description1, lv2.ItemClass, lv2.BinQuantity,
lv2.quantity,altvendor.cost,lv2.InactiveItem,altvendor.VendorNumber,lv2.DefaultBuyerGroupID
from   
(
select lv1.bin,lv1.DateLastIssue,lv1.ItemNumber,lv1.description1, lv1.ItemClass, lv1.BinQuantity,lv1.quantity,
lv1.InactiveItem,lv1.Crib,lv1.AltVendorNo,itemclass.DefaultBuyerGroupID
from 
(
	select station.bin,station.DateLastIssue,inventry.itemnumber, inventry.description1, station.quantity, inventry.ItemClass, 
	station.BinQuantity,inventry.InactiveItem,station.Crib,inventry.AltVendorNo 
	from STATION left outer JOIN INVENTRY 
	ON STATION.Item=INVENTRY.ItemNumber
) as lv1 left outer join itemclass 
on lv1.itemclass = itemclass.itemclass
) as lv2 left outer join altvendor
on lv2.AltVendorNo = altvendor.RecNumber
) as lv3 left outer join vendor
on lv3.VendorNumber = vendor.VendorNumber
where cost is not null
) as lv4
where InactiveItem=1 AND
((DefaultBuyerGroupID='INVENTORY') OR
((DefaultBuyerGroupID='CER/EXPENSE') AND
((ItemClass='COLLET CHUCK') OR (ItemClass='END MILL HOLDER') OR (ItemClass='FACE MILL')
  OR (ItemClass='HOLDER') OR (ItemClass='HYDRAULIC CHUCK') OR (ItemClass='MILLING CHUCK')
  OR (ItemClass='SHELL MILL HLDR')))) 	
order by itemclass
end
GO
/****** Object:  StoredProcedure [dbo].[InactiveUsedDetail]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InactiveUsedDetail] 
AS
BEGIN
select *
from
(
select lv3.Crib,lv3.bin as Bin,lv3.ItemNumber,lv3.description1 as Description, lv3.ItemClass, lv3.BinQuantity,
 lv3.quantity,lv3.cost as Cost, lv3.BinQuantity*lv3.cost as TotalCost,lv3.InactiveItem,lv3.VendorNumber,vendor.VendorName,lv3.DefaultBuyerGroupID
from
(
select lv2.Crib,lv2.bin,lv2.ItemNumber,lv2.description1, lv2.ItemClass, lv2.BinQuantity,
lv2.quantity,altvendor.cost,lv2.InactiveItem,altvendor.VendorNumber,lv2.DefaultBuyerGroupID
from   
(
select lv1.bin,lv1.ItemNumber,lv1.description1, lv1.ItemClass, lv1.BinQuantity,lv1.quantity,
lv1.InactiveItem,lv1.Crib,lv1.AltVendorNo,itemclass.DefaultBuyerGroupID
from 
(
select station.bin,inventry.itemnumber, inventry.description1, station.quantity, inventry.ItemClass, 
station.BinQuantity,inventry.InactiveItem,station.Crib,inventry.AltVendorNo 
	from STATION left outer JOIN INVENTRY 
	ON STATION.Item=INVENTRY.ItemNumber
) as lv1 left outer join itemclass 
on lv1.itemclass = itemclass.itemclass
) as lv2 left outer join altvendor
on lv2.AltVendorNo = altvendor.RecNumber
) as lv3 left outer join vendor
on lv3.VendorNumber = vendor.VendorNumber
where cost is not null 
) as lv4
where InactiveItem=1 AND
((DefaultBuyerGroupID='CER/EXPENSE') AND NOT
((ItemClass='SHELL MILL HLDR') OR (ItemClass='MILLING CHUCK') OR (ItemClass='HYDRAULIC CHUCK')
  OR (ItemClass='HOLDER') OR (ItemClass='FACE MILL') OR (ItemClass='END MILL HOLDER')
  OR (ItemClass='COLLET CHUCK'))) 	
order by itemclass
end

GO
/****** Object:  StoredProcedure [dbo].[InactiveUsedDetailRev1]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InactiveUsedDetailRev1] 
AS
BEGIN
select *
from
(
select lv3.Crib,lv3.bin as Bin,lv3.DateLastIssue,lv3.ItemNumber,lv3.description1 as Description, lv3.ItemClass, lv3.BinQuantity,
 lv3.quantity,lv3.cost as Cost, lv3.BinQuantity*lv3.cost as TotalCost,lv3.InactiveItem,lv3.VendorNumber,vendor.VendorName,lv3.DefaultBuyerGroupID
from
(
select lv2.Crib,lv2.bin,lv2.DateLastIssue,lv2.ItemNumber,lv2.description1, lv2.ItemClass, lv2.BinQuantity,
lv2.quantity,altvendor.cost,lv2.InactiveItem,altvendor.VendorNumber,lv2.DefaultBuyerGroupID
from   
(
select lv1.bin,lv1.DateLastIssue,lv1.ItemNumber,lv1.description1, lv1.ItemClass, lv1.BinQuantity,lv1.quantity,
lv1.InactiveItem,lv1.Crib,lv1.AltVendorNo,itemclass.DefaultBuyerGroupID
from 
(
select station.bin,station.DateLastIssue,inventry.itemnumber, inventry.description1, station.quantity, inventry.ItemClass, 
station.BinQuantity,inventry.InactiveItem,station.Crib,inventry.AltVendorNo 
	from STATION left outer JOIN INVENTRY 
	ON STATION.Item=INVENTRY.ItemNumber
) as lv1 left outer join itemclass 
on lv1.itemclass = itemclass.itemclass
) as lv2 left outer join altvendor
on lv2.AltVendorNo = altvendor.RecNumber
) as lv3 left outer join vendor
on lv3.VendorNumber = vendor.VendorNumber
where cost is not null 
) as lv4
where InactiveItem=1 AND
((DefaultBuyerGroupID='CER/EXPENSE') AND NOT
((ItemClass='SHELL MILL HLDR') OR (ItemClass='MILLING CHUCK') OR (ItemClass='HYDRAULIC CHUCK')
  OR (ItemClass='HOLDER') OR (ItemClass='FACE MILL') OR (ItemClass='END MILL HOLDER')
  OR (ItemClass='COLLET CHUCK'))) 	
order by itemclass
end
GO
/****** Object:  StoredProcedure [dbo].[InvAdj]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* detail report of changes to inventory during the cycle count */
CREATE PROCEDURE [dbo].[InvAdj] 
AS
BEGIN

SELECT 
      [station]
      ,[bin]
      ,[Item]
      ,[cost]
      ,[quantity]
      ,[Transdate]
      ,[binqty]
      ,[CribBin]
      ,[Crib]
  FROM [dbo].[TRANS]
  where Transdate > '2015-11-21 00:00:00'
  and TypeDescription in ('COUNT','ADJUS')
  and quantity < 0
  order by cost
end

GO
/****** Object:  StoredProcedure [dbo].[OrderBelowMin]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 Create Procedure [dbo].[OrderBelowMin]
 as
	 --begin lv 2
	  select  
	 VendorName,Description1,Description2,
	 NeedQuantity, (BinQuantity + RwkBinQuantity) as OnHandQuantity, Cost,
	 ItemNumber,CribBin,BinQuantity,
	 ReworkedItemNumber,RwkCribBin,RwkBinQuantity
	 from
	 (
	 --begin lv 1
	 select Vendor.VendorName,PendingOrder.Description1,PendingOrder.Description2,
	 PendingOrder.NeedQuantity, PendingOrder.Cost,
	 PendingOrder.ItemNumber,PendingOrder.CribBin,Station.BinQuantity,
	 Inventry.ReworkedItemNumber,ReworkStn.CribBin as RwkCribBin,ReworkStn.BinQuantity as RwkBinQuantity
	 from PendingOrder 
	 LEFT OUTER JOIN Inventry 
	 ON PendingOrder.ItemNumber=Inventry.ItemNumber
	 INNER JOIN Station 
	 ON PendingOrder.CribBin=Station.CribBin
	 LEFT OUTER JOIN Station as ReworkStn
	 ON Inventry.ReworkedItemNumber=ReworkStn.Item
	 INNER JOIN Vendor 
	 ON PendingOrder.VendorNumber=Vendor.VendorNumber
	 WHERE  PendingOrder.Crib=1
	 ) as lv1
	where (BinQuantity + RwkBinQuantity) < NeedQuantity
 ORDER BY VendorName, Description1

GO
/****** Object:  StoredProcedure [dbo].[sp_removeindexes]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[sp_removeindexes]
	@TableName varchar(255),		-- the table to check for indexes
	@bPrintOnly int=0
as
	-- Remove primary key constraint and all indexes from the specified table. Code to enumerate 
	-- index names borrowed from sp_helpindex system procedure. 
	-- @bPrintOnly can be used to print the commands, but may display an extra command to drop
	-- the primary key index since it is not actually removed by the print statement
	
	-- PRELIM
	set nocount on
	set xact_abort on
	declare @objid int,			-- the object id of the table
			@indid smallint,	-- the index id of an index
			@indname sysname,
			@status int,
			@dbname	sysname,
			@keyconstraintname sysname
	DECLARE @SQLCommand VARCHAR(500)
	-- Check to see that the object names are local to the current database.
	select @dbname = parsename(@TableName,3)
	if @dbname is not null and @dbname <> db_name()
	begin
			raiserror(15250,-1,-1)
			return (1)
	end
	-- Check to see the the table exists and initialize @objid.
	select @objid = object_id(@TableName)
	if @objid is NULL
	begin
		select @dbname=db_name()
		raiserror(15009,-1,-1,@TableName,@dbname)
		return (1)
	end
	-- Retrieve the primary key constraint name
	select @keyconstraintname = constraint_name from information_schema.table_constraints 
		where table_name = @TableName
	BEGIN TRAN -- Not a bad idea...
	-- Drop the primary key constraint if one was found. This also drops the corresponding index
	if @keyconstraintname is not null
		begin
		-- Generate drop constraint command
		SET @SQLCommand = 'ALTER TABLE ' + @TableName + ' DROP CONSTRAINT ' +  @keyconstraintname
		-- Print or execute
		if @bPrintOnly=1
			BEGIN
			PRINT (@SQLCommand) 
			PRINT 'GO'
			END
		ELSE
			EXEC (@SQLCommand)
		end
	-- OPEN CURSOR OVER INDEXES 
	declare ms_crs_ind cursor local static for
		select indid, name, status from sysindexes
			where id = @objid and indid > 0 and indid < 255 and (status & 64)=0 order by indid
	open ms_crs_ind
	fetch ms_crs_ind into @indid, @indname, @status
	-- IF NO INDEX, QUIT
	if @@fetch_status < 0
	begin
		deallocate ms_crs_ind
		COMMIT TRAN
		return (0)
	end
	while @@fetch_status >= 0
	begin
		-- Generate drop index command
		SET @SQLCommand = 'DROP INDEX ' + @TableName + '.' + @IndName 
		-- Print or execute
		if @bPrintOnly=1
			BEGIN
			PRINT (@SQLCommand) 
			PRINT 'GO'
			END
		ELSE
			EXEC (@SQLCommand)
		-- Next index
		fetch ms_crs_ind into @indid, @indname, @status
	end
	deallocate ms_crs_ind
	COMMIT TRAN -- Commit the changes
	return (0) -- sp_removeindexes
GO
/****** Object:  UserDefinedFunction [dbo].[AdjustQuantityForLeadTime]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    FUNCTION [dbo].[AdjustQuantityForLeadTime]
   (@Quantity int, @Interval int, @IntervalType int, @LeadTime int, @Active int)
RETURNS int
AS
BEGIN
   DECLARE @EffectiveQuantity int
   DECLARE @EffectiveInterval int
   SET @EffectiveInterval = ISNULL(dbo.ComputeWOScheduleInterval(@Interval, @IntervalType), 0)
   IF @EffectiveInterval > 0 AND ISNULL(@LeadTime, 0) > @EffectiveInterval
      SET @EffectiveQuantity = @Quantity * CEILING(cast(@LeadTime as float) / @EffectiveInterval)
   ELSE 
      SET @EffectiveQuantity = @Quantity
   IF @Active = 1
      SET @EffectiveQuantity = @EffectiveQuantity - @Quantity
   return @EffectiveQuantity
END
GO
/****** Object:  UserDefinedFunction [dbo].[bfCurrentPO]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[bfCurrentPO] 
(
) 
RETURNS char(6) 
AS
BEGIN
	Declare @retVal as char(6);
	select @retVal=fcurrentpo from btvars
	RETURN @RetVal
end

GO
/****** Object:  UserDefinedFunction [dbo].[ComputeWOScheduleInterval]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[ComputeWOScheduleInterval]
   (@Interval int, @IntervalType int)
RETURNS int
AS
BEGIN
   return CASE @IntervalType
		WHEN 0 THEN @Interval
		WHEN 1 THEN @Interval * 7 
		WHEN 2 THEN @Interval * 30
		WHEN 3 THEN @Interval * 365
		WHEN 4 THEN @Interval * 15
	ELSE NULL
   END
END
GO
/****** Object:  Table [dbo].[ACCESSCODE]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ACCESSCODE](
	[AccessCode] [varchar](1) NOT NULL,
	[AccessCodeDescription] [varchar](50) NULL,
 CONSTRAINT [ACCESSCODE_PK] PRIMARY KEY CLUSTERED 
(
	[AccessCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ActionCode]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ActionCode](
	[ActionCode] [varchar](4) NOT NULL,
	[ActionCodeDescription] [varchar](50) NULL,
	[IssueOption] [tinyint] NULL,
	[OvrOrderOption] [tinyint] NULL,
 CONSTRAINT [PK_ACTIONCODE] PRIMARY KEY CLUSTERED 
(
	[ActionCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AltVendor]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AltVendor](
	[RecNumber] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ItemNumber] [varchar](12) NOT NULL,
	[VendorNumber] [varchar](12) NOT NULL,
	[Comments] [varchar](50) NULL,
	[VendorItemNumber] [varchar](30) NULL,
	[MinOrder] [int] NULL,
	[CaseSize] [int] NULL,
	[PriceExpiration] [datetime] NULL,
	[Cost] [decimal](19, 4) NULL,
	[BreakQuantity1] [int] NULL,
	[Cost1] [decimal](19, 4) NULL,
	[BreakQuantity2] [int] NULL,
	[Cost2] [decimal](19, 4) NULL,
	[BreakQuantity3] [int] NULL,
	[Cost3] [decimal](19, 4) NULL,
	[BreakQuantity4] [int] NULL,
	[Cost4] [decimal](19, 4) NULL,
	[BreakQuantity5] [int] NULL,
	[Cost5] [decimal](19, 4) NULL,
	[BreakQuantity6] [int] NULL,
	[Cost6] [decimal](19, 4) NULL,
	[SalesTaxable] [smallint] NULL,
	[AutoPurchase] [smallint] NULL,
	[DistCost] [decimal](19, 4) NULL,
	[UnitOfMeasure] [varchar](10) NULL,
	[AltVendor_AddDate] [datetime] NULL,
	[AltVendor_AddUID] [varchar](12) NULL,
	[AltVendor_UpdateDate] [datetime] NULL,
	[AltVendor_UpdateUID] [varchar](12) NULL,
	[BlanketPONo] [int] NULL,
	[AllowAsSubstitute] [tinyint] NULL,
 CONSTRAINT [ALTVENDOR_PK] PRIMARY KEY CLUSTERED 
(
	[RecNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ASN]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ASN](
	[ASNID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[PONumber] [int] NULL,
	[ImportDate] [datetime] NULL,
	[FileName] [varchar](128) NULL,
	[RecordType] [tinyint] NULL,
	[BoxCount] [int] NULL,
	[Comments] [varchar](255) NULL,
	[DateShipped] [datetime] NULL,
	[ShipmentNumber] [int] NULL,
	[PackingListNumber] [int] NULL,
 CONSTRAINT [ASN_PK] PRIMARY KEY CLUSTERED 
(
	[ASNID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ASNDETAIL]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ASNDETAIL](
	[ASNDetailID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ASNID] [int] NOT NULL,
	[PODOriginalSeqNo] [int] NULL,
	[Quantity] [int] NULL,
	[RecdQuantity] [int] NULL,
	[UnitCost] [decimal](19, 4) NULL,
	[ResponseStatus] [varchar](10) NULL,
	[CurrentStatus] [tinyint] NULL,
	[ProcessedDate] [datetime] NULL,
	[ScanCode] [varchar](128) NULL,
	[Comments] [varchar](255) NULL,
	[ShipmentNumber] [int] NULL,
 CONSTRAINT [ASNDETAIL_PK] PRIMARY KEY CLUSTERED 
(
	[ASNDetailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Asset]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Asset](
	[AssetNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[AssetID] [varchar](18) NULL,
	[AssetTypeNo] [smallint] NULL,
	[AssetDescription] [varchar](50) NULL,
	[AssetLocation] [varchar](50) NULL,
	[AssetUser1] [varchar](12) NULL,
	[AssetUser2] [varchar](12) NULL,
	[AssetUser3] [varchar](12) NULL,
	[AssetUser4] [varchar](12) NULL,
	[AssetUser5] [varchar](12) NULL,
	[AssetUser6] [varchar](12) NULL,
	[AssetModelNumber] [varchar](30) NULL,
	[AssetSerialNumber] [varchar](30) NULL,
	[AssetInactive] [bit] NOT NULL,
	[AssetManufacturer] [varchar](20) NULL,
	[AssetRunUnits] [int] NULL,
	[LockOutTagOut] [varchar](255) NULL,
	[AssetDateInService] [datetime] NULL,
	[AssetWarrantyDate] [datetime] NULL,
	[AssetMaxRunUnits] [int] NULL,
	[AssetMTBF] [decimal](19, 4) NULL,
	[Asset_AddDate] [datetime] NULL,
	[Asset_AddUID] [varchar](12) NULL,
	[Asset_UpdateDate] [datetime] NULL,
	[Asset_UpdateUID] [varchar](12) NULL,
 CONSTRAINT [PK_ASSET] PRIMARY KEY CLUSTERED 
(
	[AssetNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ATRSettings]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ATRSettings](
	[ATRSettingsNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[SettingsTemplateNo] [int] NULL,
	[SiteID] [varchar](12) NULL,
	[Crib] [int] NULL,
	[KeyName] [varchar](40) NOT NULL,
	[Int] [int] NULL,
	[String] [varchar](250) NULL,
	[LockOption] [tinyint] NULL,
 CONSTRAINT [ATRSETTINGS_PK] PRIMARY KEY CLUSTERED 
(
	[ATRSettingsNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AttributeDef]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AttributeDef](
	[AttributeDefNo] [int] NOT NULL,
	[AttributeClassNo] [int] NOT NULL,
	[AttributeName] [nvarchar](50) NOT NULL,
	[AttributeTypeNo] [tinyint] NULL,
	[AttributeIDCode] [nvarchar](50) NULL,
	[AttributeSequence] [tinyint] NULL,
	[AttributeDesc1Code] [nvarchar](50) NULL,
	[AttributeDesc2Code] [nvarchar](50) NULL,
	[ValueIDGenType] [tinyint] NULL,
	[ValueIDLen] [tinyint] NULL,
	[ValueDesc1GenType] [tinyint] NULL,
	[ValueDesc1Len] [tinyint] NULL,
	[ValueDesc2GenType] [tinyint] NULL,
	[ValueDesc2Len] [tinyint] NULL,
	[AttributeComments] [nvarchar](255) NULL,
	[AttributeDefinition] [nvarchar](255) NULL,
	[ValueOptional] [bit] NOT NULL,
	[UseValueList] [bit] NOT NULL,
	[AttributeMinValue] [float] NULL,
	[AttributeMaxValue] [float] NULL,
	[OvrAVLAttributeDefNo] [int] NULL,
	[ATTRIBUTEDEF_AddDate] [smalldatetime] NULL,
	[ATTRIBUTEDEF_AddUID] [nvarchar](12) NULL,
	[ATTRIBUTEDEF_UpdateDate] [smalldatetime] NULL,
	[ATTRIBUTEDEF_UpdateUID] [nvarchar](12) NULL,
	[NonUnique] [bit] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AttributeType]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AttributeType](
	[AttributeTypeNo] [tinyint] NOT NULL,
	[AttributeTypeName] [nvarchar](50) NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AttributeValue]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AttributeValue](
	[AttributeValueNo] [int] NOT NULL,
	[AttributeDefNo] [int] NULL,
	[AttributeCINo] [int] NULL,
	[cValue] [nvarchar](50) NULL,
	[fValue] [float] NULL,
	[OvrFValue] [bit] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AttributeValueList]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AttributeValueList](
	[AttributeValueListNo] [int] NOT NULL,
	[AVLAttributeDefNo] [int] NOT NULL,
	[AVLText] [nvarchar](50) NOT NULL,
	[AVLAbbreviation] [nvarchar](12) NULL,
	[AVLSequence] [int] NULL,
	[AVLFValue] [float] NULL,
	[AVLOvrFValue] [bit] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BarCodeMapping]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BarCodeMapping](
	[BarCodeMappingNo] [int] IDENTITY(1,1) NOT NULL,
	[SourceMask] [varchar](50) NOT NULL,
	[DestinationMask] [varchar](50) NOT NULL,
	[Sequence] [int] NOT NULL,
	[MappingType] [tinyint] NOT NULL,
	[SiteID] [varchar](12) NOT NULL,
 CONSTRAINT [BarCodeMapping_PK] PRIMARY KEY CLUSTERED 
(
	[BarCodeMappingNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BatchLog]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BatchLog](
	[BatchLogNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[BatchDeviceId] [varchar](50) NULL,
	[BatchSequenceNo] [int] NOT NULL,
	[BatchEmployee] [varchar](25) NULL,
	[BatchMode] [varchar](20) NULL,
	[BatchIssuedTo] [varchar](25) NULL,
	[BatchWOID] [varchar](25) NULL,
	[BatchUser1] [varchar](25) NULL,
	[BatchUser2] [varchar](25) NULL,
	[BatchUser3] [varchar](25) NULL,
	[BatchUser4] [varchar](25) NULL,
	[BatchUser5] [varchar](25) NULL,
	[BatchUser6] [varchar](25) NULL,
	[BatchItemQualifier] [varchar](25) NULL,
	[BatchQuantity] [int] NULL,
	[BatchStatusCode] [int] NULL,
	[BatchStatusDate] [datetime] NULL,
	[BatchTransDate] [datetime] NULL,
	[BatchPONumber] [int] NULL,
	[BatchLogMsg] [varchar](128) NULL,
	[BatchLogBatchId] [int] NULL,
	[BatchCrib] [smallint] NULL,
	[BatchReasonCode] [varchar](12) NULL,
	[BatchTransferID] [varchar](12) NULL,
	[BatchHomeCrib] [smallint] NULL,
	[BatchRFIDTransNo] [int] NULL,
	[BatchRFIDNo] [int] NULL,
 CONSTRAINT [BATCHLOG_PK] PRIMARY KEY CLUSTERED 
(
	[BatchLogNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BinaryImage]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BinaryImage](
	[BinaryImageNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ImageSourceType] [int] NULL,
	[RetentionType] [tinyint] NULL,
	[ImageSize] [int] NULL,
	[ImageDataCRC] [int] NULL,
	[FileName] [varchar](255) NULL,
	[FileExt] [varchar](5) NULL,
	[ImageDescription] [varchar](255) NULL,
	[DateCreated] [datetime] NULL,
	[ImageData] [image] NULL,
	[EmployeeID] [varchar](12) NULL,
 CONSTRAINT [PK_BinaryImage] PRIMARY KEY CLUSTERED 
(
	[BinaryImageNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BINFIFO]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BINFIFO](
	[BinFIFOTransNo] [int] NULL,
	[BinFIFOCribBin] [varchar](15) NOT NULL,
	[BinFIFOType] [tinyint] NOT NULL,
	[BinFIFOQuantity] [int] NOT NULL,
	[BinFIFODate] [datetime] NOT NULL,
	[BinFIFOStatus] [tinyint] NOT NULL,
	[BinFIFOCost] [decimal](19, 4) NULL,
	[BinFIFONo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
 CONSTRAINT [BINFIFO_PK] PRIMARY KEY CLUSTERED 
(
	[BinFIFONo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BINFIFOTYPE]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BINFIFOTYPE](
	[BinFIFOType] [tinyint] NOT NULL,
	[BinFIFOTypeDescription] [varchar](20) NULL,
 CONSTRAINT [BINFIFOTYPE_PK] PRIMARY KEY CLUSTERED 
(
	[BinFIFOType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BinLabel]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BinLabel](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[DateOfRun] [datetime] NULL,
	[UniqueLabelRun] [int] NULL,
	[CribBin] [varchar](30) NULL,
	[ItemNumber] [varchar](12) NULL,
	[Description1] [varchar](50) NULL,
	[Description2] [varchar](50) NULL,
	[UPCCode] [varchar](20) NULL,
	[ShortDesc] [varchar](50) NULL,
	[Quantity] [int] NULL,
 CONSTRAINT [BinLabel_PK] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BlanketPO]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BlanketPO](
	[BlanketPONo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[VendorNumber] [varchar](12) NOT NULL,
	[BlanketNumber] [varchar](12) NOT NULL,
	[ExpirationDate] [datetime] NULL,
	[BlanketPOInactive] [bit] NULL DEFAULT (0),
	[BlanketPOSiteID] [varchar](12) NULL,
 CONSTRAINT [BLANKETPONO_PK] PRIMARY KEY CLUSTERED 
(
	[BlanketPONo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[btapvend]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[btapvend](
	[fvendno] [char](6) NOT NULL,
	[fcterms] [char](4) NOT NULL,
	[fccompany] [varchar](35) NOT NULL,
	[fccity] [char](20) NOT NULL,
	[fcstate] [char](20) NOT NULL,
	[fczip] [char](10) NOT NULL,
	[fccountry] [char](25) NOT NULL,
	[fcphone] [char](20) NOT NULL,
	[fcfax] [char](20) NOT NULL,
	[fmstreet] [text] NOT NULL,
	[vendorSelect] [varchar](44) NOT NULL,
	[timestamp_column] [timestamp] NULL,
	[identity_column] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[btCribBinQtyList]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[btCribBinQtyList](
	[lItem] [varchar](12) NULL,
	[lCribBinQtyList] [varchar](max) NULL,
	[rItem] [varchar](12) NULL,
	[rCribBinQtyList] [varchar](max) NULL,
	[CribBinQtyList] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[btCribLocQtyList]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[btCribLocQtyList](
	[albLItem] [varchar](12) NULL,
	[aviLItem] [varchar](12) NULL,
	[itemNumber] [varchar](12) NULL,
	[AlbLocQtyList] [varchar](max) NULL,
	[AviLocQtyList] [varchar](max) NULL,
	[CribLocQtyList] [varchar](max) NULL,
	[TBLocQtyList] [varchar](max) NULL,
	[LocQtyList] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[btDistinctToolLists]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[btDistinctToolLists](
	[OriginalProcessId] [int] NULL,
	[ProcessId] [int] NULL,
	[Customer] [nvarchar](50) NULL,
	[PartFamily] [nvarchar](50) NULL,
	[OperationDescription] [nvarchar](250) NULL,
	[PartNumber] [nvarchar](50) NULL,
	[Description] [nvarchar](356) NULL,
	[CustPartFamily] [nvarchar](103) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[btGRLog]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[btGRLog](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[VerCol] [timestamp] NOT NULL,
	[fStart] [datetime] NOT NULL,
	[fStep] [varchar](50) NOT NULL,
	[rcvStart] [char](6) NULL,
	[rcvEnd] [char](6) NULL,
	[fEnd] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[btGRTrans]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[btGRTrans](
	[podetailId] [int] NOT NULL,
	[freceiver] [char](6) NOT NULL,
	[sessionId] [int] NOT NULL,
	[remove] [varchar](1) NOT NULL,
 CONSTRAINT [UQ_btGRTrans_id] UNIQUE NONCLUSTERED 
(
	[podetailId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[btGRTrans914]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[btGRTrans914](
	[podetailId] [int] NOT NULL,
	[freceiver] [char](6) NOT NULL,
	[sessionId] [int] NOT NULL,
	[remove] [varchar](1) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[btGRTransBak]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[btGRTransBak](
	[podetailId] [int] NOT NULL,
	[freceiver] [char](6) NOT NULL,
	[sessionId] [int] NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[btGRVars]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[btGRVars](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[VerCol] [timestamp] NOT NULL,
	[fLastRun] [datetime] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[btInventry]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[btInventry](
	[ItemNumber] [varchar](12) NOT NULL,
	[Description1] [varchar](50) NULL,
	[Description2] [varchar](50) NULL,
	[Price] [numeric](19, 4) NULL,
	[MonthToDate] [numeric](19, 4) NULL,
	[YearToDate] [numeric](19, 4) NULL,
	[WeekToDate] [numeric](19, 4) NULL,
	[MonthlyRedFlag] [numeric](19, 4) NULL,
	[YearlyRedFlag] [numeric](19, 4) NULL,
	[WeeklyRedFlag] [numeric](19, 4) NULL,
	[LastYear] [numeric](19, 4) NULL,
	[ShortDesc] [varchar](30) NULL,
	[AccessCode] [varchar](2) NULL,
	[VendorNumber] [varchar](12) NULL,
	[ItemType] [smallint] NULL,
	[ItemClass] [varchar](15) NULL,
	[ReworkedItemNumber] [varchar](12) NULL,
	[UPCCode] [varchar](20) NULL,
	[Comments] [varchar](255) NULL,
	[Serialized] [int] NULL,
	[PriceType] [smallint] NULL,
	[Manufacturer] [varchar](50) NULL,
	[MfrNumber] [varchar](30) NULL,
	[DefaultQty] [int] NULL,
	[UseInPlantQuantity] [int] NULL,
	[IncludeReworked] [int] NULL,
	[Special] [varchar](20) NULL,
	[Restricted] [smallint] NULL,
	[ReceiveNewAsRework] [int] NULL,
	[AllowMaintenance] [tinyint] NULL,
	[TrackUsage] [tinyint] NULL,
	[ItemStatusCode] [varchar](4) NULL,
	[CheckOutTimeLimit] [smallint] NULL,
	[AllowOvrTimeLimit] [tinyint] NULL,
	[TrackLotNumber] [bit] NULL,
	[CINo] [int] NULL,
	[ClassNo] [int] NULL,
	[CIRevision] [int] NULL,
	[CINumber] [varchar](12) NULL,
	[LinkCINumber] [bit] NULL,
	[LinkCIDescription1] [bit] NULL,
	[LinkCIDescription2] [bit] NULL,
	[NoInterSiteTransfers] [tinyint] NULL,
	[ItemStockFromCrib] [smallint] NULL,
	[UseCheckList] [tinyint] NULL,
	[BuyerGroupID] [varchar](12) NULL,
	[Inventry_AddDate] [datetime] NULL,
	[Inventry_AddUID] [varchar](12) NULL,
	[Inventry_UpdateDate] [datetime] NULL,
	[Inventry_UpdateUID] [varchar](12) NULL,
	[ItemFODControl] [tinyint] NULL,
	[AltVendorNo] [int] NULL,
	[RequiresInspection] [tinyint] NULL,
	[CertifiedSystem] [smallint] NULL,
	[CriticalItemOption] [tinyint] NULL,
	[Locked] [smallint] NULL,
	[InactiveItem] [bit] NULL,
	[CycleCountClassNo] [int] NULL,
	[IssueUnitOfMeasure] [varchar](30) NULL,
	[AutoScrapOption] [tinyint] NULL,
	[UDFCOATING] [varchar](20) NULL,
	[UDFMINFLUTE] [varchar](20) NULL,
	[UDFGLOBALTOOL] [varchar](20) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[btItemIssued]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[btItemIssued](
	[newItemNumber] [nvarchar](32) NULL,
	[rwkItemNumber] [nvarchar](33) NULL,
	[newIssuedTotQty] [int] NULL,
	[newIssuedTotCost] [numeric](38, 4) NULL,
	[rwkIssuedTotQty] [int] NULL,
	[rwkIssuedTotCost] [numeric](38, 4) NULL,
	[issuedTotQty] [int] NULL,
	[issuedTotCost] [numeric](38, 4) NULL,
	[itemPartIssuedList] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[btItemLastIssued]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[btItemLastIssued](
	[itemNumber] [nvarchar](32) NULL,
	[lastIssued] [smalldatetime] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[btItemPartIssuedList]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[btItemPartIssuedList](
	[itemNumber] [nvarchar](32) NULL,
	[itemPartIssuedList] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[btItemQtyIssuedMonth]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[btItemQtyIssuedMonth](
	[itemNumber] [nvarchar](32) NULL,
	[lQtyIssued] [int] NULL,
	[rQtyIssued] [int] NULL,
	[qtyIssued] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[btLocQtyList]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[btLocQtyList](
	[albLItem] [varchar](12) NULL,
	[aviLItem] [varchar](12) NULL,
	[itemNumber] [varchar](12) NULL,
	[AlbLocQtyList] [varchar](max) NULL,
	[AviLocQtyList] [varchar](max) NULL,
	[CribLocQtyList] [varchar](max) NULL,
	[TB2TotQty] [int] NULL,
	[TB3TotQty] [int] NULL,
	[TB5TotQty] [int] NULL,
	[TB6TotQty] [int] NULL,
	[TB7TotQty] [int] NULL,
	[TB8TotQty] [int] NULL,
	[TB9TotQty] [int] NULL,
	[TB11TotQty] [int] NULL,
	[TB112TotQty] [int] NULL,
	[TBTotQty] [int] NULL,
	[TBLocQtyList] [varchar](max) NULL,
	[CribAndTBLocQtyList] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[btMonthInv]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[btMonthInv](
	[year] [int] NULL,
	[month] [int] NULL,
	[yearMonth] [varchar](20) NULL,
	[litemnumber] [varchar](12) NOT NULL,
	[lInactiveItem] [bit] NOT NULL,
	[lAltVendorNo] [int] NOT NULL,
	[lCost] [decimal](20, 4) NULL,
	[rItemNumber] [varchar](12) NULL,
	[rInactiveItem] [bit] NOT NULL,
	[rAltVendorNo] [int] NOT NULL,
	[rCost] [decimal](20, 4) NULL,
	[lmanufacturer] [varchar](50) NOT NULL,
	[ldescription1] [varchar](50) NOT NULL,
	[litemclass] [varchar](15) NOT NULL,
	[lDefaultBuyerGroupId] [varchar](12) NULL,
	[lVendorNumber] [varchar](12) NOT NULL,
	[lVendorName] [varchar](50) NOT NULL,
	[consumable] [int] NOT NULL,
	[albNewBinQuantity] [int] NULL,
	[albNewCribTotCost] [decimal](31, 4) NULL,
	[albRwkBinQuantity] [int] NULL,
	[albRwkCribTotCost] [decimal](31, 4) NULL,
	[albTotBinQuantity] [int] NULL,
	[albCribTotCost] [decimal](32, 4) NULL,
	[aviNewBinQuantity] [int] NULL,
	[aviNewCribTotCost] [decimal](31, 4) NULL,
	[aviRwkBinQuantity] [int] NULL,
	[aviRwkCribTotCost] [decimal](31, 4) NULL,
	[aviTotBinQuantity] [int] NULL,
	[aviCribTotCost] [decimal](32, 4) NULL,
	[cribNewBinQuantity] [int] NULL,
	[newCribTotCost] [decimal](31, 4) NULL,
	[cribRwkBinQuantity] [int] NULL,
	[rwkCribTotCost] [decimal](31, 4) NULL,
	[cribTotBinQuantity] [int] NULL,
	[cribTotCost] [decimal](32, 4) NULL,
	[TB2TotQty] [int] NULL,
	[TB2TotCost] [decimal](31, 4) NULL,
	[TB3TotQty] [int] NULL,
	[TB3TotCost] [decimal](31, 4) NULL,
	[TB5TotQty] [int] NULL,
	[TB5TotCost] [decimal](31, 4) NULL,
	[TB6TotQty] [int] NULL,
	[TB6TotCost] [decimal](31, 4) NULL,
	[TB7TotQty] [int] NULL,
	[TB7TotCost] [decimal](31, 4) NULL,
	[TB8TotQty] [int] NULL,
	[TB8TotCost] [decimal](31, 4) NULL,
	[TB9TotQty] [int] NULL,
	[TB9TotCost] [decimal](31, 4) NULL,
	[TB11TotQty] [int] NULL,
	[TB11TotCost] [decimal](31, 4) NULL,
	[TB112TotQty] [int] NULL,
	[TB112TotCost] [decimal](31, 4) NULL,
	[TBTotQty] [int] NULL,
	[TBTotCost] [decimal](31, 4) NULL,
	[cribAndTBTotQty] [int] NULL,
	[cribAndTBTotCost] [decimal](33, 4) NULL,
	[OnOrderQty] [int] NULL,
	[OnOrderTotCost] [decimal](31, 4) NULL,
	[newIssuedTotQty] [int] NULL,
	[newIssuedTotCost] [numeric](38, 4) NULL,
	[rwkIssuedTotQty] [int] NULL,
	[rwkIssuedTotCost] [numeric](38, 4) NULL,
	[issuedTotQty] [int] NULL,
	[issuedTotCost] [numeric](38, 4) NULL,
	[itemPartIssuedList] [varchar](max) NULL,
	[orderQty] [int] NULL,
	[orderCost] [decimal](31, 4) NULL,
	[AlbLocQtyList] [varchar](max) NULL,
	[AviLocQtyList] [varchar](max) NULL,
	[CribLocQtyList] [varchar](max) NULL,
	[TBLocQtyList] [varchar](max) NULL,
	[CribAndTBLocQtyList] [varchar](max) NULL,
	[newItemLastIssued] [datetime] NULL,
	[newItemInTransLog] [int] NOT NULL,
	[rwkItemLastIssued] [datetime] NULL,
	[rwkItemInTransLog] [int] NOT NULL,
	[ActiveToolLists] [varchar](max) NULL,
	[ObsToolLists] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[btmonuse]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[btmonuse](
	[ItemNumber] [varchar](12) NOT NULL,
	[MonthlyUsage] [numeric](19, 4) NOT NULL,
	[DailyUsage] [numeric](19, 4) NOT NULL,
	[ToolLists] [varchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[btmprcitem]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[btmprcitem](
	[fitemno] [char](3) NOT NULL,
	[fpartno] [char](25) NOT NULL,
	[fpartrev] [char](3) NOT NULL,
	[finvcost] [dbo].[M2MMoney] NOT NULL,
	[fcategory] [char](8) NOT NULL,
	[fcstatus] [char](1) NOT NULL,
	[fiqtyinv] [numeric](15, 5) NOT NULL,
	[fjokey] [char](10) NOT NULL,
	[fsokey] [char](6) NOT NULL,
	[fsoitem] [char](3) NOT NULL,
	[fsorelsno] [char](3) NOT NULL,
	[fvqtyrecv] [numeric](15, 5) NOT NULL,
	[fqtyrecv] [numeric](15, 5) NOT NULL,
	[freceiver] [char](6) NOT NULL,
	[frelsno] [char](3) NOT NULL,
	[fvendno] [char](6) NOT NULL,
	[fbinno] [char](14) NOT NULL,
	[fexpdate] [datetime] NOT NULL,
	[finspect] [char](1) NOT NULL,
	[finvqty] [numeric](15, 5) NOT NULL,
	[flocation] [char](14) NOT NULL,
	[flot] [char](20) NOT NULL,
	[fmeasure] [char](3) NOT NULL,
	[fpoitemno] [char](3) NOT NULL,
	[fretcredit] [char](1) NOT NULL,
	[ftype] [char](1) NOT NULL,
	[fumvori] [char](1) NOT NULL,
	[fqtyinsp] [numeric](15, 5) NOT NULL,
	[fauthorize] [char](20) NOT NULL,
	[fucost] [dbo].[M2MMoney] NOT NULL,
	[fllotreqd] [bit] NOT NULL,
	[flexpreqd] [bit] NOT NULL,
	[fctojoblot] [char](20) NOT NULL,
	[fdiscount] [numeric](5, 1) NOT NULL,
	[fueurocost] [dbo].[M2MMoney] NOT NULL,
	[futxncost] [dbo].[M2MMoney] NOT NULL,
	[fucostonly] [dbo].[M2MMoney] NOT NULL,
	[futxncston] [dbo].[M2MMoney] NOT NULL,
	[fueurcston] [dbo].[M2MMoney] NOT NULL,
	[flconvovrd] [bit] NOT NULL,
	[timestamp_column] [timestamp] NULL,
	[identity_column] [int] IDENTITY(1,1) NOT NULL,
	[fcomments] [text] NOT NULL,
	[fdescript] [text] NOT NULL,
	[fac] [dbo].[M2MFacility] NOT NULL,
	[sfac] [dbo].[M2MFacility] NOT NULL,
	[FCORIGUM] [char](3) NOT NULL,
	[fcudrev] [char](3) NOT NULL,
	[FNORIGQTY] [numeric](18, 5) NOT NULL,
	[Iso] [char](10) NOT NULL,
	[Ship_Link] [int] NOT NULL,
	[ShsrceLink] [int] NOT NULL,
	[fCINSTRUCT] [char](2) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[btmprcmast]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[btmprcmast](
	[fclandcost] [char](1) NOT NULL,
	[frmano] [char](25) NOT NULL,
	[fporev] [char](2) NOT NULL,
	[fcstatus] [char](1) NOT NULL,
	[fdaterecv] [datetime] NOT NULL,
	[fpono] [char](6) NOT NULL,
	[freceiver] [char](6) NOT NULL,
	[fvendno] [char](6) NOT NULL,
	[faccptby] [char](3) NOT NULL,
	[fbilllad] [char](18) NOT NULL,
	[fcompany] [varchar](35) NOT NULL,
	[ffrtcarr] [char](20) NOT NULL,
	[fpacklist] [char](15) NOT NULL,
	[fretship] [char](1) NOT NULL,
	[fshipwgt] [numeric](11, 2) NOT NULL,
	[ftype] [char](1) NOT NULL,
	[start] [datetime] NOT NULL,
	[fprinted] [bit] NOT NULL,
	[flothrupd] [bit] NOT NULL,
	[fccurid] [char](3) NOT NULL,
	[fcfactor] [dbo].[M2MMoney] NOT NULL,
	[fdcurdate] [datetime] NOT NULL,
	[fdeurodate] [datetime] NOT NULL,
	[feurofctr] [dbo].[M2MMoney] NOT NULL,
	[flpremcv] [bit] NOT NULL,
	[identity_column] [int] IDENTITY(1,1) NOT NULL,
	[timestamp_column] [timestamp] NULL,
	[docstatus] [char](10) NULL,
	[frmacreator] [varchar](25) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[btNeedsOrderedCnt]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[btNeedsOrderedCnt](
	[needsOrderedCnt] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[btobsmonuse]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[btobsmonuse](
	[ItemNumber] [varchar](12) NOT NULL,
	[MonthlyUsage] [numeric](19, 4) NOT NULL,
	[ToolLists] [varchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[btObsToolListItems]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[btObsToolListItems](
	[itemNumber] [nvarchar](50) NULL,
	[opDescList] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[btOpenGenPO]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[btOpenGenPO](
	[fcompany] [varchar](35) NOT NULL,
	[fpono] [char](6) NOT NULL,
	[fstatus] [char](20) NOT NULL,
	[fvendno] [char](6) NOT NULL,
	[fbuyer] [char](3) NOT NULL,
	[fchangeby] [char](25) NOT NULL,
	[forddate] [datetime] NOT NULL,
	[fcngdate] [datetime] NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[btpo]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[btpo](
	[PONumber] [int] IDENTITY(1,1) NOT NULL,
	[PODate] [datetime] NULL,
	[Vendor] [varchar](12) NULL,
	[VendorPO] [varchar](12) NULL,
	[DateRequired] [varchar](15) NULL,
	[Shipping] [varchar](50) NULL,
	[Address1] [varchar](50) NULL,
	[Address2] [varchar](50) NULL,
	[Address3] [varchar](50) NULL,
	[Address4] [varchar](50) NULL,
	[ShipTo1] [varchar](50) NULL,
	[ShipTo2] [varchar](50) NULL,
	[ShipTo3] [varchar](50) NULL,
	[ShipTo4] [varchar](50) NULL,
	[Comments] [varchar](255) NULL,
	[Type] [int] NULL,
	[Phone] [varchar](20) NULL,
	[FaxPhone] [varchar](20) NULL,
	[EdiPhone] [varchar](50) NULL,
	[BlanketPO] [varchar](12) NULL,
	[BillTo1] [varchar](50) NULL,
	[BillTo2] [varchar](50) NULL,
	[BillTo3] [varchar](50) NULL,
	[BillTo4] [varchar](50) NULL,
	[Freight] [decimal](19, 4) NULL,
	[EMailAddress] [varchar](50) NULL,
	[Terms] [varchar](30) NULL,
	[SiteID] [varchar](12) NULL,
	[PrintCount] [smallint] NULL,
	[POStatusNo] [tinyint] NULL,
	[POStatusDate] [datetime] NULL,
	[PORequestorID] [varchar](12) NULL,
	[POApproverID] [varchar](12) NULL,
	[SalesTaxPercent] [decimal](19, 4) NULL,
	[PoCreatedByID] [varchar](12) NULL,
	[PO_AddDate] [datetime] NULL,
	[PO_AddUID] [varchar](12) NULL,
	[PO_UpdateDate] [datetime] NULL,
	[PO_UpdateUID] [varchar](12) NULL,
	[AccountNumber] [varchar](30) NULL,
	[DeliverTo] [varchar](30) NULL,
	[POBuyerID] [varchar](12) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[btPODetail]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[btPODetail](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[PONumber] [int] NULL,
	[Item] [varchar](12) NULL,
	[Quantity] [smallint] NULL,
	[Received] [datetime] NULL,
	[ReceivedTime] [varchar](11) NULL,
	[CribBin] [varchar](15) NULL,
	[VendorNumber] [varchar](12) NULL,
	[ItemDescription] [varchar](50) NULL,
	[Crib] [smallint] NULL,
	[DateOrdered] [datetime] NULL,
	[UPCCode] [varchar](20) NULL,
	[Cost] [decimal](19, 4) NULL,
	[Type] [int] NULL,
	[BlanketPO] [varchar](12) NULL,
	[VendorItemNumber] [varchar](30) NULL,
	[SalesTaxable] [smallint] NULL,
	[VendorPONumber] [varchar](16) NULL,
	[Description2] [varchar](50) NULL,
	[Special] [varchar](20) NULL,
	[Comments] [varchar](50) NULL,
	[PromisedDate] [datetime] NULL,
	[RequiredDate] [datetime] NULL,
	[OriginalPODetail] [int] NULL,
	[ReturnedDate] [datetime] NULL,
	[ConfirmNumber] [varchar](20) NULL,
	[WONo] [int] NULL,
	[DistCost] [decimal](19, 4) NULL,
	[User1] [varchar](12) NULL,
	[User2] [varchar](12) NULL,
	[User3] [varchar](12) NULL,
	[User4] [varchar](12) NULL,
	[User5] [varchar](12) NULL,
	[User6] [varchar](12) NULL,
	[PODetailStatus] [tinyint] NULL,
	[ToInspectionDate] [datetime] NULL,
	[ReasonCode] [varchar](4) NULL,
	[OriginalSeqNo] [int] NULL,
	[PODetail_AddDate] [datetime] NULL,
	[PODetail_AddUID] [varchar](12) NULL,
	[PODetail_UpdateDate] [datetime] NULL,
	[PODetail_UpdateUID] [varchar](12) NULL,
	[AltVendorNo] [int] NULL,
	[OriginalPromisedDate] [datetime] NULL,
	[PromisedDateRevision] [int] NULL,
	[RequiresInspection] [tinyint] NULL,
	[AltReceiveToCribBin] [varchar](15) NULL,
	[OriginalQuantity] [int] NULL,
	[ItemWithOrder] [bit] NULL,
	[UDF_POCATEGORY] [varchar](8) NULL,
	[UDFHSPOCAT] [varchar](8) NULL,
	[ReqDetNo] [int] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[btpoitem]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[btpoitem](
	[fpono] [char](6) NOT NULL,
	[cribpo] [int] NOT NULL,
	[fpartno] [char](25) NOT NULL,
	[frev] [char](3) NOT NULL,
	[fmeasure] [char](3) NOT NULL,
	[fitemno] [char](3) NOT NULL,
	[frelsno] [char](3) NOT NULL,
	[fcategory] [char](8) NOT NULL,
	[fsokey] [char](6) NOT NULL,
	[fsoitm] [char](3) NOT NULL,
	[fsorls] [char](3) NOT NULL,
	[fjokey] [char](10) NOT NULL,
	[fjoitm] [char](6) NOT NULL,
	[fjoopno] [int] NOT NULL,
	[flstcost] [dbo].[M2MMoney] NOT NULL,
	[fstdcost] [dbo].[M2MMoney] NOT NULL,
	[fleadtime] [numeric](5, 1) NOT NULL,
	[forgpdate] [datetime] NOT NULL,
	[flstpdate] [datetime] NOT NULL,
	[fmultirls] [char](1) NOT NULL,
	[fnextrels] [int] NOT NULL,
	[fnqtydm] [numeric](15, 5) NOT NULL,
	[freqdate] [datetime] NOT NULL,
	[fretqty] [numeric](15, 5) NOT NULL,
	[fordqty] [numeric](15, 5) NOT NULL,
	[fqtyutol] [numeric](6, 2) NOT NULL,
	[fqtyltol] [numeric](6, 2) NOT NULL,
	[fbkordqty] [numeric](15, 5) NOT NULL,
	[flstsdate] [datetime] NOT NULL,
	[frcpdate] [datetime] NOT NULL,
	[frcpqty] [numeric](15, 5) NOT NULL,
	[fshpqty] [numeric](15, 5) NOT NULL,
	[finvqty] [numeric](15, 5) NOT NULL,
	[fdiscount] [numeric](5, 1) NOT NULL,
	[frework] [char](1) NOT NULL,
	[fstandard] [bit] NOT NULL,
	[ftax] [char](1) NOT NULL,
	[fsalestax] [numeric](7, 3) NOT NULL,
	[finspect] [char](1) NOT NULL,
	[flcost] [dbo].[M2MMoney] NOT NULL,
	[fucost] [dbo].[M2MMoney] NOT NULL,
	[fprintmemo] [char](1) NOT NULL,
	[fvlstcost] [dbo].[M2MMoney] NOT NULL,
	[fvleadtime] [numeric](5, 1) NOT NULL,
	[fvmeasure] [char](5) NOT NULL,
	[fvpartno] [char](25) NOT NULL,
	[fvptdes] [varchar](35) NOT NULL,
	[fvordqty] [numeric](15, 5) NOT NULL,
	[fvconvfact] [numeric](13, 9) NOT NULL,
	[fvucost] [dbo].[M2MMoney] NOT NULL,
	[fqtyshipr] [numeric](15, 5) NOT NULL,
	[fdateship] [datetime] NOT NULL,
	[fparentpo] [char](6) NOT NULL,
	[frmano] [char](25) NOT NULL,
	[fdebitmemo] [char](1) NOT NULL,
	[finspcode] [char](4) NOT NULL,
	[freceiver] [char](6) NOT NULL,
	[fnorgucost] [dbo].[M2MMoney] NOT NULL,
	[fcorgcateg] [char](19) NOT NULL,
	[fparentitm] [char](3) NOT NULL,
	[fparentrls] [char](3) NOT NULL,
	[frecvitm] [char](3) NOT NULL,
	[fnorgeurcost] [dbo].[M2MMoney] NOT NULL,
	[fnorgtxncost] [dbo].[M2MMoney] NOT NULL,
	[fueurocost] [dbo].[M2MMoney] NOT NULL,
	[futxncost] [dbo].[M2MMoney] NOT NULL,
	[fvueurocost] [dbo].[M2MMoney] NOT NULL,
	[fvutxncost] [dbo].[M2MMoney] NOT NULL,
	[fljrdif] [bit] NOT NULL,
	[fucostonly] [dbo].[M2MMoney] NOT NULL,
	[futxncston] [dbo].[M2MMoney] NOT NULL,
	[fueurcston] [dbo].[M2MMoney] NOT NULL,
	[timestamp_column] [timestamp] NULL,
	[identity_column] [int] IDENTITY(1,1) NOT NULL,
	[fcomments] [text] NOT NULL,
	[fdescript] [text] NOT NULL,
	[FCBIN] [char](14) NOT NULL,
	[FCLOC] [char](14) NOT NULL,
	[Fac] [dbo].[M2MFacility] NOT NULL,
	[fcudrev] [char](3) NOT NULL,
	[fndbrmod] [int] NOT NULL,
	[blanketPO] [bit] NOT NULL,
	[PlaceDate] [datetime] NOT NULL,
	[DockTime] [int] NOT NULL,
	[PurchBuf] [int] NOT NULL,
	[Final] [bit] NOT NULL,
	[AvailDate] [datetime] NOT NULL,
	[SchedDate] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[btpomast]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[btpomast](
	[fcompany] [varchar](35) NOT NULL,
	[fcshipto] [char](8) NOT NULL,
	[forddate] [datetime] NOT NULL,
	[fpono] [char](6) NOT NULL,
	[cribpo] [int] NOT NULL,
	[fstatus] [char](20) NOT NULL,
	[fvendno] [char](6) NOT NULL,
	[fbuyer] [char](3) NOT NULL,
	[fchangeby] [char](25) NOT NULL,
	[fcngdate] [datetime] NOT NULL,
	[fconfirm] [char](19) NOT NULL,
	[fcontact] [char](20) NOT NULL,
	[fcfname] [char](15) NOT NULL,
	[fcreate] [datetime] NOT NULL,
	[ffob] [char](20) NOT NULL,
	[fmethod] [char](1) NOT NULL,
	[foldstatus] [char](20) NOT NULL,
	[fordrevdt] [datetime] NOT NULL,
	[fordtot] [numeric](15, 5) NOT NULL,
	[fpayterm] [char](4) NOT NULL,
	[fpaytype] [char](1) NOT NULL,
	[fporev] [char](2) NOT NULL,
	[fprint] [char](1) NOT NULL,
	[freqdate] [datetime] NOT NULL,
	[freqsdt] [datetime] NOT NULL,
	[freqsno] [char](6) NOT NULL,
	[frevtot] [numeric](15, 5) NOT NULL,
	[fsalestax] [numeric](7, 3) NOT NULL,
	[fshipvia] [char](20) NOT NULL,
	[ftax] [char](1) NOT NULL,
	[fcsnaddrke] [char](4) NOT NULL,
	[fcsncity] [char](20) NOT NULL,
	[fcsnstate] [char](20) NOT NULL,
	[fcsnzip] [char](10) NOT NULL,
	[fcsncountr] [char](25) NOT NULL,
	[fcsnphone] [char](20) NOT NULL,
	[fcsnfax] [char](20) NOT NULL,
	[fcshkey] [char](6) NOT NULL,
	[fcshaddrke] [char](4) NOT NULL,
	[fcshcompan] [varchar](35) NOT NULL,
	[fcshcity] [char](20) NOT NULL,
	[fcshstate] [char](20) NOT NULL,
	[fcshzip] [char](10) NOT NULL,
	[fcshcountr] [char](25) NOT NULL,
	[fcshphone] [char](20) NOT NULL,
	[fcshfax] [char](20) NOT NULL,
	[fnnextitem] [int] NOT NULL,
	[fautoclose] [char](1) NOT NULL,
	[fcusrchr1] [char](20) NOT NULL,
	[fcusrchr2] [varchar](40) NOT NULL,
	[fcusrchr3] [varchar](40) NOT NULL,
	[fnusrqty1] [dbo].[M2MMoney] NOT NULL,
	[fnusrcur1] [money] NOT NULL,
	[fdusrdate1] [datetime] NOT NULL,
	[fccurid] [char](3) NOT NULL,
	[fcfactor] [dbo].[M2MMoney] NOT NULL,
	[fdcurdate] [datetime] NOT NULL,
	[fdeurodate] [datetime] NOT NULL,
	[feurofctr] [dbo].[M2MMoney] NOT NULL,
	[fctype] [char](1) NOT NULL,
	[timestamp_column] [timestamp] NULL,
	[identity_column] [int] IDENTITY(1,1) NOT NULL,
	[fmpaytype] [text] NOT NULL,
	[fmshstreet] [text] NOT NULL,
	[fmsnstreet] [text] NOT NULL,
	[fmusrmemo1] [text] NOT NULL,
	[fpoclosing] [text] NOT NULL,
	[freasoncng] [text] NOT NULL,
	[fndbrmod] [int] NOT NULL,
	[flpdate] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[btPORTLog]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[btPORTLog](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[VerCol] [timestamp] NOT NULL,
	[fRollBack] [bit] NULL,
	[fRBPOMastStart] [char](6) NULL,
	[fRBPOMastEnd] [char](6) NULL,
	[fPOMastStart] [char](6) NULL,
	[fPOMastEnd] [char](6) NULL,
	[fStart] [datetime] NOT NULL,
	[fEnd] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[btrcitem]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[btrcitem](
	[fitemno] [char](3) NOT NULL,
	[fpartno] [char](25) NOT NULL,
	[fpartrev] [char](3) NOT NULL,
	[finvcost] [dbo].[M2MMoney] NOT NULL,
	[fcategory] [char](8) NOT NULL,
	[fcstatus] [char](1) NOT NULL,
	[fiqtyinv] [numeric](15, 5) NOT NULL,
	[fjokey] [char](10) NOT NULL,
	[fsokey] [char](6) NOT NULL,
	[fsoitem] [char](3) NOT NULL,
	[fsorelsno] [char](3) NOT NULL,
	[fvqtyrecv] [numeric](15, 5) NOT NULL,
	[fqtyrecv] [numeric](15, 5) NOT NULL,
	[freceiver] [char](6) NOT NULL,
	[frelsno] [char](3) NOT NULL,
	[fvendno] [char](6) NOT NULL,
	[fbinno] [char](14) NOT NULL,
	[fexpdate] [datetime] NOT NULL,
	[finspect] [char](1) NOT NULL,
	[finvqty] [numeric](15, 5) NOT NULL,
	[flocation] [char](14) NOT NULL,
	[flot] [char](20) NOT NULL,
	[fmeasure] [char](3) NOT NULL,
	[fpoitemno] [char](3) NOT NULL,
	[fretcredit] [char](1) NOT NULL,
	[ftype] [char](1) NOT NULL,
	[fumvori] [char](1) NOT NULL,
	[fqtyinsp] [numeric](15, 5) NOT NULL,
	[fauthorize] [char](20) NOT NULL,
	[fucost] [dbo].[M2MMoney] NOT NULL,
	[fllotreqd] [bit] NOT NULL,
	[flexpreqd] [bit] NOT NULL,
	[fctojoblot] [char](20) NOT NULL,
	[fdiscount] [numeric](5, 1) NOT NULL,
	[fueurocost] [dbo].[M2MMoney] NOT NULL,
	[futxncost] [dbo].[M2MMoney] NOT NULL,
	[fucostonly] [dbo].[M2MMoney] NOT NULL,
	[futxncston] [dbo].[M2MMoney] NOT NULL,
	[fueurcston] [dbo].[M2MMoney] NOT NULL,
	[flconvovrd] [bit] NOT NULL,
	[timestamp_column] [timestamp] NULL,
	[identity_column] [int] IDENTITY(1,1) NOT NULL,
	[fcomments] [text] NOT NULL,
	[fdescript] [text] NOT NULL,
	[fac] [dbo].[M2MFacility] NOT NULL,
	[sfac] [dbo].[M2MFacility] NOT NULL,
	[FCORIGUM] [char](3) NOT NULL,
	[fcudrev] [char](3) NOT NULL,
	[FNORIGQTY] [numeric](18, 5) NOT NULL,
	[Iso] [char](10) NOT NULL,
	[Ship_Link] [int] NOT NULL,
	[ShsrceLink] [int] NOT NULL,
	[fCINSTRUCT] [char](2) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[btrcmast]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[btrcmast](
	[fclandcost] [char](1) NOT NULL,
	[frmano] [char](25) NOT NULL,
	[fporev] [char](2) NOT NULL,
	[fcstatus] [char](1) NOT NULL,
	[fdaterecv] [datetime] NOT NULL,
	[fpono] [char](6) NOT NULL,
	[freceiver] [char](6) NOT NULL,
	[fvendno] [char](6) NOT NULL,
	[faccptby] [char](3) NOT NULL,
	[fbilllad] [char](18) NOT NULL,
	[fcompany] [varchar](35) NOT NULL,
	[ffrtcarr] [char](20) NOT NULL,
	[fpacklist] [char](15) NOT NULL,
	[fretship] [char](1) NOT NULL,
	[fshipwgt] [numeric](11, 2) NOT NULL,
	[ftype] [char](1) NOT NULL,
	[start] [datetime] NOT NULL,
	[fprinted] [bit] NOT NULL,
	[flothrupd] [bit] NOT NULL,
	[fccurid] [char](3) NOT NULL,
	[fcfactor] [dbo].[M2MMoney] NOT NULL,
	[fdcurdate] [datetime] NOT NULL,
	[fdeurodate] [datetime] NOT NULL,
	[feurofctr] [dbo].[M2MMoney] NOT NULL,
	[flpremcv] [bit] NOT NULL,
	[identity_column] [int] IDENTITY(1,1) NOT NULL,
	[timestamp_column] [timestamp] NULL,
	[docstatus] [char](10) NULL,
	[frmacreator] [varchar](25) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[btterms]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[btterms](
	[fcterms] [char](4) NOT NULL,
	[description] [varchar](112) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[btToolItems]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[btToolItems](
	[ItemNumber] [varchar](12) NOT NULL,
	[Description1] [varchar](50) NULL,
	[ItemClass] [varchar](15) NULL,
	[DefaultBuyerGroupID] [varchar](15) NULL,
	[UDFGLOBALTOOL] [varchar](20) NULL,
	[Cost] [decimal](20, 4) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[btToolListItems]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[btToolListItems](
	[ItemNumber] [varchar](50) NOT NULL,
	[ToolLists] [varchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[btToolListPartItems]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[btToolListPartItems](
	[partNumber] [nvarchar](50) NULL,
	[itemNumber] [nvarchar](50) NULL,
	[itemsPerPart] [numeric](38, 27) NULL,
	[toolOps] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[btTransLogMonth]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[btTransLogMonth](
	[JobNumber] [nvarchar](32) NULL,
	[PartNumber] [nvarchar](25) NULL,
	[Rev] [nvarchar](3) NULL,
	[ItemNumber] [nvarchar](32) NULL,
	[Qty] [int] NULL,
	[UNITCOST] [money] NULL,
	[TranStartDateTime] [smalldatetime] NOT NULL,
	[UserNumber] [nvarchar](32) NULL,
	[UserName] [nvarchar](50) NULL,
	[Plant] [nvarchar](3) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[btUser4]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[btUser4](
	[Name] [varchar](50) NULL,
	[Comments] [varchar](255) NULL,
	[MonthToDate] [decimal](19, 4) NULL,
	[YearToDate] [decimal](19, 4) NULL,
	[WeekToDate] [decimal](19, 4) NULL,
	[MonthlyRedFlag] [decimal](19, 4) NULL,
	[YearlyRedFlag] [decimal](19, 4) NULL,
	[WeeklyRedFlag] [decimal](19, 4) NULL,
	[LastYear] [decimal](19, 4) NULL,
	[ExcludeUnrestricted] [smallint] NULL,
	[ID] [varchar](12) NOT NULL,
	[AssetNo] [int] NULL,
	[UserInactive] [bit] NULL,
	[DynamicFilterOption] [int] NULL,
	[UDFarea] [varchar](20) NULL,
	[UserSiteID] [varchar](12) NULL,
	[UserLocalID] [varchar](12) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[btVendor]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[btVendor](
	[VendorNumber] [varchar](12) NOT NULL,
	[VendorName] [varchar](50) NULL,
	[PurchaseAddress1] [varchar](50) NULL,
	[PurchaseAddress2] [varchar](50) NULL,
	[PurchaseCity] [varchar](50) NULL,
	[PurchaseState] [varchar](50) NULL,
	[PurchaseZip] [varchar](20) NULL,
	[Phone] [varchar](20) NULL,
	[FaxPhone] [varchar](50) NULL,
	[EDIPhone] [varchar](50) NULL,
	[MinAmount] [decimal](19, 4) NULL,
	[OrderMethod] [smallint] NULL,
	[Terms] [varchar](30) NULL,
	[VendorPO] [varchar](12) NULL,
	[POReleaseNumber] [int] NULL,
	[POExpiration] [datetime] NULL,
	[POComment] [varchar](200) NULL,
	[shipping] [varchar](50) NULL,
	[daterequired] [varchar](12) NULL,
	[AvgBuildTime] [int] NULL,
	[OverrideBuildTime] [int] NULL,
	[ContactInfo] [varchar](200) NULL,
	[Comments] [varchar](255) NULL,
	[EMailAddress] [varchar](50) NULL,
	[AlertEMailAddress] [varchar](255) NULL,
	[EDIFormat] [tinyint] NULL,
	[TPName] [varchar](64) NULL,
	[OvrAutoPurchaseDays] [int] NULL,
	[POPrinterName] [varchar](32) NULL,
	[VendorInactive] [bit] NULL,
	[UDFM2MVENDORNUMBER] [varchar](6) NULL,
	[UDFHARTSELLEVENDOR] [varchar](6) NULL,
	[OverrideRptRexPO] [varchar](30) NULL,
	[Vendor_AddDate] [datetime] NULL,
	[Vendor_AddUID] [varchar](12) NULL,
	[Vendor_UpdateDate] [datetime] NULL,
	[Vendor_UpdateUID] [varchar](12) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BudgetDetail]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BudgetDetail](
	[TransNumber] [int] NOT NULL,
	[BudgetTransNumber] [int] NULL,
 CONSTRAINT [BudgetDetail_PK] PRIMARY KEY CLUSTERED 
(
	[TransNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BudgetSummary]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BudgetSummary](
	[BudgetTransNumber] [int] NOT NULL,
	[OpenQuantity] [int] NULL,
 CONSTRAINT [BudgetSummary_PK] PRIMARY KEY CLUSTERED 
(
	[BudgetTransNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BuyerGroup]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BuyerGroup](
	[BuyerGroupID] [varchar](12) NOT NULL,
	[BuyerGroupDescription] [varchar](50) NULL,
 CONSTRAINT [BUYERGROUP_PK] PRIMARY KEY CLUSTERED 
(
	[BuyerGroupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CalibrationReference]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CalibrationReference](
	[CalibrationReferenceID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Revision] [int] NULL,
	[Reference] [varchar](30) NULL,
	[CertifyStandards] [text] NULL,
	[Tolerance] [decimal](19, 4) NULL,
	[CertifyFormToUse] [varchar](16) NULL,
	[CreationDate] [datetime] NULL,
	[CertifyPrecision] [tinyint] NULL,
	[CertifyScale] [tinyint] NULL,
 CONSTRAINT [CalibrationReference_PK] PRIMARY KEY CLUSTERED 
(
	[CalibrationReferenceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CAMERA]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CAMERA](
	[CameraID] [varchar](12) NOT NULL,
	[CameraIPAddress] [varchar](20) NULL,
	[CameraPassword] [varchar](10) NULL,
	[CameraPort] [int] NULL,
	[UserName] [varchar](20) NULL,
	[ImageURL] [varchar](255) NULL,
	[Crib] [smallint] NULL,
 CONSTRAINT [CAMERA_PK] PRIMARY KEY CLUSTERED 
(
	[CameraID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CheckList]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CheckList](
	[CheckListNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ItemNumber] [varchar](50) NULL,
	[CheckListID] [varchar](30) NOT NULL,
	[CheckListInstruction] [varchar](255) NULL,
	[CheckListSequence] [int] NULL,
	[CheckListScanRequired] [bit] NULL,
	[CheckListProcess] [int] NULL,
 CONSTRAINT [PK_CHECKLIST] PRIMARY KEY CLUSTERED 
(
	[CheckListNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CheckListHistory]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CheckListHistory](
	[CheckListHistoryNo] [int] IDENTITY(1,1) NOT NULL,
	[ItemNumber] [varchar](12) NOT NULL,
	[CheckListProcess] [tinyint] NOT NULL,
	[EmployeeID] [varchar](12) NOT NULL,
	[DateCompleted] [datetime] NOT NULL,
 CONSTRAINT [CheckListHistory_PK] PRIMARY KEY CLUSTERED 
(
	[CheckListHistoryNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CHECKOUT]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CHECKOUT](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Employee] [varchar](12) NULL,
	[Item] [varchar](12) NULL,
	[Quantity] [smallint] NULL,
	[CribBin] [varchar](15) NULL,
	[SerialID] [varchar](18) NULL,
	[User1] [varchar](12) NULL,
	[User3] [varchar](12) NULL,
	[User4] [varchar](12) NULL,
	[Cost] [decimal](19, 4) NULL,
	[User5] [varchar](12) NULL,
	[DateIssued] [datetime] NULL,
	[User2] [varchar](12) NULL,
	[User6] [varchar](12) NULL,
	[Consignment] [int] NULL,
	[DATEDUE] [datetime] NULL,
	[LotNo] [int] NULL,
	[CheckoutFODControl] [tinyint] NULL,
	[CheckOutRFIDNo] [int] NULL,
 CONSTRAINT [aaaaaCHECKOUT_PK] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ClassDef]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClassDef](
	[ClassNo] [int] NOT NULL,
	[ParentClassNo] [int] NULL,
	[ClassName] [nvarchar](50) NOT NULL,
	[ClassIDCode] [nvarchar](12) NULL,
	[ClassDesc1Code] [nvarchar](50) NULL,
	[ClassDesc2Code] [nvarchar](50) NULL,
	[ClassComments] [nvarchar](255) NULL,
	[ClassDefinition] [nvarchar](255) NULL,
	[ClassRevision] [int] NULL,
	[DefaultItemTypeNo] [tinyint] NULL,
	[DefaultItemClass] [nvarchar](50) NULL,
	[DefaultSerialized] [bit] NOT NULL,
	[UseSeqID] [bit] NOT NULL,
	[MinSeqDigits] [int] NULL,
	[NextSeqID] [int] NULL,
	[CLASSDEF_AddDate] [smalldatetime] NULL,
	[CLASSDEF_AddUID] [nvarchar](12) NULL,
	[CLASSDEF_UpdateDate] [smalldatetime] NULL,
	[CLASSDEF_UpdateUID] [nvarchar](12) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ClassKeyword]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClassKeyword](
	[ClassKeywordNo] [int] NOT NULL,
	[ClassNo] [int] NOT NULL,
	[Keyword] [nvarchar](50) NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CMAXREQUESTS]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CMAXREQUESTS](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Status] [int] NULL,
	[ComputerName] [varchar](50) NULL,
	[RequestDate] [datetime] NULL,
	[Requestor] [varchar](50) NULL,
	[Action] [varchar](10) NULL,
	[CribBin] [varchar](20) NULL,
	[Quantity] [int] NULL,
	[BinQuantity] [int] NULL,
	[BatchID] [int] NULL,
	[Instructions] [varchar](50) NULL,
 CONSTRAINT [PK_REQUESTNUMBER] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CommonItem]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CommonItem](
	[CINo] [int] NOT NULL,
	[CINumber] [nvarchar](12) NOT NULL,
	[CIDescription1] [nvarchar](50) NULL,
	[CIDescription2] [nvarchar](50) NULL,
	[ClassNo] [int] NULL,
	[CIDateCreated] [smalldatetime] NULL,
	[CIDateLastModified] [smalldatetime] NULL,
	[CIRevision] [int] NULL,
	[CILocked] [bit] NOT NULL,
	[CINumberOvr] [bit] NOT NULL,
	[CIDescription1Ovr] [bit] NOT NULL,
	[CIDescription2Ovr] [bit] NOT NULL,
	[CIGenSequence] [int] NULL,
	[COMMONITEM_AddDate] [smalldatetime] NULL,
	[COMMONITEM_AddUID] [nvarchar](12) NULL,
	[COMMONITEM_UpdateDate] [smalldatetime] NULL,
	[COMMONITEM_UpdateUID] [nvarchar](12) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CraftCode]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CraftCode](
	[CraftCode] [varchar](12) NOT NULL,
	[CraftDescription] [varchar](50) NULL,
	[CraftHourlyRate] [decimal](19, 4) NULL,
	[CraftCodeSiteID] [varchar](12) NULL,
 CONSTRAINT [PK_CRAFTCODE] PRIMARY KEY CLUSTERED 
(
	[CraftCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Crib]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Crib](
	[Crib] [smallint] NOT NULL,
	[Name] [varchar](50) NULL,
	[CribType] [smallint] NULL,
	[Comments] [varchar](255) NULL,
	[User1] [int] NULL,
	[User2] [int] NULL,
	[LabelPrinterName] [varchar](32) NULL,
	[CribArea] [varchar](12) NULL,
	[SiteID] [varchar](12) NULL,
	[ReturnToCrib] [smallint] NULL,
	[AlertEMailAddress] [varchar](255) NULL,
	[CribOrderType] [tinyint] NULL,
	[CribStockFromCrib] [smallint] NULL,
	[CribTelephone] [varchar](30) NULL,
	[TransferInPackageSize] [tinyint] NULL,
	[RequireWOForIssue] [tinyint] NULL,
	[EnableSiteTransfers] [tinyint] NULL,
	[CribCheckOutTimeLimit] [smallint] NULL,
	[OrderReviewOption] [tinyint] NULL,
	[TrackSpaceOption] [tinyint] NULL,
	[PrimaryCrib] [int] NULL,
	[ItemCentricOption] [tinyint] NULL,
	[BinTypeOption] [tinyint] NULL,
	[AutoDeleteOption] [tinyint] NULL,
	[CribVendorNumber] [varchar](12) NULL,
	[CribVendorOption] [tinyint] NULL,
	[Crib_AddDate] [datetime] NULL,
	[Crib_AddUID] [varchar](12) NULL,
	[Crib_UpdateDate] [datetime] NULL,
	[Crib_UpdateUID] [varchar](12) NULL,
	[CribFODOption] [tinyint] NULL DEFAULT (1),
	[NextSeqBin] [varchar](12) NULL,
	[DeviceComputerName] [varchar](15) NULL,
	[CribUserOverrideNo] [int] NULL,
	[CribSettingsTemplateNo] [int] NULL,
	[DeviceCrib] [int] NULL,
	[CribBillingOption] [tinyint] NULL,
 CONSTRAINT [Crib_PK] PRIMARY KEY CLUSTERED 
(
	[Crib] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CribSpace]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CribSpace](
	[CribSpaceId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[CribBinPrefix] [varchar](16) NULL,
	[Crib] [int] NOT NULL,
	[BinPrefix] [varchar](12) NOT NULL,
	[Description] [varchar](50) NULL,
	[Capacity] [smallint] NULL,
	[BoxSize] [varchar](12) NULL,
	[FreeSpace] [smallint] NULL,
	[AutoDeleteOption] [tinyint] NULL,
	[StopOrderingOption] [tinyint] NULL,
 CONSTRAINT [CRIBSPACEID_PK] PRIMARY KEY CLUSTERED 
(
	[CribSpaceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CribStatistics]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CribStatistics](
	[StatisticsID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[StatisticsType] [int] NULL,
	[Crib] [int] NULL,
	[BinCount] [int] NULL,
	[StatisticsDate] [datetime] NULL,
	[StatisticsValue] [decimal](19, 4) NULL,
	[CribBin] [varchar](15) NULL,
	[ItemNumber] [varchar](12) NULL,
 CONSTRAINT [CribStatistics_PK] PRIMARY KEY CLUSTERED 
(
	[StatisticsID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CribType]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CribType](
	[CribType] [int] NOT NULL,
	[Description] [varchar](50) NULL,
 CONSTRAINT [CribType_PK] PRIMARY KEY CLUSTERED 
(
	[CribType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CustomDateRange]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CustomDateRange](
	[CustomDateRangeNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[RangeType] [int] NULL,
	[RangeName] [varchar](50) NULL,
	[BeginDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
 CONSTRAINT [PK_CUSTOMDATERANGE] PRIMARY KEY CLUSTERED 
(
	[CustomDateRangeNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CustomDateType]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CustomDateType](
	[CustomDateTypeNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[TypeDescription] [varchar](15) NOT NULL,
	[AllowRptScheduling] [tinyint] NULL,
 CONSTRAINT [PK_CUSTOMDATETYPE] PRIMARY KEY CLUSTERED 
(
	[CustomDateTypeNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CycleCountClass]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CycleCountClass](
	[CycleCountClassNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[CycleCountClassID] [varchar](12) NOT NULL,
	[Description] [varchar](50) NULL,
	[Comments] [varchar](255) NULL,
	[CycleCountClass_AddDate] [datetime] NULL,
	[CycleCountClass_AddUID] [varchar](12) NULL,
	[CycleCountClass_UpdateDate] [datetime] NULL,
	[CycleCountClass_UpdateUID] [varchar](12) NULL,
 CONSTRAINT [CYCLECOUNTCLASS_PK] PRIMARY KEY CLUSTERED 
(
	[CycleCountClassNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CycleCountDetail]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CycleCountDetail](
	[CycleCountDetailNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[CribBin] [varchar](15) NULL,
	[SerialID] [varchar](18) NULL,
	[DateCounted] [datetime] NULL,
 CONSTRAINT [PK_CycleCountDetail] PRIMARY KEY CLUSTERED 
(
	[CycleCountDetailNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CycleCountSettings]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CycleCountSettings](
	[CycleCountSettingsNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[CycleCountClassNo] [int] NOT NULL,
	[Crib] [int] NOT NULL,
	[CycleDuration] [int] NULL,
	[CycleEndDate] [datetime] NULL,
	[OvrCycleStartDate] [datetime] NULL,
	[CycleEndDay] [tinyint] NULL,
	[SubCycleType] [tinyint] NULL,
	[BinSequenceOption] [tinyint] NULL,
	[ExpectedAccuracy] [tinyint] NULL,
	[AutoScheduleOption] [tinyint] NULL,
	[AutoUpdateSerialIDOption] [tinyint] NULL,
	[AutoCountSerialIDBinOption] [tinyint] NULL,
	[HideExpectedCountOption] [tinyint] NULL,
	[CycleCountSettings_AddDate] [datetime] NULL,
	[CycleCountSettings_AddUID] [varchar](12) NULL,
	[CycleCountSettings_UpdateDate] [datetime] NULL,
	[CycleCountSettings_UpdateUID] [varchar](12) NULL,
 CONSTRAINT [CYCLECOUNTSETTINGS_PK] PRIMARY KEY CLUSTERED 
(
	[CycleCountSettingsNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DataDictionary]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DataDictionary](
	[DictionaryID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[BaseTable] [varchar](30) NULL,
	[JoinedTable] [varchar](30) NULL,
	[ColumnName] [varchar](30) NULL,
	[ColumnDataType] [smallint] NULL,
	[ColumnLabel] [varchar](30) NULL,
	[ColumnSequence] [smallint] NULL,
	[DataSrcTable] [varchar](255) NULL,
	[DataSrcField] [varchar](255) NULL,
	[FieldSecEnforced] [tinyint] NULL,
	[DisplayOption] [tinyint] NULL,
	[Category] [varchar](50) NULL,
 CONSTRAINT [DataDictionary_PK] PRIMARY KEY CLUSTERED 
(
	[DictionaryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DeviceRouting]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DeviceRouting](
	[DeviceID] [varchar](50) NOT NULL,
	[HostID] [varchar](50) NOT NULL,
	[DeviceInactive] [bit] NULL,
	[HostPortNumber] [int] NULL,
	[Comments] [varchar](255) NULL,
	[DeviceType] [tinyint] NULL,
	[DeviceCrib] [int] NULL,
 CONSTRAINT [PK_DEVICEROUTING] PRIMARY KEY CLUSTERED 
(
	[DeviceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DeviceSettings]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DeviceSettings](
	[DeviceSettingsNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[DeviceID] [varchar](50) NOT NULL,
	[KeyName] [varchar](40) NOT NULL,
	[Int] [int] NULL,
	[String] [varchar](250) NULL,
 CONSTRAINT [DEVICESETTINGS_PK] PRIMARY KEY CLUSTERED 
(
	[DeviceSettingsNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[EMPLOYEE]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EMPLOYEE](
	[ID] [varchar](12) NOT NULL,
	[LastName] [varchar](50) NULL,
	[FirstName] [varchar](50) NULL,
	[Name] [varchar](50) NULL,
	[EmployeePassword] [varchar](32) NULL,
	[Category] [varchar](255) NULL,
	[User1] [varchar](15) NULL,
	[User3] [varchar](15) NULL,
	[User4] [varchar](15) NULL,
	[User2] [varchar](15) NULL,
	[AccessCode] [varchar](27) NULL,
	[Rights] [varchar](27) NULL,
	[BeginTime] [smallint] NULL,
	[EndTime] [smallint] NULL,
	[CostLimit] [decimal](19, 4) NULL,
	[CostPerIssue] [decimal](19, 4) NULL,
	[MonthToDate] [decimal](19, 4) NULL,
	[YearToDate] [decimal](19, 4) NULL,
	[WeekToDate] [decimal](19, 4) NULL,
	[MonthlyRedFlag] [decimal](19, 4) NULL,
	[YearlyRedFlag] [decimal](19, 4) NULL,
	[WeeklyRedFlag] [decimal](19, 4) NULL,
	[LastYear] [decimal](19, 4) NULL,
	[SupplierLogin] [smallint] NULL,
	[User5] [varchar](15) NULL,
	[User6] [varchar](15) NULL,
	[EmployeeLaborRate] [decimal](19, 4) NULL,
	[BadgeNumber] [varchar](20) NULL,
	[EmployeeInactive] [tinyint] NULL,
	[PrintCode] [int] NULL,
	[FaxNumber] [varchar](100) NULL,
	[EmployeeEMailAddress] [varchar](100) NULL,
	[Supervisor] [varchar](12) NULL,
	[Employee_AddDate] [datetime] NULL,
	[Employee_AddUID] [varchar](12) NULL,
	[Employee_UpdateDate] [datetime] NULL,
	[Employee_UpdateUID] [varchar](12) NULL,
	[EmployeeFODControl] [tinyint] NULL,
	[PasswordExpiration] [datetime] NULL,
	[POApprovalLimit] [decimal](19, 4) NULL,
	[LoginDisabled] [bit] NULL,
	[LastLoginActivityDate] [datetime] NULL,
	[GroupAccount] [bit] NULL,
	[LastReportEMailAddress] [varchar](100) NULL,
	[EmployeeSiteID] [varchar](12) NULL,
	[WindowsUserName] [varchar](64) NULL,
	[EmployeeLocalID] [varchar](12) NULL,
	[DefaultLocale] [varchar](20) NULL,
	[VendorNumber] [varchar](12) NULL,
	[EmployeeAccessLevel] [tinyint] NULL,
 CONSTRAINT [PK_EMPLOYEE] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[EmployeeBuyerGroup]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EmployeeBuyerGroup](
	[EmployeeID] [varchar](12) NOT NULL,
	[BuyerGroupID] [varchar](12) NOT NULL,
 CONSTRAINT [PK_EMPLOYEEBUYERGROUP] PRIMARY KEY CLUSTERED 
(
	[EmployeeID] ASC,
	[BuyerGroupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[EmployeeCraft]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EmployeeCraft](
	[EmployeeID] [varchar](12) NOT NULL,
	[CraftCode] [varchar](12) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[EmployeeCrib]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EmployeeCrib](
	[EmployeeID] [varchar](12) NOT NULL,
	[Crib] [smallint] NOT NULL,
	[CribAccessOption] [tinyint] NULL,
 CONSTRAINT [PK_EMPLOYEECRIB] PRIMARY KEY CLUSTERED 
(
	[EmployeeID] ASC,
	[Crib] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[EmployeeSecurity]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EmployeeSecurity](
	[EmployeeSecurityId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[EmployeeId] [varchar](12) NOT NULL,
	[SecurityGrpId] [int] NOT NULL,
	[ScopeType] [tinyint] NOT NULL,
 CONSTRAINT [EMPLOYEESECURITY_PK] PRIMARY KEY CLUSTERED 
(
	[EmployeeSecurityId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[EmployeeSecurityExt]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EmployeeSecurityExt](
	[EmployeeSecurityExtId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[EmployeeId] [varchar](12) NOT NULL,
	[FunctionId] [int] NOT NULL,
	[SecurityType] [tinyint] NOT NULL,
	[ScopeType] [tinyint] NOT NULL,
 CONSTRAINT [EMPLOYEESECURITYEXT_PK] PRIMARY KEY CLUSTERED 
(
	[EmployeeSecurityExtId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[EmployeeSite]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EmployeeSite](
	[EmployeeSiteNo] [int] IDENTITY(1,1) NOT NULL,
	[EmployeeID] [varchar](12) NOT NULL,
	[SiteID] [varchar](12) NOT NULL,
	[SiteAccessOption] [tinyint] NULL,
	[CribAccessOption] [tinyint] NULL,
 CONSTRAINT [PK_EmployeeSite] PRIMARY KEY CLUSTERED 
(
	[EmployeeSiteNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[EventLog]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EventLog](
	[EventLogNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[EventLogDate] [datetime] NULL,
	[EventLogType] [tinyint] NULL,
	[EventLogMessage] [varchar](255) NULL,
	[EventLogComputerName] [varchar](50) NULL,
	[EventLogKey] [varchar](30) NULL,
	[EventLogProgramName] [varchar](12) NULL,
	[EventLogAction] [varchar](20) NULL,
	[EventLogUserID] [varchar](12) NULL,
 CONSTRAINT [EVENTLOG_PK] PRIMARY KEY CLUSTERED 
(
	[EventLogNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Events]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Events](
	[Counter] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[EventType] [int] NULL,
	[EventDate] [datetime] NULL,
	[CribBin] [varchar](15) NULL,
	[ItemNumber] [varchar](12) NULL,
	[BonusKey] [varchar](30) NULL,
	[Description] [varchar](100) NULL,
	[Number1] [decimal](19, 4) NULL,
	[Number2] [decimal](19, 4) NULL,
 CONSTRAINT [Events_PK] PRIMARY KEY CLUSTERED 
(
	[Counter] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ExtendUserData]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ExtendUserData](
	[UDKey1] [varchar](20) NOT NULL,
	[UDKey2] [varchar](20) NOT NULL,
	[TemplateID] [int] NULL,
	[TableType] [int] NULL,
	[Data1] [varchar](50) NULL,
	[Data2] [varchar](50) NULL,
	[Data3] [varchar](50) NULL,
	[Data4] [varchar](50) NULL,
	[Data5] [varchar](50) NULL,
	[Data6] [varchar](50) NULL,
	[Data7] [varchar](50) NULL,
	[Data8] [varchar](50) NULL,
	[Data9] [varchar](50) NULL,
	[Data10] [varchar](50) NULL,
	[Data11] [varchar](50) NULL,
	[Data12] [varchar](50) NULL,
	[Data13] [varchar](50) NULL,
	[Data14] [varchar](50) NULL,
	[Data15] [varchar](50) NULL,
	[Data16] [varchar](50) NULL,
	[Data17] [varchar](50) NULL,
	[Data18] [varchar](50) NULL,
 CONSTRAINT [ExtendUserData_PK] PRIMARY KEY CLUSTERED 
(
	[UDKey1] ASC,
	[UDKey2] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FunctionNames]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FunctionNames](
	[FunctionId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[FunctionGrpName] [varchar](50) NOT NULL,
	[FunctionName] [varchar](50) NULL,
	[FunctionType] [tinyint] NULL,
 CONSTRAINT [FUNCTIONID_PK] PRIMARY KEY CLUSTERED 
(
	[FunctionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Gauge]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Gauge](
	[SerialId] [varchar](18) NOT NULL,
	[RecType] [smallint] NULL,
	[LastCertifyDate] [datetime] NULL,
	[NextCertifyDate] [datetime] NULL,
	[SpecialCertifyDate] [datetime] NULL,
	[DateOutOfService] [datetime] NULL,
	[CertifyIntervalBaseDate] [datetime] NULL,
	[OvrCertifyInterval] [smallint] NULL,
	[OvrUsageBeforeNextCertify] [int] NULL,
	[UsageSinceLastCertify] [int] NULL,
	[OvrReminderDays] [smallint] NULL,
	[CertifyPending] [smallint] NULL,
	[DateClockStart] [datetime] NULL,
	[GeneralNote] [text] NULL,
	[DateClockStop] [datetime] NULL,
	[InactiveDays] [int] NULL,
	[OvrCertifyIntervalType] [smallint] NULL,
	[OvrMaxInactiveDays] [int] NULL,
	[Gauge_AddDate] [datetime] NULL,
	[Gauge_AddUID] [varchar](12) NULL,
	[Gauge_UpdateDate] [datetime] NULL,
	[Gauge_UpdateUID] [varchar](12) NULL,
	[DelayedDatingOption] [tinyint] NULL,
 CONSTRAINT [Gauge_PK] PRIMARY KEY CLUSTERED 
(
	[SerialId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[GaugeCertify]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[GaugeCertify](
	[SerialID] [varchar](18) NULL,
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[CertifyDate] [datetime] NULL,
	[CertifiedBy] [varchar](50) NULL,
	[ReviewedBy] [varchar](50) NULL,
	[CertifyReason] [smallint] NULL,
	[OpeningStatus] [smallint] NULL,
	[EndingStatus] [smallint] NULL,
	[GeneralNotes] [text] NULL,
	[PreviousInactiveDays] [int] NULL,
	[PreviousUsage] [int] NULL,
	[CalibrationReferenceID] [int] NULL,
	[MasterGaugeID] [varchar](18) NULL,
	[DateRecorded] [datetime] NULL,
	[AltMasterGaugeID] [varchar](18) NULL,
 CONSTRAINT [GaugeCertify_PK] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[GaugeCertifyDetail]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GaugeCertifyDetail](
	[GaugeCertifyDetailID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[GaugeCertifyID] [int] NULL,
	[GaugeMeasureID] [int] NULL,
	[PreMeasurement] [decimal](19, 4) NULL,
	[PostMeasurement] [decimal](19, 4) NULL,
 CONSTRAINT [GaugeCertifyDetail_PK] PRIMARY KEY CLUSTERED 
(
	[GaugeCertifyDetailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[GaugeMeasurement]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[GaugeMeasurement](
	[GaugeMeasureID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[CalibrationReferenceID] [int] NULL,
	[Description] [varchar](50) NULL,
	[Standard] [decimal](19, 4) NULL,
	[Units] [varchar](15) NULL,
	[Tolerance] [decimal](19, 4) NULL,
	[MinValue] [decimal](19, 4) NULL,
	[MaxValue] [decimal](19, 4) NULL,
 CONSTRAINT [GaugeMeasurement_PK] PRIMARY KEY CLUSTERED 
(
	[GaugeMeasureID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[GlobalSettings]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[GlobalSettings](
	[KeyName] [varchar](40) NOT NULL,
	[Int] [int] NULL,
	[String] [varchar](250) NULL,
	[GlobalSettings_AddDate] [datetime] NULL,
	[GlobalSettings_AddUID] [varchar](12) NULL,
	[GlobalSettings_UpdateDate] [datetime] NULL,
	[GlobalSettings_UpdateUID] [varchar](12) NULL,
 CONSTRAINT [GlobalSettings_PK] PRIMARY KEY CLUSTERED 
(
	[KeyName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[IMAGES]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IMAGES](
	[ImageNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[CaptureDate] [datetime] NULL,
	[FileName] [varchar](255) NULL,
	[CameraID] [varchar](12) NULL,
	[Event] [varchar](20) NULL,
	[Sequence] [int] NULL,
 CONSTRAINT [PK_IMAGES] PRIMARY KEY CLUSTERED 
(
	[ImageNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[IntervalType]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IntervalType](
	[IntervalType] [tinyint] NOT NULL,
	[IntervalDescription] [varchar](30) NULL,
	[IntervalFlag] [tinyint] NULL,
 CONSTRAINT [PK_INTERVALTYPE] PRIMARY KEY CLUSTERED 
(
	[IntervalType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[INVENTRY]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[INVENTRY](
	[ItemNumber] [varchar](12) NOT NULL,
	[Description1] [varchar](50) NULL,
	[Description2] [varchar](50) NULL,
	[Price] [numeric](19, 4) NULL,
	[MonthToDate] [numeric](19, 4) NULL,
	[YearToDate] [numeric](19, 4) NULL,
	[WeekToDate] [numeric](19, 4) NULL,
	[MonthlyRedFlag] [numeric](19, 4) NULL,
	[YearlyRedFlag] [numeric](19, 4) NULL,
	[WeeklyRedFlag] [numeric](19, 4) NULL,
	[LastYear] [numeric](19, 4) NULL,
	[ShortDesc] [varchar](30) NULL,
	[AccessCode] [varchar](2) NULL,
	[VendorNumber] [varchar](12) NULL,
	[ItemType] [smallint] NULL,
	[ItemClass] [varchar](15) NULL,
	[ReworkedItemNumber] [varchar](12) NULL,
	[UPCCode] [varchar](20) NULL,
	[Comments] [varchar](255) NULL,
	[Serialized] [int] NULL,
	[PriceType] [smallint] NULL,
	[Manufacturer] [varchar](50) NULL,
	[MfrNumber] [varchar](30) NULL,
	[DefaultQty] [int] NULL,
	[UseInPlantQuantity] [int] NULL,
	[IncludeReworked] [int] NULL,
	[Special] [varchar](20) NULL,
	[Restricted] [smallint] NULL,
	[ReceiveNewAsRework] [int] NULL,
	[AllowMaintenance] [tinyint] NULL,
	[TrackUsage] [tinyint] NULL,
	[ItemStatusCode] [varchar](4) NULL,
	[CheckOutTimeLimit] [smallint] NULL,
	[AllowOvrTimeLimit] [tinyint] NULL,
	[TrackLotNumber] [bit] NULL,
	[CINo] [int] NULL,
	[ClassNo] [int] NULL,
	[CIRevision] [int] NULL,
	[CINumber] [varchar](12) NULL,
	[LinkCINumber] [bit] NULL,
	[LinkCIDescription1] [bit] NULL,
	[LinkCIDescription2] [bit] NULL,
	[NoInterSiteTransfers] [tinyint] NULL,
	[ItemStockFromCrib] [smallint] NULL,
	[UseCheckList] [tinyint] NULL,
	[BuyerGroupID] [varchar](12) NULL,
	[Inventry_AddDate] [datetime] NULL,
	[Inventry_AddUID] [varchar](12) NULL,
	[Inventry_UpdateDate] [datetime] NULL,
	[Inventry_UpdateUID] [varchar](12) NULL,
	[ItemFODControl] [tinyint] NULL,
	[AltVendorNo] [int] NULL,
	[RequiresInspection] [tinyint] NULL,
	[CertifiedSystem] [smallint] NULL,
	[CriticalItemOption] [tinyint] NULL,
	[Locked] [smallint] NULL,
	[InactiveItem] [bit] NULL,
	[CycleCountClassNo] [int] NULL,
	[IssueUnitOfMeasure] [varchar](30) NULL,
	[AutoScrapOption] [tinyint] NULL,
	[UDFCOATING] [varchar](20) NULL,
	[UDFMINFLUTE] [varchar](20) NULL,
	[UDFGLOBALTOOL] [varchar](20) NULL,
 CONSTRAINT [PK_INVENTRY] PRIMARY KEY CLUSTERED 
(
	[ItemNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[InventryGauge]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[InventryGauge](
	[ItemNumber] [varchar](12) NOT NULL,
	[GaugeType] [varchar](16) NULL,
	[Manufacturer] [varchar](50) NULL,
	[Model] [varchar](50) NULL,
	[CertifyInterval] [smallint] NULL,
	[UsageBeforeNextCertify] [int] NULL,
	[ReminderDays] [smallint] NULL,
	[CertifyCost] [decimal](19, 4) NULL,
	[CertifyAverageTime] [smallint] NULL,
	[CertifyDesignee] [text] NULL,
	[CertifyStandards] [text] NULL,
	[CertifyNotes] [text] NULL,
	[CalibrationReferenceID] [int] NULL,
	[CertifyIntervalType] [smallint] NULL,
	[MaxInactiveDays] [int] NULL,
 CONSTRAINT [InventryGauge_PK] PRIMARY KEY CLUSTERED 
(
	[ItemNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ITEMCLASS]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ITEMCLASS](
	[ItemClassNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ItemClass] [varchar](15) NOT NULL,
	[ItemClassDescription] [varchar](50) NULL,
	[DefaultBuyerGroupID] [varchar](12) NULL,
	[ItemRestrictionOption] [tinyint] NULL,
 CONSTRAINT [ITEMCLASS_PK] PRIMARY KEY CLUSTERED 
(
	[ItemClassNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ItemInventory]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ItemInventory](
	[CribBin] [varchar](15) NOT NULL,
	[ItemNumber] [varchar](12) NULL,
	[DateRequested] [datetime] NULL,
	[DateCounted] [datetime] NULL,
	[BinCount] [int] NULL,
	[BinQuantity] [int] NULL,
	[EmployeeNumber] [varchar](12) NULL,
	[DateReconciled] [datetime] NULL,
	[Crib] [smallint] NULL,
	[DateDue] [datetime] NULL,
	[CycleCountSettingsNo] [int] NULL,
 CONSTRAINT [ItemInventory_PK] PRIMARY KEY CLUSTERED 
(
	[CribBin] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ITEMLIMIT]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ITEMLIMIT](
	[ItemLimitNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[CraftCode] [varchar](12) NULL,
	[ItemNumber] [varchar](12) NULL,
	[ItemLimit] [int] NULL,
	[ItemLimitInterval] [int] NULL,
	[ItemLimitIntervalType] [tinyint] NULL,
	[ItemLimitOption] [tinyint] NULL,
 CONSTRAINT [PK_ITEMLIMIT] PRIMARY KEY CLUSTERED 
(
	[ItemLimitNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ItemLimitGrp]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ItemLimitGrp](
	[ItemLimitGrpNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[SiteID] [varchar](12) NOT NULL,
	[GrpName] [varchar](30) NOT NULL,
	[GrpDescription] [varchar](100) NULL,
	[GrpComments] [varchar](255) NULL,
	[GrpInactive] [bit] NULL,
 CONSTRAINT [PK_ItemLimitGrp] PRIMARY KEY CLUSTERED 
(
	[ItemLimitGrpNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ItemLimitGrpExt]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ItemLimitGrpExt](
	[ItemLimitGrpExtNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ItemLimitGrpNo] [int] NOT NULL,
	[ItemNumber] [varchar](12) NOT NULL,
 CONSTRAINT [PK_ItemLimitGrpExt] PRIMARY KEY CLUSTERED 
(
	[ItemLimitGrpExtNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ItemLimitGrpLimit]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ItemLimitGrpLimit](
	[ItemLimitGrpLimitNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[CraftCode] [varchar](12) NOT NULL,
	[ItemLimitGrpNo] [int] NOT NULL,
	[ItemLimit] [int] NULL,
	[ItemLimitInterval] [int] NULL,
	[ItemLimitIntervalType] [tinyint] NULL,
	[ItemLimitOption] [tinyint] NULL,
 CONSTRAINT [PK_ItemLimitGrpLimit] PRIMARY KEY CLUSTERED 
(
	[ItemLimitGrpLimitNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ItemRelationship]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ItemRelationship](
	[ItemRelationshipId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ItemNumber] [varchar](12) NOT NULL,
	[RelatedItemNumber] [varchar](12) NULL,
	[RelatedQuantity] [int] NULL,
	[Precedence] [int] NULL,
	[RelationshipTypeId] [int] NULL,
	[RelationshipCode] [varchar](30) NULL,
	[Comments] [varchar](255) NULL,
	[SpecialInstructions] [varchar](255) NULL,
	[RelationshipWODefNo] [int] NULL,
 CONSTRAINT [ITEMRELATIONSHIP_PK] PRIMARY KEY CLUSTERED 
(
	[ItemRelationshipId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ItemSerial]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ItemSerial](
	[SerialID] [varchar](18) NOT NULL,
	[ItemNumber] [varchar](12) NULL,
	[CribBin] [varchar](15) NULL,
	[Sequence] [smallint] NULL,
	[SerialNumber] [varchar](50) NULL,
	[Status] [int] NULL,
	[ParentID] [varchar](18) NULL,
	[Comments] [varchar](255) NULL,
	[StatusDate] [datetime] NULL,
	[DateInService] [datetime] NULL,
	[ExpirationDate] [datetime] NULL,
	[DateLastCount] [datetime] NULL,
	[RunUnits] [int] NULL,
	[RepairCalCycle] [smallint] NULL,
	[SerialIDEmployee] [varchar](12) NULL,
	[LotNo] [int] NULL,
	[ItemSerialCost] [decimal](19, 4) NULL,
	[StatusReasonCode] [varchar](4) NULL,
	[Manufacturer] [varchar](50) NULL,
	[MfrNumber] [varchar](30) NULL,
	[AltScanCode] [varchar](50) NULL,
	[ItemSerial_AddDate] [datetime] NULL,
	[ItemSerial_AddUID] [varchar](12) NULL,
	[ItemSerial_UpdateDate] [datetime] NULL,
	[ItemSerial_UpdateUID] [varchar](12) NULL,
	[HomeCrib] [int] NULL,
	[ReturnOption] [tinyint] NULL,
	[AssemblyStatus] [tinyint] NULL,
	[Locked] [smallint] NULL,
	[DateLastIssue] [datetime] NULL,
	[AssetNo] [int] NULL,
 CONSTRAINT [ItemSerial_PK] PRIMARY KEY CLUSTERED 
(
	[SerialID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ItemStatus]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ItemStatus](
	[ItemStatusCode] [varchar](4) NOT NULL,
	[ItemStatusDescription] [varchar](50) NULL,
 CONSTRAINT [ItemStatus_PK] PRIMARY KEY CLUSTERED 
(
	[ItemStatusCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ItemType]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ItemType](
	[ItemType] [int] NOT NULL,
	[ItemTypeDesc] [varchar](32) NULL,
 CONSTRAINT [aaaaaItemType_PK] PRIMARY KEY CLUSTERED 
(
	[ItemType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[KIT]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[KIT](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[KitNumber] [varchar](12) NULL,
	[KitDescription] [varchar](50) NULL,
	[ItemNumber] [varchar](12) NULL,
	[Quantity] [smallint] NULL,
	[AccessCode] [varchar](2) NULL,
	[KitSequence] [int] NULL,
	[Kit_AddDate] [datetime] NULL,
	[Kit_AddUID] [varchar](12) NULL,
	[Kit_UpdateDate] [datetime] NULL,
	[Kit_UpdateUID] [varchar](12) NULL,
 CONSTRAINT [KIT_PK] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[License]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[License](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[LicenseType] [smallint] NULL,
	[MachineID] [varchar](50) NULL,
	[Expiration] [datetime] NULL,
	[CheckInTime] [datetime] NULL,
	[KeyGuard] [int] NULL,
	[RefreshTime] [datetime] NULL,
	[RemainingTime] [int] NULL,
	[LicenseFlag] [int] NULL,
	[LicenseSiteID] [varchar](12) NULL,
	[LicenseEmployeeID] [varchar](12) NULL,
 CONSTRAINT [License_PK] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LicenseType]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LicenseType](
	[LicenseType] [int] NOT NULL,
	[Description] [varchar](50) NULL,
 CONSTRAINT [LicenseType_PK] PRIMARY KEY CLUSTERED 
(
	[LicenseType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LinkedFiles]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LinkedFiles](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[KeyName] [varchar](20) NULL,
	[FileName] [varchar](255) NULL,
	[Description] [varchar](30) NULL,
	[TableType] [int] NULL,
	[PrintCodes] [varchar](20) NULL,
 CONSTRAINT [LinkedFiles_PK] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LoginHistory]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoginHistory](
	[LoginHistoryNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[EmployeeID] [varchar](12) NULL,
	[LoginHistoryDate] [datetime] NOT NULL,
	[LoginEventType] [tinyint] NOT NULL,
	[Application] [varchar](15) NOT NULL,
	[ApplicationVersion] [varchar](14) NOT NULL,
	[EmplPassword] [varchar](10) NULL,
	[IPAddress] [varchar](16) NULL,
	[MACAddress] [varchar](18) NULL,
	[TerminalID] [varchar](32) NULL,
	[Comments] [varchar](255) NULL,
 CONSTRAINT [LOGINHISTORY_PK] PRIMARY KEY CLUSTERED 
(
	[LoginHistoryNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LotNumber]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LotNumber](
	[LotNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[LotItemNumber] [varchar](12) NULL,
	[LotNumber] [varchar](30) NULL,
	[LotCreationDate] [datetime] NULL,
	[LotExpirationDate] [datetime] NULL,
	[LotInactive] [bit] NOT NULL DEFAULT (0),
	[LotTotalQuantity] [int] NULL,
	[LotComments] [varchar](255) NULL,
	[LotLastTransDate] [datetime] NULL,
 CONSTRAINT [PK_LOTNUMBER] PRIMARY KEY CLUSTERED 
(
	[LotNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[M2mPO]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[M2mPO](
	[PONumber] [int] NOT NULL,
	[InM2m] [bit] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[NamedSearch]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[NamedSearch](
	[NamedSearchNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[SearchName] [varchar](25) NULL,
	[SearchText] [varchar](50) NULL,
	[ViewPaneClassId] [int] NOT NULL,
	[EmployeeID] [varchar](12) NULL,
	[IsPublicSearch] [tinyint] NULL,
	[ExtraSearchCriteria] [tinyint] NULL,
 CONSTRAINT [NAMEDSEARCH_PK] PRIMARY KEY CLUSTERED 
(
	[NamedSearchNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[NamedSearchField]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[NamedSearchField](
	[NamedSearchFieldNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[FieldName] [varchar](50) NOT NULL,
	[IncludeInSearch] [tinyint] NULL,
	[SearchCriteria] [varchar](50) NULL,
	[NamedSearchNo] [int] NOT NULL,
 CONSTRAINT [NAMEDSEARCHFIELD_PK] PRIMARY KEY CLUSTERED 
(
	[NamedSearchFieldNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[NamedSearchTBFilter]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NamedSearchTBFilter](
	[NamedSearchTBFilterNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Status] [tinyint] NOT NULL,
	[NamedSearchNo] [int] NOT NULL,
	[ToolbarFilterButtonId] [int] NOT NULL,
 CONSTRAINT [NAMEDSEARCHTBFILTER_PK] PRIMARY KEY CLUSTERED 
(
	[NamedSearchTBFilterNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[NetStat]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[NetStat](
	[StationName] [varchar](30) NULL,
	[LogTime] [datetime] NULL,
	[Action] [varchar](250) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[NetStatX]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[NetStatX](
	[StationNumber] [int] NULL,
	[StationOwner] [int] NULL,
	[StationType] [int] NULL,
	[LogTime] [datetime] NULL,
	[Action] [varchar](255) NULL,
	[HomeData] [varchar](255) NULL,
	[NotifyStatus] [tinyint] NULL,
	[NotifyStatusDate] [datetime] NULL,
	[LastSyncDate] [datetime] NULL,
	[ClientVersion] [varchar](30) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Paste Errors]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Paste Errors](
	[CribBin] [nvarchar](255) NULL,
	[Crib] [smallint] NULL,
	[Bin] [nvarchar](255) NULL,
	[Item] [nvarchar](255) NULL,
	[BinQuantity] [int] NULL,
	[Quantity] [int] NULL,
	[OnOrder] [int] NULL,
	[Comments] [nvarchar](255) NULL,
	[StopOrdering] [bit] NOT NULL,
	[OrderNowQuantity] [int] NULL,
	[ForceOrder] [int] NULL,
	[OrderPoint] [int] NULL,
	[Expr2] [float] NULL,
	[Expr1] [float] NULL,
	[OrderQuantity] [int] NULL,
	[OverrideOrderQuantity] [int] NULL,
	[AvgLeadTime] [int] NULL,
	[OverrideAvgLeadTime] [int] NULL,
	[MaxLeadTime] [int] NULL,
	[OverrideMaxLeadTime] [int] NULL,
	[MonthlyUsage] [int] NULL,
	[OverrideMonthlyUsage] [int] NULL,
	[SafetyStock] [int] NULL,
	[Expr1023] [int] NULL,
	[OverrideSafetyStock] [int] NULL,
	[UsageThisMonth] [int] NULL,
	[BinCapacity] [int] NULL,
	[MinOrder] [int] NULL,
	[StockFromCribBin] [nvarchar](255) NULL,
	[DateLastCount] [smalldatetime] NULL,
	[DateLastIssue] [smalldatetime] NULL,
	[DateLastReceipt] [smalldatetime] NULL,
	[CountType] [int] NULL,
	[PendingRework] [int] NULL,
	[OverrideDefaultQty] [int] NULL,
	[Consignment] [int] NULL,
	[OverrideIssuePrice] [float] NULL,
	[PriceType] [smallint] NULL,
	[TotalValue] [float] NULL,
	[TotalPrice] [float] NULL,
	[StationAutoPurchase] [bit] NOT NULL,
	[CriticalPoint] [int] NULL,
	[IsSurplus] [bit] NOT NULL,
	[ExcessFloor] [int] NULL,
	[OverrideExcessFloor] [int] NULL,
	[ExcessQuantity] [int] NULL,
	[BinType] [tinyint] NULL,
	[StationCheckOutTimeLimit] [smallint] NULL,
	[Station_AddDate] [smalldatetime] NULL,
	[Station_AddUID] [nvarchar](255) NULL,
	[Station_UpdateDate] [smalldatetime] NULL,
	[Station_UpdateUID] [nvarchar](255) NULL,
	[StorageSpace] [smallint] NULL,
	[CribSpaceId] [int] NULL,
	[PrimaryCribBin] [nvarchar](255) NULL,
	[AutoDelete] [bit] NOT NULL,
	[FIFOTrackingOption] [tinyint] NULL,
	[OvrAltVendorNo] [int] NULL,
	[TransfersIn] [int] NULL,
	[TransfersOut] [int] NULL,
	[ReservationAddQty] [int] NULL,
	[ReservationMinQty] [int] NULL,
	[StopIssue] [bit] NOT NULL,
	[UDF_SECTION] [nvarchar](255) NULL,
	[OvrCycleCountClassNo] [int] NULL,
	[DateLastRecalculated] [smalldatetime] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PendingOrder]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PendingOrder](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[VendorNumber] [varchar](12) NULL,
	[ItemNumber] [varchar](12) NULL,
	[CribBin] [varchar](15) NULL,
	[VendorItemNumber] [varchar](30) NULL,
	[Cost] [decimal](19, 4) NULL,
	[Type] [int] NULL,
	[NeedQuantity] [int] NULL,
	[Quantity] [int] NULL,
	[Description1] [varchar](50) NULL,
	[Description2] [varchar](50) NULL,
	[Comments] [varchar](255) NULL,
	[Special] [varchar](20) NULL,
	[DatePromised] [datetime] NULL,
	[DateRequired] [datetime] NULL,
	[OriginalPODetail] [int] NULL,
	[ConfirmNumber] [varchar](20) NULL,
	[CostFlag] [int] NULL,
	[WONo] [int] NULL,
	[DistCost] [decimal](19, 4) NULL,
	[SalesTaxable] [smallint] NULL,
	[PendingOrderType] [tinyint] NULL,
	[User1] [varchar](12) NULL,
	[User2] [varchar](12) NULL,
	[User3] [varchar](12) NULL,
	[User4] [varchar](12) NULL,
	[User5] [varchar](12) NULL,
	[User6] [varchar](12) NULL,
	[Crib] [smallint] NULL,
	[PendingOrderUPCCode] [varchar](20) NULL,
	[PendingOrderBatchID] [int] NULL,
	[MinOrderQuantity] [int] NULL,
	[AltVendorNo] [int] NULL,
	[SuggestedQuantity] [int] NULL,
	[RequiresInspection] [tinyint] NULL,
	[ItemWithOrder] [bit] NULL,
	[ReqDetNo] [int] NULL,
	[PendingOrderDate] [datetime] NULL,
 CONSTRAINT [PendingOrder_PK] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PendingOrderType]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PendingOrderType](
	[PendingOrderTypeNo] [int] NOT NULL,
	[PendingOrderTypeDescription] [varchar](20) NULL,
 CONSTRAINT [PendingOrderType_PK] PRIMARY KEY CLUSTERED 
(
	[PendingOrderTypeNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PendingPrice]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PendingPrice](
	[PendingPriceID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[CribBin] [varchar](15) NULL,
	[Quantity] [int] NULL,
	[Consignment] [int] NULL,
	[PriceType] [int] NULL,
	[DateCreated] [datetime] NULL,
	[EmployeeID] [varchar](12) NULL,
	[IssuePrice] [decimal](19, 4) NULL,
 CONSTRAINT [PendingPrice_PK] PRIMARY KEY CLUSTERED 
(
	[PendingPriceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PickList]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PickList](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[CribEmplNumber] [varchar](12) NULL,
	[CribEmplName] [varchar](50) NULL,
	[EmployeeNumber] [varchar](12) NULL,
	[EmployeeName] [varchar](50) NULL,
	[User1] [varchar](12) NULL,
	[User1Desc] [varchar](50) NULL,
	[User4] [varchar](12) NULL,
	[User4Desc] [varchar](50) NULL,
	[User5] [varchar](12) NULL,
	[User3] [varchar](12) NULL,
	[User3Desc] [varchar](50) NULL,
	[CribBin] [varchar](15) NULL,
	[ItemNumber] [varchar](12) NULL,
	[ItemName] [varchar](50) NULL,
	[Quantity] [int] NULL,
	[User2] [varchar](15) NULL,
	[User2Desc] [varchar](50) NULL,
	[User5Desc] [varchar](50) NULL,
	[User6] [varchar](15) NULL,
	[User6Desc] [varchar](15) NULL,
	[KitItemNumber] [varchar](12) NULL,
	[PickListBatchID] [int] NULL,
	[SerialID] [varchar](18) NULL,
 CONSTRAINT [PickList_PK] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PO]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PO](
	[PONumber] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[PODate] [datetime] NULL,
	[Vendor] [varchar](12) NULL,
	[VendorPO] [varchar](12) NULL,
	[DateRequired] [varchar](15) NULL,
	[Shipping] [varchar](50) NULL,
	[Address1] [varchar](50) NULL,
	[Address2] [varchar](50) NULL,
	[Address3] [varchar](50) NULL,
	[Address4] [varchar](50) NULL,
	[ShipTo1] [varchar](50) NULL,
	[ShipTo2] [varchar](50) NULL,
	[ShipTo3] [varchar](50) NULL,
	[ShipTo4] [varchar](50) NULL,
	[Comments] [varchar](255) NULL,
	[Type] [int] NULL,
	[Phone] [varchar](20) NULL,
	[FaxPhone] [varchar](20) NULL,
	[EdiPhone] [varchar](50) NULL,
	[BlanketPO] [varchar](12) NULL,
	[BillTo1] [varchar](50) NULL,
	[BillTo2] [varchar](50) NULL,
	[BillTo3] [varchar](50) NULL,
	[BillTo4] [varchar](50) NULL,
	[Freight] [decimal](19, 4) NULL,
	[EMailAddress] [varchar](50) NULL,
	[Terms] [varchar](30) NULL,
	[SiteID] [varchar](12) NULL,
	[PrintCount] [smallint] NULL,
	[POStatusNo] [tinyint] NULL,
	[POStatusDate] [datetime] NULL,
	[PORequestorID] [varchar](12) NULL,
	[POApproverID] [varchar](12) NULL,
	[SalesTaxPercent] [decimal](19, 4) NULL,
	[PoCreatedByID] [varchar](12) NULL,
	[PO_AddDate] [datetime] NULL,
	[PO_AddUID] [varchar](12) NULL,
	[PO_UpdateDate] [datetime] NULL,
	[PO_UpdateUID] [varchar](12) NULL,
	[AccountNumber] [varchar](30) NULL,
	[DeliverTo] [varchar](30) NULL,
	[POBuyerID] [varchar](12) NULL,
 CONSTRAINT [PO_PK] PRIMARY KEY CLUSTERED 
(
	[PONumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PODETAIL]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PODETAIL](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[PONumber] [int] NULL,
	[Item] [varchar](12) NULL,
	[Quantity] [smallint] NULL,
	[Received] [datetime] NULL,
	[ReceivedTime] [varchar](11) NULL,
	[CribBin] [varchar](15) NULL,
	[VendorNumber] [varchar](12) NULL,
	[ItemDescription] [varchar](50) NULL,
	[Crib] [smallint] NULL,
	[DateOrdered] [datetime] NULL,
	[UPCCode] [varchar](20) NULL,
	[Cost] [decimal](19, 4) NULL,
	[Type] [int] NULL,
	[BlanketPO] [varchar](12) NULL,
	[VendorItemNumber] [varchar](30) NULL,
	[SalesTaxable] [smallint] NULL,
	[VendorPONumber] [varchar](16) NULL,
	[Description2] [varchar](50) NULL,
	[Special] [varchar](20) NULL,
	[Comments] [varchar](50) NULL,
	[PromisedDate] [datetime] NULL,
	[RequiredDate] [datetime] NULL,
	[OriginalPODetail] [int] NULL,
	[ReturnedDate] [datetime] NULL,
	[ConfirmNumber] [varchar](20) NULL,
	[WONo] [int] NULL,
	[DistCost] [decimal](19, 4) NULL,
	[User1] [varchar](12) NULL,
	[User2] [varchar](12) NULL,
	[User3] [varchar](12) NULL,
	[User4] [varchar](12) NULL,
	[User5] [varchar](12) NULL,
	[User6] [varchar](12) NULL,
	[PODetailStatus] [tinyint] NULL,
	[ToInspectionDate] [datetime] NULL,
	[ReasonCode] [varchar](4) NULL,
	[OriginalSeqNo] [int] NULL,
	[PODetail_AddDate] [datetime] NULL,
	[PODetail_AddUID] [varchar](12) NULL,
	[PODetail_UpdateDate] [datetime] NULL,
	[PODetail_UpdateUID] [varchar](12) NULL,
	[AltVendorNo] [int] NULL,
	[OriginalPromisedDate] [datetime] NULL,
	[PromisedDateRevision] [int] NULL,
	[RequiresInspection] [tinyint] NULL,
	[AltReceiveToCribBin] [varchar](15) NULL,
	[OriginalQuantity] [int] NULL,
	[ItemWithOrder] [bit] NULL,
	[UDF_POCATEGORY] [varchar](8) NULL,
	[UDFHSPOCAT] [varchar](8) NULL,
	[ReqDetNo] [int] NULL,
 CONSTRAINT [PODETAIL_PK] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PODetailReasonCode]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PODetailReasonCode](
	[ReasonCode] [varchar](4) NOT NULL,
	[ReasonCodeDescription] [varchar](50) NULL,
 CONSTRAINT [PK_PODetailReasonCode] PRIMARY KEY CLUSTERED 
(
	[ReasonCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[POStatus]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[POStatus](
	[POStatusNo] [tinyint] NOT NULL,
	[POStatusDescription] [varchar](20) NULL,
 CONSTRAINT [POSTATUS_PK] PRIMARY KEY CLUSTERED 
(
	[POStatusNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PoType]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PoType](
	[ID] [int] NOT NULL,
	[Name] [varchar](8) NULL,
 CONSTRAINT [PoType_PK] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PriceType]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PriceType](
	[PriceType] [smallint] NOT NULL,
	[PriceTypeDesc] [varchar](20) NULL,
 CONSTRAINT [PriceType_PK] PRIMARY KEY CLUSTERED 
(
	[PriceType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ReasonCode]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ReasonCode](
	[ReasonCode] [varchar](4) NOT NULL,
	[ReasonCodeDescription] [varchar](50) NULL,
	[ReasonCodeFlag] [tinyint] NULL,
 CONSTRAINT [PK_REASONCODE] PRIMARY KEY CLUSTERED 
(
	[ReasonCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RecoveryBill]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RecoveryBill](
	[RecoveryBillNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[RecBillSiteID] [varchar](12) NULL,
	[RecBillNumber] [varchar](12) NULL,
	[RecBillVendorNumber] [varchar](12) NULL,
	[RecBillStartDate] [datetime] NULL,
	[RecBillEndDate] [datetime] NULL,
	[RecBillCreateDate] [datetime] NULL,
	[RecBillCreatedByID] [varchar](12) NULL,
	[RecBillApproveDate] [datetime] NULL,
	[RecBillApprovedByID] [varchar](12) NULL,
	[RecBillInvoiceDate] [datetime] NULL,
	[RecBillInvoicedByID] [varchar](12) NULL,
	[RecBillStatusNo] [tinyint] NULL,
	[RecBillStatusDate] [datetime] NULL,
	[RecBillComments] [varchar](255) NULL,
	[RecBillDateOption] [tinyint] NULL,
 CONSTRAINT [PK_RecoveryBill] PRIMARY KEY CLUSTERED 
(
	[RecoveryBillNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RecoveryBillDetail]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RecoveryBillDetail](
	[RecoveryBillDetailNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[RecoveryBillNo] [int] NOT NULL,
	[RecBillCribBin] [varchar](15) NOT NULL,
	[RecBillItemNumber] [varchar](12) NOT NULL,
	[RecBillBinQuantity] [int] NULL,
	[RecBillConsignedQuantity] [int] NULL,
	[RecoveryQuantity] [int] NULL,
	[RecoveryPrice] [decimal](19, 4) NULL,
	[RecoveryPriceExt] [decimal](19, 4) NULL,
	[RecBillDetailComments] [varchar](255) NULL,
	[RecBillTransNo] [int] NULL,
 CONSTRAINT [PK_RecoveryBillDetail] PRIMARY KEY CLUSTERED 
(
	[RecoveryBillDetailNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[redflag]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[redflag](
	[KeyID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ID] [varchar](12) NULL,
	[Category] [varchar](50) NULL,
	[Description] [varchar](50) NULL,
	[WeeklyAmount] [decimal](19, 4) NULL,
	[WeeklyRedFlag] [decimal](19, 4) NULL,
	[MonthlyAmount] [decimal](19, 4) NULL,
	[MonthlyRedFlag] [decimal](19, 4) NULL,
	[YearlyAmount] [decimal](19, 4) NULL,
	[YearlyRedFlag] [decimal](19, 4) NULL,
 CONSTRAINT [redflag_PK] PRIMARY KEY CLUSTERED 
(
	[KeyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RelationshipType]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RelationshipType](
	[RelationshipTypeId] [int] NOT NULL,
	[RelationshipTypeName] [varchar](50) NULL,
	[Predefined] [bit] NULL,
	[UsageType] [int] NULL,
 CONSTRAINT [PK_RelationshipTypeId] PRIMARY KEY CLUSTERED 
(
	[RelationshipTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Reports]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Reports](
	[ReportId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ReportSectionId] [int] NOT NULL,
	[ReportName] [varchar](128) NOT NULL,
	[ReportFilename] [varchar](255) NOT NULL,
	[ReportSequence] [int] NULL,
	[ReportAutoSelect] [tinyint] NULL,
	[ReportDisableSort] [tinyint] NULL,
	[ReportHeader] [varchar](255) NULL,
	[ReportFooter] [varchar](255) NULL,
	[SensitivityLevel] [int] NULL,
	[ReportDescription] [varchar](255) NULL,
	[InteractiveOption] [tinyint] NULL,
	[ReportSiteOption] [tinyint] NULL,
	[ReportInactive] [bit] NULL,
 CONSTRAINT [REPORT_PK] PRIMARY KEY CLUSTERED 
(
	[ReportId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ReportSchedule]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ReportSchedule](
	[ReportScheduleNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ExecuteInterval] [tinyint] NOT NULL,
	[ExecuteTime] [varchar](10) NULL,
	[ParameterFileName] [varchar](255) NULL,
	[PrinterName] [varchar](255) NULL,
	[ServerPrint] [bit] NULL,
	[FaxPhone] [varchar](50) NULL,
	[EmailAddress] [varchar](255) NULL,
	[LastExecuteDate] [datetime] NULL,
	[NextExecuteDate] [datetime] NULL,
	[EmployeeID] [varchar](12) NULL,
	[ReportDescription] [varchar](255) NULL,
	[CustomDateType] [int] NULL,
	[BinaryImageNo] [int] NULL,
	[CreationDate] [datetime] NULL,
 CONSTRAINT [PK_REPORTSCHEDULE] PRIMARY KEY CLUSTERED 
(
	[ReportScheduleNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ReportScheduleInterval]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ReportScheduleInterval](
	[ReportScheduleIntervalNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[IntervalDescription] [varchar](15) NOT NULL,
 CONSTRAINT [PK_REPORTSCHEDULEINTERVAL] PRIMARY KEY CLUSTERED 
(
	[ReportScheduleIntervalNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ReportSection]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ReportSection](
	[ReportSectionId] [int] NOT NULL,
	[ReportSectionName] [varchar](25) NOT NULL,
	[ReportSectionSchemaId] [tinyint] NULL,
 CONSTRAINT [REPORTSECTION_PK] PRIMARY KEY CLUSTERED 
(
	[ReportSectionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ReportSecurity]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReportSecurity](
	[ReportSecurityId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ReportId] [int] NOT NULL,
	[FunctionId] [int] NOT NULL,
	[ReportSecurityType] [tinyint] NULL,
 CONSTRAINT [REPORTSECURITY_PK] PRIMARY KEY CLUSTERED 
(
	[ReportSecurityId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ReportSite]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ReportSite](
	[ReportSiteNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ReportId] [int] NOT NULL,
	[SiteID] [varchar](12) NOT NULL,
	[SiteAccessOption] [tinyint] NULL,
 CONSTRAINT [PK_ReportSite] PRIMARY KEY CLUSTERED 
(
	[ReportSiteNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ReqDetReasonCode]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ReqDetReasonCode](
	[ReqDetReasonCode] [varchar](4) NOT NULL,
	[ReqDetReasonDescription] [varchar](50) NULL,
 CONSTRAINT [PK_ReqDetReasonCode] PRIMARY KEY CLUSTERED 
(
	[ReqDetReasonCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ReqDetReasonCodeExt]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ReqDetReasonCodeExt](
	[ReqDetReasonCode] [varchar](4) NOT NULL,
	[ReqDetStatusNo] [int] NOT NULL,
 CONSTRAINT [PK_ReqDetReasonCodeExt] PRIMARY KEY CLUSTERED 
(
	[ReqDetReasonCode] ASC,
	[ReqDetStatusNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Request]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Request](
	[ReqNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ReqCreatedDate] [datetime] NOT NULL,
	[ReqCreatedByID] [varchar](12) NOT NULL,
	[ReqStatusNo] [tinyint] NOT NULL,
	[ReqStatusDate] [datetime] NOT NULL,
	[ReqRequestorID] [varchar](12) NOT NULL,
	[ReqApproverID] [varchar](12) NULL,
	[ReqResearcherID] [varchar](12) NULL,
	[ReqAssignedToID] [varchar](12) NULL,
	[ReqDeliverTo] [varchar](100) NULL,
	[ReqComments] [varchar](255) NULL,
	[ReqCrib] [int] NULL,
	[ReqRequiredDate] [datetime] NULL,
	[ReqPriorityNo] [tinyint] NULL,
	[ReqUser1] [varchar](12) NULL,
	[ReqUser2] [varchar](12) NULL,
	[ReqUser3] [varchar](12) NULL,
	[ReqUser4] [varchar](12) NULL,
	[ReqUser5] [varchar](12) NULL,
	[ReqUser6] [varchar](12) NULL,
	[ReqOriginalReqNo] [int] NULL,
	[Request_AddDate] [datetime] NULL,
	[Request_AddUID] [varchar](12) NULL,
	[Request_UpdateDate] [datetime] NULL,
	[Request_UpdateUID] [varchar](12) NULL,
	[ReqAllowChangeOption] [tinyint] NULL,
 CONSTRAINT [PK_Request] PRIMARY KEY CLUSTERED 
(
	[ReqNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RequestDetail]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RequestDetail](
	[ReqDetNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ReqNo] [int] NOT NULL,
	[ReqDetSequence] [int] NULL,
	[ReqDetQuantity] [int] NULL,
	[ReqDetUOM] [varchar](30) NULL,
	[ReqDetItemNumber] [varchar](12) NULL,
	[ReqDetDescription1] [varchar](50) NULL,
	[ReqDetDescription2] [varchar](50) NULL,
	[ReqDetComments] [varchar](255) NULL,
	[ReqDetManufacturer] [varchar](50) NULL,
	[ReqDetMfrNumber] [varchar](30) NULL,
	[ReqDetRequiredDate] [datetime] NULL,
	[ReqDetVendorNumber] [varchar](12) NULL,
	[ReqDetStatusNo] [tinyint] NOT NULL,
	[ReqDetVendorItemNumber] [varchar](30) NULL,
	[ReqDetCost] [decimal](19, 4) NULL,
	[ReqDetPromiseDate] [datetime] NULL,
	[ReqDetOrderQty] [int] NULL,
	[ReqDetOrderUOM] [varchar](30) NULL,
	[ReqDetReceiveQty] [int] NULL,
	[ReqDetAltVendorNo] [int] NULL,
	[ReqDetStatusDate] [datetime] NULL,
	[ReqDetReasonCode] [varchar](4) NULL,
	[ReqDetOrderType] [tinyint] NULL,
	[RequestDetail_AddDate] [datetime] NULL,
	[RequestDetail_AddUID] [varchar](12) NULL,
	[RequestDetail_UpdateDate] [datetime] NULL,
	[RequestDetail_UpdateUID] [varchar](12) NULL,
 CONSTRAINT [PK_RequestDetail] PRIMARY KEY CLUSTERED 
(
	[ReqDetNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RequestRemarkHistory]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RequestRemarkHistory](
	[ReqRemHistoryNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ReqNo] [int] NOT NULL,
	[ReqDetNo] [int] NULL,
	[ReqRemEmployeeID] [varchar](12) NOT NULL,
	[ReqRemarkText] [varchar](255) NOT NULL,
	[ReqRemPrivateOption] [tinyint] NULL,
	[ReqRemDate] [datetime] NOT NULL,
 CONSTRAINT [PK_RequestRemarkHistory] PRIMARY KEY CLUSTERED 
(
	[ReqRemHistoryNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RequestStatusHistory]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RequestStatusHistory](
	[ReqStatHistoryNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ReqNo] [int] NOT NULL,
	[ReqStatusNo] [tinyint] NOT NULL,
	[ReqStatusDate] [datetime] NOT NULL,
	[ReqStatEmployeeID] [varchar](12) NOT NULL,
	[ReqStatAssignedToID] [varchar](12) NULL,
	[ReqStatApprovalOption] [tinyint] NULL,
	[ReqDetNo] [int] NULL,
	[ReqDetStatusNo] [tinyint] NULL,
	[ReqDetStatusReasonCode] [varchar](20) NULL,
 CONSTRAINT [PK_REQUESTSTATUSHISTORY] PRIMARY KEY CLUSTERED 
(
	[ReqStatHistoryNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Reservation]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Reservation](
	[ReservationNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[CreatedByEmployee] [varchar](12) NULL,
	[ReservedForEmployee] [varchar](12) NULL,
	[ApprovedByEmployee] [varchar](12) NULL,
	[DateCreated] [datetime] NOT NULL,
	[DateRequired] [datetime] NOT NULL,
	[ReservationType] [tinyint] NULL,
	[ReservationStatus] [tinyint] NOT NULL,
	[ReservationUser1] [varchar](12) NULL,
	[ReservationUser3] [varchar](12) NULL,
	[ReservationUser2] [varchar](12) NULL,
	[ReservationUser4] [varchar](12) NULL,
	[ReservationUser5] [varchar](12) NULL,
	[ReservationUser6] [varchar](12) NULL,
	[ReservationWONo] [int] NULL,
	[ReservationPriority] [tinyint] NULL,
	[ReservationComments] [varchar](255) NULL,
	[ReservationSpecialInstructions] [varchar](255) NULL,
	[ReservationWOCreateOption] [tinyint] NULL,
	[ReservationOrderOption] [tinyint] NULL,
	[ReservationWODefScheduleNo] [int] NULL,
	[ExpirationDate] [datetime] NULL,
	[ExternalID] [varchar](50) NULL,
	[ExternalSyncDate] [datetime] NULL,
	[ReservationStatusDate] [datetime] NULL,
 CONSTRAINT [RESERVATION_PK] PRIMARY KEY CLUSTERED 
(
	[ReservationNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ReservationDetail]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ReservationDetail](
	[ReservationDetailNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ReservationNo] [int] NOT NULL,
	[ReservationCribBin] [varchar](15) NULL,
	[ReservationCrib] [smallint] NOT NULL,
	[ReservationItemNumber] [varchar](12) NULL,
	[ReservationQuantity] [int] NOT NULL,
	[ReservationActualQuantity] [int] NOT NULL,
	[ReservationSerialID] [varchar](18) NULL,
	[ReservationPriority] [tinyint] NULL,
	[OriginalItemNumber] [varchar](12) NULL,
	[UsageType] [tinyint] NULL,
	[UsageCribBin] [varchar](15) NULL,
	[UsageItemNumber] [varchar](12) NULL,
	[ReservationDetailStatus] [tinyint] NOT NULL DEFAULT (0),
	[ReservationDetailComments] [varchar](255) NULL,
	[OvrOrderOption] [tinyint] NULL,
	[MinimumBidQuantity] [int] NULL,
	[IncrementQuantity] [int] NULL,
	[ReservePrice] [decimal](19, 4) NULL,
	[MinimumBid] [decimal](19, 4) NULL,
	[Units] [varchar](50) NULL,
	[CurrentBidCount] [int] NULL,
	[DateLastBid] [datetime] NULL,
	[SoldQuantity] [int] NULL,
	[CurrentBid] [decimal](19, 4) NULL,
	[BrokerCategory] [varchar](255) NULL,
	[BuyNowPrice] [decimal](19, 4) NULL,
	[BrokerCategoryName] [varchar](255) NULL,
	[ShippingCost] [decimal](19, 4) NULL,
	[IncrementShippingCost] [decimal](19, 4) NULL,
 CONSTRAINT [RESERVATIONDETAIL_PK] PRIMARY KEY CLUSTERED 
(
	[ReservationDetailNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ReservationHistory]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ReservationHistory](
	[ReservationHistoryNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ReservationNo] [int] NULL,
	[ReservationEmployeeId] [varchar](12) NULL,
	[ReservationStatusDate] [datetime] NULL,
	[ReservationStatusNo] [tinyint] NULL,
 CONSTRAINT [PK_ReservationHistory] PRIMARY KEY CLUSTERED 
(
	[ReservationHistoryNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ReservationStatus]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ReservationStatus](
	[ReservationStatus] [tinyint] NOT NULL,
	[ReservationStatusDesc] [varchar](20) NOT NULL,
 CONSTRAINT [RESERVATIONSTATUS_PK] PRIMARY KEY CLUSTERED 
(
	[ReservationStatus] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RFID]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RFID](
	[RFIDNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[RFID] [varchar](32) NULL,
	[EmployeeID] [varchar](12) NULL,
	[ItemNumber] [varchar](12) NULL,
	[SerialID] [varchar](18) NULL,
	[LotNo] [int] NULL,
	[CribBin] [varchar](15) NULL,
	[LastEmployee] [varchar](12) NULL,
	[LastTransaction] [datetime] NULL,
	[LastCrib] [int] NULL,
	[Status] [smallint] NULL,
	[ReadCount] [int] NULL,
	[RFID_AddDate] [datetime] NULL,
	[RFID_AddUID] [varchar](12) NULL,
	[RFID_UpdateDate] [datetime] NULL,
	[RFID_UpdateUID] [varchar](12) NULL,
	[ParentRFIDNo] [int] NULL,
	[OverrideCrib] [smallint] NULL,
	[TID] [varchar](32) NULL,
 CONSTRAINT [RFID_PK] PRIMARY KEY CLUSTERED 
(
	[RFIDNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RFIDACTIVITY]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RFIDACTIVITY](
	[RFIDActivityNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[RFIDTransNo] [int] NULL,
	[RFID] [varchar](32) NULL,
 CONSTRAINT [RFIDACTIVITY_PK] PRIMARY KEY CLUSTERED 
(
	[RFIDActivityNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RFIDCountDetail]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RFIDCountDetail](
	[RFIDCountDetailNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[RFIDCountSessionNo] [int] NOT NULL,
	[RFID] [varchar](32) NULL,
	[Hits] [int] NULL,
	[FirstSeen] [datetime] NULL,
	[LastSeen] [datetime] NULL,
 CONSTRAINT [PK_RFIDCountDetail] PRIMARY KEY CLUSTERED 
(
	[RFIDCountDetailNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RFIDCountSession]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RFIDCountSession](
	[RFIDCountSessionNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Crib] [int] NOT NULL,
	[EmployeeID] [varchar](12) NULL,
	[ScheduledTime] [datetime] NULL,
 CONSTRAINT [PK_RFIDCountSession] PRIMARY KEY CLUSTERED 
(
	[RFIDCountSessionNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RFIDLastSeenHistory]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RFIDLastSeenHistory](
	[RFIDLastSeenHistoryNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[RFIDNo] [int] NOT NULL,
	[RFIDReaderName] [varchar](32) NULL,
	[RFIDDateLastSeen] [datetime] NULL,
	[RFIDNotation] [varchar](32) NULL,
	[RFIDDateFirstSeen] [datetime] NULL,
 CONSTRAINT [RFIDLASTSEENHISTORY_PK] PRIMARY KEY CLUSTERED 
(
	[RFIDLastSeenHistoryNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RFIDTRANS]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RFIDTRANS](
	[RFIDTransNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[CaptureDate] [datetime] NULL,
	[Location] [varchar](20) NULL,
	[Direction] [varchar](10) NULL,
	[TagCount] [int] NULL,
	[XMLText] [text] NULL,
	[Image1No] [int] NULL,
	[Image2No] [int] NULL,
	[Image3No] [int] NULL,
	[Image4No] [int] NULL,
 CONSTRAINT [RFIDTRANS_PK] PRIMARY KEY CLUSTERED 
(
	[RFIDTransNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RunUnitsHistory]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RunUnitsHistory](
	[RunUnitsHistoryNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[AssetNo] [int] NOT NULL,
	[RunUnitsDate] [datetime] NULL,
	[RunUnits] [int] NULL,
	[MeterRunUnits] [int] NULL,
	[RunUnitsEmployeeID] [varchar](12) NULL,
 CONSTRAINT [PK_RUNUNITSHISTORY] PRIMARY KEY CLUSTERED 
(
	[RunUnitsHistoryNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SecAuditHistory]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SecAuditHistory](
	[SecAuditHistoryNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[SecurityGrpId] [int] NULL,
	[FunctionId] [int] NULL,
	[EmployeeId] [varchar](12) NULL,
	[Crib] [int] NULL,
	[SecAuditType] [tinyint] NULL,
	[SecScopeType] [tinyint] NULL,
	[SecAuditUID] [varchar](12) NULL,
	[SecAuditDate] [datetime] NULL,
 CONSTRAINT [PK_SecAuditHistory] PRIMARY KEY CLUSTERED 
(
	[SecAuditHistoryNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SECURITYACCESS]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SECURITYACCESS](
	[category] [varchar](50) NULL,
	[function] [varchar](50) NULL,
	[AccessCodeList] [varchar](50) NULL,
	[FunctionType] [tinyint] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SECURITYCLASS]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SECURITYCLASS](
	[class] [varchar](1) NOT NULL,
	[description] [varchar](50) NULL,
 CONSTRAINT [SECURITYCLASS_PK] PRIMARY KEY CLUSTERED 
(
	[class] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SecurityGrp]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SecurityGrp](
	[SecurityGrpId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[SecurityGrpName] [varchar](50) NOT NULL,
	[SecurityGrpDescription] [varchar](50) NULL,
 CONSTRAINT [SECURITYGRP_PK] PRIMARY KEY CLUSTERED 
(
	[SecurityGrpId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SecurityGrpAccess]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SecurityGrpAccess](
	[SecurityGrpAccessId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[SecurityGrpId] [int] NOT NULL,
	[FunctionId] [int] NOT NULL,
 CONSTRAINT [SECURITYGRPACCESS_PK] PRIMARY KEY CLUSTERED 
(
	[SecurityGrpAccessId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SerialStatus]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SerialStatus](
	[Status] [int] NOT NULL,
	[StatusDesc] [varchar](20) NULL,
 CONSTRAINT [SerialStatus_PK] PRIMARY KEY CLUSTERED 
(
	[Status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SerialStatusHistory]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SerialStatusHistory](
	[StatusHistoryID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[SerialId] [varchar](18) NULL,
	[Status] [int] NULL,
	[EmployeeId] [varchar](12) NULL,
	[StatusDate] [datetime] NULL,
	[SerialIDEmployee] [varchar](12) NULL,
	[StatusReasonCode] [varchar](4) NULL,
	[CribBin] [varchar](15) NULL,
	[ParentId] [varchar](18) NULL,
 CONSTRAINT [SerialStatusHistory_PK] PRIMARY KEY CLUSTERED 
(
	[StatusHistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SettingsTemplate]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SettingsTemplate](
	[SettingsTemplateNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[TemplateID] [varchar](12) NOT NULL,
	[TemplateDescription] [varchar](50) NULL,
	[TemplateComments] [varchar](255) NULL,
	[TemplateInactive] [bit] NULL,
 CONSTRAINT [PK_SettingsTemplate] PRIMARY KEY CLUSTERED 
(
	[SettingsTemplateNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SiteInventory]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SiteInventory](
	[SiteInventoryNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[SiteID] [varchar](12) NOT NULL,
	[ItemNumber] [varchar](12) NOT NULL,
	[SiteItemNumber] [varchar](50) NULL,
	[SiteItemDescription] [varchar](50) NULL,
	[SiteItemComments] [varchar](255) NULL,
	[OvrIssuePrice] [decimal](19, 4) NULL,
	[OvrAltVendorNo] [int] NULL,
	[OvrDefaultQty] [int] NULL,
	[OvrItemClass] [varchar](15) NULL,
	[OvrSiteAccessCode] [varchar](2) NULL,
 CONSTRAINT [PK_SiteInventory] PRIMARY KEY CLUSTERED 
(
	[SiteInventoryNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SiteProfile]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SiteProfile](
	[SiteID] [varchar](12) NOT NULL,
	[SiteDescription] [varchar](50) NULL,
	[SiteBuyerID] [varchar](12) NULL,
	[SitePOComment] [varchar](255) NULL,
	[SiteShipping] [varchar](50) NULL,
	[SiteBillTo1] [varchar](50) NULL,
	[SiteBillTo2] [varchar](50) NULL,
	[SiteBillTo3] [varchar](50) NULL,
	[SiteBillTo4] [varchar](50) NULL,
	[SiteShipTo1] [varchar](50) NULL,
	[SiteShipTo2] [varchar](50) NULL,
	[SiteShipTo3] [varchar](50) NULL,
	[SiteShipTo4] [varchar](50) NULL,
	[SitePhone] [varchar](20) NULL,
	[SiteFaxPhone] [varchar](20) NULL,
	[SiteCompanyName] [varchar](50) NULL,
	[SiteName] [varchar](64) NULL,
	[RecoveryVendorNumber] [varchar](12) NULL,
	[NextRecoveryBillNumber] [varchar](12) NULL,
	[SiteOvrAutoPurchaseDays] [int] NULL,
	[SitePOApprovalOption] [tinyint] NULL,
	[SitePOApproverID] [varchar](12) NULL,
	[SitePOEMailAddress] [varchar](255) NULL,
	[SiteWebLicenseCount] [int] NULL,
	[SitePrefix] [varchar](3) NULL,
	[SiteGroupID] [varchar](12) NULL,
	[SiteInactive] [bit] NULL,
	[SiteDefaultLocale] [varchar](20) NULL,
	[SiteTimeZoneID] [varchar](32) NULL,
	[SiteCribAccessOption] [tinyint] NULL,
	[ParentSiteID] [varchar](12) NULL,
	[SiteOvrBroadcastMsg] [varchar](255) NULL,
	[SiteUserOverrideNo] [int] NULL,
	[SiteSettingsTemplateNo] [int] NULL,
	[SiteSalesTaxPercent] [decimal](19, 4) NULL,
	[BarCodeMappingOption] [tinyint] NULL,
 CONSTRAINT [SiteProfile_PK] PRIMARY KEY CLUSTERED 
(
	[SiteID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[STATION]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[STATION](
	[CribBin] [varchar](15) NOT NULL,
	[Crib] [smallint] NOT NULL,
	[Bin] [varchar](12) NULL,
	[Item] [varchar](12) NULL,
	[BinQuantity] [int] NULL,
	[Quantity] [int] NULL,
	[OnOrder] [int] NULL,
	[Comments] [varchar](50) NULL,
	[StopOrdering] [bit] NOT NULL,
	[OrderNowQuantity] [int] NULL,
	[ForceOrder] [int] NULL,
	[OrderPoint] [int] NULL,
	[OverrideOrderPoint] [int] NULL,
	[Maximum] [int] NULL,
	[OrderQuantity] [int] NULL,
	[OverrideOrderQuantity] [int] NULL,
	[AvgLeadTime] [int] NULL,
	[OverrideAvgLeadTime] [int] NULL,
	[MaxLeadTime] [int] NULL,
	[OverrideMaxLeadTime] [int] NULL,
	[MonthlyUsage] [int] NULL,
	[OverrideMonthlyUsage] [int] NULL,
	[SafetyStock] [int] NULL,
	[OverrideSafetyStock] [int] NULL,
	[UsageThisMonth] [int] NULL,
	[BinCapacity] [int] NULL,
	[MinOrder] [int] NULL,
	[StockFromCribBin] [varchar](15) NULL,
	[DateLastCount] [datetime] NULL,
	[DateLastIssue] [datetime] NULL,
	[DateLastReceipt] [datetime] NULL,
	[CountType] [int] NULL,
	[PendingRework] [int] NULL,
	[OverrideDefaultQty] [int] NULL,
	[Consignment] [int] NULL,
	[OverrideIssuePrice] [decimal](19, 4) NULL,
	[PriceType] [smallint] NULL,
	[TotalValue] [decimal](19, 4) NULL,
	[TotalPrice] [decimal](19, 4) NULL,
	[StationAutoPurchase] [tinyint] NULL,
	[CriticalPoint] [int] NULL,
	[IsSurplus] [tinyint] NULL,
	[ExcessFloor] [int] NULL,
	[OverrideExcessFloor] [int] NULL,
	[ExcessQuantity] [int] NULL,
	[BinType] [tinyint] NULL,
	[StationCheckOutTimeLimit] [smallint] NULL,
	[Station_AddDate] [datetime] NULL,
	[Station_AddUID] [varchar](12) NULL,
	[Station_UpdateDate] [datetime] NULL,
	[Station_UpdateUID] [varchar](12) NULL,
	[StorageSpace] [smallint] NULL,
	[CribSpaceId] [int] NULL,
	[PrimaryCribBin] [varchar](15) NULL,
	[AutoDelete] [bit] NULL,
	[FIFOTrackingOption] [tinyint] NULL,
	[OvrAltVendorNo] [int] NULL,
	[TransfersIn] [int] NULL,
	[TransfersOut] [int] NULL,
	[ReservationAddQty] [int] NULL,
	[ReservationMinQty] [int] NULL,
	[StopIssue] [bit] NULL,
	[OvrCycleCountClassNo] [int] NULL,
	[DateLastRecalculated] [datetime] NULL,
	[StationLotNo] [int] NULL,
	[UDF_SECTION] [varchar](20) NULL,
	[UnitWeight] [decimal](19, 4) NULL,
	[ConsignedQuantity] [int] NULL,
	[ConsignedPrice] [decimal](19, 4) NULL,
	[BurnQuantity] [int] NULL,
	[ConsignmentOption] [tinyint] NULL,
	[UnitWeightQuantity] [smallint] NULL,
	[ScaleCapacity] [smallint] NULL,
	[StationBillingOption] [tinyint] NULL,
	[AvgBinQuantity] [decimal](19, 4) NULL,
 CONSTRAINT [STATION_PK] PRIMARY KEY CLUSTERED 
(
	[CribBin] ASC,
	[Crib] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[StationHistory]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[StationHistory](
	[CribBin] [varchar](15) NOT NULL,
	[Prev1] [int] NULL,
	[Prev2] [int] NULL,
	[Prev3] [int] NULL,
	[Prev4] [int] NULL,
	[Prev5] [int] NULL,
	[Prev6] [int] NULL,
	[Prev7] [int] NULL,
	[Prev8] [int] NULL,
	[Prev9] [int] NULL,
	[Prev10] [int] NULL,
	[Prev11] [int] NULL,
	[Prev12] [int] NULL,
	[Prev13] [int] NULL,
	[Prev14] [int] NULL,
	[Prev15] [int] NULL,
	[Prev16] [int] NULL,
	[Prev17] [int] NULL,
	[Prev18] [int] NULL,
	[Prev19] [int] NULL,
	[Prev20] [int] NULL,
	[Prev21] [int] NULL,
	[Prev22] [int] NULL,
	[Prev23] [int] NULL,
	[Prev24] [int] NULL,
 CONSTRAINT [StationHistory_PK] PRIMARY KEY CLUSTERED 
(
	[CribBin] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[StatusReasonCode]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[StatusReasonCode](
	[StatusReasonCode] [varchar](4) NOT NULL,
	[StatusReasonDescription] [varchar](50) NULL,
 CONSTRAINT [PK_SerialStatusReason] PRIMARY KEY CLUSTERED 
(
	[StatusReasonCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[StatusReasonCodeExt]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[StatusReasonCodeExt](
	[StatusReasonCode] [varchar](4) NOT NULL,
	[SerialStatusNo] [int] NOT NULL,
 CONSTRAINT [PK_StatusReasonValid] PRIMARY KEY CLUSTERED 
(
	[StatusReasonCode] ASC,
	[SerialStatusNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Stuff]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Stuff](
	[ID] [int] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SystemValue]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SystemValue](
	[SVNumber] [int] NOT NULL,
	[SVType] [int] NOT NULL,
	[SVName] [varchar](50) NULL,
	[SVDescription] [varchar](255) NULL,
 CONSTRAINT [PK_SystemValue] PRIMARY KEY CLUSTERED 
(
	[SVNumber] ASC,
	[SVType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TableAudit]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TableAudit](
	[TableName] [varchar](50) NOT NULL,
	[TableAuditType] [tinyint] NULL,
	[TableAuditSchemaID] [int] NULL,
 CONSTRAINT [PK_TABLEAUDIT] PRIMARY KEY CLUSTERED 
(
	[TableName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TableAuditField]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TableAuditField](
	[TableAuditFieldNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[TableName] [varchar](50) NULL,
	[FieldName] [varchar](50) NULL,
	[FieldAuditType] [tinyint] NULL,
 CONSTRAINT [PK_TABLEAUDITFIELD] PRIMARY KEY CLUSTERED 
(
	[TableAuditFieldNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TableAuditHistory]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TableAuditHistory](
	[TableAuditHistoryNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[TableName] [varchar](50) NOT NULL,
	[FieldName] [varchar](50) NOT NULL,
	[KeyValue] [varchar](50) NOT NULL,
	[AuditDate] [datetime] NOT NULL,
	[AuditType] [tinyint] NULL,
	[AuditUID] [varchar](12) NULL,
	[PreviousValue] [varchar](255) NULL,
	[CurrentValue] [varchar](255) NULL,
 CONSTRAINT [PK_TABLEAUDITHISTORY] PRIMARY KEY CLUSTERED 
(
	[TableAuditHistoryNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Task]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Task](
	[TaskNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[TaskID] [varchar](12) NULL,
	[TaskType] [int] NULL,
	[TaskDescription] [varchar](255) NULL,
	[TaskComment] [varchar](128) NULL,
	[CraftCode] [varchar](12) NULL,
	[TaskEstimatedDuration] [decimal](19, 4) NULL,
	[TaskRevision] [int] NULL,
	[TaskInactive] [bit] NOT NULL,
	[TaskEstimatedCost] [decimal](19, 4) NULL,
	[Task_AddDate] [datetime] NULL,
	[Task_AddUID] [varchar](12) NULL,
	[Task_UpdateDate] [datetime] NULL,
	[Task_UpdateUID] [varchar](12) NULL,
 CONSTRAINT [PK_TASK] PRIMARY KEY CLUSTERED 
(
	[TaskNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TaskItem]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TaskItem](
	[TaskItemNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[TaskNo] [int] NULL,
	[TaskItemNumber] [varchar](12) NULL,
	[TaskItemQuantity] [int] NULL,
	[ActionCode] [varchar](4) NULL,
	[WODefNo] [int] NULL,
	[TaskItem_AddDate] [datetime] NULL,
	[TaskItem_AddUID] [varchar](12) NULL,
	[TaskItem_UpdateDate] [datetime] NULL,
	[TaskItem_UpdateUID] [varchar](12) NULL,
 CONSTRAINT [PK_TASKITEM] PRIMARY KEY CLUSTERED 
(
	[TaskItemNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Template]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Template](
	[TemplateID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[TemplateName] [varchar](50) NULL,
	[TableName] [varchar](20) NULL,
	[Label1] [varchar](20) NULL,
	[Label2] [varchar](20) NULL,
	[Label3] [varchar](20) NULL,
	[Label4] [varchar](20) NULL,
	[Label5] [varchar](20) NULL,
	[Label6] [varchar](20) NULL,
	[Label7] [varchar](20) NULL,
	[Label8] [varchar](20) NULL,
	[Label9] [varchar](20) NULL,
	[Label10] [varchar](20) NULL,
	[Label11] [varchar](20) NULL,
	[Label12] [varchar](20) NULL,
	[Label13] [varchar](20) NULL,
	[Label14] [varchar](20) NULL,
	[Label15] [varchar](20) NULL,
	[Label16] [varchar](20) NULL,
	[Label17] [varchar](20) NULL,
	[Label18] [varchar](20) NULL,
 CONSTRAINT [Template_PK] PRIMARY KEY CLUSTERED 
(
	[TemplateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ToolbarFilterButton]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ToolbarFilterButton](
	[ToolbarFilterButtonId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ToolbarName] [varchar](25) NOT NULL,
	[ViewPaneClassId] [int] NOT NULL,
 CONSTRAINT [TOOLBARFILTERBUTTON_PK] PRIMARY KEY CLUSTERED 
(
	[ToolbarFilterButtonId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[toolinv]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[toolinv](
	[itemNumber] [nvarchar](12) NOT NULL,
	[binlocList] [nvarchar](max) NULL,
	[totqty] [int] NULL,
	[plant] [nvarchar](5) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TRANS]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TRANS](
	[transnumber] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[station] [varchar](2) NULL,
	[bin] [varchar](12) NULL,
	[Item] [varchar](12) NULL,
	[OldItem] [varchar](12) NULL,
	[employee] [varchar](12) NULL,
	[User1] [varchar](12) NULL,
	[User3] [varchar](12) NULL,
	[User2] [varchar](12) NULL,
	[User4] [varchar](12) NULL,
	[cost] [decimal](19, 4) NULL,
	[quantity] [int] NULL,
	[Transdate] [datetime] NULL,
	[Transtime] [varchar](10) NULL,
	[type] [varchar](5) NULL,
	[TypeDescription] [varchar](5) NULL,
	[binqty] [int] NULL,
	[User5] [varchar](12) NULL,
	[SerialID] [varchar](18) NULL,
	[User6] [varchar](12) NULL,
	[RelatedKey] [varchar](12) NULL,
	[Status] [smallint] NULL,
	[CribBin] [varchar](15) NULL,
	[BatchId] [int] NULL,
	[IssuedTo] [varchar](12) NULL,
	[Consignment] [int] NULL,
	[OtherCribBin] [varchar](15) NULL,
	[WONo] [int] NULL,
	[TransUsage] [int] NULL,
	[RepairCalCycle] [smallint] NULL,
	[Crib] [smallint] NULL,
	[LotNo] [int] NULL,
	[UsageType] [tinyint] NULL,
	[UsageCribBin] [varchar](15) NULL,
	[UsageItemNumber] [varchar](12) NULL,
	[ReservationNo] [int] NULL,
	[SubType] [int] NULL,
	[OtherSiteNo] [int] NULL,
	[CycleCountClassNo] [int] NULL,
	[ExpectedAccuracy] [int] NULL,
	[TransRFIDNo] [int] NULL,
	[LocalTransDate] [datetime] NULL,
 CONSTRAINT [TRANS_PK] PRIMARY KEY CLUSTERED 
(
	[transnumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TRANSDETAIL]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TRANSDETAIL](
	[TransDetailNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[TransNo] [int] NOT NULL,
	[TransComment] [varchar](255) NULL,
	[TransDetailDate] [datetime] NULL,
	[TransDetailEmployeeID] [varchar](12) NULL,
	[TransReasonCode] [varchar](4) NULL,
	[ConfirmationNumber] [varchar](50) NULL,
 CONSTRAINT [TRANSDETAIL_PK] PRIMARY KEY CLUSTERED 
(
	[TransDetailNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[transfer]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[transfer](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[CribEmplNumber] [varchar](12) NULL,
	[CribEmplName] [varchar](50) NULL,
	[ItemNumber] [varchar](12) NULL,
	[ItemName] [varchar](50) NULL,
	[FromBin] [varchar](15) NULL,
	[ToBin] [varchar](15) NULL,
	[Quantity] [int] NULL,
 CONSTRAINT [transfer_PK] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Transfers]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Transfers](
	[Counter] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[DateOrdered] [datetime] NULL,
	[TimeOrdered] [varchar](50) NULL,
	[ItemNumber] [varchar](12) NULL,
	[Quantity] [int] NULL,
	[CribBinFrom] [varchar](15) NULL,
	[CribBinTo] [varchar](15) NULL,
	[Why] [varchar](50) NULL,
	[TransferType] [int] NULL,
	[OnOrderSet] [bit] NOT NULL,
	[OrderingEmployee] [varchar](12) NULL,
	[KitSerialId] [varchar](18) NULL,
	[SerialId] [varchar](18) NULL,
	[TransferBatchId] [int] NULL,
	[TransferStatus] [tinyint] NULL,
	[LotNo] [int] NULL,
	[SiteTransferNo] [int] NULL,
	[CINo] [int] NULL,
	[FromSiteNo] [smallint] NULL,
	[ToSiteNo] [smallint] NULL,
	[TrackingCrib] [smallint] NULL,
	[TrackingCribBin] [varchar](15) NULL,
	[CribFrom] [smallint] NULL,
	[CribTo] [smallint] NULL,
	[PODetailID] [int] NULL,
	[SiteTransferSyncTime] [datetime] NULL,
	[LastModifiedTime] [datetime] NULL,
	[SyncGeneration] [int] NULL,
	[SiteTransferBatchID] [int] NULL,
	[SaveForceOrder] [int] NULL,
	[PendingOrderID] [int] NULL,
	[OriginalItemNumber] [varchar](12) NULL,
	[UnitCost] [decimal](19, 4) NULL,
	[UsageType] [tinyint] NULL,
	[UsageCribBin] [varchar](15) NULL,
	[UsageItemNumber] [varchar](12) NULL,
 CONSTRAINT [Transfers_PK] PRIMARY KEY CLUSTERED 
(
	[Counter] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TransferStatus]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TransferStatus](
	[TransferStatusNo] [int] NOT NULL,
	[TransferStatusDescription] [varchar](20) NULL,
 CONSTRAINT [TransferStatus_PK] PRIMARY KEY CLUSTERED 
(
	[TransferStatusNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TransReason]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TransReason](
	[TransReasonCode] [varchar](4) NOT NULL,
	[TransReasonDescription] [varchar](50) NULL,
 CONSTRAINT [TransReason_PK] PRIMARY KEY CLUSTERED 
(
	[TransReasonCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TransReceipt]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TransReceipt](
	[TransReceiptNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[TransNo] [int] NULL,
	[RecipientName] [varchar](100) NULL,
	[EmailAddress] [varchar](100) NULL,
	[TransactionDate] [datetime] NOT NULL,
	[PostDate] [datetime] NOT NULL,
	[SalesTax1] [decimal](19, 4) NULL,
	[SalesTax2] [decimal](19, 4) NULL,
	[SalesTax3] [decimal](19, 4) NULL,
	[Total] [decimal](19, 4) NULL,
	[LastSentDate] [datetime] NULL,
	[TransReceiptBatchId] [int] NULL,
	[CardNumber] [varchar](30) NULL,
	[CardType] [varchar](20) NULL,
	[OrderID] [varchar](50) NULL,
	[AuthorizationType] [varchar](20) NULL,
	[Tax1Label] [varchar](20) NULL,
	[Tax2Label] [varchar](20) NULL,
	[Tax3Label] [varchar](20) NULL,
 CONSTRAINT [PK_TRANSRECEIPT] PRIMARY KEY CLUSTERED 
(
	[TransReceiptNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TransType]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TransType](
	[TransType] [varchar](5) NOT NULL,
	[TypeDescription] [varchar](50) NULL,
	[QuantityFactor] [smallint] NULL,
	[BinQuantityFactor] [smallint] NULL,
 CONSTRAINT [PK_TRANSTYPE] PRIMARY KEY CLUSTERED 
(
	[TransType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UDT_POCATEGORY]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UDT_POCATEGORY](
	[UDF_POCATEGORY] [varchar](8) NOT NULL,
	[UDF_POCATEGORYDescription] [varchar](50) NULL,
 CONSTRAINT [UDT_POCATEGORY_PK] PRIMARY KEY CLUSTERED 
(
	[UDF_POCATEGORY] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UDTCOATING]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UDTCOATING](
	[UDFCOATING] [varchar](20) NOT NULL,
	[UDFCOATINGDescription] [varchar](50) NULL,
 CONSTRAINT [UDTCOATING_PK] PRIMARY KEY CLUSTERED 
(
	[UDFCOATING] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UDTGLOBALTOOL]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UDTGLOBALTOOL](
	[UDFGLOBALTOOL] [varchar](20) NOT NULL,
	[UDFGLOBALTOOLDescription] [varchar](50) NULL,
 CONSTRAINT [UDTGLOBALTOOL_PK] PRIMARY KEY CLUSTERED 
(
	[UDFGLOBALTOOL] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UDTHSPOCAT]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UDTHSPOCAT](
	[UDFHSPOCAT] [varchar](8) NOT NULL,
	[UDFHSPOCATDescription] [varchar](50) NULL,
 CONSTRAINT [UDTHSPOCAT_PK] PRIMARY KEY CLUSTERED 
(
	[UDFHSPOCAT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[User1]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[User1](
	[Name] [varchar](50) NULL,
	[Comments] [varchar](255) NULL,
	[MonthToDate] [decimal](19, 4) NULL,
	[YearToDate] [decimal](19, 4) NULL,
	[WeekToDate] [decimal](19, 4) NULL,
	[MonthlyRedFlag] [decimal](19, 4) NULL,
	[YearlyRedFlag] [decimal](19, 4) NULL,
	[WeeklyRedFlag] [decimal](19, 4) NULL,
	[LastYear] [decimal](19, 4) NULL,
	[ExcludeUnrestricted] [smallint] NULL,
	[ID] [varchar](12) NOT NULL,
	[AssetNo] [int] NULL,
	[UserInactive] [bit] NULL DEFAULT (0),
	[DynamicFilterOption] [int] NULL,
	[UserSiteID] [varchar](12) NULL,
	[UserLocalID] [varchar](12) NULL,
 CONSTRAINT [User1_PK] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[User2]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[User2](
	[Name] [varchar](50) NULL,
	[Comments] [varchar](255) NULL,
	[MonthToDate] [decimal](19, 4) NULL,
	[YearToDate] [decimal](19, 4) NULL,
	[WeekToDate] [decimal](19, 4) NULL,
	[MonthlyRedFlag] [decimal](19, 4) NULL,
	[YearlyRedFlag] [decimal](19, 4) NULL,
	[WeeklyRedFlag] [decimal](19, 4) NULL,
	[LastYear] [decimal](19, 4) NULL,
	[ExcludeUnrestricted] [smallint] NULL,
	[ID] [varchar](12) NOT NULL,
	[AssetNo] [int] NULL,
	[UserInactive] [bit] NULL,
	[DynamicFilterOption] [int] NULL,
	[UserSiteID] [varchar](12) NULL,
	[UserLocalID] [varchar](12) NULL,
 CONSTRAINT [User2_PK] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[User3]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[User3](
	[Name] [varchar](50) NULL,
	[Comments] [varchar](255) NULL,
	[MonthToDate] [decimal](19, 4) NULL,
	[YearToDate] [decimal](19, 4) NULL,
	[WeekToDate] [decimal](19, 4) NULL,
	[MonthlyRedFlag] [decimal](19, 4) NULL,
	[YearlyRedFlag] [decimal](19, 4) NULL,
	[WeeklyRedFlag] [decimal](19, 4) NULL,
	[LastYear] [decimal](19, 4) NULL,
	[ExcludeUnrestricted] [smallint] NULL,
	[ID] [varchar](12) NOT NULL,
	[AssetNo] [int] NULL,
	[UserInactive] [bit] NULL,
	[DynamicFilterOption] [int] NULL,
	[UserSiteID] [varchar](12) NULL,
	[UserLocalID] [varchar](12) NULL,
 CONSTRAINT [User3_PK] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[User4]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[User4](
	[Name] [varchar](50) NULL,
	[Comments] [varchar](255) NULL,
	[MonthToDate] [decimal](19, 4) NULL,
	[YearToDate] [decimal](19, 4) NULL,
	[WeekToDate] [decimal](19, 4) NULL,
	[MonthlyRedFlag] [decimal](19, 4) NULL,
	[YearlyRedFlag] [decimal](19, 4) NULL,
	[WeeklyRedFlag] [decimal](19, 4) NULL,
	[LastYear] [decimal](19, 4) NULL,
	[ExcludeUnrestricted] [smallint] NULL,
	[ID] [varchar](12) NOT NULL,
	[AssetNo] [int] NULL,
	[UserInactive] [bit] NULL DEFAULT (0),
	[DynamicFilterOption] [int] NULL,
	[UDFarea] [varchar](20) NULL,
	[UserSiteID] [varchar](12) NULL,
	[UserLocalID] [varchar](12) NULL,
 CONSTRAINT [User4_PK] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[User5]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[User5](
	[Name] [varchar](50) NULL,
	[Comments] [varchar](255) NULL,
	[MonthToDate] [decimal](19, 4) NULL,
	[YearToDate] [decimal](19, 4) NULL,
	[WeekToDate] [decimal](19, 4) NULL,
	[MonthlyRedFlag] [decimal](19, 4) NULL,
	[YearlyRedFlag] [decimal](19, 4) NULL,
	[WeeklyRedFlag] [decimal](19, 4) NULL,
	[LastYear] [decimal](19, 4) NULL,
	[ExcludeUnrestricted] [smallint] NULL,
	[ID] [varchar](12) NOT NULL,
	[AssetNo] [int] NULL,
	[UserInactive] [bit] NULL,
	[DynamicFilterOption] [int] NULL,
	[UserSiteID] [varchar](12) NULL,
	[UserLocalID] [varchar](12) NULL,
 CONSTRAINT [User5_PK] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[User6]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[User6](
	[Name] [varchar](50) NULL,
	[Comments] [varchar](255) NULL,
	[MonthToDate] [decimal](19, 4) NULL,
	[YearToDate] [decimal](19, 4) NULL,
	[WeekToDate] [decimal](19, 4) NULL,
	[MonthlyRedFlag] [decimal](19, 4) NULL,
	[YearlyRedFlag] [decimal](19, 4) NULL,
	[WeeklyRedFlag] [decimal](19, 4) NULL,
	[LastYear] [decimal](19, 4) NULL,
	[ExcludeUnrestricted] [smallint] NULL,
	[ID] [varchar](12) NOT NULL,
	[AssetNo] [int] NULL,
	[UserInactive] [bit] NULL,
	[DynamicFilterOption] [int] NULL,
	[UserSiteID] [varchar](12) NULL,
	[UserLocalID] [varchar](12) NULL,
 CONSTRAINT [User6_PK] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserItem1]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserItem1](
	[ID] [varchar](12) NULL,
	[ItemNumber] [varchar](12) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserItem2]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserItem2](
	[ID] [varchar](12) NULL,
	[ItemNumber] [varchar](12) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserItem3]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserItem3](
	[ID] [varchar](12) NULL,
	[ItemNumber] [varchar](12) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserItem4]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserItem4](
	[ID] [varchar](12) NULL,
	[ItemNumber] [varchar](12) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserItem5]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserItem5](
	[ID] [varchar](12) NULL,
	[ItemNumber] [varchar](12) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserItem6]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserItem6](
	[ID] [varchar](12) NULL,
	[ItemNumber] [varchar](12) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserOverride]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserOverride](
	[UserOverrideNo] [int] IDENTITY(1,1) NOT NULL,
	[UserOverrideType] [tinyint] NOT NULL,
	[User1IssueOption] [tinyint] NULL,
	[User1WOOption] [tinyint] NULL,
	[User1Label] [varchar](50) NULL,
	[DefaultUser1] [varchar](12) NULL,
	[User2IssueOption] [tinyint] NULL,
	[User2WOOption] [tinyint] NULL,
	[User2Label] [varchar](50) NULL,
	[DefaultUser2] [varchar](12) NULL,
	[User3IssueOption] [tinyint] NULL,
	[User3WOOption] [tinyint] NULL,
	[User3Label] [varchar](50) NULL,
	[DefaultUser3] [varchar](12) NULL,
	[User4IssueOption] [tinyint] NULL,
	[User4WOOption] [tinyint] NULL,
	[User4Label] [varchar](50) NULL,
	[DefaultUser4] [varchar](12) NULL,
	[User5IssueOption] [tinyint] NULL,
	[User5WOOption] [tinyint] NULL,
	[User5Label] [varchar](50) NULL,
	[DefaultUser5] [varchar](12) NULL,
	[User6IssueOption] [tinyint] NULL,
	[User6WOOption] [tinyint] NULL,
	[User6Label] [varchar](50) NULL,
	[DefaultUser6] [varchar](12) NULL,
 CONSTRAINT [PK_UserOverride] PRIMARY KEY CLUSTERED 
(
	[UserOverrideNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserXRef]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserXRef](
	[UserXRefNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[FromID] [varchar](18) NULL,
	[FromIDType] [tinyint] NULL,
	[ToID] [varchar](18) NULL,
	[ToIDType] [tinyint] NULL,
 CONSTRAINT [PK_UserXRef] PRIMARY KEY CLUSTERED 
(
	[UserXRefNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[VENDOR]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[VENDOR](
	[VendorNumber] [varchar](12) NOT NULL,
	[VendorName] [varchar](50) NULL,
	[PurchaseAddress1] [varchar](50) NULL,
	[PurchaseAddress2] [varchar](50) NULL,
	[PurchaseCity] [varchar](50) NULL,
	[PurchaseState] [varchar](50) NULL,
	[PurchaseZip] [varchar](20) NULL,
	[Phone] [varchar](20) NULL,
	[FaxPhone] [varchar](50) NULL,
	[EDIPhone] [varchar](50) NULL,
	[MinAmount] [decimal](19, 4) NULL,
	[OrderMethod] [smallint] NULL,
	[Terms] [varchar](30) NULL,
	[VendorPO] [varchar](12) NULL,
	[POReleaseNumber] [int] NULL,
	[POExpiration] [datetime] NULL,
	[POComment] [varchar](200) NULL,
	[shipping] [varchar](50) NULL,
	[daterequired] [varchar](12) NULL,
	[AvgBuildTime] [int] NULL,
	[OverrideBuildTime] [int] NULL,
	[ContactInfo] [varchar](200) NULL,
	[Comments] [varchar](255) NULL,
	[EMailAddress] [varchar](50) NULL,
	[AlertEMailAddress] [varchar](255) NULL,
	[EDIFormat] [tinyint] NULL,
	[TPName] [varchar](64) NULL,
	[OvrAutoPurchaseDays] [int] NULL,
	[POPrinterName] [varchar](32) NULL,
	[VendorInactive] [bit] NULL DEFAULT (0),
	[UDFM2MVENDORNUMBER] [varchar](6) NULL,
	[UDFHARTSELLEVENDOR] [varchar](6) NULL,
	[OverrideRptRexPO] [varchar](30) NULL,
	[Vendor_AddDate] [datetime] NULL,
	[Vendor_AddUID] [varchar](12) NULL,
	[Vendor_UpdateDate] [datetime] NULL,
	[Vendor_UpdateUID] [varchar](12) NULL,
 CONSTRAINT [VENDOR_PK] PRIMARY KEY CLUSTERED 
(
	[VendorNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ViewPaneClass]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ViewPaneClass](
	[ViewPaneClassId] [int] NOT NULL,
	[ViewName] [varchar](30) NOT NULL,
 CONSTRAINT [VIEWPANECLASS_PK] PRIMARY KEY CLUSTERED 
(
	[ViewPaneClassId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[VLookup]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[VLookup](
	[Name] [nvarchar](50) NULL,
	[Albion] [char](6) NULL,
	[Hartselle] [char](6) NULL,
	[id] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[WO]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[WO](
	[WONo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[WOID] [varchar](12) NULL,
	[WODefNo] [int] NULL,
	[AssetNo] [int] NULL,
	[WODescription] [varchar](50) NULL,
	[DateCreated] [datetime] NULL,
	[DateAssigned] [datetime] NULL,
	[DateRequired] [datetime] NULL,
	[WOStatusNo] [tinyint] NULL,
	[CreatedByEmployee] [varchar](12) NULL,
	[AssignedToEmployee] [varchar](12) NULL,
	[DownTime] [decimal](19, 4) NULL,
	[RunUnits] [int] NULL,
	[ReasonCode] [varchar](4) NULL,
	[WOComment] [varchar](255) NULL,
	[DateClosed] [datetime] NULL,
	[WOCraftCode] [varchar](12) NULL,
	[WOCloseComment] [varchar](255) NULL,
	[WOCost] [decimal](19, 4) NULL,
	[WOTypeNo] [tinyint] NULL,
	[WOUser1] [varchar](12) NULL,
	[WOUser2] [varchar](12) NULL,
	[WOUser3] [varchar](12) NULL,
	[WOUser4] [varchar](12) NULL,
	[WOUser5] [varchar](12) NULL,
	[WOUser6] [varchar](12) NULL,
	[WOBatchId] [int] NULL,
	[WOAdditionalCost] [decimal](19, 4) NULL,
	[OutputItemNumber] [varchar](12) NULL,
	[DrawingNumber] [varchar](50) NULL,
	[SpecialInstructions] [varchar](255) NULL,
	[RequestedQuantity] [int] NULL,
	[ActualQuantity] [int] NULL,
	[WOCostOvr] [decimal](19, 4) NULL,
	[WOLocationID] [varchar](12) NULL,
	[ReservationNo] [int] NULL,
	[PartsCrib] [int] NULL,
	[WOPriority] [tinyint] NULL,
	[WO_AddDate] [datetime] NULL,
	[WO_AddUID] [varchar](12) NULL,
	[WO_UpdateDate] [datetime] NULL,
	[WO_UpdateUID] [varchar](12) NULL,
 CONSTRAINT [PK_WO] PRIMARY KEY CLUSTERED 
(
	[WONo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[WODef]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[WODef](
	[WODefNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[WODefID] [varchar](12) NULL,
	[WODefDescription] [varchar](50) NULL,
	[DateCreated] [datetime] NULL,
	[WODefOwner] [varchar](12) NULL,
	[WODefComment] [varchar](128) NULL,
	[WODefRevision] [int] NULL,
	[WODefInactive] [bit] NOT NULL,
	[WODefEstimatedCost] [decimal](19, 4) NULL,
	[WODefUser1] [varchar](12) NULL,
	[WODefUser2] [varchar](12) NULL,
	[WODefUser3] [varchar](12) NULL,
	[WODefUser4] [varchar](12) NULL,
	[WODefUser5] [varchar](12) NULL,
	[WODefUser6] [varchar](12) NULL,
	[WOTypeNo] [tinyint] NULL,
	[OutputItemNumber] [varchar](12) NULL,
	[DrawingNumber] [varchar](50) NULL,
	[SpecialInstructions] [varchar](255) NULL,
	[WODef_AddDate] [datetime] NULL,
	[WODef_AddUID] [varchar](12) NULL,
	[WODef_UpdateDate] [datetime] NULL,
	[WODef_UpdateUID] [varchar](12) NULL,
 CONSTRAINT [PK_WODEF] PRIMARY KEY CLUSTERED 
(
	[WODefNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[WODefSchedule]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[WODefSchedule](
	[WODefScheduleNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[WODefNo] [int] NULL,
	[AssetNo] [int] NULL,
	[EquipmentType] [tinyint] NULL,
	[LastWODate] [datetime] NULL,
	[BaseDate] [datetime] NULL,
	[NextWODate] [datetime] NULL,
	[OverrideNextWODate] [datetime] NULL,
	[Interval] [int] NULL,
	[IntervalType] [tinyint] NULL,
	[PreferredDay] [tinyint] NULL,
	[Priority] [tinyint] NULL,
	[WONo] [int] NULL,
	[FloatSchedule] [bit] NOT NULL,
	[LastRunUnits] [int] NULL,
	[BaseRunUnits] [int] NULL,
	[NextRunUnits] [int] NULL,
	[OverrideNextRunUnits] [int] NULL,
	[WODefScheduleInactive] [bit] NOT NULL,
	[RunUnitsInterval] [int] NULL,
	[ReasonCode] [varchar](4) NULL,
	[PartsCrib] [int] NULL,
	[WODefSchedule_AddDate] [datetime] NULL,
	[WODefSchedule_AddUID] [varchar](12) NULL,
	[WODefSchedule_UpdateDate] [datetime] NULL,
	[WODefSchedule_UpdateUID] [varchar](12) NULL,
	[OvrWODueDays] [int] NULL,
 CONSTRAINT [PK_WODEFSCHEDULE] PRIMARY KEY CLUSTERED 
(
	[WODefScheduleNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[WODefTask]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WODefTask](
	[WODefTaskNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[WODefNo] [int] NULL,
	[TaskNo] [int] NULL,
	[TaskSequence] [smallint] NULL,
 CONSTRAINT [PK_WODEFTASK] PRIMARY KEY CLUSTERED 
(
	[WODefTaskNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[WOLabor]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[WOLabor](
	[WOLaborNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[WONo] [int] NULL,
	[WOTaskNo] [int] NULL,
	[WOLaborDate] [datetime] NULL,
	[WOLaborEmployeeID] [varchar](12) NULL,
	[WOLaborCraftCode] [varchar](12) NULL,
	[WOLaborDuration] [decimal](19, 4) NULL,
	[WOLaborRate] [decimal](19, 4) NULL,
	[WOLaborUser1] [varchar](12) NULL,
	[WOLaborUser2] [varchar](12) NULL,
	[WOLaborUser3] [varchar](12) NULL,
	[WOLaborUser4] [varchar](12) NULL,
	[WOLaborUser5] [varchar](12) NULL,
	[WOLaborUser6] [varchar](12) NULL,
	[WOLaborStartTime] [datetime] NULL,
	[WOLaborEndTime] [datetime] NULL,
	[WOLaborEstDuration] [decimal](19, 4) NULL,
	[WOLaborCost] [decimal](19, 4) NULL,
	[WOLaborCostOvr] [decimal](19, 4) NULL,
	[WOLaborPayType] [tinyint] NULL,
	[WOLaborComment] [varchar](255) NULL,
 CONSTRAINT [PK_WOLABOR] PRIMARY KEY CLUSTERED 
(
	[WOLaborNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[WOLocation]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[WOLocation](
	[WOLocationId] [varchar](12) NOT NULL,
	[Description] [varchar](50) NULL,
	[Comments] [varchar](255) NULL,
 CONSTRAINT [WOLocation_PK] PRIMARY KEY CLUSTERED 
(
	[WOLocationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[WOLocationHistory]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[WOLocationHistory](
	[WOLocationHistoryNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[WONo] [int] NULL,
	[WOLocationId] [varchar](12) NULL,
	[WOEmployeeId] [varchar](12) NULL,
	[WOLocationStartTime] [datetime] NULL,
	[WOLocationEndTime] [datetime] NULL,
 CONSTRAINT [PK_WOLOCATIONHISTORY] PRIMARY KEY CLUSTERED 
(
	[WOLocationHistoryNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[WOStatus]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[WOStatus](
	[WOStatusNo] [tinyint] NOT NULL,
	[WOStatusDescription] [varchar](20) NULL,
 CONSTRAINT [PK_WOSTATUS] PRIMARY KEY CLUSTERED 
(
	[WOStatusNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[WOStatusHistory]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[WOStatusHistory](
	[WOStatusHistoryNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[WONo] [int] NULL,
	[WOStatusDate] [datetime] NULL,
	[WOStatusNo] [tinyint] NULL,
	[WOEmployeeID] [varchar](12) NULL,
 CONSTRAINT [PK_WOSTATUSHISTORY] PRIMARY KEY CLUSTERED 
(
	[WOStatusHistoryNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[WOTask]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[WOTask](
	[WOTaskNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[WONo] [int] NULL,
	[TaskNo] [int] NULL,
	[DateCompleted] [datetime] NULL,
	[WOTaskSequence] [smallint] NULL,
	[WOTaskComplete] [bit] NOT NULL,
	[WOTaskCloseComment] [varchar](128) NULL,
 CONSTRAINT [PK_WOTASK] PRIMARY KEY CLUSTERED 
(
	[WOTaskNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[WOTaskItem]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[WOTaskItem](
	[WOTaskItemNo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[WOTaskNo] [int] NULL,
	[WONo] [int] NULL,
	[TaskItemNo] [int] NULL,
	[ItemNumber] [varchar](12) NULL,
	[TaskQuantity] [int] NULL,
	[TaskActionCode] [varchar](4) NULL,
	[ActualQuantity] [int] NULL,
	[ActualActionCode] [varchar](4) NULL,
	[WOTIStatusDate] [datetime] NULL,
	[WOTIComplete] [bit] NOT NULL,
 CONSTRAINT [PK_WOTASKITEM] PRIMARY KEY CLUSTERED 
(
	[WOTaskItemNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[WOType]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[WOType](
	[WOTypeNo] [tinyint] NOT NULL,
	[WOTypeDescription] [varchar](20) NULL,
 CONSTRAINT [PK_WOTYPE] PRIMARY KEY CLUSTERED 
(
	[WOTypeNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[XEmployeeDay]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[XEmployeeDay](
	[TransDate] [datetime] NOT NULL,
	[SiteID] [varchar](12) NULL,
	[EmployeeID] [varchar](12) NULL,
	[EmployeeName] [varchar](50) NULL,
	[Item] [varchar](30) NULL,
	[Description1] [varchar](50) NULL,
	[TypeDescription] [varchar](5) NULL,
	[ItemClass] [varchar](15) NULL,
	[ItemType] [int] NULL,
	[ItemTypeDesc] [varchar](32) NULL,
	[CostSum] [decimal](19, 4) NULL,
	[QtySum] [int] NULL,
	[DistinctItemCount] [int] NULL,
	[ItemCount] [int] NULL,
	[Consignment] [int] NULL,
	[Crib] [smallint] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[XEmployeeMonth]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[XEmployeeMonth](
	[TransDate] [datetime] NOT NULL,
	[SiteID] [varchar](12) NULL,
	[EmployeeID] [varchar](12) NULL,
	[EmployeeName] [varchar](50) NULL,
	[Item] [varchar](30) NULL,
	[Description1] [varchar](50) NULL,
	[TypeDescription] [varchar](5) NULL,
	[ItemClass] [varchar](15) NULL,
	[ItemType] [int] NULL,
	[ItemTypeDesc] [varchar](32) NULL,
	[CostSum] [decimal](19, 4) NULL,
	[QtySum] [int] NULL,
	[DistinctItemCount] [int] NULL,
	[ItemCount] [int] NULL,
	[Consignment] [int] NULL,
	[Crib] [smallint] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[XTransDay]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[XTransDay](
	[TransDate] [datetime] NOT NULL,
	[SiteID] [varchar](12) NULL,
	[Item] [varchar](30) NULL,
	[Description1] [varchar](50) NULL,
	[TypeDescription] [varchar](5) NULL,
	[ItemClass] [varchar](15) NULL,
	[ItemType] [int] NULL,
	[ItemTypeDesc] [varchar](32) NULL,
	[CostSum] [decimal](19, 4) NULL,
	[QtySum] [int] NULL,
	[DistinctItemCount] [int] NULL,
	[ItemCount] [int] NULL,
	[Consignment] [int] NULL,
	[Crib] [smallint] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[XTransMonth]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[XTransMonth](
	[TransDate] [datetime] NOT NULL,
	[SiteID] [varchar](12) NULL,
	[Item] [varchar](30) NULL,
	[Description1] [varchar](50) NULL,
	[TypeDescription] [varchar](5) NULL,
	[ItemClass] [varchar](15) NULL,
	[ItemType] [int] NULL,
	[ItemTypeDesc] [varchar](32) NULL,
	[CostSum] [decimal](19, 4) NULL,
	[QtySum] [int] NULL,
	[DistinctItemCount] [int] NULL,
	[ItemCount] [int] NULL,
	[Consignment] [int] NULL,
	[Crib] [smallint] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[XUDFDay]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[XUDFDay](
	[TransDate] [datetime] NOT NULL,
	[SiteID] [varchar](12) NULL,
	[UserField] [varchar](12) NULL,
	[UDFValue] [varchar](12) NULL,
	[Item] [varchar](30) NULL,
	[Description1] [varchar](50) NULL,
	[TypeDescription] [varchar](5) NULL,
	[ItemClass] [varchar](15) NULL,
	[ItemType] [int] NULL,
	[ItemTypeDesc] [varchar](32) NULL,
	[CostSum] [decimal](19, 4) NULL,
	[QtySum] [int] NULL,
	[DistinctItemCount] [int] NULL,
	[ItemCount] [int] NULL,
	[Consignment] [int] NULL,
	[Crib] [smallint] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[XUDFMonth]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[XUDFMonth](
	[TransDate] [datetime] NOT NULL,
	[SiteID] [varchar](12) NULL,
	[UserField] [varchar](12) NULL,
	[UDFValue] [varchar](12) NULL,
	[Item] [varchar](30) NULL,
	[Description1] [varchar](50) NULL,
	[TypeDescription] [varchar](5) NULL,
	[ItemClass] [varchar](15) NULL,
	[ItemType] [int] NULL,
	[ItemTypeDesc] [varchar](32) NULL,
	[CostSum] [decimal](19, 4) NULL,
	[QtySum] [int] NULL,
	[DistinctItemCount] [int] NULL,
	[ItemCount] [int] NULL,
	[Consignment] [int] NULL,
	[Crib] [smallint] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  View [dbo].[VItemPrice]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VItemPrice] AS
   SELECT INVENTRY.ItemNumber AS ItemNumber,
          PRICETYPE,
          ITEMTYPE,
          CASE INVENTRY.PRICETYPE
             WHEN NULL THEN ISNULL(ALTVENDOR.COST, 0)
             WHEN 0 THEN ISNULL(INVENTRY.Price, ISNULL(ALTVENDOR.COST, 0))
             WHEN 1 THEN ISNULL(INVENTRY.Price, 1) * ISNULL(ALTVENDOR.COST, 0)
             WHEN 2 THEN ISNULL(INVENTRY.Price, 0) + ISNULL(ALTVENDOR.COST, 0)
             WHEN 3 THEN ISNULL(INVENTRY.Price, ISNULL(ALTVENDOR.COST, 0))
             ELSE ISNULL(ALTVENDOR.COST, 0)
          END AS Price,
          AltVendorNo,
          COST
     FROM INVENTRY LEFT OUTER JOIN ALTVENDOR ON INVENTRY.AltVendorNo = ALTVENDOR.RecNumber
GO
/****** Object:  View [dbo].[bvInventory]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create VIEW [dbo].[bvInventory] AS
	select 
	litemnumber,lInactiveItem,lAltVendorNo,lCost,
	rItemNumber,rInactiveItem,rAltVendorNo,rCost,
	lmanufacturer, ldescription1,litemclass,lDefaultBuyerGroupId,lVendorNumber,lVendorName,consumable,

	albNewBinQuantity,albNewBinQuantity*lCost as albNewCribTotCost,
	albRwkBinQuantity,albRwkBinQuantity*rCost as albRwkCribTotCost,
	albTotBinQuantity,(albNewBinQuantity*lCost)+(albRwkBinQuantity*rCost) as albCribTotCost,

	aviNewBinQuantity,aviNewBinQuantity*lCost as aviNewCribTotCost,
	aviRwkBinQuantity,aviRwkBinQuantity*rCost as aviRwkCribTotCost,
	aviTotBinQuantity,(aviNewBinQuantity*lCost)+(aviRwkBinQuantity*rCost) as aviCribTotCost,

	cribNewBinQuantity,(cribNewBinQuantity*lCost) as newCribTotCost,
	cribRwkBinQuantity,(cribRwkBinQuantity*rCost) as rwkCribTotCost,
	cribTotBinQuantity,(cribNewBinQuantity*lCost)+(cribRwkBinQuantity*rCost) as cribTotCost,
	
	TB2TotQty,TB2TotQty*lCost as TB2TotCost,
	TB3TotQty,TB3TotQty*lCost as TB3TotCost,
	TB5TotQty,TB5TotQty*lCost as TB5TotCost,
	TB6TotQty,TB6TotQty*lCost as TB6TotCost,
	TB7TotQty,TB7TotQty*lCost as TB7TotCost,
	TB8TotQty,TB8TotQty*lCost as TB8TotCost,
	TB9TotQty,TB9TotQty*lCost as TB9TotCost,
	TB11TotQty,TB11TotQty*lCost as TB11TotCost,
	TB112TotQty,TB112TotQty*lCost as TB112TotCost,

	TBTotQty,TBTotQty*lCost as TBTotCost,

	TBTotQty + cribTotBinQuantity as cribAndTBTotQty, 
	(cribNewBinQuantity*lCost)+(cribRwkBinQuantity*rCost)
	+ (TBTotQty*lCost) as cribAndTBTotCost,

	OnOrderQty,OnOrderQty*lCost as OnOrderTotCost,

	newIssuedTotQty,newIssuedTotCost,
	rwkIssuedTotQty,rwkIssuedTotCost,
	issuedTotQty,issuedTotCost,
	itemPartIssuedList,

	case 
		when (issuedTotQty - TBTotQty - cribTotBinQuantity - OnOrderQty) > 0 
		then issuedTotQty - TBTotQty - cribTotBinQuantity - OnOrderQty
		else 0
	end orderQty,

	case 
		when (issuedTotQty - TBTotQty - cribTotBinQuantity - OnOrderQty) > 0 
		then (issuedTotQty - TBTotQty - cribTotBinQuantity - OnOrderQty) * lCost
		else 0
	end orderCost,

	AlbLocQtyList,AviLocQtyList,CribLocQtyList,TBLocQtyList,CribAndTBLocQtyList, 

	newItemLastIssued,newItemInTransLog,
	rwkItemLastIssued,rwkItemInTransLog,
	case 
		when ToolLists is null then 'Not on any Active ToolLists'
		else ToolLists
	end 
	as ActiveToolLists,
	case 
		when opDescList is null then 'Not on any Obsolete ToolLists'
		else OpDescList
	end  
	as ObsToolLists 
	from
	(
		select
		litemnumber,lInactiveItem,lAltVendorNo,
		rItemNumber,rInactiveItem,rAltVendorNo,
		lmanufacturer, ldescription1,litemclass,lDefaultBuyerGroupId,lVendorNumber,lVendorName,
		albNewBinQuantity,albRwkBinQuantity,albTotBinQuantity,
		aviNewBinQuantity,aviRwkBinQuantity,aviTotBinQuantity,
		cribNewBinQuantity,cribRwkBinQuantity,cribTotBinQuantity,
		newItemLastIssued,newItemInTransLog,
		rwkItemLastIssued,rwkItemInTransLog,
		AlbLocQtyList,AviLocQtyList,CribLocQtyList,TBLocQtyList,CribAndTBLocQtyList,
		TB2TotQty,TB3TotQty,TB5TotQty,TB6TotQty,TB7TotQty,TB8TotQty,
		TB9TotQty,TB11TotQty,TB112TotQty,TBTotQty,
		OnOrderQty,
		case
			when newIssuedTotQty is null then 0
			else newIssuedTotQty
		end as newIssuedTotQty,
		case
			when newIssuedTotCost is null then 0.0
			else newIssuedTotCost
		end as newIssuedTotCost,
		case 
			when rwkIssuedTotQty is null then 0
			else rwkIssuedTotQty
		end as rwkIssuedTotQty,
		case 
			when rwkIssuedTotCost is null then 0.0
			else rwkIssuedTotCost
		end as rwkIssuedTotCost,
		case
			when issuedTotQty is null then 0
			else issuedTotQty
		end as issuedTotQty,
		case 
			when issuedTotCost is null then 0.0
			else issuedTotCost
		end as issuedTotCost,
		case 
			when itemPartIssuedList is null then 'none'
			else itemPartIssuedList
		end as itemPartIssuedList,
		case
			when consItemNumber is null then 0
			else 1
		end as consumable,
		case 
			when lPrice.COST is null then cast(0.0 as decimal(18,2)) 
			else lPrice.COST 
		end as lCost, 
		case 
			when rPrice.COST is null then cast(0.0 as decimal(18,2)) 
			else rPrice.COST 
		end as rCost 
		from
		(
			select
			litemnumber,lInactiveItem,lAltVendorNo,
			rItemNumber,rInactiveItem,rAltVendorNo,
			lmanufacturer, ldescription1,litemclass,lDefaultBuyerGroupId,lVendorNumber,lVendorName,
			albNewBinQuantity,albRwkBinQuantity,albTotBinQuantity,
			aviNewBinQuantity,aviRwkBinQuantity,aviTotBinQuantity,
			cribNewBinQuantity,cribRwkBinQuantity,cribTotBinQuantity,
			case
				when lili.lastIssued is null then CONVERT(datetime, '1.01.9999', 104)
				else lili.lastIssued
			end newItemLastIssued,
			case
				when lili.lastIssued is null then 0
				else 1
			end newItemInTransLog,
			case
				when rili.lastIssued is null then CONVERT(datetime, '1.01.9999', 104)
				else rili.lastIssued
			end rwkItemLastIssued,
			case
				when rili.lastIssued is null then 0
				else 1
			end rwkItemInTransLog,
			case
				when lql.AlbLocQtyList is null then 'None in Albion Crib'
				else lql.AlbLocQtyList
			end AlbLocQtyList, 
			case
				when lql.AviLocQtyList is null then 'None in Avilla Crib'
				else lql.AviLocQtyList
			end AviLocQtyList, 
			case
				when lql.CribLocQtyList is null then 'None in Albion or Avilla Cribs'
				else lql.CribLocQtyList
			end CribLocQtyList, 
			case
				when lql.TBLocQtyList is null then 'None in ToolBosses'
				else lql.TBLocQtyList
			end TBLocQtyList, 
			case
				when lql.CribAndTBLocQtyList is null then 'None in Cribs or ToolBosses'
				else lql.CribAndTBLocQtyList
			end CribAndTBLocQtyList, 
			case
				when lql.TB2TotQty is null then 0
				else lql.TB2TotQty
			end TB2TotQty, 
			case
				when lql.TB3TotQty is null then 0
				else lql.TB3TotQty
			end TB3TotQty, 
			case
				when lql.TB5TotQty is null then 0
				else lql.TB5TotQty
			end TB5TotQty, 
			case
				when lql.TB6TotQty is null then 0
				else lql.TB6TotQty
			end TB6TotQty, 
			case
				when lql.TB7TotQty is null then 0
				else lql.TB7TotQty
			end TB7TotQty, 
			case
				when lql.TB8TotQty is null then 0
				else lql.TB8TotQty
			end TB8TotQty, 
			case
				when lql.TB9TotQty is null then 0
				else lql.TB9TotQty
			end TB9TotQty, 
			case
				when lql.TB11TotQty is null then 0
				else lql.TB11TotQty
			end TB11TotQty, 
			case
				when lql.TB112TotQty is null then 0
				else lql.TB112TotQty
			end TB112TotQty, 
			case
				when lql.TBTotQty is null then 0
				else lql.TBTotQty
			end TBTotQty, 
			case
				when OnOrderQty is null then 0
				else OnOrderQty
			end OnOrderQty
			from
			(
				select 
				litemnumber,lInactiveItem,lAltVendorNo,
				rItemNumber,rInactiveItem,rAltVendorNo,
				lmanufacturer, ldescription1,litemclass,lDefaultBuyerGroupId,lVendorNumber,lVendorName,
				albNewBinQuantity,albRwkBinQuantity,albTotBinQuantity,
				aviNewBinQuantity,aviRwkBinQuantity,aviTotBinQuantity,
				albNewBinQuantity + aviNewBinQuantity as cribNewBinQuantity,
				albRwkBinQuantity + aviRwkBinQuantity as cribRwkBinQuantity,
				albTotBinQuantity + aviTotBinQuantity as cribTotBinQuantity
				from
				(
					select 
					litemnumber,lInactiveItem,lAltVendorNo,
					rItemNumber,rInactiveItem,rAltVendorNo,
					lmanufacturer, ldescription1,litemclass,lDefaultBuyerGroupId,lVendorNumber,lVendorName,
					case
						when albNewBinQuantity is null then 0
						else albNewBinQuantity
					end albNewBinQuantity,
					case
						when albRwkBinQuantity is null then 0
						else albRwkBinQuantity
					end albRwkBinQuantity,
					case
						when (albNewBinQuantity is null) and (albRwkBinQuantity is null) then 0
						when (albNewBinQuantity is not null) and (albRwkBinQuantity is null) then albNewBinQuantity
						when (albNewBinQuantity is null) and (albRwkBinQuantity is not null) then albRwkBinQuantity
						else albNewBinQuantity + albRwkBinQuantity
					end albTotBinQuantity,
					case
						when aviNewBinQuantity is null then 0
						else aviNewBinQuantity
					end aviNewBinQuantity,
					case
						when aviRwkBinQuantity is null then 0
						else aviRwkBinQuantity
					end aviRwkBinQuantity,
					case
						when (aviNewBinQuantity is null) and (aviRwkBinQuantity is null) then 0
						when (aviNewBinQuantity is not null) and (aviRwkBinQuantity is null) then aviNewBinQuantity
						when (aviNewBinQuantity is null) and (aviRwkBinQuantity is not null) then aviRwkBinQuantity
						else aviNewBinQuantity + aviRwkBinQuantity
					end aviTotBinQuantity
					from
					(
						/* lv */
						select litemnumber,lInactiveItem,ldescription1,
						litemclass,lDefaultBuyerGroupId,lmanufacturer,lAltVendorNo,lVendorNumber,lVendorName,
						isnull(rinv.ItemNumber,lItemNumber + 'R') as ritemnumber,
						isnull(rinv.inactiveItem,0) as rInactiveItem,
						isnull(rinv.AltVendorNo,99999999) rAltVendorNo
						from
						(
							select linv.itemnumber litemnumber,
							ISNULL(linv.InactiveItem,0) as lInactiveItem, 
							ISNULL(linv.description1,'No Description') as ldescription1, 
							isnull(linv.ItemClass,'No ItemClass') as litemclass, 
							case
								when ic.DefaultBuyerGroupId is null then 'NONE'
								else ic.DefaultBuyerGroupId
							end as lDefaultBuyerGroupId,
							isnull(linv.Manufacturer,'No Manufacturer') as lmanufacturer,
							isnull(linv.AltVendorNo,99999999) as lAltVendorNo, 
							isnull(vnd.VendorNumber,99999999) as lVendorNumber, 
							isnull(vnd.VendorName,'none') as lVendorName, 
							isnull(linv.ReworkedItemNumber,'none') lReworkedItemNumber
							from 
							INVENTRY linv
							left outer join ITEMCLASS ic
							on linv.ItemClass=ic.ItemClass
							left outer join altVendor avd
							on linv.AltVendorNo=avd.RecNumber
							left outer join Vendor vnd
							on avd.VendorNumber=vnd.VendorNumber
							--14915
							--14947		
							where linv.ItemNumber not like '%R' 
								and linv.itemnumber <> '' and linv.itemnumber <> '.' and linv.itemnumber is not null 
							--11856
						) linv
						left outer join
						inventry rinv
						on lReworkedItemNumber = rinv.ItemNumber  
						--11836
					)a
					left outer join
					(
						select item, sum(BinQuantity) albNewBinQuantity 
						from station
						group by crib,item
						having crib = 1 and item not like '%R' 
						and item <> '' and item <> '.'  and item is not null
						--8403
					)b
					on a.litemnumber=b.Item
					--111836
					left outer join
					(
						select item, sum(BinQuantity) albRwkBinQuantity 
						from station
						group by crib,item
						having crib = 1 and item like '%R' 
						and item <> '' and item <> '.'  and item is not null
						--2216
					)b2
					on a.ritemnumber=b2.Item
					left outer join
					(
						select item, sum(BinQuantity) AviNewBinQuantity 
						from station
						group by crib,item
						having crib = 11 and item not like '%R' 
						and item <> '' and item <> '.'  and item is not null
						--8403
					)b3
					on a.litemnumber=b3.Item
					--111836
					left outer join
					(
						select item, sum(BinQuantity) AviRwkBinQuantity 
						from station
						group by crib,item
						having crib = 11 and item like '%R' 
						and item <> '' and item <> '.'  and item is not null
						--2216
					)b4
					on a.ritemnumber=b4.Item
					--111836
				)b5
					--11836
			)f
			left outer join
			(
				select item,albOnOrder,aviOnOrder, albOnOrder + aviOnOrder as OnOrderQty
				from
				(
					select item,sum(albOnOrder) albOnOrder,sum(aviOnOrder) aviOnOrder
					from
					(
						select item,albOnOrder,aviOnOrder 
						from
						(
							(
								select item,onorder albOnOrder, 0 as aviOnOrder,crib,cribbin from station 
								where crib =1 and (onorder <> 0) and (onorder is not null) 
								--200
							)
							union
							(
								select item,0 as albOnOrder,onorder aviOnOrder,crib,cribbin from station 
								where crib =11 and (OnOrder <> 0) and (onorder is not null)
								--41
							)
						)c
						--241
					)d
					--241
					--just to prove if an item is onorder according to an avilla station it will say
					-- onorder 0 or null in an albion station
					group by item
				)e
			)g
			on f.litemnumber=g.Item
			left outer join btLocQtyList lql
			on f.litemnumber=lql.itemNumber
			left outer join btItemLastIssued lili
			on f.litemNumber=lili.itemNumber
			left outer join btItemLastIssued rili
			on f.ritemNumber=rili.itemNumber
			--11856
			/* end lv1 */
			/* THIS IS THE final RECORD SET -- DON'T ADD OR REMOVE ANY RECORDS */
		) lv5
		left outer join vitemprice lprice
		on
		lv5.litemnumber=lprice.ItemNumber
		left outer join vitemprice rprice
		on
		lv5.ritemnumber=rprice.ItemNumber
		left outer join
		btItemIssued iis
		on 
		lv5.litemnumber=iis.newItemNumber
		left outer join
		(
			-- All these items are marked as consumable on ToolList
			select distinct itemNumber as consItemNumber
			from btToolListPartItems 
		)ipp
		on lv5.litemNumber=ipp.consItemNumber
	) lv7
	left outer join
	btToolListItems atl
	on 
	lv7.litemNumber = atl.ItemNumber
	left outer join
	btObsToolListItems otl
	on 
	lv7.litemNumber = otl.ItemNumber
	--11856

GO
/****** Object:  View [dbo].[bvPartNumberDescr]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[bvPartNumberDescr]
as
	select dtl.PartNumber,Customer,PartFamily,CustPartFamily
	from
	(
		-- pick a toollist to represent all those associated
		-- with a partNumber
		select partNumber,max(originalProcessId) maxOrigPID
		from btDistinctToollists 
		group by partNumber
		-- 529
	) tlm
	inner join
	(
		select * from btDistinctToolLists 
		-- 731
	) dtl	
	on
	tlm.maxOrigPID=dtl.originalprocessid
	--529

GO
/****** Object:  View [dbo].[bvRestockTransLog]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[bvRestockTransLog]
AS
	select  Plant,tlm.partNumber,
	case 
		when pnd.CustPartFamily is null then 'Customer/Part Family is unknown'
		else pnd.CustPartFamily
	end CustPartFamily, 
	itemnumber,
	case
		when itemnumber like '%R' then substring(itemnumber,1,len(itemnumber)-1) 
		else itemnumber
	end newItemNumber,
	TranStartDateTime as transTime, qty, 
	cast(unitCost as decimal(18,2)) as unitCost, cast(qty*unitCost as decimal(18,2)) as totCost, userName 
	from btTransLogMonth tlm
	--12275
	left outer join
	bvPartNumberDescr pnd
	on 
	tlm.PartNumber = pnd.partNumber
	--12269

GO
/****** Object:  View [dbo].[VObsInventory]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create VIEW [dbo].[VObsInventory] AS
select 
litemnumber,ldescription1,litemclass,lmanufacturer,lAltVendorNo,lCribBinList,lCost,lTotBinQty, 
(lcost * lTotBinQty) lTotCost,
ritemnumber,rAltVendorNo,rCribBinList,rCost,rTotBinQty,
(rcost * rTotBinQty) rTotCost,
TotBinQty, 
((lcost * lTotBinQty) + (rcost * rTotBinQty)) TotCost,
CribBinList
from 
(
	select litemnumber,ldescription1,litemclass,lmanufacturer,lAltVendorNo,lCost, lCribBinList,lTotBinQty, 
	ritemnumber,rAltVendorNo,rCribBinList,
	case 
	when VItemPrice.COST is null then cast(0.0 as decimal(18,2)) 
	else VItemPrice.COST 
	end as rCost, 
	rTotBinQty,TotBinQty, 
	CribBinList 
	from
	(
		select litemnumber,ldescription1,litemclass,lmanufacturer,lAltVendorNo,lCribBinList, 
		case 
		when VItemPrice.COST is null then cast(0.0 as decimal(18,2)) 
		else VItemPrice.COST 
		end as lCost, 
		lTotBinQty, 
		ritemnumber,rAltVendorNo,rCribBinList,rTotBinQty,TotBinQty, 
		CribBinList 
		from
		(
				select litemnumber,ldescription1,litemclass,
				ISNULL(lmanufacturer,'none') as lmanufacturer,
				case 
					when lAltVendorNo is null then cast(0.0 as decimal(18,2)) 
					else lAltVendorNo 
				end as lAltVendorNo, 
				ISNULL(lCribBinList,'none') as lCribBinList,
				case 
					when lTotBinQty is null then cast(0.0 as decimal(18,2)) 
					else lTotBinQty 
				end as lTotBinQty, 
				ISNULL(ritemnumber,'none') as ritemnumber, 
				case 
					when rAltVendorNo is null then cast(0.0 as decimal(18,2)) 
					else rAltVendorNo 
				end as rAltVendorNo, 
				ISNULL(rCribBinList,'none') as rCribBinList,
				case 
					when sum(st2.BinQuantity) is null then cast(0.0 as decimal(18,2)) 
					else sum(st2.BinQuantity)  
				end as rTotBinQty, 
				case 
					when ((lTotBinQty is null) and (sum(st2.BinQuantity) is null)) then cast(0.0 as decimal(18,2)) 
					when ((lTotBinQty is null) and (sum(st2.BinQuantity) is not null)) then sum(st2.BinQuantity) 
					when ((lTotBinQty is not null) and (sum(st2.BinQuantity) is null)) then lTotBinQty 
					when ((lTotBinQty is not null) and (sum(st2.BinQuantity) is not null)) then (lTotBinQty + sum(st2.BinQuantity)) 
				end as TotBinQty, 
				case 
					when ((lCribBinList is null) and (rCribBinList is null)) then 'none' 
					when ((lCribBinList is null) and (rCribBinList is not null)) then rCribBinList 
					when ((lCribBinList is not null) and (rCribBinList is null)) then lCribBinList 
					when ((lCribBinList is not null) and (lCribBinList is not null)) then lCribBinList + '<br>' + rCribBinList 
				end as CribBinList 
				from
				(
					select litemnumber,ldescription1,litemclass,lmanufacturer,
					lAltVendorNo,       
					lCribBinList,lTotBinQty,
					ritemnumber,rAltVendorNo,
					SUBSTRING(
						list.xmlDoc.value('.', 'varchar(max)'),
						5, 10000
					) AS rCribBinList
					from
					(
						select litemnumber,ldescription1,litemclass,lmanufacturer,
						lCribBinList,sum(st1.BinQuantity) lTotBinQty,
						lAltVendorNo,ritemnumber,rAltVendorNo       
						from
						(
							select litemnumber,ldescription1,litemclass,lmanufacturer,
							SUBSTRING(
							   list.xmlDoc.value('.', 'varchar(max)'),
							   5, 10000
							) AS lCribBinList,
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
									where linv.ItemNumber not like '%R' and linv.InactiveItem = 1
										and linv.itemnumber <> '' and linv.itemnumber <> '.' 
										--5581
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
								select * from station where crib = '1' or crib = '11'
							  ) lstn
							  where lv1.litemnumber=lstn.Item
							  order by lstn.CribBin
							  for xml path(''), type
							) as list(xmlDoc)
						) lv2
						left outer join
						(
							select * from station where crib = '1' or crib = '11'
						) st1
						on lv2.lItemNumber = st1.Item
						group by litemnumber,ldescription1,litemclass,lmanufacturer,
							lCribBinList,
							lAltVendorNo,ritemnumber,rAltVendorNo       
					) lv3
					cross apply(
						select '<br>'+ rstn.CribBin as ListItem
						from 
						(
						select * from station where crib = '1' or crib = '11'
						) rstn
						where lv3.ritemnumber=rstn.Item
						order by rstn.CribBin
						for xml path(''), type
					) as list(xmlDoc)
				) lv4
				left outer join
				(
					select * from station where crib = '1' or crib = '11'
				) st2
				on lv4.rItemNumber = st2.Item
				group by litemnumber,ldescription1,litemclass,lmanufacturer,
				lAltVendorNo,       
				lCribBinList,lTotBinQty,
				ritemnumber,rAltVendorNo,
				rCribBinList
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
/****** Object:  View [dbo].[VEmployeeSite]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VEmployeeSite]  AS
SELECT     SITEID, EMPLOYEEID, SITEACCESSOPTION
FROM         EMPLOYEESITE es1
UNION ALL
SELECT     s2.SITEID, EMPLOYEEID, SITEACCESSOPTION
FROM         (EMPLOYEESITE es2 INNER JOIN
                      SITEPROFILE s1 ON es2.SITEID = s1.SITEID) INNER JOIN
                      SITEPROFILE s2 ON s1.SITEID = S2.PARENTSITEID
WHERE     NOT EXISTS
                          (SELECT     *
                            FROM          EMPLOYEESITE es3
                            WHERE      es3.SITEID = s2.SITEID AND es3.EMPLOYEEID = es2.EMPLOYEEID)

GO
/****** Object:  View [dbo].[VEmployeeSiteCrib]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VEmployeeSiteCrib] AS
SELECT     t1.SITEID, t1.EMPLOYEEID, t1.SITEACCESSOPTION, t2.Crib
FROM         VEmployeeSite AS t1 INNER JOIN
                      dbo.Crib AS t2 ON t1.SITEID = t2.SiteID
WHERE     (t1.SITEACCESSOPTION <> 0) AND (NOT EXISTS
                          (SELECT     EmployeeID, Crib, CribAccessOption
                            FROM          EmployeeCrib AS t3
                            WHERE      (t2.Crib = Crib) AND (CribAccessOption = 0) AND (EmployeeID = t1.EMPLOYEEID)))

GO
/****** Object:  View [dbo].[VObsTotalInventory]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create View [dbo].[VObsTotalInventory] 
as
select * 
from VObsInventory vinv
inner join btobsmonuse mu
on vinv.litemnumber = mu.itemnumber

GO
/****** Object:  View [dbo].[VInventory]    Script Date: 4/20/2018 11:41:39 AM ******/
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
/****** Object:  View [dbo].[VTotalInventory]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create View [dbo].[VTotalInventory] 
as
select * 
from VInventory vinv
inner join btmonuse mu
on vinv.litemnumber = mu.itemnumber

GO
/****** Object:  View [dbo].[VRFIDSTATUS]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VRFIDSTATUS](RFIDNO,
                        RFID,
                        PARENTRFIDNO,
                        EMPLOYEEID,
                        ITEMNUMBER,
                        SERIALID,
                        CRIB,
                        CRIBBIN,
                        LASTEMPLOYEE,
                        LASTCRIB,
                        STATUS,
                        SERIALIDCRIBBIN,
                        HOMECRIB,
                        LASTTRANSACTION,
                        READCOUNT,
                        SERIALSTATUS) AS
   SELECT RFIDNo,
   		  RFID,
          ParentRFIDNo,
          EmployeeID,
          ItemNumber,
          SerialID,
          OverrideCrib,
          NULL,
          LastEmployee,
          LastCrib,
          Status,
          NULL AS SerialIDCribBin,
          NULL AS HomeCrib,
          LastTransaction,
          ReadCount,
          NULL AS SERIALSTATUS
     FROM RFID
    WHERE CRIBBIN IS NULL AND SERIALID IS NULL
   UNION
   SELECT RFIDNo,
   		  RFID,
          ParentRFIDNo,
          EmployeeID,
          Item AS ItemNumber,
          RFID.SerialID,
          STATION.CRIB,
          RFID.CribBin AS CRIBBIN,
          LastEmployee,
          LastCrib,
          RFID.Status AS STATUS,
          ITEMSERIAL.CribBin AS SerialIDCribBin,
          HomeCrib,
          LastTransaction,
          ReadCount,
          ITEMSERIAL.Status AS SERIALSTATUS
     FROM (RFID INNER JOIN STATION ON RFID.CRIBBIN = STATION.CRIBBIN)
	 	 LEFT JOIN ITEMSERIAL ON RFID.SERIALID = ITEMSERIAL.SERIALID
    WHERE RFID.CRIBBIN IS NOT NULL
   UNION
   SELECT RFIDNo,
   		  RFID,
          ParentRFIDNo,
          EmployeeID,
          ITEMSERIAL.ItemNumber,
          RFID.SerialID,
          STATION.CRIB,
          RFID.CribBin,
          LastEmployee,
          LastCrib,
          RFID.Status,
          ITEMSERIAL.CribBin,
          HomeCrib,
          LastTransaction,
          ReadCount,
          ITEMSERIAL.Status
     FROM (RFID INNER JOIN ITEMSERIAL ON RFID.SERIALID = ITEMSERIAL.SERIALID)
	 	  LEFT JOIN STATION ON ITEMSERIAL.CRIBBIN = STATION.CRIBBIN
    WHERE RFID.CRIBBIN IS NULL AND RFID.SERIALID IS NOT NULL

GO
/****** Object:  View [dbo].[VRFIDSTATUSSUMMARY]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VRFIDSTATUSSUMMARY](ITEMNUMBER, RFIDTAGCOUNT, CRIB, STATUS) AS
   SELECT   ITEMNUMBER,
            COUNT(*),
            CASE STATUS
               WHEN 1 THEN ISNULL(LASTCRIB, CRIB)
               WHEN 2 THEN CRIB
               ELSE ISNULL(LASTCRIB, CRIB)
            END AS CRIB,
            STATUS
       FROM VRFIDSTATUS
   GROUP BY ITEMNUMBER,
            CASE STATUS
               WHEN 1 THEN ISNULL(LASTCRIB, CRIB)
               WHEN 2 THEN CRIB
               ELSE ISNULL(LASTCRIB, CRIB)
            END,
            STATUS
GO
/****** Object:  View [dbo].[VALLWODEFSCHEDULEWOITEMS]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VALLWODEFSCHEDULEWOITEMS](TASKITEMNO,
                                     TASKNO,
                                     TASKITEMNUMBER,
                                     TASKITEMQUANTITY,
                                     ACTIONCODE,
                                     ISSUEOPTION,
                                     OVRORDEROPTION,
                                     NEXTWODATE,
                                     WODEFSCHEDULENO,
                                     WODEFNO,
                                     PARTSCRIB,
                                     WONO,
                                     INTERVAL,
                                     INTERVALTYPE) AS
   SELECT TASKITEMNO,
          TASKNO,
          TASKITEMNUMBER,
          TASKITEMQUANTITY,
          TASKITEM.ACTIONCODE,
          ISSUEOPTION,
          OVRORDEROPTION,
          NEXTWODATE,
          WODEFSCHEDULENO,
          WODEFSCHEDULE.WODEFNO,
          ISNULL(PARTSCRIB, (SELECT MAX(INT)
                               FROM GLOBALSETTINGS
                              WHERE KEYNAME = 'Purchasing_MaintenanceCrib')),
          WODEFSCHEDULE.WODEFNO,
          INTERVAL,
          INTERVALTYPE
     FROM TASKITEM INNER JOIN WODEFSCHEDULE ON TASKITEM.WODEFNO = WODEFSCHEDULE.WODEFNO
LEFT JOIN ACTIONCODE ON TASKITEM.ACTIONCODE = ACTIONCODE.ACTIONCODE
    WHERE TASKITEM.WODEFNO = WODEFSCHEDULE.WODEFNO 
	 AND   ISNULL(WODEFSCHEDULEINACTIVE, 0) = 0
   UNION ALL
   -- Task items attached to a scheduled WODEF via a TASK
   SELECT TASKITEMNO,
          TASKITEM.TASKNO,
          TASKITEMNUMBER,
          TASKITEMQUANTITY,
          TASKITEM.ACTIONCODE,
          ISSUEOPTION,
          OVRORDEROPTION,
          NEXTWODATE,
          WODEFSCHEDULENO,
          WODEFSCHEDULE.WODEFNO,
          ISNULL(PARTSCRIB, (SELECT MAX(INT)
                               FROM GLOBALSETTINGS
                              WHERE KEYNAME = 'Purchasing_MaintenanceCrib')),
          WODEFSCHEDULE.WODEFNO,
          INTERVAL,
          INTERVALTYPE
     FROM TASKITEM INNER JOIN WODEFTASK ON TASKITEM.TASKNO = WODEFTASK.TASKNO 
    INNER JOIN WODEFSCHEDULE ON WODEFTASK.WODEFNO = WODEFSCHEDULE.WODEFNO 
     LEFT JOIN ACTIONCODE ON TASKITEM.ACTIONCODE = ACTIONCODE.ACTIONCODE
    WHERE ISNULL(WODEFSCHEDULEINACTIVE, 0) = 0
   UNION ALL
   -- Open, Assigned, Parts Need Work Order parts that have not yet been completed
   -- or filled
   SELECT TASKITEMNO,
          TASKNO,
          ITEMNUMBER,
          TASKQUANTITY - ISNULL(WOTASKITEM.ACTUALQUANTITY, 0),
          ISNULL(ACTUALACTIONCODE, TASKACTIONCODE),
          ISSUEOPTION,
          OVRORDEROPTION,
          GETDATE(),
          NULL,
          WODEFNO,
          ISNULL(PARTSCRIB, (SELECT MAX(INT)
                               FROM GLOBALSETTINGS
                              WHERE KEYNAME = 'Purchasing_MaintenanceCrib')),
          WO.WONO,
          NULL,
          NULL
     FROM WOTASKITEM INNER JOIN WO ON WOTASKITEM.WONO = WO.WONO 
	  LEFT JOIN WOTASK ON WOTASKITEM.WOTASKNO = WOTASK.WOTASKNO 
	  LEFT JOIN ACTIONCODE ON ISNULL(ACTUALACTIONCODE,TASKACTIONCODE) = ACTIONCODE.ACTIONCODE
    WHERE WOSTATUSNO IN(0, 1, 4)
      AND TASKQUANTITY > ISNULL(WOTASKITEM.ACTUALQUANTITY, 0)
      AND ISNULL(WOTICOMPLETE, 0) = 0
      AND ISNULL(WOTASKCOMPLETE, 0) = 0
GO
/****** Object:  View [dbo].[VPreferredCribBin]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VPreferredCribBin](PreferredCribBin, ItemNumber, CRIB) AS
   SELECT   MIN(CRIBBIN) AS PREFERREDCRIBBIN,
            ITEM AS ITEMNUMBER,
            CRIB
       FROM STATION
      WHERE ITEM IS NOT NULL AND ISNULL(BINTYPE, 0) NOT IN(1, 3)
   GROUP BY CRIB, ITEM
GO
/****** Object:  View [dbo].[VALLWOITEMWITHCRIBBIN]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VALLWOITEMWITHCRIBBIN](PARTSCRIB,
                                  PREFERREDCRIBBIN,
                                  TASKITEMNUMBER,
                                  TASKITEMQUANTITY,
                                  EFFECTIVEQUANTITY,
                                  NEXTWODATE,
                                  INTERVAL,
                                  INTERVALTYPE,
                                  ACTIONCODE,
                                  ISSUEOPTION,
                                  OVRORDEROPTION,
                                  WONO,
                                  WODEFSCHEDULENO,
                                  ACTUALAVGLEADTIME) AS
   SELECT PARTSCRIB,
          PREFERREDCRIBBIN,
          TASKITEMNUMBER,
          TASKITEMQUANTITY,
          dbo.ADJUSTQUANTITYFORLEADTIME(TASKITEMQUANTITY,
                                        INTERVAL,
                                        INTERVALTYPE,
                                        ISNULL(OverrideAvgLeadTime,
                                               ISNULL(AvgLeadTime,
                                                      (SELECT MAX(INT)
                                                         FROM GLOBALSETTINGS
                                                        WHERE KEYNAME =
                                                                     'Purchasing_LeadTime'))),
                                        CASE
                                           WHEN WONO IS NOT NULL
                                           AND WODEFSCHEDULENO IS NOT NULL THEN 1
                                           ELSE 0
                                        END) AS EFFECTIVEQUANTITY,
          NEXTWODATE,
          INTERVAL,
          INTERVALTYPE,
          ACTIONCODE,
          ISSUEOPTION,
          OVRORDEROPTION,
          WONO,
          WODEFSCHEDULENO,
          ISNULL(OverrideAvgLeadTime,
                 ISNULL(AvgLeadTime, (SELECT MAX(INT)
                                        FROM GLOBALSETTINGS
                                       WHERE KEYNAME = 'Purchasing_LeadTime')))
                                                                     AS ActualAvgLeadTime
     FROM VALLWODEFSCHEDULEWOITEMS v1 LEFT JOIN VPREFERREDCRIBBIN v2 ON v1.taskitemnumber =
                                                                             v2.itemnumber
                                                                   AND v1.partscrib =
                                                                                   v2.CRIB LEFT JOIN STATION s ON PREFERREDCRIBBIN =
                                                                                                                    s.cribbin
GO
/****** Object:  View [dbo].[VReservCribBinOrderQtyLT]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VReservCribBinOrderQtyLT] AS
   SELECT   reservationcribbin,
            SUM(CASE ISNULL(ovrorderoption, ISNULL(reservationorderoption, 0))
                   WHEN 0 THEN   ISNULL(ReservationQuantity, 0)
                               - ISNULL(ReservationActualQuantity, 0)
                   ELSE 0
                END) AS DefaultOrderQty,
            SUM(CASE ISNULL(ovrorderoption, ISNULL(reservationorderoption, 0))
                   WHEN 1 THEN   ISNULL(ReservationQuantity, 0)
                               - ISNULL(ReservationActualQuantity, 0)
                   ELSE 0
                END) AS AdditionalOrderQty,
            SUM(CASE ISNULL(ovrorderoption, ISNULL(reservationorderoption, 0))
                   WHEN 2 THEN   ISNULL(ReservationQuantity, 0)
                               - ISNULL(ReservationActualQuantity, 0)
                   ELSE 0
                END) AS MinOrderQty,
            SUM(CASE ISNULL(ovrorderoption, ISNULL(reservationorderoption, 0))
                   WHEN 3 THEN   ISNULL(ReservationQuantity, 0)
                               - ISNULL(ReservationActualQuantity, 0)
                   ELSE 0
                END) AS NoneOrderQty
       FROM (RESERVATIONDETAIL r2 INNER JOIN RESERVATION r1 ON r1.reservationno = r2.reservationno) 
		 INNER JOIN STATION s ON r2.reservationcribbin = s.cribbin
      WHERE (   RESERVATIONSTATUS IN(1, 2)
             OR RESERVATIONSTATUS =
                   CASE (SELECT INT
                           FROM GLOBALSETTINGS
                          WHERE KEYNAME = 'Purchasing_OrderForOpenReservations')
                      WHEN 1 THEN 0
                      ELSE 1
                   END)
        AND ISNULL(ReservationQuantity, 0) > ISNULL(ReservationActualQuantity, 0)
        AND daterequired <
                 CAST(CONVERT(VARCHAR, GETDATE(), 20) AS datetime)
               + ISNULL(OverrideAvgLeadTime, AvgLeadTime)
               + (SELECT ISNULL(MAX(INT), 0) + 1
                    FROM GLOBALSETTINGS
                   WHERE KEYNAME = 'Purchasing_MoreLeadDays')
   GROUP BY reservationcribbin
GO
/****** Object:  View [dbo].[VAllCribBinReservOrderQtyLT]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VAllCribBinReservOrderQtyLT] AS
   SELECT CribBin,
          ReservationAddQty,
          ReservationMinQty,
            ISNULL(AdditionalOrderQty, 0)
          + CASE(ISNULL((SELECT INT
                           FROM GLOBALSETTINGS
                          WHERE STRING = 'Purchasing_DefaultReservationOrderOption'), 1))
               WHEN 1 THEN ISNULL(DefaultOrderQty, 0)
               ELSE 0
            END AS AdditionalOrderQty,
            ISNULL(MinOrderQty, 0)
          + CASE(ISNULL((SELECT INT
                           FROM GLOBALSETTINGS
                          WHERE STRING = 'Purchasing_DefaultReservationOrderOption'), 1))
               WHEN 2 THEN ISNULL(DefaultOrderQty, 0)
               ELSE 0
            END AS MinOrderQty
     FROM STATION LEFT JOIN VReservCribBinOrderQtyLT v 
	    ON STATION.CRIBBIN = V.RESERVATIONCRIBBIN
GO
/****** Object:  View [dbo].[VToolItems]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create VIEW [dbo].[VToolItems] 
AS
select inv.ItemNumber,
case 
when inv.Description1 is null then cast('none' as varchar(50)) 
else inv.Description1 
end as Description1,
case 
when inv.ItemClass is null then cast('none' as varchar(15)) 
else inv.ItemClass 
end as ItemClass, 
case 
when inv.UDFGLOBALTOOL is null then cast('NO' as varchar(20)) 
else inv.UDFGLOBALTOOL 
end as UDFGLOBALTOOL, 
case 
when ip.COST is null then cast(0.0 as decimal(18,2)) 
else ip.COST 
end as Cost
from inventry inv
inner join
VItemPrice ip
on inv.ItemNumber = ip.ItemNumber
where inv.ItemNumber <> '.'


GO
/****** Object:  View [dbo].[VKitBOM1]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VKitBOM1] AS
   SELECT KIT.KitNumber AS KitNumber, 
	Kit.ItemNumber as ItemNumber,
        Kit.Quantity As KitQuantity, 
	1 as LevelNumber, 
	Kit.KitNumber + '/' + Kit.ItemNumber As KitPath
FROM KIT
GO
/****** Object:  View [dbo].[VKitBOM2]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VKitBOM2] AS
   SELECT KIT.KitNumber AS KitNumber,
          KIT.ItemNumber AS ItemNumber,
          KIT.Quantity AS KitQuantity,
          1 AS LevelNumber,
          NULL AS SubKitNumber,
          KIT.KitNumber + '/' + KIT.ItemNumber AS KitPath
     FROM KIT
   UNION ALL
   SELECT KIT.KitNumber AS KitNumber,
          VKitBOM1.ItemNumber AS ItemNumber,
          KIT.Quantity * VKitBOM1.KitQuantity AS KitQuantity,
          LevelNumber + 1,
          VKitBom1.KITNUMBER,
          KIT.KitNumber + '/' + VKitBom1.KitPath
     FROM KIT INNER JOIN VKitBom1 ON KIT.ITEMNUMBER = VKitBom1.KITNUMBER
GO
/****** Object:  View [dbo].[VToolInv]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[VToolInv]
as
select litemnumber as itemNumber,
CribBinList as binlocList,
TotBinQty as totqty,
'0' as plant
from Vinventory


GO
/****** Object:  View [dbo].[VKitBOM3]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VKitBOM3] AS
   SELECT KIT.KitNumber AS KitNumber,
          KIT.ItemNumber AS ItemNumber,
          KIT.Quantity AS KitQuantity,
          1 AS LevelNumber,
          NULL AS SubKitNumber,
          KIT.KitNumber + '/' + KIT.ItemNumber AS KitPath
     FROM KIT
   UNION ALL
   SELECT KIT.KitNumber AS KitNumber,
          VKitBOM2.ItemNumber AS ItemNumber,
          KIT.Quantity * VKitBOM2.KitQuantity AS KitQuantity,
          LevelNumber + 2,
          VKitBom2.KITNUMBER,
          KIT.KitNumber + '/' + VKitBom2.KitPath
     FROM KIT INNER JOIN VKitBom2 ON KIT.ITEMNUMBER = VKitBom2.KITNUMBER
GO
/****** Object:  View [dbo].[VKitBOM4]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VKitBOM4] AS
   SELECT KIT.KitNumber AS KitNumber,
          KIT.ItemNumber AS ItemNumber,
          KIT.Quantity AS KitQuantity,
          1 AS LevelNumber,
          NULL AS SubKitNumber,
          KIT.KitNumber + '/' + KIT.ItemNumber AS KitPath
     FROM KIT
   UNION ALL
   SELECT KIT.KitNumber AS KitNumber,
          VKitBOM3.ItemNumber AS ItemNumber,
          KIT.Quantity * VKitBOM3.KitQuantity AS KitQuantity,
          LevelNumber + 3,
          VKitBom3.KITNUMBER,
          KIT.KitNumber + '/' + VKitBom3.KitPath
     FROM KIT INNER JOIN VKitBom3 ON KIT.ITEMNUMBER = VKitBom3.KITNUMBER
GO
/****** Object:  View [dbo].[VKitBOM5]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VKitBOM5] AS
   SELECT KIT.KitNumber AS KitNumber,
          KIT.ItemNumber AS ItemNumber,
          KIT.Quantity AS KitQuantity,
          1 AS LevelNumber,
          NULL AS SubKitNumber,
          KIT.KitNumber + '/' + KIT.ItemNumber AS KitPath
     FROM KIT
   UNION ALL
   SELECT KIT.KitNumber AS KitNumber,
          VKitBOM4.ItemNumber AS ItemNumber,
          KIT.Quantity * VKitBOM4.KitQuantity AS KitQuantity,
          LevelNumber + 4,
          VKitBom4.KITNUMBER,
          KIT.KitNumber + '/' + VKitBom4.KitPath
     FROM KIT INNER JOIN VKitBom4 ON KIT.ITEMNUMBER = VKitBom4.KITNUMBER
GO
/****** Object:  View [dbo].[VKitBOM6]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VKitBOM6] AS
   SELECT KIT.KitNumber AS KitNumber,
          KIT.ItemNumber AS ItemNumber,
          KIT.Quantity AS KitQuantity,
          1 AS LevelNumber,
          NULL AS SubKitNumber,
          KIT.KitNumber + '/' + KIT.ItemNumber AS KitPath
     FROM KIT
   UNION ALL
   SELECT KIT.KitNumber AS KitNumber,
          VKitBOM5.ItemNumber AS ItemNumber,
          KIT.Quantity * VKitBOM5.KitQuantity AS KitQuantity,
          LevelNumber + 5,
          VKitBom5.KITNUMBER,
          KIT.KitNumber + '/' + VKitBom5.KitPath
     FROM KIT INNER JOIN VKitBom5 ON KIT.ITEMNUMBER = VKitBom5.KITNUMBER
GO
/****** Object:  View [dbo].[VKitBOM7]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VKitBOM7] AS
   SELECT KIT.KitNumber AS KitNumber,
          KIT.ItemNumber AS ItemNumber,
          KIT.Quantity AS KitQuantity,
          1 AS LevelNumber,
          NULL AS SubKitNumber,
          KIT.KitNumber + '/' + KIT.ItemNumber AS KitPath
     FROM KIT
   UNION ALL
   SELECT KIT.KitNumber AS KitNumber,
          VKitBOM6.ItemNumber AS ItemNumber,
          KIT.Quantity * VKitBOM6.KitQuantity AS KitQuantity,
          LevelNumber + 6,
          VKitBom6.KITNUMBER,
          KIT.KitNumber + '/' + VKitBom6.KitPath
     FROM KIT INNER JOIN VKitBom6 ON KIT.ITEMNUMBER = VKitBom6.KITNUMBER
GO
/****** Object:  View [dbo].[VKitBOM8]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VKitBOM8] AS
   SELECT KIT.KitNumber AS KitNumber,
          KIT.ItemNumber AS ItemNumber,
          KIT.Quantity AS KitQuantity,
          1 AS LevelNumber,
          NULL AS SubKitNumber,
          KIT.KitNumber + '/' + KIT.ItemNumber AS KitPath
     FROM KIT
   UNION ALL
   SELECT KIT.KitNumber AS KitNumber,
          VKitBOM7.ItemNumber AS ItemNumber,
          KIT.Quantity * VKitBOM7.KitQuantity AS KitQuantity,
          LevelNumber + 7,
          VKitBom7.KITNUMBER,
          KIT.KitNumber + '/' + VKitBom7.KitPath
     FROM KIT INNER JOIN VKitBom7 ON KIT.ITEMNUMBER = VKitBom7.KITNUMBER
GO
/****** Object:  View [dbo].[VKitBOM9]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VKitBOM9] AS
   SELECT KIT.KitNumber AS KitNumber,
          KIT.ItemNumber AS ItemNumber,
          KIT.Quantity AS KitQuantity,
          1 AS LevelNumber,
          NULL AS SubKitNumber,
          KIT.KitNumber + '/' + KIT.ItemNumber AS KitPath
     FROM KIT
   UNION ALL
   SELECT KIT.KitNumber AS KitNumber,
          VKitBOM8.ItemNumber AS ItemNumber,
          KIT.Quantity * VKitBOM8.KitQuantity AS KitQuantity,
          LevelNumber + 8,
          VKitBom8.KITNUMBER,
          KIT.KitNumber + '/' + VKitBom8.KitPath
     FROM KIT INNER JOIN VKitBom8 ON KIT.ITEMNUMBER = VKitBom8.KITNUMBER
GO
/****** Object:  View [dbo].[VKitBOM]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VKitBOM] AS
   SELECT KitNumber,
          ItemNumber,
          KitQuantity,
          LevelNumber,
          SubKitNumber,
          KitPath
     FROM VKitBom3
GO
/****** Object:  View [dbo].[VKitBOMCost]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VKitBOMCost] AS
   SELECT   VKITBOM.KitNumber AS KitNumber,
            SUM(VKITBOM.KitQuantity * ISNULL(ALTVENDOR.COST, 0)) AS KitBOMCost
       FROM (VKITBOM INNER JOIN INVENTRY ON VKITBOM.ItemNumber = INVENTRY.ItemNumber) LEFT JOIN ALTVENDOR ON INVENTRY.AltVendorNo =
                                                                                                               ALTVENDOR.RecNumber
      WHERE ITEMTYPE <> 4
   GROUP BY VKITBOM.Kitnumber
GO
/****** Object:  View [dbo].[VItemCostWithBOM]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VItemCostWithBOM] AS
   SELECT INVENTRY.ItemNumber,
          ISNULL(KitBOmCost, ISNULL(ALTVENDOR.COST, 0)) AS COST
     FROM (INVENTRY LEFT JOIN VKitBOMCost ON INVENTRY.ItemNumber = VKitBOMCost.KitNumber) LEFT JOIN ALTVENDOR ON INVENTRY.AltVendorNo =
                                                                                                              ALTVENDOR.RecNumber
GO
/****** Object:  View [dbo].[VAsmblyTfrAdjQtyIn]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VAsmblyTfrAdjQtyIn] AS
   SELECT   CribBinTo AS AssemblyBin,
			CribBinFrom As ComponentBin,
            ItemNumber,
            SUM(quantity * CASE
                   WHEN CRIBBINFROM IS NULL THEN 1
                   ELSE -1
                END) AS AdjustQty
       FROM TRANSFERS
      WHERE transfertype = 3
   GROUP BY CribBinTo, ItemNumber, CribBinFrom
GO
/****** Object:  View [dbo].[VAsmblyTfrAdjQtyOut]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VAsmblyTfrAdjQtyOut] AS
   SELECT   CribBinFrom AS AssemblyBin,
			CribBinTo As ComponentBin,
            ItemNumber,
            SUM(quantity * CASE
                   WHEN CRIBBINTO IS NULL THEN -1
                   ELSE 1
                END) AS AdjustQty
       FROM TRANSFERS
      WHERE transfertype = 4
   GROUP BY CribBinFrom, ItemNumber, CribBinTo
GO
/****** Object:  View [dbo].[VAsmblyTfrAdjQtyInOut]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VAsmblyTfrAdjQtyInOut] AS
   SELECT AssemblyBin,
		  ComponentBin,
          ItemNumber,
          AdjustQty
     FROM VAsmblyTfrAdjQtyIn 
   UNION ALL
   SELECT AssemblyBin,
	      ComponentBin,
          ItemNumber,
          AdjustQty
     FROM VAsmblyTfrAdjQtyOut
GO
/****** Object:  View [dbo].[bvTotalInventory]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create View [dbo].[bvTotalInventory] 
as
select lv6.*,
case
	when lQtyIssued is null then 0
	else lQtyIssued
end newQtyIssued,
case
	when rQtyIssued is null then 0
	else rQtyIssued
end ReworkQtyIssued,
case
	when qtyIssued is null then 0
	else qtyIssued
end qtyIssued
from
(
	select 
	case 
		when opDescList is null then 'Not on any Obsolete ToolLists'
		else OpDescList
	end  
	as ObsToolLists, 
	lv5.*
	from
	(
		select 
		case 
			when ToolLists is null then 'Not on any Active ToolLists'
			else ToolLists
		end 
		as ActiveToolLists, 
		lv4.*
		from
		(
			select 
			TBTotQty * lCost as totCostTB,
			totBinQty + TBTotQty as totQtyTBandCrib,
			(TBTotQty * lCost) + TotCost as totCostTBandCrib,
			CribBinQtyList + '<br>' + TBLocQtyList as LocQtyList,
			*
			from
			(
				select 
				case
					when tbinv.TBLocQtyList is null then 'None in ToolBosses'
					else tbinv.TBLocQtyList
				end 
				as TBLocQtyList,
				case
					when tbinv.TBTotQty is null then 0
					else tbinv.TBTotQty
				end
				as TBTotQty,
				vinv.* 
				from bvInventory vinv
				left outer join
				(
					select itemNumber,TBTotQty,
					SUBSTRING(
						list.xmlDoc.value('.', 'varchar(max)'),
						5, 10000
					) AS TBLocQtyList
					from 
					(
						select itemNumber,
						sum(totQty) as TBTotQty
						from 
						(
							select * 
							from toolinv
							where plant <> 0
						)lv1
						group by itemNumber
					)lv2
					cross apply(
						select '<br>'+ ti.binloclist + ', Qty: ' + cast(cast(totqty as int) as varchar(15)) as ListItem
						from 
						(
							select * 
							from toolinv
							where plant <> 0
						) ti
						where lv2.itemNumber=ti.itemnumber
						order by ti.binLocList
						for xml path(''), type
					) as list(xmlDoc)
				)tbInv
				on
				vinv.litemnumber=tbInv.itemNumber
			) lv3
		)lv4
		left outer join
		btToolListItems tli
		on 
		lv4.litemNumber = tli.ItemNumber
	)lv5
	left outer join
	btObsToolListItems tli
	on 
	lv5.litemNumber = tli.ItemNumber
)lv6
left outer join
btItemQtyIssuedMonth qi
on
lv6.litemNumber=qi.itemNumber

GO
/****** Object:  View [dbo].[VAsmblyTfrAdjQtyTotals]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VAsmblyTfrAdjQtyTotals] AS
   SELECT   AssemblyBin,
			ComponentBin,
            ItemNumber,
            SUM(AdjustQty) AS AdjustQuantity
       FROM VAsmblyTfrAdjQtyInOut 
   GROUP BY AssemblyBin, ItemNumber, ComponentBin
GO
/****** Object:  View [dbo].[VAsmblyTfrAdjValues]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VAsmblyTfrAdjValues] AS
   SELECT VAsmblyTfrAdjQtyTotals.
          AssemblyBin, 
          VAsmblyTfrAdjQtyTotals.AdjustQuantity, 
          VAsmblyTfrAdjQtyTotals.ItemNumber, 
          VItemCostWithBOM.Cost, 
          AdjustQuantity * VItemCostWithBOM.Cost AS ComputedValue
      FROM VAsmblyTfrAdjQtyTotals LEFT JOIN VItemCostWithBOM ON VAsmblyTfrAdjQtyTotals.ItemNumber = VItemCostWithBOM.ItemNumber
GO
/****** Object:  View [dbo].[VAsmblyTfrAdjValuesByBin]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VAsmblyTfrAdjValuesByBin] AS
   SELECT VAsmblyTfrAdjValues.AssemblyBin, Sum("ComputedValue") AS TransfersValue
      FROM VAsmblyTfrAdjValues
   GROUP BY VAsmblyTfrAdjValues.AssemblyBin
GO
/****** Object:  View [dbo].[VKitBOMPrice]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VKitBOMPrice] AS
   SELECT   VKitBOM.KitNumber,
            SUM(VKitBOM.KitQuantity * PRICE) AS BOMPrice
       FROM VKitBOM INNER JOIN VItemPrice ON VKitBOM.ItemNumber = VItemPrice.ItemNumber
      WHERE ITEMTYPE <> 4
   GROUP BY VKitBOM.KitNumber
GO
/****** Object:  View [dbo].[VItemPriceWithBOM]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VItemPriceWithBOM] AS
   SELECT ItemNumber,
          ISNULL(BOmPrice, Price) AS PRICE,
          AltVendorNo,
          COST
     FROM VItemPrice LEFT JOIN VKitBOMPrice ON VItemPrice.ItemNumber =
                                                                    VKitBOmPrice.KitNumber
GO
/****** Object:  View [dbo].[VBinPrice]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VBinPrice] AS
   SELECT CribBin,
          ItemNumber,
          CASE STATION.PRICETYPE
             WHEN NULL THEN ISNULL(VItemPriceWithBOM.Price, 0)
             WHEN 0 THEN ISNULL(STATION.OverrideIssuePrice,
                                ISNULL(VItemPriceWithBOM.Price, 0))
             WHEN 1 THEN ISNULL(STATION.OverrideIssuePrice, 1) * ISNULL(COST, 0)
             WHEN 2 THEN ISNULL(STATION.OverrideIssuePrice, 0) + ISNULL(COST, 0)
             WHEN 3 THEN ISNULL(STATION.OverrideIssuePrice,
                                ISNULL(VItemPriceWithBOM.Price, 0))
             ELSE ISNULL(VItemPriceWithBOM.Price, 0)
          END AS Price
     FROM STATION LEFT JOIN VItemPriceWithBOM ON STATION.Item =
                                                              VItemPriceWithBOM.ItemNumber
GO
/****** Object:  View [dbo].[VAsmblyTfrAdjPrices]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VAsmblyTfrAdjPrices] AS 
     SELECT VAsmblyTfrAdjQtyTotals.AssemblyBin,
       VAsmblyTfrAdjQtyTotals.AdjustQuantity,
       VAsmblyTfrAdjQtyTotals.ItemNumber,
       Price * AdjustQuantity AS ComputedPrice
  FROM VAsmblyTfrAdjQtyTotals INNER JOIN VBinPrice ON VAsmblyTfrAdjQtyTotals.ComponentBin = VBinPrice.CribBin
GO
/****** Object:  View [dbo].[VAsmblyTfrAdjPricesByBin]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VAsmblyTfrAdjPricesByBin] AS
   SELECT   VAsmblyTfrAdjPrices.AssemblyBin,
            SUM(ComputedPrice) AS TransfersPrice
       FROM VAsmblyTfrAdjPrices
   GROUP BY VAsmblyTfrAdjPrices.AssemblyBin
GO
/****** Object:  View [dbo].[bvToolItems]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--///////////////////////////////////////////////////////////////////////////////////
-- Used to generate the btToolItems which contains Cribmaster item info needed for reports
--///////////////////////////////////////////////////////////////////////////////////
Create VIEW [dbo].[bvToolItems] 
AS
select inv.ItemNumber,
case 
when inv.Description1 is null then cast('none' as varchar(50)) 
else inv.Description1 
end as Description1,
case 
when inv.ItemClass is null then cast('none' as varchar(15)) 
else inv.ItemClass 
end as ItemClass, 
case 
when ic.DefaultBuyerGroupID is null then cast('none' as varchar(15)) 
else ic.DefaultBuyerGroupID 
end as DefaultBuyerGroupID, 
case 
when inv.UDFGLOBALTOOL is null then cast('NO' as varchar(20)) 
else inv.UDFGLOBALTOOL 
end as UDFGLOBALTOOL, 
case 
when ip.COST is null then cast(0.0 as decimal(18,2)) 
else ip.COST 
end as Cost
from inventry inv
--14951
inner join
VItemPrice ip
on inv.ItemNumber = ip.ItemNumber
--14951
left outer join
itemclass ic
on inv.ItemClass = ic.ItemClass
--14919 need outer join
where inv.ItemNumber <> '.' and inv.ItemNumber <> ''

GO
/****** Object:  View [dbo].[VSecAuditType]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VSecAuditType] AS
	SELECT SVNumber, SVName, SVDescription FROM SYSTEMVALUE WHERE SVTYPE=30
GO
/****** Object:  View [dbo].[VSecAuditHistory]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VSecAuditHistory] AS
   SELECT SECAUDITHISTORY.SecAuditHistoryNo,
          VSecAuditType.SVName,
          SECURITYGRP.SecurityGrpName,
          SECURITYGRP.SecurityGrpDescription,
          FUNCTIONNAMES.FunctionGrpName,
          FUNCTIONNAMES.FunctionName,
          SECAUDITHISTORY.EmployeeId,
          EMPLOYEE.NAME,
          SECAUDITHISTORY.SecScopeType,
          SECAUDITHISTORY.SecAuditUID,
          EMPLOYEE_1.NAME AS AuditUIDName,
          SECAUDITHISTORY.SecAuditDate,
          SECAUDITHISTORY.SecAuditType,
          SECURITYGRP.SecurityGrpId,
          FUNCTIONNAMES.FunctionId,
	  SECAUDITHISTORY.CRIB,
	  CRIB.NAME AS CribName,
          ISNULL(CAST (SECAUDITHISTORY.Crib AS VARCHAR), ISNULL(FunctionGrpName, SecurityGrpName)) AS AuditDescriptor1,
	  CASE WHEN SECAUDITHISTORY.CRIB IS NULL THEN
	          CASE WHEN FunctionGrpName IS NULL THEN SecurityGrpDescription ELSE ISNULL(FUNCTIONNAME, '<ALL>') END 
	  ELSE CRIB.NAME END AS AuditDescriptor2,
          CASE SecScopeType WHEN 1 THEN 'Non-primary' ELSE 'Primary' END AS SecScopeTypeDescription
     FROM SECAUDITHISTORY INNER JOIN VSecAuditType ON SECAUDITHISTORY.SecAuditType = VSecAuditType.SVNumber 
    	LEFT OUTER JOIN EMPLOYEE EMPLOYEE_1 ON SECAUDITHISTORY.SecAuditUID = EMPLOYEE_1.ID 
		LEFT OUTER JOIN FUNCTIONNAMES ON SECAUDITHISTORY.FunctionId = FUNCTIONNAMES.FunctionId 
		LEFT OUTER JOIN SECURITYGRP ON SECAUDITHISTORY.SecurityGrpId =SECURITYGRP.SecurityGrpId 
		LEFT OUTER JOIN EMPLOYEE ON SECAUDITHISTORY.EmployeeId = EMPLOYEE.ID
		LEFT OUTER JOIN CRIB ON SECAUDITHISTORY.CRIB = CRIB.CRIB
GO
/****** Object:  View [dbo].[VCribWithAreaCribs]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VCribWithAreaCribs] AS
   SELECT c1.CRIB AS CRIB,
          ISNULL(c1.CribArea, c1.CRIB) AS CribArea,
          c2.CRIB AS AreaCrib
     FROM CRIB c1 INNER JOIN CRIB c2 ON(c1.CRIB = c2.CRIB OR c1.cribarea = c2.cribarea)
GO
/****** Object:  View [dbo].[VCribAreaItemSummary]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VCribAreaItemSummary] AS
   SELECT   v.CRIB,
            v.CribArea,
            STATION.Item,
            SUM(STATION.BinQuantity) AS SumBinQuantity,
            SUM(STATION.Quantity) AS SumQuantity,
            SUM(STATION.MonthlyUsage) AS SumMonthlyUsage,
            SUM(STATION.OnOrder) AS SumOnOrder
       FROM VCribWithAreaCribs v INNER JOIN STATION ON v.AreaCrib = STATION.CRIB
   GROUP BY v.CRIB, v.cribarea, STATION.Item
GO
/****** Object:  View [dbo].[VReservFillableByArea]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VReservFillableByArea] AS
   SELECT   ReservationCribBin,
	    ReservationCrib,
            ReservationStatus,
	    ReservationType,
	    RESERVATION.ReservationNo as ReservationNo,
	    ReservationDetailNo, 	
	    ReservationWONo,
	    ReservationQuantity,
	    ReservationActualQuantity,
            ReservationItemNumber, 
	    SumBinQuantity,
	    SumBinQuantity - (ReservationQuantity - ISNULL(ReservationActualQuantity,0)) as ExcessAvailableQty
       FROM (RESERVATION INNER JOIN RESERVATIONDETAIL
	   ON RESERVATION.RESERVATIONNO = RESERVATIONDETAIL.RESERVATIONNO) 
	   INNER JOIN VCribAreaItemSummary ON RESERVATIONDETAIL.RESERVATIONCRIB = VCribAreaItemSummary.CRIB
		AND VCribAreaItemSummary.ITEM = RESERVATIONDETAIL.RESERVATIONITEMNUMBER
           where reservationstatus in (1, 2)
	   and ReservationQuantity > ISNULL(ReservationActualQuantity,0)
           and SumBinQuantity > 0
GO
/****** Object:  View [dbo].[VCribItemSummary]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VCribItemSummary] AS
	SELECT Crib.Crib, Crib.Name, STATION.Item, SUM(STATION.BinQuantity) AS SumBinQuantity, SUM(STATION.Quantity) AS SumQuantity, 
		SUM(STATION.MonthlyUsage) AS SumMonthlyUsage, SUM(STATION.OnOrder) AS SumOnOrder, Crib.EnableSiteTransfers
		FROM Crib INNER JOIN STATION ON Crib.Crib = STATION.Crib
		GROUP BY Crib.Crib, Crib.Name, STATION.Item, Crib.EnableSiteTransfers
GO
/****** Object:  View [dbo].[VCribRelatedItemSummary]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VCribRelatedItemSummary] AS
   SELECT INVENTRY.Description1,
          INVENTRY.Description2,
          INVENTRY.Price,
          INVENTRY.VendorNumber,
          INVENTRY.ACCESSCODE,
          INVENTRY.ITEMTYPE,
          INVENTRY.ITEMCLASS,
          INVENTRY.ReworkedItemNumber,
          INVENTRY.UPCCode,
          INVENTRY.Comments,
          INVENTRY.PRICETYPE,
          INVENTRY.Manufacturer,
          INVENTRY.MfrNumber,
          INVENTRY.DefaultQty,
          INVENTRY.RESTRICTED,
          INVENTRY.ItemStatusCode,
          INVENTRY.TrackLotNumber,
          INVENTRY.CINo,
          INVENTRY.ClassNo,
          INVENTRY.CIRevision,
          INVENTRY.CINumber,
          INVENTRY.ItemFODControl,
          INVENTRY.AltVendorNo,
          INVENTRY.RequiresInspection,
          INVENTRY.InactiveItem,
          INVENTRY.IssueUnitOfMeasure,
          ITEMRELATIONSHIP.ItemRelationshipId,
          ITEMRELATIONSHIP.RelatedItemNumber,
          ITEMRELATIONSHIP.ItemNumber,
          ITEMRELATIONSHIP.RelatedQuantity,
          VCribItemSummary.CRIB,
          VCribItemSummary.NAME,
          VCribItemSummary.SumBinQuantity,
          VCribItemSummary.SumQuantity,
          VCribItemSummary.SumMonthlyUsage,
          VCribItemSummary.SumOnOrder,
          VCribItemSummary.EnableSiteTransfers,
          ITEMRELATIONSHIP.RelationshipTypeId,
          ITEMRELATIONSHIP.RelationshipCode,
          ITEMRELATIONSHIP.SpecialInstructions,
          RELATIONSHIPTYPE.RelationshipTypeName,
          RELATIONSHIPTYPE.Predefined,
          RELATIONSHIPTYPE.UsageType,
          ITEMRELATIONSHIP.Precedence
     FROM ((INVENTRY INNER JOIN ITEMRELATIONSHIP ON INVENTRY.ItemNumber = ITEMRELATIONSHIP.RelatedItemNumber)
		INNER JOIN VCribItemSummary ON ITEMRELATIONSHIP.RelatedItemNumber =	VCribItemSummary.Item)
		INNER JOIN RELATIONSHIPTYPE ON ITEMRELATIONSHIP.RelationshipTypeId = RELATIONSHIPTYPE.RelationshipTypeId

GO
/****** Object:  UserDefinedFunction [dbo].[bfMonthInvClass]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[bfMonthInvClass]
(  
 @yearMonth varchar(20)
)
RETURNS TABLE 
AS
RETURN
	select lInactiveItem,lDefaultBuyerGroupId,litemclass, 
	sum(albNewCribTotCost) albNewCribTotCost, 
	sum(albRwkCribTotCost) albRwkCribTotCost, 
	sum(aviNewCribTotCost) aviNewCribTotCost, 
	sum(aviRwkCribTotCost) aviRwkCribTotCost,
	sum(cribTotCost) cribTotCost,
	sum(TB2TotCost) TB2TotCost,
	sum(TB3TotCost) TB3TotCost,
	sum(TB5TotCost) TB5TotCost,
	sum(TB6TotCost) TB6TotCost,
	sum(TB7TotCost) TB7TotCost,
	sum(TB8TotCost) TB8TotCost,
	sum(TB9TotCost) TB9TotCost,
	sum(TB11TotCost) TB11TotCost,
	sum(TB112TotCost) TB112TotCost,
	sum(TBTotCost) TBTotCost,
	sum(newIssuedTotCost) newIssuedTotCost,
	sum(rwkIssuedTotCost) rwkIssuedTotCost,
	sum(issuedTotCost) issuedTotCost,
	sum(OnOrderTotCost) OnOrderTotCost,
	sum(orderCost) orderCost
	from 
	(
		select * 
		from btMonthInv
		where yearMonth = @yearMonth
	)lv1
	group by lInactiveItem,lDefaultBuyerGroupId,litemclass


GO
/****** Object:  UserDefinedFunction [dbo].[bfMonthInvClassDiff]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[bfMonthInvClassDiff]
(
 @LYearMonth varchar(20),
 @RYearMonth varchar(20)
 )
RETURNS TABLE 
AS
RETURN

	select

	lInactiveItemL,lInactiveItemR,lDefaultBuyerGroupIdL,lDefaultBuyerGroupIdR,litemclassL,litemclassR,
	albNewCribTotCostL,albNewCribTotCostR,albNewCribTotCostL-albNewCribTotCostR albNewCribTotCostDiff,
	albRwkCribTotCostL,albRwkCribTotCostR,albRwkCribTotCostL-albRwkCribTotCostR albRwkCribTotCostDiff,
	aviNewCribTotCostL,aviNewCribTotCostR,aviNewCribTotCostL-aviNewCribTotCostR aviNewCribTotCostDiff,
	aviRwkCribTotCostL,aviRwkCribTotCostR,aviRwkCribTotCostL-aviRwkCribTotCostR aviRwkCribTotCostDiff,
	cribTotCostL,cribTotCostR,cribTotCostL-cribTotCostR cribTotCostDiff,
	TB2TotCostL,TB2TotCostR,TB2TotCostL-TB2TotCostR TB2TotCostDiff,
	TB3TotCostL,TB3TotCostR,TB3TotCostL-TB3TotCostR TB3TotCostDiff,
	TB5TotCostL,TB5TotCostR,TB5TotCostL-TB5TotCostR TB5TotCostDiff,
	TB6TotCostL,TB6TotCostR,TB6TotCostL-TB6TotCostR TB6TotCostDiff,
	TB7TotCostL,TB7TotCostR,TB7TotCostL-TB7TotCostR TB7TotCostDiff,
	TB8TotCostL,TB8TotCostR,TB8TotCostL-TB8TotCostR TB8TotCostDiff,
	TB9TotCostL,TB9TotCostR,TB9TotCostL-TB9TotCostR TB9TotCostDiff,
	TB11TotCostL,TB11TotCostR,TB11TotCostL-TB11TotCostR TB11TotCostDiff,
	TB112TotCostL,TB112TotCostR,TB112TotCostL-TB112TotCostR TB112TotCostDiff,
	TBTotCostL,TBTotCostR,TBTotCostL-TBTotCostR TBTotCostDiff,
	newIssuedTotCostL,newIssuedTotCostR,newIssuedTotCostL-newIssuedTotCostR newIssuedTotCostDiff,
	rwkIssuedTotCostL,rwkIssuedTotCostR,rwkIssuedTotCostL-rwkIssuedTotCostR rwkIssuedTotCostDiff,
	issuedTotCostL,issuedTotCostR,issuedTotCostL-issuedTotCostR issuedTotCostDiff,
	OnOrderTotCostL,OnOrderTotCostR,OnOrderTotCostL-OnOrderTotCostR OnOrderTotCostDiff,
	orderCostL,orderCostR,orderCostL-orderCostR orderCostDiff
	from
	(
		select 
		case 
			when l.lInactiveItem is null then 1
			else l.lInactiveItem
		end lInactiveItemL,
		case 
			when l.lDefaultBuyerGroupId is null then 'None'
			else l.lDefaultBuyerGroupId
		end lDefaultBuyerGroupIdL,
		case 
			when l.litemclass is null then 'None'
			else l.litemclass
		end litemclassL,
		case 
			when l.albNewCribTotCost is null then 0.0
			else l.albNewCribTotCost
		end albNewCribTotCostL,
		case 
			when l.albRwkCribTotCost is null then 0.0
			else l.albRwkCribTotCost
		end albRwkCribTotCostL,
		case 
			when l.aviNewCribTotCost is null then 0.0
			else l.aviNewCribTotCost
		end aviNewCribTotCostL,
		case 
			when l.aviRwkCribTotCost is null then 0.0
			else l.aviRwkCribTotCost
		end aviRwkCribTotCostL, 
		case 
			when l.cribTotCost is null then 0.0
			else l.cribTotCost
		end cribTotCostL,
		case 
			when l.TB2TotCost is null then 0.0
			else l.TB2TotCost
		end TB2TotCostL,
		case 
			when l.TB3TotCost is null then 0.0
			else l.TB3TotCost
		end TB3TotCostL,
		case 
			when l.TB5TotCost is null then 0.0
			else l.TB5TotCost
		end TB5TotCostL,
		case 
			when l.TB6TotCost is null then 0.0
			else l.TB6TotCost
		end TB6TotCostL,
		case 
			when l.TB7TotCost is null then 0.0
			else l.TB7TotCost
		end TB7TotCostL,
		case 
			when l.TB8TotCost is null then 0.0
			else l.TB8TotCost
		end TB8TotCostL,
		case 
			when l.TB9TotCost is null then 0.0
			else l.TB9TotCost
		end TB9TotCostL,
		case 
			when l.TB11TotCost is null then 0.0
			else l.TB11TotCost
		end TB11TotCostL,
		case 
			when l.TB112TotCost is null then 0.0
			else l.TB112TotCost
		end TB112TotCostL,
		case 
			when l.TBTotCost is null then 0.0
			else l.TBTotCost
		end TBTotCostL,
		case 
			when l.newIssuedTotCost is null then 0.0
			else l.newIssuedTotCost
		end newIssuedTotCostL,
		case 
			when l.rwkIssuedTotCost is null then 0.0
			else l.rwkIssuedTotCost
		end rwkIssuedTotCostL,
		case 
			when l.issuedTotCost is null then 0.0
			else l.issuedTotCost
		end issuedTotCostL,
		case 
			when l.OnOrderTotCost is null then 0.0
			else l.OnOrderTotCost
		end OnOrderTotCostL,
		case 
			when l.orderCost is null then 0.0
			else l.orderCost
		end orderCostL,
		case 
			when r.lInactiveItem is null then 1
			else r.lInactiveItem
		end lInactiveItemR,
		case 
			when r.lDefaultBuyerGroupId is null then 'None'
			else r.lDefaultBuyerGroupId
		end lDefaultBuyerGroupIdR,
		case 
			when r.litemclass is null then 'None'
			else r.litemclass
		end litemclassR,
		case 
			when r.albNewCribTotCost is null then 0.0
			else r.albNewCribTotCost
		end albNewCribTotCostR,
		case 
			when r.albRwkCribTotCost is null then 0.0
			else r.albRwkCribTotCost
		end albRwkCribTotCostR,
		case 
			when r.aviNewCribTotCost is null then 0.0
			else r.aviNewCribTotCost
		end aviNewCribTotCostR,
		case 
			when r.aviRwkCribTotCost is null then 0.0
			else r.aviRwkCribTotCost
		end aviRwkCribTotCostR, 
		case 
			when r.cribTotCost is null then 0.0
			else r.cribTotCost
		end cribTotCostR,
		case 
			when r.TB2TotCost is null then 0.0
			else r.TB2TotCost
		end TB2TotCostR,
		case 
			when r.TB3TotCost is null then 0.0
			else r.TB3TotCost
		end TB3TotCostR,
		case 
			when r.TB5TotCost is null then 0.0
			else r.TB5TotCost
		end TB5TotCostR,
		case 
			when r.TB6TotCost is null then 0.0
			else r.TB6TotCost
		end TB6TotCostR,
		case 
			when r.TB7TotCost is null then 0.0
			else r.TB7TotCost
		end TB7TotCostR,
		case 
			when r.TB8TotCost is null then 0.0
			else r.TB8TotCost
		end TB8TotCostR,
		case 
			when r.TB9TotCost is null then 0.0
			else r.TB9TotCost
		end TB9TotCostR,
		case 
			when r.TB11TotCost is null then 0.0
			else r.TB11TotCost
		end TB11TotCostR,
		case 
			when r.TB112TotCost is null then 0.0
			else r.TB112TotCost
		end TB112TotCostR,
		case 
			when r.TBTotCost is null then 0.0
			else r.TBTotCost
		end TBTotCostR,
		case 
			when r.newIssuedTotCost is null then 0.0
			else r.newIssuedTotCost
		end newIssuedTotCostR,
		case 
			when r.rwkIssuedTotCost is null then 0.0
			else r.rwkIssuedTotCost
		end rwkIssuedTotCostR,
		case 
			when r.issuedTotCost is null then 0.0
			else r.issuedTotCost
		end issuedTotCostR,
		case 
			when r.OnOrderTotCost is null then 0.0
			else r.OnOrderTotCost
		end OnOrderTotCostR,
		case 
			when r.orderCost is null then 0.0
			else r.orderCost
		end orderCostR
		from 
		bfMonthInvClass(@LYearMonth) l
		full join
		bfMonthInvClass(@RYearMonth) r
		on
		l.lInactiveItem=r.lInactiveItem and
		l.lDefaultBuyerGroupId=r.lDefaultBuyerGroupId and
		l.litemclass=r.litemclass
		--235
	)lv1

GO
/****** Object:  UserDefinedFunction [dbo].[bfMonthInvClassDetails]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[bfMonthInvClassDetails]
(  
 @LYearMonth varchar(20)
)
RETURNS TABLE 
AS
RETURN
	select 
	lItemNumber lItemNumberL,
	ldescription1 ldescription1L,
	lManufacturer lManufacturerL,
	lInactiveItem lInactiveItemL,
	lDefaultBuyerGroupId lDefaultBuyerGroupIdL,
	litemclass litemclassL, 
	albNewCribTotCost albNewCribTotCostL, 
	albRwkCribTotCost albRwkCribTotCostL, 
	aviNewCribTotCost aviNewCribTotCostL, 
	aviRwkCribTotCost aviRwkCribTotCostL,
	cribTotCost cribTotCostL,
	TB2TotCost TB2TotCostL,
	TB3TotCost TB3TotCostL,
	TB5TotCost TB5TotCostL,
	TB6TotCost TB6TotCostL,
	TB7TotCost TB7TotCostL,
	TB8TotCost TB8TotCostL,
	TB9TotCost TB9TotCostL,
	TB11TotCost TB11TotCostL,
	TB112TotCost TB112TotCostL,
	TBTotCost TBTotCostL,
	newIssuedTotCost newIssuedTotCostL,
	rwkIssuedTotCost rwkIssuedTotCostL,
	issuedTotCost issuedTotCostL,
	OnOrderTotCost OnOrderTotCostL,
	orderCost orderCostL
	from 
	(
		select * 
		from btMonthInv
		where yearMonth = @LYearMonth
	)lv1

GO
/****** Object:  UserDefinedFunction [dbo].[SplitStrings_Moden]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[SplitStrings_Moden]
(
   @List NVARCHAR(MAX),
   @Delimiter NVARCHAR(255)
)
RETURNS TABLE
WITH SCHEMABINDING AS
RETURN
  WITH E1(N)        AS ( SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
                         UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
                         UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1),
       E2(N)        AS (SELECT 1 FROM E1 a, E1 b),
       E4(N)        AS (SELECT 1 FROM E2 a, E2 b),
       E42(N)       AS (SELECT 1 FROM E4 a, E2 b),
       cteTally(N)  AS (SELECT 0 UNION ALL SELECT TOP (DATALENGTH(ISNULL(@List,1))) 
                         ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM E42),
       cteStart(N1) AS (SELECT t.N+1 FROM cteTally t
                         WHERE (SUBSTRING(@List,t.N,1) = @Delimiter OR t.N = 0))
  SELECT Item = SUBSTRING(@List, s.N1, ISNULL(NULLIF(CHARINDEX(@Delimiter,@List,s.N1),0)-s.N1,8000))
    FROM cteStart s;
GO
/****** Object:  View [dbo].[bvDistinctMonthInv]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[bvDistinctMonthInv]
as
select distinct yearMonth 
from btMonthInv

GO
/****** Object:  View [dbo].[bvItemIssued]    Script Date: 4/20/2018 11:41:39 AM ******/
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
/****** Object:  View [dbo].[bvitemPartIssuedList]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--///////////////////////////////////////////////////////////////////////////////////
-- For each translog items create a record containing newIssuedTotQty,newIssuedTotCost,
-- rwkIssuedTotQty,rwkIssuedTotCost, issuedTotQty,issuedTotCost
--///////////////////////////////////////////////////////////////////////////////////
create view [dbo].[bvitemPartIssuedList] 
AS
	select 
	case 
		when new.PartNumber is null then SUBSTRING(rwk.PartNumber,1,len(rwk.partNumber)-1)
		else new.PartNumber
	end partNumber,
	case 
		when new.ItemNumber is null then SUBSTRING(rwk.ItemNumber,1,len(rwk.ItemNumber)-1)
		else new.ItemNumber
	end itemNumber,
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
		select partNumber,itemNumber,sum(qty) newIssuedTotQty, sum(qty*unitCost) newIssuedTotCost 
		from btTransLogMonth
		group by partNumber,ItemNumber
		having ItemNumber <> '' and ItemNumber <> '.'
		and itemNumber not like '%R'
		--2613
	)new
	full join
	(
		select partNumber,itemNumber,sum(qty) rwkIssuedTotQty, sum(qty*unitCost) rwkIssuedTotCost 
		from btTransLogMonth
		group by partNumber,ItemNumber
		having ItemNumber <> '' and ItemNumber <> '.'
		and itemNumber like '%R'
		--80
	)rwk
	on
	new.PartNumber=rwk.partNumber and
	new.ItemNumber=rwk.ItemNumber
	--2193


GO
/****** Object:  View [dbo].[VAltVendorWithBlanketPO]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VAltVendorWithBlanketPO] AS
   SELECT ALTVENDOR.RecNumber,
          ALTVENDOR.ItemNumber,
          ALTVENDOR.VendorNumber,
          ALTVENDOR.Comments,
          ALTVENDOR.VendorItemNumber,
          ALTVENDOR.MinOrder,
          ALTVENDOR.CaseSize,
          ALTVENDOR.PriceExpiration,
          ALTVENDOR.COST,
          ALTVENDOR.BreakQuantity1,
          ALTVENDOR.Cost1,
          ALTVENDOR.BreakQuantity2,
          ALTVENDOR.Cost2,
          ALTVENDOR.BreakQuantity3,
          ALTVENDOR.Cost3,
          ALTVENDOR.BreakQuantity4,
          ALTVENDOR.Cost4,
          ALTVENDOR.BreakQuantity5,
          ALTVENDOR.Cost5,
          ALTVENDOR.BreakQuantity6,
          ALTVENDOR.Cost6,
          ALTVENDOR.SalesTaxable,
          ALTVENDOR.AutoPurchase,
          ALTVENDOR.DistCost,
          ALTVENDOR.UnitOfMeasure,
          ALTVENDOR.AllowAsSubstitute,
          BLANKETPO.BlanketPONo,
          BLANKETPO.BlanketNumber,
          BLANKETPO.ExpirationDate,
          BLANKETPO.BlanketPOInactive
     FROM ALTVENDOR LEFT OUTER JOIN BLANKETPO ON ALTVENDOR.BlanketPONo =
                                                                     BLANKETPO.BlanketPONo

GO
/****** Object:  View [dbo].[VASNACKTYPE]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VASNACKTYPE] AS
	SELECT SVNumber, SVName, SVDescription FROM SYSTEMVALUE WHERE SVTYPE=26
GO
/****** Object:  View [dbo].[VASNCURSTATUSTYPE]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VASNCURSTATUSTYPE] AS
	SELECT SVNumber, SVName, SVDescription FROM SYSTEMVALUE WHERE SVTYPE=24
GO
/****** Object:  View [dbo].[VAssemblyStatus]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VAssemblyStatus] AS
	SELECT SVNumber, SVName, SVDescription FROM SYSTEMVALUE WHERE SVTYPE=20
GO
/****** Object:  View [dbo].[VAutoScrapOption]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VAutoScrapOption] AS
	SELECT SVNumber, SVName, SVDescription FROM SYSTEMVALUE WHERE SVTYPE=37
GO
/****** Object:  View [dbo].[VBinType]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VBinType] AS
	SELECT SVNumber, SVName, SVDescription FROM SYSTEMVALUE WHERE SVTYPE=22
GO
/****** Object:  View [dbo].[VCribFODOption]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VCribFODOption] AS
	SELECT SVNumber, SVName, SVDescription FROM SYSTEMVALUE WHERE SVTYPE=33
GO
/****** Object:  View [dbo].[VEmployeeFODControl]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VEmployeeFODControl] AS
	SELECT SVNumber, SVName, SVDescription FROM SYSTEMVALUE WHERE SVTYPE=36
GO
/****** Object:  View [dbo].[VEmployeePermissions]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VEmployeePermissions] AS
SELECT EMPLOYEEID,
       FUNCTIONID,
       FUNCTIONGRPNAME,
       FUNCTIONNAME,
       SCOPETYPE
  FROM (SELECT es.employeeid,
               sgf.functionid,
               sgf.functiongrpname,
               sgf.functionname,
               scopetype
          FROM EMPLOYEESECURITY es,
               (SELECT sga.securitygrpid,
                       fn.functionid,
                       fn.functiongrpname,
                       fn.functionname
                  FROM FUNCTIONNAMES fn, SECURITYGRPACCESS sga
                 WHERE sga.functionid = fn.functionid AND fn.functionname IS NOT NULL
                UNION
                SELECT sga.securitygrpid,
                       fn2.functionid,
                       fn2.functiongrpname,
                       fn2.functionname
                  FROM FUNCTIONNAMES fn, SECURITYGRPACCESS sga, FUNCTIONNAMES fn2
                 WHERE sga.functionid = fn.functionid
                   AND fn.functionname IS NULL
                   AND fn.functiongrpname = fn2.functiongrpname
                   AND fn2.functionname IS NOT NULL) SGF
         WHERE es.securitygrpid = sgf.securitygrpid AND scopetype = 0
        UNION
        SELECT es.employeeid,
               ff.functionid,
               ff.functiongrpname,
               ff.functionname,
               scopetype
          FROM EMPLOYEESECURITYEXT es,
               (SELECT fn2.functionid,
                       fn2.functionname,
                       fn2.functiongrpname,
                       fn.functionid origfunctionid
                  FROM FUNCTIONNAMES fn, FUNCTIONNAMES fn2
                 WHERE fn.functiongrpname = fn2.functiongrpname
                   AND fn.functionname IS NULL
                   AND fn2.functionname IS NOT NULL
                UNION
                SELECT functionid,
                       functionname,
                       functiongrpname,
                       functionid
                  FROM FUNCTIONNAMES
                 WHERE functionname IS NOT NULL AND functiongrpname IS NOT NULL) FF
         WHERE es.functionid = ff.origfunctionid AND scopetype = 0 AND securitytype = 2
        EXCEPT
        SELECT es.employeeid,
               ff.functionid,
               ff.functiongrpname,
               ff.functionname,
               scopetype
          FROM EMPLOYEESECURITYEXT es,
               (SELECT fn2.functionid,
                       fn2.functionname,
                       fn2.functiongrpname,
                       fn.functionid origfunctionid
                  FROM FUNCTIONNAMES fn, FUNCTIONNAMES fn2
                 WHERE fn.functiongrpname = fn2.functiongrpname
                   AND fn.functionname IS NULL
                   AND fn2.functionname IS NOT NULL
                UNION
                SELECT functionid,
                       functionname,
                       functiongrpname,
                       functionid
                  FROM FUNCTIONNAMES
                 WHERE functionname IS NOT NULL AND functiongrpname IS NOT NULL) FF
         WHERE es.functionid = ff.origfunctionid AND scopetype = 0 AND securitytype = 1) TT
UNION
(SELECT es.employeeid,
        sgf.functionid,
        sgf.functiongrpname,
        sgf.functionname,
        scopetype
   FROM EMPLOYEESECURITY es,
        (SELECT sga.securitygrpid,
                fn.functionid,
                fn.functiongrpname,
                fn.functionname
           FROM FUNCTIONNAMES fn, SECURITYGRPACCESS sga
          WHERE sga.functionid = fn.functionid AND fn.functionname IS NOT NULL
         UNION
         SELECT sga.securitygrpid,
                fn2.functionid,
                fn2.functiongrpname,
                fn2.functionname
           FROM FUNCTIONNAMES fn, SECURITYGRPACCESS sga, FUNCTIONNAMES fn2
          WHERE sga.functionid = fn.functionid
            AND fn.functionname IS NULL
            AND fn.functiongrpname = fn2.functiongrpname
            AND fn2.functionname IS NOT NULL) SGF
  WHERE es.securitygrpid = sgf.securitygrpid AND scopetype = 1
 UNION
 SELECT es.employeeid,
        ff.functionid,
        ff.functiongrpname,
        ff.functionname,
        scopetype
   FROM EMPLOYEESECURITYEXT es,
        (SELECT fn2.functionid,
                fn2.functionname,
                fn2.functiongrpname,
                fn.functionid origfunctionid
           FROM FUNCTIONNAMES fn, FUNCTIONNAMES fn2
          WHERE fn.functiongrpname = fn2.functiongrpname
            AND fn.functionname IS NULL
            AND fn2.functionname IS NOT NULL
         UNION
         SELECT functionid,
                functionname,
                functiongrpname,
                functionid
           FROM FUNCTIONNAMES
          WHERE functionname IS NOT NULL AND functiongrpname IS NOT NULL) FF
  WHERE es.functionid = ff.origfunctionid AND scopetype = 1 AND securitytype = 2
 EXCEPT
 SELECT es.employeeid,
        ff.functionid,
        ff.functiongrpname,
        ff.functionname,
        scopetype
   FROM EMPLOYEESECURITYEXT es,
        (SELECT fn2.functionid,
                fn2.functionname,
                fn2.functiongrpname,
                fn.functionid origfunctionid
           FROM FUNCTIONNAMES fn, FUNCTIONNAMES fn2
          WHERE fn.functiongrpname = fn2.functiongrpname
            AND fn.functionname IS NULL
            AND fn2.functionname IS NOT NULL
         UNION
         SELECT functionid,
                functionname,
                functiongrpname,
                functionid
           FROM FUNCTIONNAMES
          WHERE functionname IS NOT NULL AND functiongrpname IS NOT NULL) FF
  WHERE es.functionid = ff.origfunctionid AND scopetype = 1 AND securitytype = 1)

GO
/****** Object:  View [dbo].[VEventLogType]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VEventLogType] AS
	SELECT SVNumber, SVName, SVDescription FROM SYSTEMVALUE WHERE SVTYPE=32
GO
/****** Object:  View [dbo].[VItemWithRelatedCribBin]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VItemWithRelatedCribBin] AS
   SELECT INVENTRY.Description1,
          INVENTRY.Description2,
          INVENTRY.Price,
          INVENTRY.ACCESSCODE,
          INVENTRY.VendorNumber,
          INVENTRY.ITEMTYPE,
          INVENTRY.ITEMCLASS,
          INVENTRY.ReworkedItemNumber,
          INVENTRY.UPCCode,
          INVENTRY.Comments,
          INVENTRY.Serialized,
          INVENTRY.PRICETYPE,
          INVENTRY.Manufacturer,
          INVENTRY.MfrNumber,
          INVENTRY.DefaultQty,
          INVENTRY.RESTRICTED,
          INVENTRY.ItemStatusCode,
          INVENTRY.TrackLotNumber,
          INVENTRY.CINo,
          INVENTRY.ClassNo,
          INVENTRY.CIRevision,
          INVENTRY.CINumber,
          INVENTRY.UseCheckList,
          INVENTRY.ItemFODControl,
          INVENTRY.AltVendorNo,
          INVENTRY.RequiresInspection,
          INVENTRY.InactiveItem,
          INVENTRY.IssueUnitOfMeasure,
          ITEMRELATIONSHIP.ItemRelationshipId,
          ITEMRELATIONSHIP.RelatedItemNumber,
          ITEMRELATIONSHIP.RelatedQuantity,
          ITEMRELATIONSHIP.Precedence,
          ITEMRELATIONSHIP.RelationshipCode,
          ITEMRELATIONSHIP.Comments AS RelationshipComment,
          ITEMRELATIONSHIP.SpecialInstructions,
          ITEMRELATIONSHIP.RelationshipWODefNo,
          RELATIONSHIPTYPE.RelationshipTypeId,
          RELATIONSHIPTYPE.RelationshipTypeName,
          RELATIONSHIPTYPE.Predefined,
          RELATIONSHIPTYPE.UsageType,
          STATION.CribBin,
          STATION.CRIB,
          STATION.BinQuantity,
          STATION.Quantity,
          STATION.OnOrder,
          STATION.Comments AS BinComments,
          STATION.StopOrdering,
          STATION.BinCapacity,
          STATION.PendingRework,
          ITEMRELATIONSHIP.ItemNumber
     FROM INVENTRY
	 INNER JOIN ITEMRELATIONSHIP ON INVENTRY.ItemNumber = ITEMRELATIONSHIP.RelatedItemNumber
	 INNER JOIN RELATIONSHIPTYPE ON ITEMRELATIONSHIP.RelationshipTypeId = RELATIONSHIPTYPE.RelationshipTypeId
	 INNER JOIN STATION ON ITEMRELATIONSHIP.RelatedItemNumber = STATION.Item

GO
/****** Object:  View [dbo].[VLaborPayType]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VLaborPayType] AS
	SELECT SVNumber, SVName, SVDescription FROM SYSTEMVALUE WHERE SVTYPE=28
GO
/****** Object:  View [dbo].[VLoginEventType]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VLoginEventType] AS
	SELECT SVNumber, SVName, SVDescription FROM SYSTEMVALUE WHERE SVTYPE=29
GO
/****** Object:  View [dbo].[VOnHandAvgSum_Item_Crib]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VOnHandAvgSum_Item_Crib] AS
SELECT     YEAR(StatisticsDate) AS Year, MONTH(StatisticsDate) AS Month, StatisticsDate AS TransDate, Crib, ItemNumber, SUM(StatisticsValue) AS OnHandAvg
FROM         dbo.CRIBSTATISTICS
WHERE     (StatisticsType = 14)
GROUP BY YEAR(StatisticsDate), MONTH(StatisticsDate), StatisticsDate, Crib, ItemNumber

GO
/****** Object:  View [dbo].[VP21RECTYPE]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VP21RECTYPE] AS
	SELECT SVNumber, SVName, SVDescription FROM SYSTEMVALUE WHERE SVTYPE=25
GO
/****** Object:  View [dbo].[VPendingWithAltVendor]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VPendingWithAltVendor] AS
   SELECT ALTVENDOR.AutoPurchase,
          STATION.StationAutoPurchase,
          STATION.BinCapacity,
          ALTVENDOR.BreakQuantity1,
          ALTVENDOR.BreakQuantity2,
          ALTVENDOR.BreakQuantity3,
          ALTVENDOR.BreakQuantity4,
          ALTVENDOR.BreakQuantity5,
          ALTVENDOR.BreakQuantity6,
          ALTVENDOR.CaseSize,
          ALTVENDOR.Cost1,
          ALTVENDOR.Cost2,
          ALTVENDOR.Cost3,
          ALTVENDOR.Cost4,
          ALTVENDOR.Cost5,
          ALTVENDOR.Cost6,
          PENDINGORDER.DatePromised,
          PENDINGORDER.DateRequired,
          PENDINGORDER.ID,
          PENDINGORDER.NeedQuantity,
          PENDINGORDER.Quantity,
          STATION.PendingRework,
          INVENTRY.ReworkedItemNumber,
          ALTVENDOR.SalesTaxable AS AVSalesTaxable,
          PENDINGORDER.SalesTaxable,
          INVENTRY.ShortDesc,
          STATION.Comments AS BinComment,
          STATION.CribBin,
          STATION.Quantity AS StationQuantity,
          STATION.StockFromCribBin,
          PENDINGORDER.TYPE,
          INVENTRY.UPCCode,
          ALTVENDOR.Comments AS AltVendorComment,
          PENDINGORDER.COST,
          ALTVENDOR.COST AS AVCost,
          ALTVENDOR.MinOrder AS AVMinOrder,
          INVENTRY.ITEMCLASS,
          PENDINGORDER.Description1,
          PENDINGORDER.Description2,
          INVENTRY.ItemNumber,
          PENDINGORDER.Special,
          PENDINGORDER.VendorItemNumber,
          PENDINGORDER.VendorNumber,
          PENDINGORDER.Comments,
          INVENTRY.Comments AS InventryComment,
          STATION.MinOrder,
          PENDINGORDER.OriginalPODetail,
          PENDINGORDER.ConfirmNumber,
          STATION.AvgLeadTime,
          PENDINGORDER.CRIB,
          PENDINGORDER.CostFlag,
          PENDINGORDER.DistCost,
          PENDINGORDER.WONo,
          STATION.OverrideAvgLeadTime,
          ALTVENDOR.PriceExpiration,
          PENDINGORDER.PendingOrderUPCCode,
          STATION.Consignment,
          PENDINGORDER.PendingOrderBatchID,
          PENDINGORDER.AltVendorNo,
          INVENTRY.CINo,
          INVENTRY.CINumber,
          PENDINGORDER.PENDINGORDERTYPE,
          PENDINGORDER.MinOrderQuantity,
          INVENTRY.BuyerGroupID,
          PENDINGORDER.SuggestedQuantity,
          BLANKETPO.BlanketPONo,
          BLANKETPO.BlanketNumber,
          STATION.UsageThisMonth,
          STATION.MonthlyUsage,
          BLANKETPO.ExpirationDate,
          PENDINGORDER.RequiresInspection,
          PENDINGORDER.ItemWithOrder,
          PENDINGORDER.USER1,
          PENDINGORDER.USER2,
          PENDINGORDER.USER3,
          PENDINGORDER.USER4,
          PENDINGORDER.USER5,
          PENDINGORDER.USER6,
          ALTVENDOR.UnitOfMeasure,
          ALTVENDOR.AllowAsSubstitute,
		  INVENTRY.ItemType,
		  STATION.OverrideMonthlyUsage,
		  PENDINGORDER.ReqDetNo,
		  PENDINGORDER.PendingOrderDate
     FROM PENDINGORDER
	 LEFT OUTER JOIN INVENTRY ON PENDINGORDER.ItemNumber = INVENTRY.ItemNumber
	 LEFT OUTER JOIN STATION ON PENDINGORDER.CribBin = STATION.CribBin
	 LEFT OUTER JOIN ALTVENDOR ON PENDINGORDER.AltVendorNo = ALTVENDOR.RecNumber
	 LEFT OUTER JOIN BLANKETPO ON ALTVENDOR.BlanketPONo = BLANKETPO.BlanketPONo

GO
/****** Object:  View [dbo].[VRecoveryBillStatus]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VRecoveryBillStatus] AS
	SELECT SVNumber, SVName, SVDescription FROM SYSTEMVALUE WHERE SVTYPE=38

GO
/****** Object:  View [dbo].[VRequestDetailStatus]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VRequestDetailStatus] AS
	SELECT SVNumber, SVName, SVDescription FROM SYSTEMVALUE WHERE SVTYPE=40

GO
/****** Object:  View [dbo].[VRequestStatus]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VRequestStatus] AS
	SELECT SVNumber, SVName, SVDescription FROM SYSTEMVALUE WHERE SVTYPE=39

GO
/****** Object:  View [dbo].[VReservationOrderOption]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VReservationOrderOption] AS
	SELECT SVNumber, SVName, SVDescription FROM SYSTEMVALUE WHERE SVTYPE=27
GO
/****** Object:  View [dbo].[VReservationType]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VReservationType] AS
	SELECT SVNumber, SVName, SVDescription FROM SYSTEMVALUE WHERE SVTYPE=23
GO
/****** Object:  View [dbo].[VReservCribBin]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VReservCribBin] AS
   SELECT   ReservationCribBin,
            ReservationStatus,
	    ReservationType,
	    RESERVATION.ReservationNo as ReservationNo,
	    ReservationDetailNo, 	
	    ReservationWONo,
	    ReservationQuantity,
	    ReservationActualQuantity,
            ReservationItemNumber
       FROM (RESERVATION INNER JOIN RESERVATIONDETAIL
	   ON RESERVATION.RESERVATIONNO = RESERVATIONDETAIL.RESERVATIONNO) 
	   INNER JOIN STATION ON RESERVATIONDETAIL.RESERVATIONCRIBBIN = STATION.CRIBBIN
GO
/****** Object:  View [dbo].[VRFIDTagStatus]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VRFIDTagStatus] AS
	SELECT SVNumber, SVName, SVDescription FROM SYSTEMVALUE WHERE SVTYPE=35
GO
/****** Object:  View [dbo].[VRptExportFormatType]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VRptExportFormatType] AS
	SELECT SVNumber, SVName, SVDescription FROM SYSTEMVALUE WHERE SVTYPE=31
GO
/****** Object:  View [dbo].[VRptSensitivityLevel]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VRptSensitivityLevel] AS
	SELECT SVNumber, SVName, SVDescription FROM SYSTEMVALUE WHERE SVTYPE=34
GO
/****** Object:  View [dbo].[VStationForCycleCount]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VStationForCycleCount] AS
   SELECT STATION.CRIBBIN AS CribBin,
          STATION.CRIB AS CRIB,
          INVENTRY.ITEMNUMBER AS ItemNumber,
          STATION.BinQuantity AS BinQuantity,
          STATION.DateLastCount AS DateLastCount,
          ISNULL(OvrAltVendorNo, AltVendorNo) AS AltVendorNo,
          STATION.CountType AS CountType,
          ISNULL(OvrCycleCountClassNo, CycleCountClassNo) AS CycleCountClassNo
     FROM STATION INNER JOIN INVENTRY
       ON STATION.item = INVENTRY.itemnumber
GO
/****** Object:  View [dbo].[VStationMinFIFODate]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VStationMinFIFODate] AS  
    SELECT CribBin, 
	(SELECT MIN(BINFIFODATE) FROM BINFIFO 
		WHERE BINFIFO.BINFIFOCRIBBIN = STATION.CRIBBIN) AS MinBinFIFODate
    FROM STATION
GO
/****** Object:  View [dbo].[VStatisticsType]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VStatisticsType] AS
	SELECT SVNumber, SVName, SVDescription FROM SYSTEMVALUE WHERE SVTYPE=41

GO
/****** Object:  View [dbo].[VTBMonthlyUsage]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create View [dbo].[VTBMonthlyUsage] 
as
select 
	ISNULL(lv1.CribToolID,'none') as CribToolID,
	case 
		when TLMonthlyUsage is null then cast(0.0 as decimal(18,2)) 
		else cast(TLMonthlyUsage as decimal(18,2)) 
	end as TLMonthlyUsage, 
	isnull(SUBSTRING(
		list.xmlDoc.value('.', 'varchar(max)'),
		6, 10000
	),'Misc,Fixture,or Global') AS ToolLists
from
(
	select CribToolID, cast(sum(MonthlyUsage) as decimal(18,2)) TLMonthlyUsage
	from [Busche ToolList].dbo.VMonthlyUsage vmu
	group by cribtoolid
) lv1
cross apply(
	select ',<br>'+ rVMonthlyUsage.DescUsage as ListItem
	from 
	(
		select CribToolID,tlDescription, sum(MonthlyUsage) MonthlyUsage,
		 tlDescription + ', ' + OpDescription + ', ' + 'Usage:' + cast(cast(sum(MonthlyUsage) as decimal(18,2)) as varchar(max)) 
		as DescUsage 
		from [Busche ToolList].dbo.VMonthlyUsage vmu
		group by CribToolID,tlDescription,OpDescription,tooldescription
	) rVMonthlyUsage
	where lv1.cribtoolid=rVMonthlyUsage.cribtoolid
	order by rVMonthlyUsage.DescUsage
	for xml path(''), type
) as list(xmlDoc)


GO
/****** Object:  View [dbo].[VTransExceededLimit]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VTransExceededLimit] AS
SELECT t1.*
  FROM TRANS t1 INNER JOIN CRIB c on t1.crib = c.crib
WHERE  typedescription = 'ISSUE'
  AND EXISTS(SELECT *
     FROM ((ITEMLIMIT t2 INNER JOIN CRAFTCODE t3 ON t2.CRAFTCODE = t3.CRAFTCODE)
         INNER JOIN EMPLOYEECRAFT t4 ON t3.CRAFTCODE = t4.CRAFTCODE)
         INNER JOIN EMPLOYEE t5 ON t4.employeeid = t5.ID
          WHERE t2.itemnumber = t1.item)
AND NOT EXISTS (SELECT * FROM (ITEMLIMIT t6 INNER JOIN CRAFTCODE t7 ON t6.CRAFTCODE = t7.CRAFTCODE)
         INNER JOIN EMPLOYEECRAFT t10 ON t7.CRAFTCODE = t10.CRAFTCODE WHERE t1.issuedto = t10.employeeID and t6.ITEMNUMBER=t1.ITEM AND
         t6.itemlimit >=
                  ISNULL(
                        case WHEN ISNULL(t6.itemlimitoption,0) = 1 AND (select itemclass from inventry where itemnumber=t1.item) IS NOT NULL THEN
                           (SELECT SUM(quantity) from TRANS t8 INNER JOIN INVENTRY t9 on t8.item = t9.itemnumber where TYPEDESCRIPTION = 'ISSUE' AND t8.issuedto=t1.issuedto and t8.transdate <= t1.transdate and
                                    (t9.itemclass is null or t9.itemclass  in (select itemclass from inventry where itemnumber=t1.item))
                                    and t8.transdate > DATEADD(day,-CASE WHEN ISNULL(t6.itemlimitinterval, 0) > 0 THEN t6.itemlimitinterval-1 ELSE 0 END,
                                       CONVERT(DATETIME, CONVERT(VARCHAR, t1.TRANSDATE, 102), 102)))
                        ELSE
                           (SELECT SUM(quantity) from TRANS t8 where t8.issuedto=t1.issuedto and t8.transdate <= t1.transdate and t8.item=t1.item AND TYPEDESCRIPTION = 'ISSUE'
                                    and t8.transdate > DATEADD(day,-CASE WHEN ISNULL(t6.itemlimitinterval, 0) > 0 THEN t6.itemlimitinterval-1 ELSE 0 END,
                                       CONVERT(DATETIME, CONVERT(VARCHAR, t1.TRANSDATE, 102), 102)))
                        END,
                  0)
                  )

GO
/****** Object:  View [dbo].[VUsageSum_Crib_Item]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VUsageSum_Crib_Item] AS
SELECT     YEAR(Transdate) AS Year, MONTH(Transdate) AS Month, Max(TransDate) as TransDate, Crib, Item, SUM(quantity) AS Usage
FROM         dbo.TRANS
WHERE     (TypeDescription IN ('ISSUE', 'RETNW'))
GROUP BY YEAR(Transdate), MONTH(Transdate), Crib, Item

GO
/****** Object:  View [dbo].[VUsageType]    Script Date: 4/20/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VUsageType] AS
	SELECT SVNumber, SVName, SVDescription FROM SYSTEMVALUE WHERE SVTYPE=21
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ALTVENDOR_IX_ITEMVENDOR]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [ALTVENDOR_IX_ITEMVENDOR] ON [dbo].[AltVendor]
(
	[ItemNumber] ASC,
	[VendorNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_ASSET_AssetID]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_ASSET_AssetID] ON [dbo].[Asset]
(
	[AssetID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ATRSETTINGS_CRIB]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_ATRSETTINGS_CRIB] ON [dbo].[ATRSettings]
(
	[Crib] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_ATRSETTINGS_SITEID]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_ATRSETTINGS_SITEID] ON [dbo].[ATRSettings]
(
	[SiteID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ATRSETTINGS_TEMPLATE]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_ATRSETTINGS_TEMPLATE] ON [dbo].[ATRSettings]
(
	[SettingsTemplateNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_BATCHLOG_DEVSEQ]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_BATCHLOG_DEVSEQ] ON [dbo].[BatchLog]
(
	[BatchDeviceId] ASC,
	[BatchSequenceNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_BINFIFO_TRANSNO]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_BINFIFO_TRANSNO] ON [dbo].[BINFIFO]
(
	[BinFIFOTransNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_BLANKETPO_BLANKETPONO]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_BLANKETPO_BLANKETPONO] ON [dbo].[BlanketPO]
(
	[BlanketPONo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_CHECKLIST_ITEMNUMBER]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_CHECKLIST_ITEMNUMBER] ON [dbo].[CheckList]
(
	[ItemNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_CHECKLIST_ITEMNUMBER]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_CHECKLIST_ITEMNUMBER] ON [dbo].[CheckListHistory]
(
	[ItemNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_CRIBSPACE_CRIBBINPREFIX]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_CRIBSPACE_CRIBBINPREFIX] ON [dbo].[CribSpace]
(
	[CribBinPrefix] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_RangeType_Dates]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_RangeType_Dates] ON [dbo].[CustomDateRange]
(
	[RangeType] ASC,
	[BeginDate] ASC,
	[EndDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_CYCLECOUNTCLASS_ID]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_CYCLECOUNTCLASS_ID] ON [dbo].[CycleCountClass]
(
	[CycleCountClassID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_CYCLECOUNTDETAIL_CRIBBIN]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_CYCLECOUNTDETAIL_CRIBBIN] ON [dbo].[CycleCountDetail]
(
	[CribBin] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_CYCLECOUNTSETTINGS_CRIB]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_CYCLECOUNTSETTINGS_CRIB] ON [dbo].[CycleCountSettings]
(
	[CycleCountClassNo] ASC,
	[Crib] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_DEVICESETTINGS_DEVICEIDKEY]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_DEVICESETTINGS_DEVICEIDKEY] ON [dbo].[DeviceSettings]
(
	[DeviceID] ASC,
	[KeyName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_EMPLOYEE_BADGENUMBER]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_EMPLOYEE_BADGENUMBER] ON [dbo].[EMPLOYEE]
(
	[BadgeNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_EmployeeCraft]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_EmployeeCraft] ON [dbo].[EmployeeCraft]
(
	[EmployeeID] ASC,
	[CraftCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_EMPSEC_EMPGRPSCOPE]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_EMPSEC_EMPGRPSCOPE] ON [dbo].[EmployeeSecurity]
(
	[EmployeeId] ASC,
	[SecurityGrpId] ASC,
	[ScopeType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_EMPSECEXT_EMPGRPSCOPE]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_EMPSECEXT_EMPGRPSCOPE] ON [dbo].[EmployeeSecurityExt]
(
	[EmployeeId] ASC,
	[FunctionId] ASC,
	[ScopeType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_EMPLOYEESITE_EMPLOYEE]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_EMPLOYEESITE_EMPLOYEE] ON [dbo].[EmployeeSite]
(
	[EmployeeID] ASC,
	[SiteID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [GaugeId]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [GaugeId] ON [dbo].[GaugeCertify]
(
	[SerialID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_GaugeCertifyDetail]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_GaugeCertifyDetail] ON [dbo].[GaugeCertifyDetail]
(
	[GaugeCertifyID] ASC,
	[GaugeMeasureID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [CalibrationReferenceID]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [CalibrationReferenceID] ON [dbo].[GaugeMeasurement]
(
	[CalibrationReferenceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ItemNumber]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [ItemNumber] ON [dbo].[InventryGauge]
(
	[ItemNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ITEMCLASS_IX_ITEMCLASS]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [ITEMCLASS_IX_ITEMCLASS] ON [dbo].[ITEMCLASS]
(
	[ItemClass] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [CribBin]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [CribBin] ON [dbo].[ItemInventory]
(
	[CribBin] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_ITEMLIMIT_CRAFTITEM]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_ITEMLIMIT_CRAFTITEM] ON [dbo].[ITEMLIMIT]
(
	[ItemNumber] ASC,
	[CraftCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_ITEMLIMITGRP_GRPSITEID]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_ITEMLIMITGRP_GRPSITEID] ON [dbo].[ItemLimitGrp]
(
	[GrpName] ASC,
	[SiteID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_ITEMLIMITGRP_SITEID]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_ITEMLIMITGRP_SITEID] ON [dbo].[ItemLimitGrp]
(
	[SiteID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ITEMLIMITGRPEXT_GRP]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_ITEMLIMITGRPEXT_GRP] ON [dbo].[ItemLimitGrpExt]
(
	[ItemLimitGrpNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_ITEMLIMITGRPEXT_ITEMNUMBER]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_ITEMLIMITGRPEXT_ITEMNUMBER] ON [dbo].[ItemLimitGrpExt]
(
	[ItemNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_ILGRPLIMIT_CRAFTCODE]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_ILGRPLIMIT_CRAFTCODE] ON [dbo].[ItemLimitGrpLimit]
(
	[CraftCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ILGRPLIMIT_GRP]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_ILGRPLIMIT_GRP] ON [dbo].[ItemLimitGrpLimit]
(
	[ItemLimitGrpNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_CRIBBIN]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_CRIBBIN] ON [dbo].[ItemSerial]
(
	[CribBin] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_ITEMNUMBER]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_ITEMNUMBER] ON [dbo].[ItemSerial]
(
	[ItemNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_LinkedFiles_KeyName]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_LinkedFiles_KeyName] ON [dbo].[LinkedFiles]
(
	[KeyName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [LOGINHIST_IX_EMPLOYEEID]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [LOGINHIST_IX_EMPLOYEEID] ON [dbo].[LoginHistory]
(
	[EmployeeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_LOT_ITEMNUMLOTNUM]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_LOT_ITEMNUMLOTNUM] ON [dbo].[LotNumber]
(
	[LotItemNumber] ASC,
	[LotNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_NAMEDSEARCH_SEARCHNAMES]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_NAMEDSEARCH_SEARCHNAMES] ON [dbo].[NamedSearch]
(
	[SearchName] ASC,
	[ViewPaneClassId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_NAMEDSEARCHFIELD]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_NAMEDSEARCHFIELD] ON [dbo].[NamedSearchField]
(
	[FieldName] ASC,
	[NamedSearchNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_NAMEDSEARCHTBFILTER]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_NAMEDSEARCHTBFILTER] ON [dbo].[NamedSearchTBFilter]
(
	[NamedSearchNo] ASC,
	[ToolbarFilterButtonId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [NetStat]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [NetStat] ON [dbo].[NetStat]
(
	[StationName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [NetStatX]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [NetStatX] ON [dbo].[NetStatX]
(
	[StationNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [CribBin]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [CribBin] ON [dbo].[PendingOrder]
(
	[CribBin] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ItemNumber]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [ItemNumber] ON [dbo].[PendingOrder]
(
	[ItemNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [VendorNumber]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [VendorNumber] ON [dbo].[PendingOrder]
(
	[VendorNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [Date]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [Date] ON [dbo].[PO]
(
	[PODate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [Vendor]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [Vendor] ON [dbo].[PO]
(
	[Vendor] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [VENDORPO]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [VENDORPO] ON [dbo].[PO]
(
	[VendorPO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [CribBin]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [CribBin] ON [dbo].[PODETAIL]
(
	[CribBin] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ITEM]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [ITEM] ON [dbo].[PODETAIL]
(
	[Item] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [PONUMBER]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [PONUMBER] ON [dbo].[PODETAIL]
(
	[PONumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_REPSECURITY_REPORTFUNCTION]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_REPSECURITY_REPORTFUNCTION] ON [dbo].[ReportSecurity]
(
	[ReportId] ASC,
	[FunctionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ReportSite_ReportID]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_ReportSite_ReportID] ON [dbo].[ReportSite]
(
	[ReportId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_ReportSite_SiteID]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_ReportSite_SiteID] ON [dbo].[ReportSite]
(
	[SiteID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_REQUEST_REQASSIGNEDTOID]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_REQUEST_REQASSIGNEDTOID] ON [dbo].[Request]
(
	[ReqAssignedToID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_REQUEST_REQREQUESTORID]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_REQUEST_REQREQUESTORID] ON [dbo].[Request]
(
	[ReqRequestorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_REQUESTDETAIL_REQNO]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_REQUESTDETAIL_REQNO] ON [dbo].[RequestDetail]
(
	[ReqNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_REQREMHISTORY_REQDETNO]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_REQREMHISTORY_REQDETNO] ON [dbo].[RequestRemarkHistory]
(
	[ReqDetNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_REQREMHISTORY_REQNO]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_REQREMHISTORY_REQNO] ON [dbo].[RequestRemarkHistory]
(
	[ReqNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_REQSTATHISTORY_REQDETNO]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_REQSTATHISTORY_REQDETNO] ON [dbo].[RequestStatusHistory]
(
	[ReqDetNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_REQSTATHISTORY_REQNO]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_REQSTATHISTORY_REQNO] ON [dbo].[RequestStatusHistory]
(
	[ReqNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Reservation_ReservationWODefScheduleNo]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_Reservation_ReservationWODefScheduleNo] ON [dbo].[Reservation]
(
	[ReservationWODefScheduleNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ResDetail_IX_CribBin]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [ResDetail_IX_CribBin] ON [dbo].[ReservationDetail]
(
	[ReservationCribBin] ASC,
	[ReservationCrib] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ResDetail_IX_ItemNumber]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [ResDetail_IX_ItemNumber] ON [dbo].[ReservationDetail]
(
	[ReservationItemNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [ResDetail_IX_ResNo]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [ResDetail_IX_ResNo] ON [dbo].[ReservationDetail]
(
	[ReservationNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [RESERVHIST_IX_RESERVATIONNO]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [RESERVHIST_IX_RESERVATIONNO] ON [dbo].[ReservationHistory]
(
	[ReservationNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [RFID_IX_RFID]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [RFID_IX_RFID] ON [dbo].[RFID]
(
	[RFID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_RFIDACTIVITY_RFIDTransNo]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_RFIDACTIVITY_RFIDTransNo] ON [dbo].[RFIDACTIVITY]
(
	[RFIDTransNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_RFIDLASTSEENHISTORY_RFIDNO]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_RFIDLASTSEENHISTORY_RFIDNO] ON [dbo].[RFIDLastSeenHistory]
(
	[RFIDNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [AssetNo]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [AssetNo] ON [dbo].[RunUnitsHistory]
(
	[AssetNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [group_]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [group_] ON [dbo].[SECURITYACCESS]
(
	[category] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [class]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [class] ON [dbo].[SECURITYCLASS]
(
	[class] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_SECGRP_SECURITYGRPNAME]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_SECGRP_SECURITYGRPNAME] ON [dbo].[SecurityGrp]
(
	[SecurityGrpName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_SECURITYGRPACCESS_GRPFUNC]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_SECURITYGRPACCESS_GRPFUNC] ON [dbo].[SecurityGrpAccess]
(
	[SecurityGrpId] ASC,
	[FunctionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [SerialId]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [SerialId] ON [dbo].[SerialStatusHistory]
(
	[SerialId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_SITEINVENTORY_SITEIDITEM]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_SITEINVENTORY_SITEIDITEM] ON [dbo].[SiteInventory]
(
	[SiteID] ASC,
	[ItemNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ItemNumber]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [ItemNumber] ON [dbo].[STATION]
(
	[Item] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [TABLEAUDITFIELD_IX_TABLENAME]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [TABLEAUDITFIELD_IX_TABLENAME] ON [dbo].[TableAuditField]
(
	[TableName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [TABAUDITHIST_IX_TABLENAME]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [TABAUDITHIST_IX_TABLENAME] ON [dbo].[TableAuditHistory]
(
	[TableName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_TaskID]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_TaskID] ON [dbo].[Task]
(
	[TaskID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_TASKITEM]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_TASKITEM] ON [dbo].[TaskItem]
(
	[TaskItemNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_TOOLBARFILTERBUTTON]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_TOOLBARFILTERBUTTON] ON [dbo].[ToolbarFilterButton]
(
	[ToolbarName] ASC,
	[ViewPaneClassId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [TRANSDETAIL_IX_TRANSNO]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [TRANSDETAIL_IX_TRANSNO] ON [dbo].[TRANSDETAIL]
(
	[TransNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_TRANSRECEIPT_TRANSNO]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_TRANSRECEIPT_TRANSNO] ON [dbo].[TransReceipt]
(
	[TransNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ID]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [ID] ON [dbo].[UserItem1]
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ItemNumber]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [ItemNumber] ON [dbo].[UserItem1]
(
	[ItemNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ID]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [ID] ON [dbo].[UserItem2]
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ItemNumber]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [ItemNumber] ON [dbo].[UserItem2]
(
	[ItemNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ID]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [ID] ON [dbo].[UserItem3]
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ItemNumber]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [ItemNumber] ON [dbo].[UserItem3]
(
	[ItemNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ID]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [ID] ON [dbo].[UserItem5]
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ItemNumber]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [ItemNumber] ON [dbo].[UserItem5]
(
	[ItemNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ID]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [ID] ON [dbo].[UserItem6]
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ItemNumber]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [ItemNumber] ON [dbo].[UserItem6]
(
	[ItemNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_UserXRef_FromID]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_UserXRef_FromID] ON [dbo].[UserXRef]
(
	[FromID] ASC,
	[FromIDType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_UserXRef_ToID]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_UserXRef_ToID] ON [dbo].[UserXRef]
(
	[ToID] ASC,
	[ToIDType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_VIEWPANECLASS_VIEWNAME]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_VIEWPANECLASS_VIEWNAME] ON [dbo].[ViewPaneClass]
(
	[ViewName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_WO_AssetNo]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_WO_AssetNo] ON [dbo].[WO]
(
	[AssetNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_WO_WODEFNO]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_WO_WODEFNO] ON [dbo].[WO]
(
	[WODefNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_WO_WOID]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_WO_WOID] ON [dbo].[WO]
(
	[WOID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_WODefID]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_WODefID] ON [dbo].[WODef]
(
	[WODefID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_WODEFSCHED_ASSETNO]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_WODEFSCHED_ASSETNO] ON [dbo].[WODefSchedule]
(
	[AssetNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_WOLABOR_WONO]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_WOLABOR_WONO] ON [dbo].[WOLabor]
(
	[WONo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_WOLOCATIONHISTORY_WONO]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_WOLOCATIONHISTORY_WONO] ON [dbo].[WOLocationHistory]
(
	[WONo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_WOTASK_WONO]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_WOTASK_WONO] ON [dbo].[WOTask]
(
	[WONo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_WOTASKITEM_WOTASK]    Script Date: 4/20/2018 11:41:39 AM ******/
CREATE NONCLUSTERED INDEX [IX_WOTASKITEM_WOTASK] ON [dbo].[WOTaskItem]
(
	[WOTaskNo] ASC,
	[WONo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fpono]  DEFAULT ('') FOR [fpono]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fpartno]  DEFAULT ('') FOR [fpartno]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__frev]  DEFAULT ('') FOR [frev]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fmeasure]  DEFAULT ('') FOR [fmeasure]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fitemno]  DEFAULT ('') FOR [fitemno]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__frelsno]  DEFAULT ('') FOR [frelsno]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fcategory]  DEFAULT ('') FOR [fcategory]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fsokey]  DEFAULT ('') FOR [fsokey]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fsoitm]  DEFAULT ('') FOR [fsoitm]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fsorls]  DEFAULT ('') FOR [fsorls]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fjokey]  DEFAULT ('') FOR [fjokey]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fjoitm]  DEFAULT ('') FOR [fjoitm]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF_btpoitem_fjoopno]  DEFAULT ((0)) FOR [fjoopno]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF_btpoitem_flstcost]  DEFAULT ((0)) FOR [flstcost]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF_btpoitem_fstdcost]  DEFAULT ((0)) FOR [fstdcost]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fleadtime]  DEFAULT ((0)) FOR [fleadtime]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__forgpdate]  DEFAULT ('01/01/1900') FOR [forgpdate]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__flstpdate]  DEFAULT ('01/01/1900') FOR [flstpdate]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fmultirls]  DEFAULT ('') FOR [fmultirls]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF_btpoitem_fnextrels]  DEFAULT ((0)) FOR [fnextrels]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fnqtydm]  DEFAULT ((0)) FOR [fnqtydm]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__freqdate]  DEFAULT ('01/01/1900') FOR [freqdate]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fretqty]  DEFAULT ((0)) FOR [fretqty]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fordqty]  DEFAULT ((0)) FOR [fordqty]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fqtyutol]  DEFAULT ((0)) FOR [fqtyutol]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fqtyltol]  DEFAULT ((0)) FOR [fqtyltol]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fbkordqty]  DEFAULT ((0)) FOR [fbkordqty]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__flstsdate]  DEFAULT ('01/01/1900') FOR [flstsdate]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__frcpdate]  DEFAULT ('01/01/1900') FOR [frcpdate]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__frcpqty]  DEFAULT ((0)) FOR [frcpqty]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fshpqty]  DEFAULT ((0)) FOR [fshpqty]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__finvqty]  DEFAULT ((0)) FOR [finvqty]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fdiscount]  DEFAULT ((0)) FOR [fdiscount]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__frework]  DEFAULT ('') FOR [frework]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fstandard]  DEFAULT ((0)) FOR [fstandard]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__ftax]  DEFAULT ('') FOR [ftax]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fsalestax]  DEFAULT ((0)) FOR [fsalestax]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__finspect]  DEFAULT ('') FOR [finspect]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF_btpoitem_flcost]  DEFAULT ((0)) FOR [flcost]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF_btpoitem_fucost]  DEFAULT ((0)) FOR [fucost]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fprintmemo]  DEFAULT ('') FOR [fprintmemo]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF_btpoitem_fvlstcost]  DEFAULT ((0)) FOR [fvlstcost]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fvleadtime]  DEFAULT ((0)) FOR [fvleadtime]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fvmeasure]  DEFAULT ('') FOR [fvmeasure]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fvpartno]  DEFAULT ('') FOR [fvpartno]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fvptdes]  DEFAULT ('') FOR [fvptdes]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fvordqty]  DEFAULT ((0)) FOR [fvordqty]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fvconvfact]  DEFAULT ((0)) FOR [fvconvfact]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF_btpoitem_fvucost]  DEFAULT ((0)) FOR [fvucost]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fqtyshipr]  DEFAULT ((0)) FOR [fqtyshipr]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fdateship]  DEFAULT ('01/01/1900') FOR [fdateship]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fparentpo]  DEFAULT ('') FOR [fparentpo]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__frmano]  DEFAULT ('') FOR [frmano]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fdebitmemo]  DEFAULT ('') FOR [fdebitmemo]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__finspcode]  DEFAULT ('') FOR [finspcode]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__freceiver]  DEFAULT ('') FOR [freceiver]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF_btpoitem_fnorgucost]  DEFAULT ((0)) FOR [fnorgucost]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fcorgcateg]  DEFAULT ('') FOR [fcorgcateg]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fparentitm]  DEFAULT ('') FOR [fparentitm]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fparentrls]  DEFAULT ('') FOR [fparentrls]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__frecvitm]  DEFAULT ('') FOR [frecvitm]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF_btpoitem_fnorgeurcost]  DEFAULT ((0)) FOR [fnorgeurcost]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF_btpoitem_fnorgtxncost]  DEFAULT ((0)) FOR [fnorgtxncost]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF_btpoitem_fueurocost]  DEFAULT ((0)) FOR [fueurocost]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF_btpoitem_futxncost]  DEFAULT ((0)) FOR [futxncost]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF_btpoitem_fvueurocost]  DEFAULT ((0)) FOR [fvueurocost]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF_btpoitem_fvutxncost]  DEFAULT ((0)) FOR [fvutxncost]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fljrdif]  DEFAULT ((0)) FOR [fljrdif]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF_btpoitem_fucostonly]  DEFAULT ((0)) FOR [fucostonly]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF_btpoitem_futxncston]  DEFAULT ((0)) FOR [futxncston]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF_btpoitem_fueurcston]  DEFAULT ((0)) FOR [fueurcston]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fcomments]  DEFAULT ('') FOR [fcomments]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fdescript]  DEFAULT ('') FOR [fdescript]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__FCBIN]  DEFAULT ('') FOR [FCBIN]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__FCLOC]  DEFAULT ('') FOR [FCLOC]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__Fac]  DEFAULT ('') FOR [Fac]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF__btpoitem__fcudrev]  DEFAULT ('') FOR [fcudrev]
GO
ALTER TABLE [dbo].[btpoitem] ADD  CONSTRAINT [DF_btpoitem_fndbrmod]  DEFAULT ((0)) FOR [fndbrmod]
GO
ALTER TABLE [dbo].[btpoitem] ADD  DEFAULT ((0)) FOR [blanketPO]
GO
ALTER TABLE [dbo].[btpoitem] ADD  DEFAULT ('01/01/1900') FOR [PlaceDate]
GO
ALTER TABLE [dbo].[btpoitem] ADD  DEFAULT ((0)) FOR [DockTime]
GO
ALTER TABLE [dbo].[btpoitem] ADD  DEFAULT ((0)) FOR [PurchBuf]
GO
ALTER TABLE [dbo].[btpoitem] ADD  DEFAULT ((0)) FOR [Final]
GO
ALTER TABLE [dbo].[btpoitem] ADD  DEFAULT ('01/01/1900') FOR [AvailDate]
GO
ALTER TABLE [dbo].[btpoitem] ADD  DEFAULT ('01/01/1900') FOR [SchedDate]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fcompany]  DEFAULT ('') FOR [fcompany]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fcshipto]  DEFAULT ('') FOR [fcshipto]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__forddate]  DEFAULT ('01/01/1900') FOR [forddate]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fpono]  DEFAULT ('') FOR [fpono]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fstatus]  DEFAULT ('') FOR [fstatus]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fvendno]  DEFAULT ('') FOR [fvendno]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fbuyer]  DEFAULT ('') FOR [fbuyer]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fchangeby]  DEFAULT ('') FOR [fchangeby]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fcngdate]  DEFAULT ('01/01/1900') FOR [fcngdate]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fconfirm]  DEFAULT ('') FOR [fconfirm]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fcontact]  DEFAULT ('') FOR [fcontact]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fcfname]  DEFAULT ('') FOR [fcfname]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fcreate]  DEFAULT ('01/01/1900') FOR [fcreate]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__ffob]  DEFAULT ('') FOR [ffob]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fmethod]  DEFAULT ('') FOR [fmethod]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__foldstatus]  DEFAULT ('') FOR [foldstatus]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fordrevdt]  DEFAULT ('01/01/1900') FOR [fordrevdt]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fordtot]  DEFAULT ((0)) FOR [fordtot]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fpayterm]  DEFAULT ('') FOR [fpayterm]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fpaytype]  DEFAULT ('') FOR [fpaytype]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fporev]  DEFAULT ('') FOR [fporev]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fprint]  DEFAULT ('') FOR [fprint]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__freqdate]  DEFAULT ('01/01/1900') FOR [freqdate]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__freqsdt]  DEFAULT ('01/01/1900') FOR [freqsdt]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__freqsno]  DEFAULT ('') FOR [freqsno]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__frevtot]  DEFAULT ((0)) FOR [frevtot]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fsalestax]  DEFAULT ((0)) FOR [fsalestax]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fshipvia]  DEFAULT ('') FOR [fshipvia]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__ftax]  DEFAULT ('') FOR [ftax]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fcsnaddrke]  DEFAULT ('') FOR [fcsnaddrke]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fcsncity]  DEFAULT ('') FOR [fcsncity]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fcsnstate]  DEFAULT ('') FOR [fcsnstate]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fcsnzip]  DEFAULT ('') FOR [fcsnzip]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fcsncountr]  DEFAULT ('') FOR [fcsncountr]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fcsnphone]  DEFAULT ('') FOR [fcsnphone]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fcsnfax]  DEFAULT ('') FOR [fcsnfax]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fcshkey]  DEFAULT ('') FOR [fcshkey]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fcshaddrke]  DEFAULT ('') FOR [fcshaddrke]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fcshcompan]  DEFAULT ('') FOR [fcshcompan]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fcshcity]  DEFAULT ('') FOR [fcshcity]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fcshstate]  DEFAULT ('') FOR [fcshstate]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fcshzip]  DEFAULT ('') FOR [fcshzip]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fcshcountr]  DEFAULT ('') FOR [fcshcountr]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fcshphone]  DEFAULT ('') FOR [fcshphone]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fcshfax]  DEFAULT ('') FOR [fcshfax]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF_btpomast_fnnextitem]  DEFAULT ((0)) FOR [fnnextitem]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fautoclose]  DEFAULT ('') FOR [fautoclose]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fcusrchr1]  DEFAULT ('') FOR [fcusrchr1]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fcusrchr2]  DEFAULT ('') FOR [fcusrchr2]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fcusrchr3]  DEFAULT ('') FOR [fcusrchr3]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF_btpomast_fnusrqty1]  DEFAULT ((0)) FOR [fnusrqty1]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fnusrcur1]  DEFAULT ((0)) FOR [fnusrcur1]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fdusrdate1]  DEFAULT ('01/01/1900') FOR [fdusrdate1]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fccurid]  DEFAULT ('') FOR [fccurid]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF_btpomast_fcfactor]  DEFAULT ((0)) FOR [fcfactor]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fdcurdate]  DEFAULT ('01/01/1900') FOR [fdcurdate]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fdeurodate]  DEFAULT ('01/01/1900') FOR [fdeurodate]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF_btpomast_feurofctr]  DEFAULT ((0)) FOR [feurofctr]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fctype]  DEFAULT ('') FOR [fctype]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fmpaytype]  DEFAULT ('') FOR [fmpaytype]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fmshstreet]  DEFAULT ('') FOR [fmshstreet]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fmsnstreet]  DEFAULT ('') FOR [fmsnstreet]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fmusrmemo1]  DEFAULT ('') FOR [fmusrmemo1]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__fpoclosing]  DEFAULT ('') FOR [fpoclosing]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF__btpomast__freasoncng]  DEFAULT ('') FOR [freasoncng]
GO
ALTER TABLE [dbo].[btpomast] ADD  CONSTRAINT [DF_btpomast_fndbrmod]  DEFAULT ((0)) FOR [fndbrmod]
GO
ALTER TABLE [dbo].[btpomast] ADD  DEFAULT ('1/1/1900') FOR [flpdate]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF__btrcitem__fitemno]  DEFAULT ('') FOR [fitemno]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF__btrcitem__fpartno]  DEFAULT ('') FOR [fpartno]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF__btrcitem__fpartrev]  DEFAULT ('') FOR [fpartrev]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF_btrcitem_finvcost]  DEFAULT ((0)) FOR [finvcost]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF__btrcitem__fcategory]  DEFAULT ('') FOR [fcategory]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF__btrcitem__fcstatus]  DEFAULT ('') FOR [fcstatus]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF__btrcitem__fiqtyinv]  DEFAULT ((0)) FOR [fiqtyinv]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF__btrcitem__fjokey]  DEFAULT ('') FOR [fjokey]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF__btrcitem__fsokey]  DEFAULT ('') FOR [fsokey]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF__btrcitem__fsoitem]  DEFAULT ('') FOR [fsoitem]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF__btrcitem__fsorelsno]  DEFAULT ('') FOR [fsorelsno]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF__btrcitem__fvqtyrecv]  DEFAULT ((0)) FOR [fvqtyrecv]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF__btrcitem__fqtyrecv]  DEFAULT ((0)) FOR [fqtyrecv]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF__btrcitem__freceiver]  DEFAULT ('') FOR [freceiver]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF__btrcitem__frelsno]  DEFAULT ('') FOR [frelsno]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF__btrcitem__fvendno]  DEFAULT ('') FOR [fvendno]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF__btrcitem__fbinno]  DEFAULT ('') FOR [fbinno]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF__btrcitem__fexpdate]  DEFAULT ('01/01/1900') FOR [fexpdate]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF__btrcitem__finspect]  DEFAULT ('') FOR [finspect]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF__btrcitem__finvqty]  DEFAULT ((0)) FOR [finvqty]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF__btrcitem__flocation]  DEFAULT ('') FOR [flocation]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF__btrcitem__flot]  DEFAULT ('') FOR [flot]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF__btrcitem__fmeasure]  DEFAULT ('') FOR [fmeasure]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF__btrcitem__fpoitemno]  DEFAULT ('') FOR [fpoitemno]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF__btrcitem__fretcredit]  DEFAULT ('') FOR [fretcredit]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF__btrcitem__ftype]  DEFAULT ('') FOR [ftype]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF__btrcitem__fumvori]  DEFAULT ('') FOR [fumvori]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF__btrcitem__fqtyinsp]  DEFAULT ((0)) FOR [fqtyinsp]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF__btrcitem__fauthorize]  DEFAULT ('') FOR [fauthorize]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF_btrcitem_fucost]  DEFAULT ((0)) FOR [fucost]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF__btrcitem__fllotreqd]  DEFAULT ((0)) FOR [fllotreqd]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF__btrcitem__flexpreqd]  DEFAULT ((0)) FOR [flexpreqd]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF__btrcitem__fctojoblot]  DEFAULT ('') FOR [fctojoblot]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF__btrcitem__fdiscount]  DEFAULT ((0)) FOR [fdiscount]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF_btrcitem_fueurocost]  DEFAULT ((0)) FOR [fueurocost]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF_btrcitem_futxncost]  DEFAULT ((0)) FOR [futxncost]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF_btrcitem_fucostonly]  DEFAULT ((0)) FOR [fucostonly]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF_btrcitem_futxncston]  DEFAULT ((0)) FOR [futxncston]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF_btrcitem_fueurcston]  DEFAULT ((0)) FOR [fueurcston]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF__btrcitem__flconvovrd]  DEFAULT ((0)) FOR [flconvovrd]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF__btrcitem__fcomments]  DEFAULT ('') FOR [fcomments]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF__btrcitem__fdescript]  DEFAULT ('') FOR [fdescript]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF__btrcitem__fac]  DEFAULT ('') FOR [fac]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF__btrcitem__sfac]  DEFAULT ('') FOR [sfac]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF__btrcitem__FCORIGUM]  DEFAULT ('') FOR [FCORIGUM]
GO
ALTER TABLE [dbo].[btrcitem] ADD  CONSTRAINT [DF__btrcitem__fcudrev]  DEFAULT ('') FOR [fcudrev]
GO
ALTER TABLE [dbo].[btrcitem] ADD  DEFAULT ((0)) FOR [FNORIGQTY]
GO
ALTER TABLE [dbo].[btrcitem] ADD  DEFAULT ('') FOR [Iso]
GO
ALTER TABLE [dbo].[btrcitem] ADD  DEFAULT ((0)) FOR [Ship_Link]
GO
ALTER TABLE [dbo].[btrcitem] ADD  DEFAULT ((0)) FOR [ShsrceLink]
GO
ALTER TABLE [dbo].[btrcitem] ADD  DEFAULT ('') FOR [fCINSTRUCT]
GO
ALTER TABLE [dbo].[btrcmast] ADD  CONSTRAINT [DF__btrcmast__fclandcost]  DEFAULT ('') FOR [fclandcost]
GO
ALTER TABLE [dbo].[btrcmast] ADD  CONSTRAINT [DF__btrcmast__frmano]  DEFAULT ('') FOR [frmano]
GO
ALTER TABLE [dbo].[btrcmast] ADD  CONSTRAINT [DF__btrcmast__fporev]  DEFAULT ('') FOR [fporev]
GO
ALTER TABLE [dbo].[btrcmast] ADD  CONSTRAINT [DF__btrcmast__fcstatus]  DEFAULT ('') FOR [fcstatus]
GO
ALTER TABLE [dbo].[btrcmast] ADD  CONSTRAINT [DF__btrcmast__fdaterecv]  DEFAULT ('01/01/1900') FOR [fdaterecv]
GO
ALTER TABLE [dbo].[btrcmast] ADD  CONSTRAINT [DF__btrcmast__fpono]  DEFAULT ('') FOR [fpono]
GO
ALTER TABLE [dbo].[btrcmast] ADD  CONSTRAINT [DF__btrcmast__freceiver]  DEFAULT ('') FOR [freceiver]
GO
ALTER TABLE [dbo].[btrcmast] ADD  CONSTRAINT [DF__btrcmast__fvendno]  DEFAULT ('') FOR [fvendno]
GO
ALTER TABLE [dbo].[btrcmast] ADD  CONSTRAINT [DF__btrcmast__faccptby]  DEFAULT ('') FOR [faccptby]
GO
ALTER TABLE [dbo].[btrcmast] ADD  CONSTRAINT [DF__btrcmast__fbilllad]  DEFAULT ('') FOR [fbilllad]
GO
ALTER TABLE [dbo].[btrcmast] ADD  CONSTRAINT [DF__btrcmast__fcompany]  DEFAULT ('') FOR [fcompany]
GO
ALTER TABLE [dbo].[btrcmast] ADD  CONSTRAINT [DF__btrcmast__ffrtcarr]  DEFAULT ('') FOR [ffrtcarr]
GO
ALTER TABLE [dbo].[btrcmast] ADD  CONSTRAINT [DF__btrcmast__fpacklist]  DEFAULT ('') FOR [fpacklist]
GO
ALTER TABLE [dbo].[btrcmast] ADD  CONSTRAINT [DF__btrcmast__fretship]  DEFAULT ('') FOR [fretship]
GO
ALTER TABLE [dbo].[btrcmast] ADD  CONSTRAINT [DF__btrcmast__fshipwgt]  DEFAULT ((0)) FOR [fshipwgt]
GO
ALTER TABLE [dbo].[btrcmast] ADD  CONSTRAINT [DF__btrcmast__ftype]  DEFAULT ('') FOR [ftype]
GO
ALTER TABLE [dbo].[btrcmast] ADD  CONSTRAINT [DF__btrcmast__start]  DEFAULT ('01/01/1900') FOR [start]
GO
ALTER TABLE [dbo].[btrcmast] ADD  CONSTRAINT [DF__btrcmast__fprinted]  DEFAULT ((0)) FOR [fprinted]
GO
ALTER TABLE [dbo].[btrcmast] ADD  CONSTRAINT [DF__btrcmast__flothrupd]  DEFAULT ((0)) FOR [flothrupd]
GO
ALTER TABLE [dbo].[btrcmast] ADD  CONSTRAINT [DF__btrcmast__fccurid]  DEFAULT ('') FOR [fccurid]
GO
ALTER TABLE [dbo].[btrcmast] ADD  CONSTRAINT [DF_btrcmast_fcfactor]  DEFAULT ((0)) FOR [fcfactor]
GO
ALTER TABLE [dbo].[btrcmast] ADD  CONSTRAINT [DF__btrcmast__fdcurdate]  DEFAULT ('01/01/1900') FOR [fdcurdate]
GO
ALTER TABLE [dbo].[btrcmast] ADD  CONSTRAINT [DF__btrcmast__fdeurodate]  DEFAULT ('01/01/1900') FOR [fdeurodate]
GO
ALTER TABLE [dbo].[btrcmast] ADD  CONSTRAINT [DF_btrcmast_feurofctr]  DEFAULT ((0)) FOR [feurofctr]
GO
ALTER TABLE [dbo].[btrcmast] ADD  CONSTRAINT [DF__btrcmast__flpremcv]  DEFAULT ((0)) FOR [flpremcv]
GO
ALTER TABLE [dbo].[btrcmast] ADD  CONSTRAINT [DF__btrcmast__DocStatus]  DEFAULT ('STARTED') FOR [docstatus]
GO
ALTER TABLE [dbo].[btrcmast] ADD  DEFAULT ('') FOR [frmacreator]
GO
ALTER TABLE [dbo].[CheckList] ADD  DEFAULT (0) FOR [CheckListProcess]
GO
ALTER TABLE [dbo].[DeviceRouting] ADD  DEFAULT (0) FOR [DeviceInactive]
GO
ALTER TABLE [dbo].[EmployeeCrib] ADD  DEFAULT ((1)) FOR [CribAccessOption]
GO
ALTER TABLE [dbo].[Request] ADD  DEFAULT ((0)) FOR [ReqStatusNo]
GO
ALTER TABLE [dbo].[RFID] ADD  DEFAULT (0) FOR [Status]
GO
ALTER TABLE [dbo].[User2] ADD  DEFAULT (0) FOR [UserInactive]
GO
ALTER TABLE [dbo].[User3] ADD  DEFAULT (0) FOR [UserInactive]
GO
ALTER TABLE [dbo].[User5] ADD  DEFAULT (0) FOR [UserInactive]
GO
ALTER TABLE [dbo].[User6] ADD  DEFAULT (0) FOR [UserInactive]
GO
USE [master]
GO
ALTER DATABASE [Cribmaster] SET  READ_WRITE 
GO
