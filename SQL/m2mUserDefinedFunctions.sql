USE [m2mdata01]
GO
/****** Object:  UserDefinedFunction [dbo].[BeGetItemOnHandQuantity]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
-- ************************************************************************
	--
	-- Author: 		Brent Groves
	-- Date:		03/10/14
	-- Function name:	GetItemOnHandQuantity
	--
	-- Purpose:		Returns the NETTABLE On Hand amount for the  
	--			passed in fac, part, and rev.
	--
	-- Parameters:		@fac - Facility of the item for which we're 
	--			retrieving the on hand amount.
	--
	--			@partno - Part Number of the item for which we're 
	--			retrieving the on hand amount.
	--
	--			@rev - Revision number of the item for which we're 
	--			retrieving the on hand amount.
	--
	-- ************************************************************************
	
	CREATE FUNCTION [dbo].[BeGetItemOnHandQuantity]
	(@fac char(20), @partno char(25), @rev char(3))
	returns numeric (15,5)
	as
	
	begin
	
		declare @returnval as numeric (15,5)
		set @returnval =
		isnull(
		(select sum(inonhd.fonhand)
		from inonhd inner join location inloca
		on inonhd.fac = @fac and inonhd.fpartno = @partno and inonhd.fpartrev = @rev
		AND inloca.fcfacility = @fac and inloca.fcmrpexcl <> 'Y' and inonhd.flocation = inloca.flocation )
		,0.00000)
	
		return @returnval
		
	end

GO
/****** Object:  UserDefinedFunction [dbo].[BeGetPcsReqByDate]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
-- ************************************************************************
	--
	-- Author: 		Brent Groves
	-- Date:		03/10/14
	-- Function name:	GetPcsReqByDate
	--
	-- Purpose:		Returns the parts still needed to make or buy  
	--			to make commitment of a specified date
	--
	-- Parameters:		@fac - Facility of the item for which we're 
	--			retrieving the on hand amount.
	--
	--			@partno - Part Number of the item for which we're 
	--			retrieving the on hand amount.
	--
	--			@rev - Revision number of the item for which we're 
	--			retrieving the on hand amount.
	--
	--			@due - Due date of the order
	-- Notes: 
	-- ************************************************************************
	
	CREATE FUNCTION [dbo].[BeGetPcsReqByDate]
	(@fac char(20), @partno char(25), @rev char(3), @due datetime)
	returns numeric (15,5)
	as
	
	begin
		declare @returnval as numeric (15,5)
		set @returnval =
		isnull(
		(-- We want to know the total parts required by this date which haven't already shipped. No matter what the soitem is.
		select sum(SORels.fOrderQty - (SORels.fShipBook + SORels.fShipBuy + SORels.fShipMake)) AS fnBOQty
		FROM sorels 
		JOIN SoMast 
		ON SOMast.fSONo = SORels.fSONo 
		JOIN SoItem 
		ON SoItem.fSONo = SoRels.fSONo AND SoItem.fInumber = SoRels.fInumber 
		WHERE SOMast.fStatus = 'OPEN' 
		AND fMasterRel = 0 AND SOItem.fShipItem =  1 
		AND fOrderQty > (fShipBook + fShipBuy + fShipMake)  
		AND soitem.fac = @fac
		and soitem.fPartNo = @partno 
		AND soitem.fpartRev = @rev 
		and sorels.fduedate <= @due)
		,0.00000) 	

		return @returnval
		
	end

GO
/****** Object:  UserDefinedFunction [dbo].[bfActiveJobNoToolListCnt]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[bfActiveJobNoToolListCnt](
@startDateParam DATETIME, 
@endDateParam DATETIME 
)
RETURNS int
AS
BEGIN
	Declare @RetVal int
	select  @RetVal =count(*) 
	from
	(
		select jobNumber,lv1.partNumber,fdescript,qty
		from (
			SELECT jobNumber,lv1.partNumber,lv2.fdescript,qty from 
			bfGetPartsProduced(@startDateParam,@endDateParam) lv1
			left outer join
			bvGetPnDescript lv2
			on
			lv1.partNumber = lv2.fpartno
		) lv1
		left outer join
		ActiveToolLists lv2
		on lv1.partNumber = lv2.partNumber
		where lv2.partNumber is null
	) lv3
	RETURN @RetVal
end

GO
/****** Object:  UserDefinedFunction [dbo].[bfActiveJobNoToolListWeek]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[bfActiveJobNoToolListWeek](
)
  RETURNS @ActiveJobNoToolList Table 
    (jobNumber char(10), 
     partNumber char(25), 
     description varchar(40),
	 qty numeric(15,5)
	  )  
AS 
begin
	Declare @startDateParam DATETIME 
	Declare @endDateParam DATETIME 
	set @startDateParam = DateAdd(week, -1, GetDate())
	set @endDateParam = GetDate()
	insert into @ActiveJobNoToolList select * from bfActiveJobNoToolList(@startDateParam,@endDateParam) 
	RETURN 
end

GO
/****** Object:  UserDefinedFunction [dbo].[bfBudgetedVrsActualHiDiffCnt]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--////////////////////////////////////////////////////////
-- bfBudgetedVrsActualHiDiffCnt
-- Consumable toollist items whose cost estimates are more
-- than 100% off.
--////////////////////////////////////////////////////////
create FUNCTION [dbo].[bfBudgetedVrsActualHiDiffCnt]()
RETURNS int
AS
BEGIN
	Declare @BudgetedVrsActualHiDiffCnt int
	Declare @today DATETIME
	Declare @month int
	Declare @year int
	select @today = GETDATE(),
	@month = month(@today),
	@year = year(@today)

	select @BudgetedVrsActualHiDiffCnt= count(*) from  btMonthToolLife
	--838
	where year = @year and month = @month
	--838
	and budgetedVrsActualCost > 200.0 or budgetedVrsActualCost = 0.0
	--112
	RETURN @BudgetedVrsActualHiDiffCnt
END	

GO
/****** Object:  UserDefinedFunction [dbo].[bfConsVrsActualLowCnt]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[bfConsVrsActualLowCnt] 
(
@startDateParam DATETIME,
@endDateParam DATETIME,
@consVrsActualLowCnt integer
) 
RETURNS integer 
AS
BEGIN
	Declare @RetVal int
	select @RetVal=count(*) from  bfWorkSumLv6IJ(@startDateParam,@endDateParam)
	where consumablevrsactualpct <= @consVrsActualLowCnt
	RETURN @RetVal
end

GO
/****** Object:  UserDefinedFunction [dbo].[bfCurrentPO]    Script Date: 4/24/2018 7:56:09 AM ******/
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
	Declare @RetVal as char(6);
	set @RetVal = '123456'
--	select @RetVal=count(*) from  bfWorkSumLv6IJ(@startDateParam,@endDateParam)
--	where consumablevrsactualpct <= @consVrsActualLowCnt
	RETURN @RetVal
end


GO
/****** Object:  UserDefinedFunction [dbo].[bfNoValueAddSalesOrToolAllowanceWeek]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[bfNoValueAddSalesOrToolAllowanceWeek]()
  RETURNS @RetTable Table 
    (jobNumber char(10), 
     partNumber char(25), 
	 partRev char(3),
     description varchar(40),
	 pcsProduced numeric(15,5),
	 valueAddedSales decimal(18,2),
	 budgetedToolAllowance decimal(18,2)
	  )  
AS 
begin
Declare @startDateParam DATETIME 
Declare @endDateParam DATETIME 
set @startDateParam = DateAdd(week, -1, GetDate())
set @endDateParam = GetDate()
insert into @RetTable select * from bfNoValueAddSalesOrToolAllowance (@startDateParam,@endDateParam) 
RETURN
end

GO
/****** Object:  UserDefinedFunction [dbo].[bfNoValueAddSalesWeek]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[bfNoValueAddSalesWeek]()
  RETURNS @RetTable Table 
    (jobNumber char(10), 
     partNumber char(25), 
	 partRev char(3),
     description varchar(40),
	 pcsProduced int,
	 valueAddedSales decimal(18,2)
	  )  
AS 
begin
Declare @startDateParam DATETIME 
Declare @endDateParam DATETIME 
set @startDateParam = DateAdd(week, -1, GetDate())
set @endDateParam = GetDate()

insert into @RetTable select * from bfNoValueAddSales (@startDateParam,@endDateParam) 
RETURN
end

GO
/****** Object:  UserDefinedFunction [dbo].[bfNoVendorCostWeek]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[bfNoVendorCostWeek](
)
  RETURNS @RetTable Table 
    (
	[ItemNumber] [nvarchar](32) NULL,
	[description1] [nvarchar](50) NULL
	  )  
AS 
begin
	Declare @startDateParam DATETIME 
	Declare @endDateParam DATETIME 
	set @startDateParam = DateAdd(week, -1, GetDate())
	set @endDateParam = GetDate()
	insert into @RetTable select * from  bfNoVendorCost(@startDateParam,@endDateParam) bfNoVendorCostWeek order by itemNumber

	RETURN 
end

GO
/****** Object:  UserDefinedFunction [dbo].[bfPnNoLaborToolCost]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--////////////////////////////////////////////////////////
-- bfPnNoLaborToolCost
-- ToolLists with no labor or tooling costs
--////////////////////////////////////////////////////////
create FUNCTION [dbo].[bfPnNoLaborToolCost]()
RETURNS @PnObsTab TABLE
   (
	partNumber varchar(50)
   )
AS
BEGIN
	Declare @startDateParam DATETIME
	Declare @endDateParam DATETIME
	set @startDateParam = DATEADD (year ,-3, GETDATE())
	set @endDateParam = GETDATE()
	INSERT @PnObsTab
		select partNumber
		from
		bfWorkSumLv4NLBTC(@startDateParam,@endDateParam)
	RETURN
END	-- ToolLists with no labor or tooling costs

GO
/****** Object:  UserDefinedFunction [dbo].[DisplayAddress]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[DisplayAddress] 
 (@City nvarchar(50), 
  @State nvarchar(20),
  @PostalCode nvarchar(10), 
  @Country nvarchar(30) = NULL)
RETURNS nvarchar(100)
AS
BEGIN

Declare @ReturnVal As nvarchar(100),
 @AddressOrder as nvarchar(20)

--Make sure the country is not empty.  If it is, then get the default country.
 SELECT @Country = dbo.GetCountryCode(@Country)
/*       If (@Country IS NULL)
    BEGIN
         SELECT @Country = UTCURR.fccountry
                    FROM CSGENL 
                 INNER JOIN UTCURR ON UTCURR.fccurid = CSGENL.fccurid
    END */

--Create the formatting for the input values
 SELECT @Country = RTRIM(LTRIM(@Country))
 SELECT @City = RTRIM(LTRIM(@City))
 SELECT @State = RTRIM(LTRIM(dbo.m2mTransform(@State, dbo.m2mPictState(@Country),2,default)))
 SELECT @PostalCode = RTRIM(LTRIM(dbo.m2mTransform(@PostalCode, dbo.m2mPictZip(@Country),2,default)))

--Get the address order
 SELECT @AddressOrder = RTRIM(LTRIM(dbo.m2mAddrOrder(@Country)))

--Build the order of the city, state, and zip.
 SELECT @ReturnVal = CASE
         
         WHEN @AddressOrder = 'CITY,STATE,ZIP'
            THEN @City + '  ' + @State + ' ' + @PostalCode

         WHEN @AddressOrder = 'ZIP,CITY,STATE'
            THEN @PostalCode + ', ' + @City + '  ' + @State

         WHEN @AddressOrder = 'ZIP,STATE,CITY'
            THEN @PostalCode + ', ' + @State + '  ' + @City

         WHEN @AddressOrder = 'CITY,COUNTY,ZIP'
            THEN
                 CASE 
                         WHEN LEN(RTRIM(LTRIM(@State))) = 0 
                            THEN
                                 --City, Postal Code
                                 @City + ', ' + @PostalCode
                 ELSE
                         --City
                         --County, Postal Code
                         @City + CHAR(13) + @State + ', ' + @PostalCode
                 END
         
         ELSE
                 --No matching choice....use CITY,STATE,ZIP
                 @City + '  ' + @State + ' ' + @PostalCode
 END

Return @ReturnVal

END
GO
/****** Object:  UserDefinedFunction [dbo].[DisplayBlankDims]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[DisplayBlankDims](@UM1 int, @UM2 int, @UM3 int, @UM4 int, @UM5 int) 
RETURNS varchar(255)
AS
BEGIN
 DECLARE @RV varchar(255)

 SET @RV = ''

 IF @UM1 IS NULL
         RETURN @RV

 SET @RV = '______ ' + RTRIM((SELECT fcPopVal FROM CSPopUp WHERE identity_column = @UM1))

 IF @UM2 IS NULL
         RETURN @RV

 SET @RV = @RV + ' x ______ ' + RTRIM((SELECT fcPopVal FROM CSPopUp WHERE identity_column = @UM2))

 IF @UM3 IS NULL
         RETURN @RV

 SET @RV = @RV + ' x ______ ' + RTRIM((SELECT fcPopVal FROM CSPopUp WHERE identity_column = @UM3))

 IF @UM4 IS NULL
         RETURN @RV

 SET @RV = @RV + ' x ______ ' + RTRIM((SELECT fcPopVal FROM CSPopUp WHERE identity_column = @UM4))

 IF @UM5 IS NULL
         RETURN @RV

 SET @RV = @RV + ' x ______ ' + RTRIM((SELECT fcPopVal FROM CSPopUp WHERE identity_column = @UM5))

 RETURN @RV
END
GO
/****** Object:  UserDefinedFunction [dbo].[DisplayCostUnit]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[DisplayCostUnit] 
 (@pAmount Numeric(17,5),
  @pcSubType char(1) = '', 
  @pcCountry nvarchar(30) = NULL, 
  @pcNegNo nvarchar(10) = '', 
  @pcRounding nvarchar(20) = '')
--RETURNS Numeric(17,4)
RETURNS nvarchar(100)
AS
BEGIN

--Declare @ReturnVal As Numeric(17,4)
 DECLARE @RetVal nvarchar(100)
 SELECT @pcCountry = dbo.GetCountryCode(@pcCountry)

/*PARAMETERS pAmount, pcSubType, pcCountry, pcNegNo, pcRounding
 LOCAL loLoc, lcPict, lcOffset, lcReturn
 *** DJW  WL 38844  Limited error checking added for executable.
 IF oSession.lRunExe AND (TYPE("pAmount") <> 'N') AND (TYPE("pAmount") <> 'Y')
         RETURN pAmount
 ENDIF           
 ***
 * Get the correct country object.
 ***
 IF EMPTY(pcCountry)
         loLoc = oDisplay.oNative
 ELSE
         loLoc = oLocales.GetLocale(pcCountry)
 ENDIF
 
 ***
 * Determine which picture to use based
 * on pcSubType.
 ***
 IF TYPE("pcNegNo") <> "C"
         pcNegNo = ""
 ENDIF
 
 IF TYPE("pcRounding") <> "C"
         pcRounding = ""
 ENDIF
 IF TYPE("pcSubType") <> "C"
         pcSubType = ""
 ENDIF
 
 lcPict = loLoc.cPictUnits
 pAmount = ROUND(pAmount, loLoc.nDecPrice) */
 SELECT @pAmount = ROUND(@pAmount, dbo.m2mDecPrice(@pcCountry))
 
 /***
 * Set our separator and other values as specified
 * for the locale.
 ***
*!*              SET SEPARATOR TO loLoc.cSymbolSeparator
*!*              SET POINT TO loLoc.cSymbolPoint
*!*              SET CURRENCY TO loLoc.cSymbolCurrency
*!*              IF loLoc.nSymbolPos = 1
*!*                      SET CURRENCY LEFT
*!*              ELSE
*!*                      SET CURRENCY RIGHT
*!*              ENDIF   
 ***
 * Perform the transformation using the selected picture
 * We use the absolute value, since we'll handle negative
 * number formatting ourselves.
 ***
 lcReturn = ALLTRIM(TRANSFORM(ABS(pAmount), lcPict)) */
 SELECT @RetVal = RTRIM(LTRIM(dbo.m2mTransform(ABS(@pAmount), dbo.m2mPictUnits(@pcCountry),3,default)))
 
 /***
 * Are we dealing with a negative number?  If so,
 * format it appropriately.  Check pcNegNo for
 * P, D, or C first.  If none of those are present,
 * use the locale info's settings.
 ***
 IF pAmount < 0
         DO CASE
                 CASE pcNegNo == ""
                         * Simply do a negative sign
                         lcReturn = "-" + lcReturn
                 CASE pcNegNo == "P"
                         * Surround the number with parentheses
                         lcReturn = "(" + lcReturn + ")"
                 CASE pcNegNo == "D"
                         * DR
                         lcReturn = lcReturn + " DR"
                 CASE pcNegNo == "C"
                         * CR
                         lcReturn = lcReturn + " CR"
                 CASE loLoc.nParensAmount == 2
                         * CR
                         lcReturn = lcReturn + " CR"
                 CASE loLoc.nParensAmount == 3
                         * Surround the number with parentheses
                         lcReturn = "(" + lcReturn + ")"
                 OTHERWISE
                         * Simply do a negative sign
                         lcReturn = "-" + lcReturn
         ENDCASE
 ELSE
         ***
         * Add some spaces to postive numbers to make
         * things line up nicely.
         ***
         DO CASE
                 CASE pcNegNo == "P"
                         lcReturn = lcReturn + " "
                 CASE pcNegNo $ "C,D"
                         lcReturn = lcReturn + "   "
                 CASE loLoc.nParensAmount == 2
                         lcReturn = lcReturn + "   "
                 CASE loLoc.nParensAmount == 3
                         lcReturn = lcReturn + " "
         ENDCASE
 ENDIF*/

 IF @pAmount < 0
         SELECT @RetVal = 
             CASE
                 WHEN @pcNegNo = '' THEN
                         '-' + @RetVal 
                 WHEN @pcNegNo = 'P' THEN
                         '(' + @RetVal + ')' 
                 WHEN @pcNegNo = 'D' THEN
                         @RetVal + ' DR'  
                 WHEN @pcNegNo = 'C' THEN
                         @RetVal + ' CR'  
                 WHEN dbo.m2mParensAmount(@pcCountry) = 3 THEN
                         '(' + @RetVal + ')'
                 ELSE '-' + @RetVal
             END -- CASE
 ELSE
         SELECT @RetVal = 
             CASE
                 WHEN @pcNegNo = 'P' THEN
                         @RetVal + ' ' 
                 WHEN @pcNegNo = 'C' OR @pcNegNo = 'D' THEN
                         @RetVal + '   ' 
                 WHEN dbo.m2mParensAmount(@pcCountry) = 2 THEN
                         @RetVal + '   '
                 WHEN dbo.m2mParensAmount(@pcCountry) = 3 THEN
                         @RetVal + ' '
             END -- CASE

 /****
 * Attach currency sign
 ****
 IF pcSubType="T" .AND. loLoc.nSymbolPos > 1
         IF loLoc.nSymbolPos = 2
                 lcReturn = PADL(loLoc.cSymbolCurrency + ' ' + ALLTRIM(lcReturn),24)
         ELSE
                 lcReturn = PADL(ALLTRIM(lcReturn)+' '+loLoc.cSymbolCurrency,24)
         ENDIF
 ELSE
         lcReturn = PADL(lcReturn, 24)
 ENDIF
 RETURN lcReturn */
 IF @pcSubType = 'T' AND dbo.m2mSymbolPos(@pcCountry) > 1
 BEGIN
         IF dbo.m2mSymbolPos(@pcCountry) = 2
                 BEGIN
                         SELECT @RetVal = RTRIM(LTRIM(dbo.m2mSymbolCurrency(@pcCountry))) + ' ' + RTRIM(LTRIM(@RetVal))
                         IF (24 - LEN(@RetVal)) > 0
                                 SELECT @RetVal = SPACE(24 - LEN(@RetVal)) + @RetVal
                 END
         ELSE
                 BEGIN
                         SELECT @RetVal = RTRIM(LTRIM(@RetVal)) + ' ' + RTRIM(LTRIM(dbo.m2mSymbolCurrency(@pcCountry)))
                         IF (24 - LEN(@RetVal)) > 0
                                 SELECT @RetVal = SPACE(24 - LEN(@RetVal)) + @RetVal
                 END
 END

Return @RetVal

END
GO
/****** Object:  UserDefinedFunction [dbo].[DisplayCurrency]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[DisplayCurrency] 
 (@pAmount Numeric(17,5),
          @pcSubType char(1) = '', 
  @pcCountry nvarchar(30) = NULL, 
  @pcNegNo nvarchar(10) = '', 
  @pcRounding nvarchar(20) = '')
--RETURNS Numeric(17,4)
RETURNS nvarchar(100)
AS
BEGIN

 DECLARE @RetVal nvarchar(100)
 DECLARE @lcPict nvarchar(100) 
 DECLARE @TempRevStr nvarchar(100) 
 DECLARE @TempPos int
 DECLARE @llAtR bit
 DECLARE @PadLen int
 SELECT @pcCountry = dbo.GetCountryCode(@pcCountry)

 DECLARE @lcSeparatorDefault char(1)
 SELECT @lcSeparatorDefault = dbo.m2mSymbolSeparator(@pcCountry)
 DECLARE @lcPointDefault char(1)
 SELECT @lcPointDefault = dbo.m2mSymbolPoint(@pcCountry)


/*FUNCTION DisplayCurrency
PARAMETERS pAmount, pcSubType, pcCountry, pcNegNo, pcRounding

LOCAL loLoc, lcPict, lcOffset, lcreturn

*** DJW  WL 38844  Limited error checking added for executable.
IF oSession.lRunExe AND (TYPE("pAmount") <> 'N') AND (TYPE("pAmount") <> 'Y')
   RETURN pAmount
ENDIF

***
* Get the correct country object.
***
IF EMPTY(pcCountry)
   loLoc = oDisplay.oNative
ELSE
   loLoc = oLocales.GetLocale(pcCountry)
ENDIF

***
* Determine which picture to use based
* on pcSubType.
***
IF TYPE("pcNegNo") <> "C"
   pcNegNo = ""
ENDIF

IF TYPE("pcRounding") <> "C"
   pcRounding = ""
ENDIF

IF TYPE("pcSubType") <> "C"
   pcSubType = ""
ENDIF

** SVV 03/09/98 CR 44916 Changed CASE pcRounding = "" to CASE EMPTY(pcRounding)
IF pcSubType <> "T"
   * Select the appropriate amount picture
   DO CASE
      CASE EMPTY(pcRounding)
         lcPict = loLoc.cPictAmount
         pAmount = ROUND(pAmount, loLoc.nDecCurrency)
      CASE pcRounding = "T"
         lcPict = loLoc.cPictAmountThousands
         pAmount = ROUND(pAmount/1000, 0)
      CASE pcRounding = "M"
         lcPict = loLoc.cPictAmountMillions
         pAmount = ROUND(pAmount/1000000, 0)
      CASE pcRounding = "X"
         lcPict = loLoc.cPictAmount
      CASE pcRounding = "U"
         lcPict = loLoc.cPictAmountUnits
         pAmount = ROUND(pAmount, 0)
      OTHERWISE
         lcPict = loLoc.cPictAmount
         pAmount = ROUND(pAmount, loLoc.nDecCurrency)
   ENDCASE
ELSE
   * Select the appropriate total amount picture
   DO CASE
      CASE EMPTY(pcRounding)
         lcPict = loLoc.cPictAmountTotal
         pAmount = ROUND(pAmount, loLoc.nDecCurrency)
      CASE pcRounding = "T"
         lcPict = loLoc.cPictAmountTotalThousands
         pAmount = ROUND(pAmount/1000, 0)
      CASE pcRounding = "M"
         lcPict = loLoc.cPictAmountTotalMillions
         pAmount = ROUND(pAmount/1000000, 0)
      CASE pcRounding = "X"
         lcPict = loLoc.cPictAmountTotal
      CASE pcRounding = "U"
         lcPict = loLoc.cPictAmountTotalUnits
         pAmount = ROUND(pAmount, 0)
      OTHERWISE
         lcPict = loLoc.cPictAmountTotal
         pAmount = ROUND(pAmount, loLoc.nDecCurrency)
   ENDCASE
ENDIF */
 IF @pcSubType <> 'T'
    BEGIN
         SELECT @pAmount =
                 CASE
                         WHEN @pcRounding = '' THEN
                                 ROUND(@pAmount, dbo.m2mDecCurrency(@pcCountry))
                         WHEN @pcRounding = 'T' THEN
                                 ROUND(@pAmount/1000, 0)
                         WHEN @pcRounding = 'M' THEN
                                 ROUND(@pAmount/1000000, 0)
                         WHEN @pcRounding = 'U' THEN
                                 ROUND(@pAmount, 0)
                         ELSE ROUND(@pAmount, dbo.m2mDecCurrency(@pcCountry))
                 END -- CASE
         SELECT @lcPict =
                 CASE
                         WHEN @pcRounding = '' THEN
                                 dbo.m2mPictAmount(@pcCountry)
                         WHEN @pcRounding = 'T' THEN
                                 dbo.m2mPictAmountThousands(@pcCountry)
                         WHEN @pcRounding = 'M' THEN
                                 dbo.m2mPictAmountMillions(@pcCountry)
                         WHEN @pcRounding = 'X' THEN
                                 dbo.m2mPictAmount(@pcCountry)
                         WHEN @pcRounding = 'U' THEN
                                 dbo.m2mPictAmountUnits(@pcCountry)
                         ELSE dbo.m2mPictAmount(@pcCountry)
                 END -- CASE
    END  
 ELSE
    BEGIN
         SELECT @pAmount =
                 CASE
                         WHEN @pcRounding = '' THEN
                                 ROUND(@pAmount, dbo.m2mDecCurrency(@pcCountry))
                         WHEN @pcRounding = 'T' THEN
                                 ROUND(@pAmount/1000, 0)
                         WHEN @pcRounding = 'M' THEN
                                 ROUND(@pAmount/1000000, 0)
                         WHEN @pcRounding = 'U' THEN
                                 ROUND(@pAmount, 0)
                         ELSE ROUND(@pAmount, dbo.m2mDecCurrency(@pcCountry))
                 END -- CASE
         SELECT @lcPict =
                 CASE
                         WHEN @pcRounding = '' THEN
                                 dbo.m2mPictAmountTotal(@pcCountry)
                         WHEN @pcRounding = 'T' THEN
                                 dbo.m2mPictAmountThousands(@pcCountry)
                         WHEN @pcRounding = 'M' THEN
                                 dbo.m2mPictAmountMillions(@pcCountry)
                         WHEN @pcRounding = 'X' THEN
                                 dbo.m2mPictAmountTotal(@pcCountry)
                         WHEN @pcRounding = 'U' THEN
                                 dbo.m2mPictAmountUnits(@pcCountry)
                         ELSE dbo.m2mPictAmountTotal(@pcCountry)
                 END -- CASE
    END

/***
* Set our separator and other values as specified
* for the locale.
***
*!*              SET SEPARATOR TO loLoc.cSymbolSeparator
*!*              SET POINT TO loLoc.cSymbolPoint
*!*              SET CURRENCY TO loLoc.cSymbolCurrency
*!*              IF loLoc.nSymbolPos = 1
*!*                      SET CURRENCY LEFT
*!*              ELSE
*!*                      SET CURRENCY RIGHT
*!*              ENDIF

***
* Perform the transformation using the selected picture
* We use the absolute value, since we'll handle negative
* number formatting ourselves.
***

*** MKG 2/13/98 IF Decimal separator is a comma and 1000s separator is
*** a period, switch the separators and switch them back after the transform is done.
*** Transform caused overflow problem when converting using a mask of "999.999.999,99"
&&  MKG 7/16/98 -- We have to compare to ',' and '.' even if SET POINT and SET SEPARATOR
&&       are switched.  If we switch them manually as below then we won't end up with 
&&  numbers like ***,***,***.***
*!*      IF loLoc.csymbolpoint = ',' AND loLoc.csymbolseparator = '.'
*!*         lcPict = STRTRAN(lcPict,",",":")
*!*         lcPict = STRTRAN(lcPict,".",",")
*!*         lcPict = STRTRAN(lcPict,":",".")
*!*      ENDIF

***
* DEB CR #067107 - Modified per M2M 3.2:
*        SVV CR 66063: Allow any symbol as decimal or thousand separator, not only . and ,
****


   llAtR = (LEFTC(lcPict,3) = "@R ")

   IF llAtR
      lcPict = SUBSTRC(lcPict,4)
   ENDIF

   IF NOT loLoc.cSymbolPoint $ lcPict && Rounding, no decimals
      lcPict = STRTRAN(lcPict,loLoc.cSymbolSeparator,',')
   ELSE
      lcPict = STRTRAN(LEFTC(lcPict, RATC(loLoc.cSymbolPoint,lcPict) - 1), ;
         loLoc.cSymbolSeparator,',') + '.' + SUBSTRC(lcPict,RATC(loLoc.cSymbolPoint,lcPict) + 1)
   ENDIF

   IF llAtR
      lcPict = "@R " + lcPict
   ENDIF
***
* DEB - END CR #067107
***/
 IF LEFT(@lcPict, 3) = '@R '
         SELECT @llAtR = 1
 IF @llAtR = 1
         SELECT @lcPict = SUBSTRING(@lcPict, 4, LEN(@lcPict) - 3)

 IF CHARINDEX(@lcPointDefault, @lcPict) = 0
         SELECT @lcPict = REPLACE(@lcPict, @lcSeparatorDefault, ',')
 ELSE
   BEGIN
         SELECT @TempRevStr = REVERSE(@lcPict)
         SELECT @TempPos = CHARINDEX(@lcPointDefault, @TempRevStr)
         SELECT @TempPos = (LEN(@lcPict) - @TempPos) + 1
         SELECT @lcPict = REPLACE(LEFT(@lcPict, @TempPos - 1), @lcSeparatorDefault, ',') + '.' +
                                  SUBSTRING(@lcPict, @TempPos + 1, LEN(@lcPict) - @TempPos)
   END
 IF @llAtR = 1
         SELECT @lcPict = '@R ' + @lcPict

/*&& Transform() will convert the display using the appropriate decimal and separator
&& according to SET POINT and SET SEPARATOR -- if the currency we're using doesn't
&& need these settings, then we'll have to change the display manually.
lcreturn = ALLTRIM(TRANSFORM(ABS(pAmount), lcPict))*/

 SELECT @RetVal = RTRIM(LTRIM(dbo.m2mTransform(ABS(@pAmount), @lcPict, 3, default)))

/*IF SET('POINT') <> loLoc.csymbolpoint  OR  SET('SEPARATOR ') <> loLoc.csymbolseparator
*!*              lcreturn = STRTRAN(lcreturn,",",":")
*!*              lcreturn = STRTRAN(lcreturn,".",",")
*!*              lcreturn = STRTRAN(lcreturn,":",".")

***
* DEB - CR #067107 - Modified per M2M 3.2:
***
      ****
      * SVV CR 66063
      ****
      IF SET('POINT') $ lcreturn
         lcreturn = STRTRAN(LEFTC(lcreturn, AT_C(SET('POINT'),lcreturn) - 1), ;
            SET('SEPARATOR'),loLoc.cSymbolSeparator) + loLoc.cSymbolPoint + SUBSTRC(lcreturn,AT_C(SET('POINT'),lcreturn) + 1)
      ELSE       && Rounding, no decimals
         lcreturn = STRTRAN(lcreturn,SET('SEPARATOR'),loLoc.cSymbolSeparator)
      ENDIF

***
* DEB - END CR #067107
***
ENDIF */

 DECLARE @FirstPart nvarchar(30)
 DECLARE @SecondPart nvarchar(30)
 SELECT @TempPos = CHARINDEX('.', @RetVal)
 IF @TempPos = 0
         SELECT @RetVal = REPLACE(@RetVal, ',', @lcSeparatorDefault)
 ELSE
    BEGIN
         SELECT @FirstPart = REPLACE(SUBSTRING(@RetVal, 1, @TempPos - 1), ',', @lcSeparatorDefault)
         SELECT @SecondPart = SUBSTRING(@RetVal, @TempPos + 1, LEN(@RetVal) - @TempPos)
         SELECT @RetVal = @FirstPart + @lcPointDefault + @SecondPart
    END


/***
* Are we dealing with a negative number?  If so,
* format it appropriately.  Check pcNegNo for
* P, D, or C first.  If none of those are present,
* use the locale info's settings.
***
IF pAmount < 0
   DO CASE
      CASE pcNegNo == ""
         * Simply do a negative sign
         lcreturn = "-" + lcreturn

      CASE pcNegNo == "P"
         * Surround the number with parentheses
         lcreturn = "(" + lcreturn + ")"

      CASE pcNegNo == "D"
         * DR
         lcreturn = lcreturn + " DR"

      CASE pcNegNo == "C"
         * CR
         lcreturn = lcreturn + " CR"

      CASE loLoc.nParensAmount == 2
         * CR
         lcreturn = lcreturn + " CR"

      CASE loLoc.nParensAmount == 3
         * Surround the number with parentheses
         lcreturn = "(" + lcreturn + ")"

      OTHERWISE
         * Simply do a negative sign
         lcreturn = "-" + lcreturn
   ENDCASE
ELSE
   ***
   * Add some spaces to postive numbers to make
   * things line up nicely.
   ***
   DO CASE
      CASE pcNegNo == "P"
         lcreturn = lcreturn + " "

      CASE pcNegNo $ "C,D"
         lcreturn = lcreturn + "   "

      CASE loLoc.nParensAmount == 2
         lcreturn = lcreturn + "   "

      CASE loLoc.nParensAmount == 3
         lcreturn = lcreturn + " "
   ENDCASE
ENDIF*/

 IF @pAmount < 0
         SELECT @RetVal = 
             CASE
                 WHEN @pcNegNo = '' THEN
                         '-' + @RetVal 
                 WHEN @pcNegNo = 'P' THEN
                         '(' + @RetVal + ')' 
                 WHEN @pcNegNo = 'D' THEN
                         @RetVal + ' DR'  
                 WHEN @pcNegNo = 'C' THEN
                         @RetVal + ' CR'  
                 WHEN dbo.m2mParensAmount(@pcCountry) = 2 THEN
                         @RetVal + ' CR'
                 WHEN dbo.m2mParensAmount(@pcCountry) = 3 THEN
                         '(' + @RetVal + ')'
                 ELSE '-' + @RetVal
             END -- CASE
 ELSE
         SELECT @RetVal = 
             CASE
                 WHEN @pcNegNo = 'P' THEN
                         @RetVal + ' ' 
                 WHEN @pcNegNo = 'C' OR @pcNegNo = 'D' THEN
                         @RetVal + '   ' 
                 WHEN dbo.m2mParensAmount(@pcCountry) = 2 THEN
                         @RetVal + '   '
                 WHEN dbo.m2mParensAmount(@pcCountry) = 3 THEN
                         @RetVal + ' '
             END -- CASE

/*****
* Attach currency sign
****
lnpadllen = LENC(loLoc.cSymbolCurrency)+LENC(ALLTRIM(lcreturn))+LENC(' ')
&& MKG CR #051685 11/19/98:  Symbol position 2 = before, 3 = after, and 1 = none.
&& Right now position = 1 is not displaying correctly.  Change "loLoc.nSymbolPos >= 1"
&& to "loLoc.nSymbolPos >= 2"
IF pcSubType="T" .AND. loLoc.nSymbolPos >= 2
   IF loLoc.nSymbolPos = 2
      lcreturn = PADL(loLoc.cSymbolCurrency + ' ' + ALLTRIM(lcreturn),lnpadllen)
   ELSE
      lcreturn = PADL(ALLTRIM(lcreturn)+' '+loLoc.cSymbolCurrency,lnpadllen)
   ENDIF
ELSE
   lcreturn = PADL(lcreturn, 24)
ENDIF

RETURN lcreturn */
 SELECT @PadLen = LEN(dbo.m2mSymbolCurrency(@pcCountry)) + LEN(@RetVal) + 1

 IF @pcSubType = 'T' AND dbo.m2mSymbolPos(@pcCountry) >= 2
   BEGIN
         IF dbo.m2mSymbolPos(@pcCountry) = 2
                 BEGIN
                         SELECT @RetVal = RTRIM(LTRIM(dbo.m2mSymbolCurrency(@pcCountry))) + ' ' + RTRIM(LTRIM(@RetVal))
                         IF (@PadLen - LEN(@RetVal)) > 0
                                 SELECT @RetVal = SPACE(@PadLen - LEN(@RetVal)) + @RetVal
                 END
         ELSE
                 BEGIN
                         SELECT @RetVal = RTRIM(LTRIM(@RetVal)) + ' ' + RTRIM(LTRIM(dbo.m2mSymbolCurrency(@pcCountry)))
                         IF (@PadLen - LEN(@RetVal)) > 0
                                 SELECT @RetVal = SPACE(@PadLen - LEN(@RetVal)) + @RetVal
                 END
   END

 Return SPACE(24 - LEN(@RetVal)) + @RetVal

END
GO
/****** Object:  UserDefinedFunction [dbo].[DisplayCurrName]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[DisplayCurrName]
 (@CurrencyID char(3))
RETURNS nvarchar(100)
AS
BEGIN

DECLARE @CurrName AS nvarchar(35)

 SELECT @CurrencyID = dbo.GetCountryCode(@CurrencyID)
 SELECT @CurrName = rtrim(ltrim(utcurr.fcCountry)) + ' ' + rtrim(ltrim(utcurr.fcCurName))
         FROM utcurr
         WHERE utcurr.fccurid = @CurrencyID
 
 RETURN @CurrName
END
GO
/****** Object:  UserDefinedFunction [dbo].[DisplayDate]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[DisplayDate] 
 (@pdDate nvarchar(20), 
  @plShort bit = 1, 
  @pcCountry nvarchar(30) = NULL)
RETURNS nvarchar(100)
AS
BEGIN

 DECLARE @RetVal nvarchar(100)
 DECLARE @TempDatePict nvarchar(100)
 DECLARE @TempDayPart nvarchar(2)

/*
PARAMETERS pdDate, plShort, pcCountry
 LOCAL loLoc, lcReturn, lcSetDate
 ***
 * Were we passed a date?
 ***
 IF TYPE("pdDate") <> "D"
         ***
         * To mimic the old behavior, we'll
         * simply return what we were passed.
         ***
         RETURN pdDate
 ENDIF
 ***
 * Get the correct country object.
 ***
 IF EMPTY(pcCountry)
         loLoc = oDisplay.oNative
 ELSE
         loLoc = oLocales.GetLocale(pcCountry)
 ENDIF
 ***
 * Are we doing short or long dates?
 ***
 IF plShort
         ***
         * Use transform.  Note that we assume that
         * the address format string is one of the
         * appropriate types.
         ***
         lcCurrDateSetting = SET("DATE")
         lcSetDate = "SET DATE TO " + loLoc.cPictDate
         &lcSetDate
         lcReturn = TRANSFORM(pdDate,"@D")
         SET DATE TO (lcCurrDateSetting)
 ELSE
         ***
         * Long dates can't use the transform command,
         * since it won't handle long formats from countries
         * other than the user's defaults.
         * TODO: This won't really work for international.
         * CMONTH and DAY will hopefully translate properly into
         * the user's language, but won't work properly, for
         * example, if a German customer is doing a date for
         * an Italian vendor.
         ***
         DO CASE
                 CASE loLoc.cPictDate $ "AMERICAN,MDY"
                         lcReturn = CMONTH(pdDate) + " " + ;
                                                 PADL(LTRIM(STR(DAY(pdDate))),2,'0') + ;
                                                 ", " + STR(YEAR(pdDate),4)
                 CASE loLoc.cPictDate $ "JAPAN,YMD,ANSI"
                         lcReturn = STR(YEAR(pdDate),4) + " " + ;
                                                 CMONTH(pdDate) + " " + ;
                                                 PADL(LTRIM(STR(DAY(pdDate))),2,'0')
                 OTHERWISE
                         lcReturn = LTRIM(STR(DAY(pdDate))) + " " + ;
                                                 CMONTH(pdDate) + " " + STR(YEAR(pdDate),4)
         ENDCASE
 ENDIF

 RETURN lcReturn
*/
 IF @plShort = 1
         Select @RetVal = dbo.m2mTransform(@pdDate, '@D', 4, dbo.m2mPictDate(@pcCountry))
 ELSE
         BEGIN
                 SELECT @TempDatePict = dbo.m2mPictDate(@pcCountry)
                 SELECT @TempDayPart = LTRIM(STR(DAY(@pdDate)))
                 SELECT @TempDayPart = REPLICATE('0', 2 - LEN(@TempDayPart)) + @TempDayPart 
                 SELECT @RetVal = 
                    CASE
                         WHEN @TempDatePict = 'AMERICAN' OR @TempDatePict = 'MDY' THEN
                                 STR(MONTH(@pdDate)) + ' ' + @TempDayPart + ', ' + STR(YEAR(@pdDate),4)  
                         WHEN @TempDatePict = 'JAPAN' OR @TempDatePict = 'YMD' OR @TempDatePict = 'ANSI' THEN
                                 STR(YEAR(@pdDate),4) + ' ' + STR(MONTH(@pdDate)) + ' ' + @TempDayPart
                         ELSE LTRIM(STR(DAY(@pdDate))) + ' ' + STR(MONTH(@pdDate)) + ' ' + STR(YEAR(@pdDate),4)
                    END -- CASE
         END   

 RETURN @RetVal

END
GO
/****** Object:  UserDefinedFunction [dbo].[DisplayDims]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[DisplayDims](@Dim1 numeric(17,5), @UM1 int, @Dim2 numeric(17,5), @UM2 int, @Dim3 numeric(17,5), @UM3 int, 
 @Dim4 numeric(17,5), @UM4 int, @Dim5 numeric(17,5), @UM5 int, @Decimals int = 2) 
RETURNS varchar(255)
AS
BEGIN
 DECLARE @RV varchar(255)

 SET @RV = ''

 IF @Dim1 IS NULL
         RETURN @RV

 IF @UM1 IS NULL
         RETURN @RV

 SET @RV = LTRIM(STR(ROUND(@Dim1,@Decimals),17,@Decimals)) +  ' ' + RTRIM((SELECT fcPopVal FROM CSPopUp WHERE identity_column = @UM1))

 IF @Dim2 IS NULL
         RETURN @RV

 IF @UM2 IS NULL
         RETURN @RV

 SET @RV = @RV + ' x ' + LTRIM(STR(ROUND(@Dim2,@Decimals),17,@Decimals)) +  ' ' + RTRIM((SELECT fcPopVal FROM CSPopUp WHERE identity_column = @UM2))

 IF @Dim3 IS NULL
         RETURN @RV

 IF @UM3 IS NULL
         RETURN @RV

 SET @RV = @RV + ' x ' + LTRIM(STR(ROUND(@Dim3,@Decimals),17,@Decimals)) +  ' ' + RTRIM((SELECT fcPopVal FROM CSPopUp WHERE identity_column = @UM3))

 IF @Dim4 IS NULL
         RETURN @RV

 IF @UM4 IS NULL
         RETURN @RV

 SET @RV = @RV + ' x ' + LTRIM(STR(ROUND(@Dim4,@Decimals),17,@Decimals)) +  ' ' + RTRIM((SELECT fcPopVal FROM CSPopUp WHERE identity_column = @UM4))

 IF @Dim5 IS NULL
         RETURN @RV

 IF @UM5 IS NULL
         RETURN @RV

 SET @RV = @RV + ' x ' + LTRIM(STR(ROUND(@Dim5,@Decimals),17,@Decimals)) +  ' ' + RTRIM((SELECT fcPopVal FROM CSPopUp WHERE identity_column = @UM5))

 RETURN @RV
END
GO
/****** Object:  UserDefinedFunction [dbo].[DisplayGL]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[DisplayGL] 
 (@pcAccount nvarchar(50) = NULL, 
  @pcCountry nvarchar(30) = NULL)
RETURNS nvarchar(100)
AS
BEGIN

 DECLARE @RetVal nvarchar(100)

/*PARAMETERS pcAccount, pcCountry
 LOCAL loLoc, lcReturn
 *** DJW  WL 38844  Limited error checking added for executable.
 IF oSession.lRunExe AND (TYPE("pcAccount") <> 'C')
         RETURN pcAccount
 ENDIF           
 ***
 * Get the correct country object.
 ***
 IF EMPTY(pcCountry)
         loLoc = oDisplay.oNative
 ELSE
         loLoc = oLocales.GetLocale(pcCountry)
 ENDIF
 lcReturn = IIF(.NOT. EMPTY(pcAccount), TRANSFORM(pcAccount, loLoc.cPictGL), "")
 
 RETURN lcReturn */

 IF @pcAccount IS NOT NULL
         SELECT @RetVal = dbo.m2mTransform(@pcAccount, dbo.m2mPictGL(@pcCountry), 2, default)
 ELSE
         SELECT @RetVal = ''
 RETURN @RetVal

END
GO
/****** Object:  UserDefinedFunction [dbo].[DisplayGLCat]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[DisplayGLCat] 
 (@AcctNo nvarchar(25))
RETURNS nvarchar(40)
AS
BEGIN

Declare @ReturnVal As nvarchar(40)

SELECT @ReturnVal = fcdescr FROM glhead
WHERE fccode IN (SELECT fccode FROM glmast WHERE fcacctnum = rtrim(ltrim(@AcctNo)))

Return @ReturnVal

END
GO
/****** Object:  UserDefinedFunction [dbo].[DisplayInvStatus]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[DisplayInvStatus] 
 (@StatusCode nvarchar(20))
RETURNS nvarchar(20)
AS
BEGIN

Declare @ReturnVal As nvarchar(20)

SELECT @ReturnVal = 
 CASE
 
 WHEN @StatusCode = 'U'
    THEN 'Unpaid'
 
 WHEN @StatusCode = 'P'
    THEN 'Partially Paid'
 
 WHEN @StatusCode = 'N'
    THEN 'New, Not Confirmed'
 
 WHEN @StatusCode = 'F'
    THEN 'Paid in Full'
 
 WHEN @StatusCode = 'H'
    THEN 'Hold For Approval'
 
 WHEN @StatusCode = 'V'
    THEN 'VOID'

 END

Return @ReturnVal

END
GO
/****** Object:  UserDefinedFunction [dbo].[DisplayNum]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[DisplayNum] 
 (@pAmount Numeric(17,5),
          @plTotal bit, 
  @pcCountry nvarchar(30) = NULL, 
  @pcNegNo nvarchar(10) = '')
RETURNS nvarchar(100)
AS
BEGIN

 DECLARE @RetVal As nvarchar(100)
 DECLARE @TempRevStr as nvarchar(30)
 DECLARE @TempPos as int

/*FUNCTION DisplayNum
PARAMETERS       pAmount, ;
                 plTotal, ;
                 pcCountry, ;
                 pcNegNo

 LOCAL loLoc, lcPict, lcreturn

 *** DJW  WL 38844  Limited error checking added for executable.
 IF oSession.lRunExe AND (TYPE('pAmount')<>'N') AND (TYPE('pAmount')<>'Y')
    RETURN pAmount
 ENDIF

 ***
 * Get the correct country object.
 ***
 IF EMPTY(pcCountry)
    loLoc = oDisplay.oNative
 ELSE
    loLoc = oLocales.GetLocale(pcCountry)
 ENDIF*/
 SELECT @pcCountry = dbo.GetCountryCode(@pcCountry)

 /*IF TYPE("pcNegNo") <> "C"
    pcNegNo = ""
 ENDIF
 
 ***
 * Select the picture to use.
 ***
 IF plTotal
    lcPict = loLoc.cPictNumericTotal
 ELSE
    lcPict = loLoc.cPictNumeric
 ENDIF*/

 /*DECLARE @lcPict nvarchar(30)
 IF @plTotal = 1
         SELECT @lcPict = dbo.m2mPictNumericTotal(@pcCountry)
 ELSE
         SELECT @lcPict = dbo.m2mPictNumeric(@pcCountry) */

 /**     Get the thousands separator and decimal separator characters
 lcSeparatorDefault      = loLoc.csymbolseparator
 lcPointDefault          = loLoc.csymbolpoint*/

 DECLARE @lcSeparatorDefault char(1)
 SELECT @lcSeparatorDefault = dbo.m2mSymbolSeparator(@pcCountry)
 DECLARE @lcPointDefault char(1)
 SELECT @lcPointDefault = dbo.m2mSymbolPoint(@pcCountry)

 /**     Define a mask to handle numbers up to 9,999,999,999.99999 (just under 10 billion)
 lcPict = "@R "  + '9' + lcSeparatorDefault + ;
                                 '999' + lcSeparatorDefault + ;
                                 '999' + lcSeparatorDefault + ;
                                 '999' + lcPointDefault + ;
                                 REPLICATE('9',oCompany.fnQtyDec)*/

 DECLARE @lcPict nvarchar(30)
 SELECT @lcPict = '@R 9' + @lcSeparatorDefault + 
                   '999' + @lcSeparatorDefault +
                   '999' + @lcSeparatorDefault +
                   '999' + @lcPointDefault +
                   REPLICATE('9', dbo.m2mDecQuantity(@pcCountry))

 /***
 *       DEB - CR #066320 - Modified per M2M 3.2:
 *                        SVV CR 66158: round the amount prior to displaying
 ***
 pAmount = ROUND(pAmount, OCCURS('9', SUBSTRC(lcPict, RATC(loLoc.cSymbolPoint, lcPict) + 1))) */

 SELECT @TempPos = CHARINDEX(@lcPointDefault, RTRIM(@lcPict))
 IF @TempPos <> 0
         SELECT @pAmount = ROUND(@PAmount, LEN(@lcPict) - @TempPos)
 ELSE
         SELECT @pAmount = ROUND(@PAmount, 0)
 

 /***
 * DEB - End CR #066320
 ***

 &&  MKG 7/16/98 -- We have to compare to ',' and '.' even if SET POINT and SET SEPARATOR
 &&      are switched.  If we switch them manually as below then we won't end up with 
 &&  numbers like ***,***,***.***  or with quantities the quanity of 2 displayed as
 &&  2.000.000.000,000
 *!*     IF loLoc.csymbolpoint = ',' AND loLoc.csymbolseparator = '.'
 *!*        lcPict = STRTRAN(lcPict,",",":")
 *!*        lcPict = STRTRAN(lcPict,".",",")
 *!*        lcPict = STRTRAN(lcPict,":",".")
 *!*     ENDIF

 ***
 * DEB - CR #067107
 ***
 ****
 * SVV CR 66063: allow any decimal or thousand separator, not only . and ,
 ****
 llAtR = (LEFTC(lcPict,3) = "@R ")

 IF llAtR
         lcPict = SUBSTRC(lcPict,4)
 ENDIF */

 DECLARE @llAtR bit
 IF LEFT(@lcPict, 3) = '@R '
         SELECT @llAtR = 1
 IF @llAtR = 1
         SELECT @lcPict = SUBSTRING(@lcPict, 4, LEN(@lcPict) - 3) 

 /*IF NOT loLoc.cSymbolPoint $ lcPict && Rounding, no decimals
         lcPict = STRTRAN(lcPict, loLoc.cSymbolSeparator, ',')
 ELSE
         lcPict = STRTRAN(LEFTC(lcPict, RATC(loLoc.cSymbolPoint,lcPict) - 1), ;
                                  loLoc.cSymbolSeparator, ',') + ;
                          '.' + ;
                          SUBSTRC(lcPict, RATC(loLoc.cSymbolPoint,lcPict) + 1)
 ENDIF */
 IF CHARINDEX(@lcPointDefault, @lcPict) = 0
         SELECT @lcPict = REPLACE(@lcPict, @lcSeparatorDefault, ',')
 ELSE
   BEGIN
         SELECT @TempRevStr = REVERSE(@lcPict)
         SELECT @TempPos = CHARINDEX(@lcPointDefault, @TempRevStr)
         SELECT @TempPos = (LEN(@lcPict) - @TempPos) + 1
         SELECT @lcPict = REPLACE(LEFT(@lcPict, @TempPos - 1), @lcSeparatorDefault, ',') + '.' + 
                                  SUBSTRING(@lcPict, @TempPos + 1, LEN(@lcPict) - @TempPos)
   END
         

 /*IF llAtR
         lcPict = "@R " + lcPict
 ENDIF */

 IF @llAtR = 1
         SELECT @lcPict = '@R ' + @lcPict

 /***
 * DEB - End CR #067107
 ***

 && Transform() will convert the display using the appropriate decimal and separator
 && according to SET POINT and SET SEPARATOR -- if the currency we're using doesn't
 && need these settings, then we'll have to change the display manually.
 lcreturn = ALLTRIM(TRANSFORM(ABS(pAmount), lcPict)) */

 SELECT @RetVal = RTRIM(LTRIM(dbo.m2mTransform(ABS(@pAmount), @lcPict, 1, default)))

 /*IF SET('POINT') <> loLoc.csymbolpoint  OR  SET('SEPARATOR ') <> loLoc.csymbolseparator
 *!*             lcreturn = STRTRAN(lcreturn,",",":")
 *!*             lcreturn = STRTRAN(lcreturn,".",",")
 *!*             lcreturn = STRTRAN(lcreturn,":",".")

 ***
 * DEB - CR #067107 - Modified per M2M 3.2:
 ****
 *       SVV CR 66063
 ****
         IF SET('POINT') $ lcreturn
                 lcreturn = STRTRAN(LEFTC(lcreturn, AT_C(SET('POINT'),lcreturn) - 1), ;
                                                         SET('SEPARATOR'), ;
                                         loLoc.cSymbolSeparator) + ;
                         loLoc.cSymbolPoint + ;
                         SUBSTRC(lcreturn, AT_C(SET('POINT'),lcreturn) + 1)
         ELSE    && Rounding, no decimals
                 lcreturn = STRTRAN(lcreturn, ;
                                                 SET('SEPARATOR'), ;
                                                 loLoc.cSymbolSeparator)
         ENDIF
       
 ***
 * DEB - END CR #067107
 ***
 ENDIF */
 DECLARE @FirstPart nvarchar(30)
 DECLARE @SecondPart nvarchar(30)
 SELECT @TempPos = CHARINDEX('.', @RetVal)
 IF @TempPos = 0
         SELECT @RetVal = REPLACE(@RetVal, ',', @lcSeparatorDefault)
 ELSE
    BEGIN
         SELECT @FirstPart = REPLACE(SUBSTRING(@RetVal, 1, @TempPos - 1), ',', @lcSeparatorDefault)
         SELECT @SecondPart = SUBSTRING(@RetVal, @TempPos + 1, LEN(@RetVal) - @TempPos)
         SELECT @RetVal = @FirstPart + @lcPointDefault + @SecondPart
    END

 /***
 * Are we dealing with a negative number?  If so,
 * format it appropriately.  Check pcNegNo for
 * P, D, or C first.  If none of those are present,
 * use the locale info's settings.
 ***
 IF pAmount < 0
    DO CASE
       CASE pcNegNo == "P"
          * Surround the number with parentheses
          lcreturn = "(" + lcreturn + ")"

       CASE pcNegNo == "D"
          * DR
          lcreturn = lcreturn + " DR"

       CASE pcNegNo == "C"
          * CR
          lcreturn = lcreturn + " CR"

       CASE loLoc.nParensNumber == 2
          * CR
          lcreturn = lcreturn + " CR"

       CASE loLoc.nParensNumber == 3
          * Surround the number with parentheses
          lcreturn = "(" + lcreturn + ")"

       OTHERWISE
          * Simply do a negative sign
          lcreturn = "-" + lcreturn
    ENDCASE
 ENDIF

RETURN lcreturn*/

 IF @pAmount < 0
         SELECT @RetVal = 
             CASE
                 WHEN @pcNegNo = '' THEN
                         '-' + @RetVal 
                 WHEN @pcNegNo = 'P' THEN
                         '(' + @RetVal + ')' 
                 WHEN @pcNegNo = 'D' THEN
                         @RetVal + ' DR'  
                 WHEN @pcNegNo = 'C' THEN
                         @RetVal + ' CR'  
                 WHEN dbo.m2mParensAmount(@pcCountry) = 2 THEN
                         @RetVal + ' CR'
                 WHEN dbo.m2mParensAmount(@pcCountry) = 3 THEN
                         '(' + @RetVal + ')'
                 ELSE '-' + @RetVal
             END -- CASE


 RETURN @RetVal

END
GO
/****** Object:  UserDefinedFunction [dbo].[DisplayPhone]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[DisplayPhone] 
 (@pPhoneNum nvarchar(20), 
  @pcCountry nvarchar(30) = NULL)
RETURNS nvarchar(20)
AS
BEGIN

 DECLARE @RetVal nvarchar(20)
 DECLARE @TempPhonePict nvarchar(20)

/*PARAMETERS pPhoneNum, pcCountry
 LOCAL loLoc, lcReturn
 *** DJW  WL 38844  Limited error checking added for executable.
 IF oSession.lRunExe AND (TYPE('pPhoneNum') <> 'C')
         RETURN pPhoneNum
 ENDIF           
 ***
 * Get the correct country object.
 ***
 IF EMPTY(pcCountry)
         loLoc = oDisplay.oNative
 ELSE
         loLoc = oLocales.GetLocale(pcCountry)
 ENDIF
 lcReturn = IIF(.NOT. EMPTY(loLoc.cPictPhone), ;
                         TRANSFORM(pPhoneNum, loLoc.cPictPhone), ;
                         pPhoneNum)
 RETURN lcReturn */
 SELECT @TempPhonePict = dbo.m2mPictPhone(@pcCountry) 
 IF LTRIM(RTRIM(@TempPhonePict)) = '@R' OR @TempPhonePict IS NULL
         SELECT @RetVal = @pPhoneNum
 ELSE 
         SELECT @RetVal = dbo.m2mTransform(@pPhoneNum, @TempPhonePict, 2, default)

 RETURN @RetVal

END
GO
/****** Object:  UserDefinedFunction [dbo].[DisplayPopUp]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[DisplayPopUp] 
 (@Key nvarchar(20),
  @Value nvarchar(10))
RETURNS nvarchar(80)
AS
BEGIN

Declare @ReturnVal As nvarchar(80)

SELECT @ReturnVal = fcpoptext FROM cspopup
WHERE RTRIM(LTRIM(fcpopkey)) = RTRIM(LTRIM(@Key))
   AND RTRIM(LTRIM(fcpopval)) = RTRIM(LTRIM(@Value))

Return @ReturnVal

END
GO
/****** Object:  UserDefinedFunction [dbo].[DisplaySSN]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[DisplaySSN] 
 (@pSSN nvarchar(20),
  @plValid bit = 0,
  @pcCountry nvarchar(30) = NULL,
  @pcOldMask nvarchar(30) = NULL)
RETURNS nvarchar(25)
AS
BEGIN

 DECLARE @RetVal As nvarchar(25)

/*PARAMETERS pSSN, plValid, pcCountry, pcOldMask
 LOCAL lcSSN, llIsValid, lcErrMsg, lcReturn, loLoc, lcMask
 
 ***
 * If we're not given a string, convert.
 ***
 IF TYPE("pSSN") <> "C"
         IF TYPE("pSSN") $ "N,Y"
                 lcSSN = STR(pSSN)
         ELSE
                 ***
                 * Hmmm...don't know what it is.
                 ***
                 lcSSN = ""
         ENDIF
 ELSE
         lcSSN = pSSN
 ENDIF
 IF TYPE("pcCountry") <> "C" OR EMPTY(pcCountry)
         loLoc = oDisplay.oNative
 ELSE
         loLoc = oLocales.GetLocale(pcCountry)
 ENDIF */

 SELECT @pcCountry = dbo.GetCountryCode(@pcCountry)      

 /***
 * Remove any hyphens...
 ***
 * SVV Abra - Canadian Project, since different countries can
 * have different formats for their IDs, need to remove any mask
 * character, not only hyphen
 ***
 * lcSSN = ALLTRIM(STRTRAN(lcSSN, "-"))
 ***
 IF TYPE("pcOldMask") <> "C" OR EMPTY(pcOldMask)
         pcOldMask = IIF(EMPTY(oUtCurr.fcSSN),"999-99-9999",ALLT(oUtCurr.fcSSN))
 ENDIF
 lcSSN = TakeOffMask(lcSSN,pcOldMask) */

 SELECT @pSSN = RTRIM(LTRIM(@pSSN))
 DECLARE @TempSSNPict nvarchar(30)
 SELECT @TempSSNPict = (SELECT fcssn
                        FROM UTCURR
                        WHERE fccurid = @pcCountry)
 IF @TempSSNPict IS NULL OR RTRIM(LTRIM(@TempSSNPict)) = ''
         BEGIN
                 SELECT @pcOldMask = '999-99-9999'
                 SELECT @TempSSNPict = '999-99-9999'
         END
 ELSE
         SELECT @pcOldMask = RTRIM(LTRIM(@TempSSNPict))
 DECLARE @LenSSN int
 DECLARE @LenMask int
 DECLARE @LenLoop int
 DECLARE @cntr int
 SELECT @LenSSN = LEN(@pSSN)
 SELECT @LenMask = LEN(@pcOldMask)
 IF @LenSSN >= @LenMask
         SELECT @LenLoop = @LenMask
 ELSE
         SELECT @LenLoop = @LenSSN
 DECLARE @MaskChar char(1)
 DECLARE @NoMask nvarchar(20)
 SELECT @NoMask = ''
 SELECT @cntr = 1
 -- This loop to remove the mask assumes the correct mask is being used for what's input.
 WHILE @cntr <= @LenLoop
    BEGIN
         SELECT @MaskChar = UPPER(SUBSTRING(@pcOldMask, @cntr, 1))
         IF @MaskChar IN ('#','!','9','A','X')
                 SELECT @NoMask = @NoMask + SUBSTRING(@pSSN, @cntr, 1)
         SELECT @cntr = @cntr + 1
    END

 /*lcExpr = ALLT(lcExpr)
 lcMask = ALLT(lcMask)
 lnLenc = MIN(LENC(lcExpr),LENC(lcMask))
 lcRet  = ""
 
 FOR lni = 1 TO lnLenc
         lcMaskChar = UPPER(SUBSTRC(lcMask,lni,1))
         IF lcMaskChar $ "#!9AX"
                 lcRet = lcRet + SUBSTRC(lcExpr,lni,1)
         ENDIF
 ENDFOR */

 
 /*IF plValid
         llIsValid = .T.
         **CR 68835 SRZ 7/13/00 Changed the case statement to only check for
         **SSNs that are all 0's or all 9's
         DO CASE
*!*                              CASE lcSSN == "111111111" .OR. lcSSN == "333333333"
*!*                                      llIsValid = .F.
*!*                                      *lcErrMsg = "SSN cannot equal " + lcSSN + "."
*!*                                      lcErrMsg = oMsg.getmsg('SYS_SSN_CANT_EQUAL',lcSSN)
*!*                              CASE LEFTC(lcSSN,3) == "000" .OR. BETWEEN(LEFTC(lcSSN,3), "729", "999")
*!*                                      llIsValid = .F.
*!*                                      *lcErrMsg = "SSN cannot begin with 000 or 729-999."
*!*                                      lcErrMsg = oMsg.getmsg('SYS_SSN_CANT_BEGIN')
                 CASE lcSSN == "000000000" .OR. lcSSN == "999999999"
                         llIsValid = .F.
                         *lcErrMsg = "SSN cannot equal " + lcSSN + "."
                         lcErrMsg = oMsg.getmsg('SYS_SSN_CANT_EQUAL',lcSSN)
                 CASE LENC(lcSSN) <> 9
                         llIsValid = .F.
                         *lcErrMsg = "SSN must be 9 digits in length."
                         lcErrMsg = oMsg.getmsg('SYS_SSN_LONG')
                 CASE VAL(lcSSN) == 0
                         llIsValid = .F.
                         *lcErrMsg = "SSN must contain only digitis 0 - 9."
                         lcErrMsg = oMsg.getmsg('SYS_SSN_CONT')
         ENDCASE
         
         IF .NOT. llIsValid
                 *=oMsg.Stop(lcErrMsg + "  Please enter a valid SSN.", "", "Input Error")
                 =oMsg.Stop('SYS_VALID_SSN',,'SYS_TTL_INPUT_ERR', lcErrMsg)
                 *****
                 * The calling code is expecting this function to return an empty string when the SSN is invalid.
                 * Otherwise the record will get saved with the invalid data and the user would
                 * have to edit the record to correct it.
                 * CR 47960
                 *****
                 RETURN ""
                 * RETURN lcSSN
         ENDIF
 ENDIF

 -- Not doing validation of SSN in the database.
 
 **
 * SVV CR 53380 If country does not have SSN format, use the SSN format of the default country.
 * If SSN format of the default country is blank, use "999-99-9999".
 **
 lcMask   = IIF(EMPTY(loLoc.cpictSSN) OR UPPER(ALLT(loLoc.cpictSSN)) == "@R","@R " + IIF(NOT EMPTY(oUtCurr.fcSSN),oUtCurr.fcSSN,"999-99-9999"),loLoc.cPictSSN)
 lcReturn = TRANSFORM(lcSSN, lcMask)
 
 RETURN lcReturn */
 
 DECLARE @lcMask nvarchar(20)
 DECLARE @SSNPict nvarchar(30)
 SELECT @SSNPict = dbo.m2mPictSSN(@pcCountry)    
 IF @SSNPict = '' OR RTRIM(LTRIM(@SSNPict)) = '@R'
         SELECT @lcMask = '@R ' + @TempSSNPict 
 ELSE
         SELECT @lcMask = @SSNPict
 SELECT @RetVal = dbo.m2mTransform(@NoMask, @lcMask, 2, default) 
 RETURN @RetVal
END
GO
/****** Object:  UserDefinedFunction [dbo].[DisplayState]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[DisplayState] 
 (@pcState nvarchar(30), 
  @pcCountry nvarchar(30) = NULL)
RETURNS nvarchar(30)
AS
BEGIN

 DECLARE @RetVal nvarchar(30)
 DECLARE @TempStatePict nvarchar(30)

/*PARAMETERS pcState, pcCountry
 LOCAL loLoc, lcReturn
 
 lcReturn = ""
 
 IF TYPE("pcState") == "C"
         ***
         * Get the correct country object.
         ***
         IF EMPTY(pcCountry)
                 loLoc = oDisplay.oNative
         ELSE
                 loLoc = oLocales.GetLocale(pcCountry)
         ENDIF
         lcReturn = IIF(.NOT. EMPTY(loLoc.cPictState), ;
                                         TRANSFORM(pcState, loLoc.cPictState), ;
                                         pcState)
 ENDIF
 
 RETURN lcReturn */
 SELECT @TempStatePict = dbo.m2mPictState(@pcCountry) 
 IF LTRIM(RTRIM(@TempStatePict)) = '@R' OR @TempStatePict IS NULL
         SELECT @RetVal = @pcState
 ELSE 
         SELECT @RetVal = dbo.m2mTransform(@pcState, @TempStatePict, 2, default)

 RETURN @RetVal

END
GO
/****** Object:  UserDefinedFunction [dbo].[DisplayTaxID]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[DisplayTaxID] 
 (@pcID nvarchar(20), 
  @plValid bit = 0)
RETURNS nvarchar(20)
AS
BEGIN

 DECLARE @RetVal As nvarchar(20)

/*PARAMETERS pcID, plValid
 LOCAL lcReturn
 *** DJW  WL 38844  Limited error checking added for executable.
 IF oSession.lRunExe AND (TYPE("pcID") <> 'C')
         RETURN pcID
 ENDIF           
 IF plValid
         ***
         * Validate the tax ID, making sure the
         * left two digits are allowable.
         ***
         IF LEFTC(pcID, 2) $ "00,07,08,09,10,17,18,19,20,26,27,28,29,30,40,;
                                                 49,50,60,69,70,78,79,80,89,90"
                 
                 *=oMsg.Stop("Federal tax ID cannot begin with " + LEFTC(pcID, 2) + 
                 *                       ". Please enter a correct value.", "", "Input Error")
                 =oMsg.Stop('SYS_TAX_ID',,'SYS_TTL_INPUT_ERR', LEFTC(pcID, 2))
                 THIS.cResult = pcID
                 RETURN pcID
         ENDIF
 ENDIF
 lcReturn = TRANSFORM(ALLTRIM(STRTRAN(pcID,"-")), "@! 99-99999999")
 
 RETURN lcReturn */
 -- Not doing Tax ID validation on the database
 SELECT @pcID = LTRIM(RTRIM(REPLACE(@pcID,'-','')))
 SELECT @RetVal = dbo.m2mTransform(@pcID, '@!R 99-99999999', 2, default)
 RETURN @RetVal

END
GO
/****** Object:  UserDefinedFunction [dbo].[DisplayVal]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[DisplayVal] 
 (@pcType nvarchar(10), 
  @pvValue sql_variant = NULL,
  @pcOpt1 sql_variant = NULL,
  @pcOpt2 sql_variant = NULL,
  @pcOpt3 sql_variant = NULL)
RETURNS nvarchar(100) -- Return a formatted string up to 100 characters in length.
AS
BEGIN
 --Trim the pcType variable
         SELECT @pcType = UPPER(RTrim(LTrim(@pcType)))   

 --
 -- Some types all start with a common
 -- first char, so we'll get that here.
 --
 DECLARE @FirstChar char
 SELECT @FirstChar = SUBSTRING(@pcType,1,1)

 --
 -- Other functions have a subtype,
 -- such as currency.  The subtype is the second character of the type.
 --
 DECLARE @lcSubType char
 IF LEN(@pcType) > 1
         SELECT @lcSubType = SUBSTRING(@pcType,2,1)
 ELSE
         SELECT @lcSubType = ''

 DECLARE @DisplayValResult nvarchar(100) -- Return value

 --Figure out which DisplayVal UDF to call
 SELECT @DisplayValResult = 
     CASE
         WHEN @pcType = 'A' THEN 
           ------
           -- Parameters:
           -- @pvValue -   City
           -- @pcOpt1  -   State
           -- @pcOpt2  -   Zip Code
           -- @pcOpt3  -   Country
           ------
                 dbo.DisplayAddress(CAST(@pvValue as nvarchar(50)), CAST(@pcOpt1 as nvarchar(20)), CAST(@pcOpt2 as nvarchar(10)), CAST(@pcOpt3 as nvarchar(30)))

                 WHEN @pcType = 'CU' THEN 
           ------
           -- Parameters:
           -- @pvValue -   Currency Amount
           -- @lcSubType - T for thousands, M for Millions, U for units
           -- @pcOpt1  -   Country
           -- @pcOpt2  -   Negative number formatting  "P,D,C" or blank 
           -- @pcOpt3  -   Rounding
           ------
                 dbo.DisplayCostUnit(CAST(@pvValue as numeric(17,5)), @lcSubType, CAST(@pcOpt1 as nvarchar(30)), CAST(@pcOpt2 as nvarchar(10)), CAST(@pcOpt3 as nvarchar(20)))

                 WHEN @pcType = 'CN' THEN 
           ------
           -- Parameters:
           -- @pvValue -   Currency Id
           ------
                 dbo.DisplayCurrName(CAST(@pvValue as char(3)))

         WHEN @pcType = 'C' Or @pcType = 'CT' THEN 
           ------
           -- Parameters:
           -- @pvValue -   Currency Amount
           -- @lcSubType - T for thousands, M for Millions, U for units
           -- @pcOpt1  -   Country
           -- @pcOpt2  -   Negative number formatting  "P,D,C" or blank 
           -- @pcOpt3  -   Rounding
           ------
                 dbo.DisplayCurrency(CAST(@pvValue as numeric(17,5)), @lcSubType, CAST(@pcOpt1 as nvarchar(30)), CAST(@pcOpt2 as nvarchar(10)), CAST(@pcOpt3 as nvarchar(20)))

                 WHEN @pcType = 'D' Or @pcType =  'DS' THEN 
           ------
           -- Parameters:
           -- @pvValue -   Date string
           -- boolean -   .T. for short date format
           -- @pcOpt1  -   Country
           ------
                 dbo.DisplayDate(CAST(@pvValue as nvarchar(20)), 1, CAST(@pcOpt1 as nvarchar(30)))

                 WHEN @pcType = 'GL' THEN 
           ------
           -- Parameters:
           -- @pvValue - Account number
           -- @pcOpt1  - Country
           ------
                 dbo.DisplayGL(CAST(@pvValue as nvarchar(50)), CAST(@pcOpt1 as nvarchar(30)))

                 WHEN @pcType = 'GLCAT' THEN 
           ------
           -- Parameters:
           -- @pvValue -   AccountNumber
           ------
                 dbo.DisplayGLCat(CAST(@pvValue as nvarchar(25)))

                 --WHEN @pcType = 'MONEY' THEN --DisplayMoney not being used by m2m currently.
           ------
           -- Parameters:
           -- @pvValue     -   Amount to display
           ------
                 --dbo.DisplayMoney(CAST(@pvValue as numeric(17,4)))

                 WHEN @pcType = 'F' Or @pcType = 'FV' THEN 
           ------
           -- Parameters:
           -- @pvValue -   A Federal Tax ID
           -- boolean -   .T. to validate ID
           ------
                 dbo.DisplayTaxID(CAST(@pvValue as nvarchar(20)), 0)

                 WHEN @pcType = 'N' Or @pcType = 'NT' THEN 
           ------
           -- Parameters:
           -- @pvValue     -   Unformatted numeric
           -- boolean     -   .T. to display totals.
           -- @pcOpt1      -   Locale to use
           -- @pcOpt2      -   Negative number handling  "P,D,C" or blank 
           ------
                 dbo.DisplayNum(CAST(@pvValue as numeric(17,5)), 1, CAST(@pcOpt1 as nvarchar(30)), CAST(@pcOpt2 as nvarchar(10)))

                 WHEN @pcType = 'P' THEN 
           ------
           -- Parameters:
           -- @pvValue     -   Unformatted phone number
           -- @pcOpt1      -   Locale to use
           ------
                 dbo.DisplayPhone(CAST(@pvValue as nvarchar(20)), CAST(@pcOpt1 as nvarchar(30)))
                                           
                 WHEN @pcType = 'POP' THEN 
           ------
           -- Parameters:
           -- @pvValue     -   CSPopup key
           -- @pcOpt1      -   CSPopup value
           -- @pcOpt2      -   Return length
           ------
                 dbo.DisplayPopUp(CAST(@pvValue as nvarchar(20)), CAST(@pcOpt1 as nvarchar(10)))
                                           
                 WHEN @pcType = 'S' Or @pcType = 'SV' THEN 
           ------
           -- Parameters:
           -- @pvValue -   Unformatted SSN
           -- boolean -   If .T., validate the SSN
           -- @pcOpt1  -   country   optional 
           -- @pcOpt2  -   old mask  optional 
           ------
                 dbo.DisplaySSN(CAST(@pvValue as nvarchar(20)), 0, CAST(@pcOpt1 as nvarchar(30)), CAST(@pcOpt2 as nvarchar(30)))
                 
                                         
                 WHEN @pcType = 'T' THEN 
           ------
           -- Parameters:
           -- @pvValue -   Unformatted State/Province
           -- @pcOpt1  -   Locale to use
           ------
                 dbo.DisplayState(CAST(@pvValue as nvarchar(30)), CAST(@pcOpt1 as nvarchar(30)))
                                           
                 WHEN @pcType = 'Z' THEN 
           ------
           -- Parameters:
           -- @pvValue -   Unformatted postal code
           -- @pcOpt1  -   Locale to use
           ------
                 dbo.DisplayZip(CAST(@pvValue as nvarchar(20)), CAST(@pcOpt1 as nvarchar(25)))
                                         
                 WHEN @pcType = 'INV' THEN 
              ------
              -- CR #064404 JGH 6/22/00
              ------
                 dbo.DisplayInvStatus(CAST(@pvValue as nvarchar(20)))

                 ELSE 'Unknown format'
           ------
           -- Unknown format type.  Return the string 'Unknown format'
           ------         
     END -- Case

 RETURN @DisplayValResult

END
GO
/****** Object:  UserDefinedFunction [dbo].[DisplayZip]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[DisplayZip] 
 (@pcZip nvarchar(20), 
  @pcCountry nvarchar(30) = NULL)
RETURNS nvarchar(20)
AS
BEGIN

 DECLARE @RetVal nvarchar(20)
 DECLARE @TempZipPict nvarchar(20)

/*PARAMETERS pcZip, pcCountry
 LOCAL loLoc, lcReturn
 *** DJW  WL 38844  Limited error checking added for executable.
 IF oSession.lRunExe AND (TYPE('pcZip') <> 'C')
         RETURN pcZip
 ENDIF           
 ***
 * Get the correct country object.
 ***
 IF EMPTY(pcCountry)
         loLoc = oDisplay.oNative
 ELSE
         loLoc = oLocales.GetLocale(pcCountry)
 ENDIF
 lcReturn = IIF(.NOT. EMPTY(loLoc.cPictZip), ;
                         TRANSFORM(pcZip, loLoc.cPictZip), ;
                         pcZip)
 ** SVV 04/21/97 WL38707 If ZIP only has 5 digits, get rid of the dash.          
 lcReturn = IIF(RIGHTC(ALLT(lcReturn),1) = '-',LEFTC(lcReturn,LENC(ALLT(lcReturn))-1),lcReturn)
 RETURN lcReturn */

 SELECT @TempZipPict = dbo.m2mPictZip(@pcCountry) 
 IF LTRIM(RTRIM(@TempZipPict)) = '@R' OR @TempZipPict IS NULL
         SELECT @RetVal = @pcZip
 ELSE 
         SELECT @RetVal = dbo.m2mTransform(@pcZip, @TempZipPict, 2, default)

 IF RIGHT(LTRIM(RTRIM(@RetVal)),1) = '-'
         SELECT @RetVal = LEFT(@RetVal, LEN(LTRIM(RTRIM(@RetVal))) - 1)

 RETURN @RetVal

END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_OrderROI]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_OrderROI] ()
RETURNS @retOrderROI 
         TABLE (RowNumber int IDENTITY (1, 1),  ProjectId int )

AS
BEGIN
     INSERT @retOrderROI(ProjectId)
     SELECT [YEAR]
     FROM dbo.[Plant 2 Production Summary]
RETURN
END




GO
/****** Object:  UserDefinedFunction [dbo].[formatdefault]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[formatdefault]
(@default nvarchar(128), @trimparens bit)
returns nvarchar(4000)
as
begin
	declare @return nvarchar(4000)

	select @return = case
				when charindex('UW_ZeroDefault', isnull(@default, '')) > 0 then '(0)'
				when charindex('UW_StringDefault', isnull(@default, '')) > 0 then '('' '')'
				when charindex('UW_DateDefault', isnull(@default, '')) > 0 then '(''01/01/1900'')'
				when charindex('UW_BinaryDefault', isnull(@default, '')) > 0 then '(0x00)'
				when charindex('UW_GUIDDefault', isnull(@default, '')) > 0 then '00000000-0000-0000-0000-000000000000'
				else isnull(@default, '')
			end

	if @trimparens = 1 set @return = dbo.trimparens(@return)

	return @return
end
GO
/****** Object:  UserDefinedFunction [dbo].[FunctionExists]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[FunctionExists](@FunctionName as sysname)
RETURNS bit
AS
BEGIN
        DECLARE @Exists AS bit

        SET @Exists = (select COUNT(*) from dbo.sysobjects where id = object_id(@FunctionName) and xtype in ('FN', 'IF', 'TF'))

        RETURN @Exists
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetColBoundDefaultName]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[GetColBoundDefaultName](@TableName AS sysname, @ColumnName AS sysname)
RETURNS sysname
AS
BEGIN
        DECLARE @DefaultName sysname

        SET @DefaultName = (SELECT CASE WHEN cnsts.constid IS NULL 
                                THEN SUBSTRING(cols.COLUMN_DEFAULT,16,CHARINDEX(' ',cols.COLUMN_DEFAULT,16) - 16 ) ELSE NULL END AS BoundConstraint
                          FROM INFORMATION_SCHEMA.COLUMNS AS cols
                          LEFT OUTER JOIN sysconstraints AS cnsts ON cols.TABLE_NAME = object_name(cnsts.id) AND cols.COLUMN_NAME = COL_NAME(cnsts.id, cnsts.colid) 
                                AND OBJECTPROPERTY(cnsts.constid, 'IsDefaultCnst') = 1
                          WHERE cols.TABLE_NAME = @TableName AND cols.COLUMN_DEFAULT IS NOT NULL AND cols.COLUMN_NAME = @ColumnName
)

        RETURN @DefaultName
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetColDefaultConstraintName]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[GetColDefaultConstraintName](@TableName AS sysname, @ColumnName AS sysname)
RETURNS sysname
AS
BEGIN
        DECLARE @ConstName sysname

        SET @ConstName = (SELECT OBJECT_NAME(cnsts.constid) AS ConstraintName
                                          FROM INFORMATION_SCHEMA.COLUMNS AS cols
                                          LEFT OUTER JOIN sysconstraints AS cnsts ON cols.TABLE_NAME = object_name(cnsts.id) 
                                                AND cols.COLUMN_NAME = COL_NAME(cnsts.id, cnsts.colid) 
                                                AND OBJECTPROPERTY(cnsts.constid, 'IsDefaultCnst') = 1
                                          WHERE cols.TABLE_NAME = @TableName AND cols.COLUMN_NAME = @ColumnName 
                                                AND cols.COLUMN_DEFAULT IS NOT NULL)

        RETURN @ConstName
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetCountryCode]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[GetCountryCode] 
 (@Country nvarchar(30)) 
RETURNS char(3) 
AS
BEGIN
 IF @Country IS NULL
 BEGIN
         SELECT @Country = (SELECT fccurid
                            FROM CSGENL)
         RETURN @Country
 END
 IF LEN(@Country) > 3 -- Country name instead of country code was entered.
         SELECT @Country = (SELECT fccurid
                            FROM UTCURR
                            WHERE fccountry = @Country)
         IF @Country IS NULL -- Country name doesn't exist.
                 SELECT @Country = (SELECT fccurid
                                    FROM CSGENL)
                 
 RETURN @Country
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetCustBalance]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
-- ************************************************************************
	--
	-- Author: 		Brian Boyd
	-- Date:		06/08/07
	-- Function name:	GetCustBalance
	--
	-- Purpose:		Returns the balance due for the 
	--			passed in customer.
	--
	-- Parameters:		@custno - Number of the customer for whom we're 
	--			retrieving the balance due.
	--	CR 149083 - DJH 12/12/07 - optimized
	-- ************************************************************************
	
	CREATE FUNCTION [dbo].[GetCustBalance]
	(@custno char(6))
	returns money
	as
	
	begin
		declare @returnval as money

		set @returnval = isnull(
			(select sum(lnamount - lyamtapplied - gainloss)
			From (
				Select
					case 
					when csgenl.fmulticurr = 1 and (a.fccurid is not null and a.fccurid <> csgenl.fccurid) or a.fcstatus = 'V' 
					then
						a.ftotprice
					else
						a.fnamount
					end
					as lnamount, 
					case when a.fnamount < 0 then -1 else 1 end * a.fncredits + IsNull(c.amtapplied,0) as lyamtapplied,
					IsNull(c.gainloss,0) gainloss
				From (
					select max(armast.fcstatus) fcstatus, armast.fcinvoice, 
						max(armast.fncredits) fncredits, max(armast.fccurid) fccurid, 
						max(armast.fnamount) fnamount, IsNull(sum(aritem.ftotprice),0) ftotprice
					from armast
					left join aritem on armast.fcinvoice=aritem.fcinvoice
					Where armast.fcustno = @custno and not armast.fcstatus In ('N','V','F')
					Group By armast.fcinvoice) a
					Left Join (
						select i.fcinvoice,
							sum(i.fncashamt + i.fndiscount + i.fnadjamt) as amtapplied, 
							sum(case when a.fccurid <> m.fccurid and not (a.feurofctr <> 0 and m.fccurid = 'EUR')
							then
								i.fngainloss
							else
								0
							end) as gainloss 
						from glcshi i 
						inner join glcshm m on m.fccashnum = i.fccashnum
						inner join armast a on i.fcinvoice=a.fcinvoice
						where i.fcnameid = @custno and m.fcpayclass = 'R' and m.fcstatus <> 'S' 
							and i.fcpayclass = 'R' and i.fctype <> 'C'
						group by i.fcinvoice
						) c on a.fcinvoice=c.fcinvoice, csgenl) d)
				,0)
	
		return @returnval
	end
GO
/****** Object:  UserDefinedFunction [dbo].[GetCustLastPayDate]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
-- ************************************************************************
	--
	-- Author: 		Brian Boyd
	-- Date:		06/08/07
	-- Function name:	GetCustLastPayDate
	--
	-- Purpose:		Returns the last payment date for the 
	--			passed in customer.
	--
	-- Parameters:		@custno - Number of the customer for whom we're 
	--			retrieving the last payment date.
	--
	-- ************************************************************************
	
	CREATE FUNCTION [dbo].[GetCustLastPayDate] 
	(@custno char(6))
	returns datetime
	as
	
	begin
		declare @returnval as datetime
	
		set @returnval =
		isnull(
		(select max(fdpaiddate) 
		from glcshm 
		where fcpayclass = 'R' and fcstatus = 'P' 
		and fcnameid = @custno)
		,'1900-01-01')
		
		return @returnval
	end
GO
/****** Object:  UserDefinedFunction [dbo].[GetCustLastPayment]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
-- ************************************************************************
	--
	-- Author: 		Brian Boyd
	-- Date:		06/08/07
	-- Function name:	GetCustLastPayment
	--
	-- Purpose:		Returns the last payment amount for the 
	--			passed in customer.
	--
	-- Parameters:		@custno - Number of the customer for whom we're 
	--			retrieving the last payment amount.
	--
	-- ************************************************************************
	
	CREATE FUNCTION [dbo].[GetCustLastPayment]
	(@custno char(6))
	returns numeric (17,5)
	as
	
	begin
		declare @returnval as numeric (17,5)
	
		set @returnval =
		isnull(
		(SELECT top 1 fnamount 
			FROM GlcShm 
			WHERE fcPayClass = 'R' AND fcStatus = 'P'
			and fcnameid = @custno
			order by fdpaiddate desc)
		,0.0)
	
		return @returnval
	end
GO
/****** Object:  UserDefinedFunction [dbo].[GetCustMTDSales]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
-- ************************************************************************
	--
	-- Author: 		Brian Boyd
	-- Date:		06/08/07
	-- Function name:	GetCustMTDSales
	--
	-- Purpose:		Returns the MTD sales amount for the 
	--			passed in customer.
	--
	-- Parameters:		@custno - Number of the customer for whom we're 
	--			retrieving the MTD sales amount.
	--
	--			@currentdate - Today's date.
	--
	-- ************************************************************************
	
	CREATE FUNCTION [dbo].[GetCustMTDSales]
	(@custno char(6), @currentdate datetime)
	returns numeric (17,5)
	as
	
	begin
		declare @returnval as numeric (17,5)
	
		set @returnval =
		isnull(
		(SELECT SUM(Sorels.fUnetPrice*(Sorels.fbook+Sorels.fbqty+Sorels.fmqty))
				FROM Somast JOIN Sorels ON Somast.fSono = Sorels.fSono
				WHERE Somast.fStatus IN ('OPEN', 'CLOSED', 'ON HOLD')
				AND Sorels.fMasterRel <> 1 
				and somast.fcustno = @custno
				and year(Somast.fAckDate) = year(@currentdate) 			
				and month(Somast.fAckDate) = month(@currentdate))
		,0.0)
		
		return @returnval
	end
GO
/****** Object:  UserDefinedFunction [dbo].[GetCustOpenCredits]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
-- ************************************************************************
	--
	-- Author: 		Brian Boyd
	-- Date:		06/08/07
	-- Function name:	GetCustOpenCredits
	--
	-- Purpose:		Returns the open credits amount for the 
	--			passed in customer.
	--
	-- Parameters:		@custno - Number of the customer for whom we're 
	--			retrieving the open credits amount.
	--   CR 149083 - DJH 12/12/07 - optimized
	-- ************************************************************************
	
	CREATE FUNCTION [dbo].[GetCustOpenCredits]
	(@custno char(6))
	returns money
	as
	
	begin
		declare @returnval as money
	
		set @returnval = isnull(
			(select sum(lnamount - lyamtapplied - gainloss)*-1
			From (
				Select
					case 
					when csgenl.fmulticurr = 1 and (a.fccurid is not null and a.fccurid <> csgenl.fccurid) or a.fcstatus = 'V' 
					then
						a.ftotprice
					else
						a.fnamount
					end
					as lnamount, 
					case when fnamount < 0 then -1 else 1 end * fncredits + IsNull(c.amtapplied,0) as lyamtapplied,
					IsNull(c.gainloss,0) gainloss
				From (
					select max(armast.fcstatus) fcstatus, armast.fcinvoice, 
						max(armast.fncredits) fncredits, max(armast.fccurid) fccurid, 
						max(armast.fnamount) fnamount, IsNull(sum(aritem.ftotprice),0) ftotprice
					from armast
					left join aritem on armast.fcinvoice=aritem.fcinvoice
					Where armast.fcustno = @custno and not armast.fcstatus In ('N','V','F')
						and armast.finvtype in ('C', 'P')
					Group By armast.fcinvoice) a
					Left Join (
						select i.fcinvoice,
							sum(i.fncashamt + i.fndiscount + i.fnadjamt) as amtapplied, 
							sum(case when a.fccurid <> m.fccurid and not (a.feurofctr <> 0 and m.fccurid = 'EUR')
							then
								i.fngainloss
							else
								0
							end) as gainloss 
						from glcshi i 
						inner join glcshm m on m.fccashnum = i.fccashnum
						inner join armast a on i.fcinvoice=a.fcinvoice
						where i.fcnameid = @custno and m.fcpayclass = 'R' and m.fcstatus <> 'S' 
							and i.fcpayclass = 'R' and i.fctype <> 'C'
						group by i.fcinvoice
						) c on a.fcinvoice=c.fcinvoice, csgenl) d)
				,0)
	
		return @returnval
	end
GO
/****** Object:  UserDefinedFunction [dbo].[GetCustOpenOrders]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
-- ************************************************************************
	--
	-- Author: 		Brian Boyd
	-- Date:		06/08/07
	-- Function name:	GetCustOpenOrders
	--
	-- Purpose:		Returns the open order amount for the 
	--			passed in customer
	--
	-- Parameters:		@custno - Number of the customer for whom we're 
	--			retrieve the open order amount.
	--
	-- ************************************************************************
	CREATE FUNCTION [dbo].[GetCustOpenOrders]
	(@custno char(6))
	returns numeric (17,5)
	as
	
	begin
		declare @returnval as numeric (17,5)
	
		set @returnval =
		isnull(
		(select sum(sorels.forderqty * sorels.funetprice)
			from somast JOIN sorels ON somast.fsono = sorels.fsono
			where  somast.fstatus IN ('Open', 'On Hold') 
			and not Sorels.fmasterrel = 1 
			and somast.fcustno = @custno)
		,0.0)
		
		return @returnval
	end
GO
/****** Object:  UserDefinedFunction [dbo].[GetCustYTDSales]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
-- ************************************************************************
	--
	-- Author: 		Brian Boyd
	-- Date:		06/08/07
	-- Function name:	GetCustYTDSales
	--
	-- Purpose:		Returns the YTD sales amount for the 
	--			passed in customer.
	--
	-- Parameters:		@custno - Number of the customer for whom we're 
	--			retrieving the YTD sales amount.
	--
	--			@currentdate - Today's date.
	--
	-- ************************************************************************
	
	CREATE FUNCTION [dbo].[GetCustYTDSales]
	(@custno char(6), @currentdate datetime)
	returns numeric (17,5)
	as
	
	begin
		declare @returnval as numeric (17,5)
	
		set @returnval =
		isnull(
		(SELECT SUM(Sorels.fUnetPrice*(Sorels.fbook+Sorels.fbqty+Sorels.fmqty))
				FROM Somast JOIN Sorels ON Somast.fSono = Sorels.fSono
				WHERE Somast.fStatus IN ('OPEN', 'CLOSED', 'ON HOLD')
				AND Sorels.fMasterRel <> 1 
				and somast.fcustno = @custno
				and year(Somast.fAckDate) = year(@currentdate))
		,0.0)
		
		return @returnval
	end
GO
/****** Object:  UserDefinedFunction [dbo].[GetIntransitAcct]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE   FUNCTION [dbo].[GetIntransitAcct]
 (	@Facility AS M2MFacility = ' ',
	@SFacility AS M2MFacility = ' ',
	@Part AS CHAR(25) = ' ',
	@Rev AS CHAR(3) = ' ',
	@WIP AS BIT)
RETURNS M2MGLAccount
AS
BEGIN

	DECLARE @lFac AS M2MFacility,
		@LTProdCl AS M2MProductClass,
		@LINTRANSACCT AS M2MGLAccount,
		@PostAtRecv AS BIT

	SET @LTProdCl = ''
	/* Set Intransit account to error account as a default value */
	SELECT @LINTRANSACCT = fcerAcct FROM CSGENL

	/*** Find out what facility is going to have responsibility of the Intransit Account. ***/
	SELECT @PostAtRecv = postatrecv FROM CSPROD
	IF @PostAtRecv = 1
		SET @lFac = @SFacility
	ELSE
		SET @lFac = @Facility
	
	/*** Find Product Class of facility responsible for Intransit Account ***/
	IF EXISTS(SELECT fProdCl FROM INMAST
			WHERE Fac = @lFac
			AND fPartNo = @Part
			AND fRev = @Rev)
	  BEGIN
		SELECT @LTProdCl = fProdCl FROM INMAST
		WHERE Fac = @lFac
		AND fPartNo = @Part
		AND fRev = @Rev
	  END

	IF @LTProdCl = ''
		RETURN @LINTRANSACCT

	/*** Find Intransit Account for this Product class ***/
	IF EXISTS(SELECT fintracc FROM inprod
		WHERE Inprod.fac = @lFac
		AND Inprod.FPC_NUMBER = @LTProdCl)
	  BEGIN
		IF @WIP = 1
			SELECT @LINTRANSACCT = fintracc FROM inprod
			WHERE Inprod.fac = @lFac
			AND Inprod.FPC_NUMBER = @LTProdCl
		ELSE
			SELECT @LINTRANSACCT = FINVTRANS FROM inprod
			WHERE Inprod.fac = @lFac
			AND Inprod.FPC_NUMBER = @LTProdCl
	  END

	RETURN @LINTRANSACCT
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetInvAcct]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE   FUNCTION [dbo].[GetInvAcct]
 (	@FileType AS CHAR(1) = ' ',
	@ProductClass As M2MProductClass,
	@Facility AS M2MFacility = ' ',
	@Part AS CHAR(25) = ' ',
	@Rev AS CHAR(3) = ' ')
RETURNS M2MGLAccount
AS
BEGIN

   DECLARE @InvAcc AS M2MGLAccount

   /* Set Inventory account to error account as a default value */
   SELECT @InvAcc = fcerAcct FROM CSGENL

   IF @FileType = 'I' 
	AND EXISTS(SELECT fProdCl FROM INMAST
			WHERE Fac = @Facility 
			AND fPartNo = @Part
			AND fRev = @Rev)
	
	/** NEED TO GET THE PRODUCT CLASS FROM THE ITEM MASTER FILE **/
	BEGIN

		SELECT @ProductClass = fProdCl FROM INMAST
		WHERE Fac = @Facility 
		AND fPartNo = @Part
		AND fRev = @Rev
	END

   /** GET THE INVENTORY ACCT FROM THE PRODUCT CLASS FILE **/
   IF EXISTS(SELECT fInvAcc FROM InProd
		WHERE fac = @Facility 
		AND fpc_number = @ProductClass)
	BEGIN
	   SELECT @InvAcc = fInvAcc FROM InProd
	   WHERE fac = @Facility 
	   AND fpc_number = @ProductClass
	END
   RETURN @InvAcc
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetItemCommittedQuantity]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
-- ************************************************************************
	--
	-- Author: 		Brian Boyd
	-- Date:		06/08/07
	-- Function name:	GetItemCommittedQuantity
	--
	-- Purpose:		Returns the committed quantity for the 
	--			passed in facility, part, and rev.
	--
	-- Parameters:		@fac - Facility of the item for which we're 
	--			retrieving the commited quantity.
	--
	--			@partno - Part Number of the item for which we're 
	--			retrieving the commited quantity.
	--
	--			@rev - Revision number of the item for which we're 
	--			retrieving the commited quantity.
	--
	-- CR 148628 - DJH 11/9/07 - added @commited_so2 and selects related to it
	-- CR 153438 - DSW 05/27/08 - Removed ref to INMAST and replaced with INMASTX. 
	--                            Removed @commited_so2 and combined logic into 
        --                            first pass calculating @commited. Made other 
	--                            miscellaneous changes to help performance.
	--
	-- ************************************************************************
	
	CREATE FUNCTION [dbo].[GetItemCommittedQuantity]
	(@fac char(20), @partno char(25), @rev char(3))
	returns numeric (15,5)
	as
	
	begin
		declare @returnval as numeric (15,5)
		 
		set @returnval =
		isnull(
			(Select sum(commited)
			From (
				select sum
					(
						Case
							When soitem.fsource = 'S' Then
							   Case
								  WHEN sorels.fshipbook + sorels.fshipbuy + sorels.fshipmake < sorels.forderqty Then
									 sorels.forderqty  - (sorels.fshipbook + sorels.fshipbuy + sorels.fshipmake)
								  ELSE
									 0.00000
							   END
							When soitem.fsource = 'M' Then
								sorels.fstkqty
							Else
								0.00000
						End
					) commited
				 from soitem 
				 inner join somast on somast.fstatus = 'OPEN' and soitem.fac = @fac and soitem.fpartno = @partno and soitem.fpartrev = @rev
					and  soitem.fsource IN ('S', 'M') and  soitem.fsono = somast.fsono 
				 inner join sorels on sorels.fsono = soitem.fsono  and sorels.fmasterrel = 0 and soitem.finumber=sorels.finumber 
				 Union All
				 select sum
					(
						case 
							when jodbom.flextend = 1 then 
								case
									when jomast.fquantity * jodbom.ftotqty - jodbom.fqty_iss > 0 then 
										(jomast.fquantity * jodbom.ftotqty - jodBom.fqty_iss) 
									else
										0.00000 
								end
							else 
								case
									when jodbom.ftotqty - jodbom.fqty_iss > 0 then
										(jodbom.ftotqty - jodbom.fqty_iss)
									else
										0.00000
								end
						end
					) commited
					from jodbom 
					inner join inmastx on jodbom.cfac = @fac and jodbom.fbompart = @partno and jodbom.fbomrev = @rev 
						and jodbom.fbomsource = 'S' and jodbom.fresponse <> 'C' 
						and inmastx.fac = @fac and inmastx.fpartno = @partno and inmastx.frev = @rev
						and inmastx.fbulkissue <> 'Y' 
					inner join jomast on jomast.fjobno = jodbom.fjobno 
					where jomast.fstatus IN ('OPEN', 'RELEASED', 'COMPLETED', 'ON HOLD')
		    ) x)
		,0.00000)
		
		return @returnval
		
	end
GO
/****** Object:  UserDefinedFunction [dbo].[GetItemInProcessQuantity]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
-- ************************************************************************
	--
	-- Author: 		Brian Boyd
	-- Date:		06/08/07
	-- Function name:	GetItemInProcessQuantity
	--
	-- Purpose:		Returns the quantity in process for the 
	--			passed in facility, part, and rev.
	--
	-- Parameters:		@fac - Facility of the item for which we're 
	--			retrieving the in process quantity.
	--
	--			@partno - Part Number of the item for which we're 
	--			retrieving the in process quantity.
	--
	--			@rev - Revision number of the item for which we're 
	--			retrieving the in process quantity.
	--
	-- ************************************************************************
	
	CREATE FUNCTION [dbo].[GetItemInProcessQuantity]
	(@fac char(20), @partno char(25), @rev char(3))
	returns numeric (15,5)
	as
	
	begin
		declare @returnval as numeric (15,5)
		set @returnval =
		isnull(
		(
		 select sum(jomast.fquantity - jodrtg.fnqty_move)
			from jomast 
			inner join jodrtg on jomast.fac = @fac and jomast.fpartno = @partno and jomast.fpartrev = @rev
				and jomast.fjobno = jodrtg.fjobno
			inner join ( select a.fjobno, max(a.foperno) foperno  from jodrtg  a
				 inner join jomast b on 
					 b.fac = @fac and b.fpartno = @partno and b.fpartrev = @rev
					 and a.fjobno=b.fjobno
					 and b.fstatus in ('RELEASED','OPEN','COMPLETED','ON HOLD')
					 and b.fjobno LIKE '%-0000' 
					 and b.ftype = 'I' and b.fitype = '1' 	
					group by a.fjobno
				) c on jomast.fjobno=c.fjobno and jodrtg.foperno=c.foperno
				and jomast.fquantity - jodrtg.fnqty_move >=0
		),0.0)
		
		return @returnval
	end
GO
/****** Object:  UserDefinedFunction [dbo].[GetItemInspectionQuantity]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
-- ************************************************************************
	--
	-- Author: 		Brian Boyd
	-- Date:		06/08/07
	-- Function name:	GetItemInspectionQuantity
	--
	-- Purpose:		Returns the quantity in inspection for the  
	--			passed in fac, part, and rev.
	--
	-- Parameters:		@fac - Facility of the item for which we're 
	--			retrieving the inspection amount.
	--
	--			@partno - Part Number of the item for which we're 
	--			retrieving the inspection amount.
	--
	--			@rev - Revision number of the item for which we're 
	--			retrieving the inspection amount.
	--
	-- ************************************************************************
	
	CREATE FUNCTION [dbo].[GetItemInspectionQuantity]
	(@fac char(20), @partno char(25), @rev char(3))
	returns numeric (15,5)
	as
	
	begin
	
		declare @returnval as numeric (15,5)
		set @returnval =
		isnull(
		(select sum(inonhd.fonhand)
		from inonhd inner join location inloca
		on inonhd.fac = @fac and inonhd.fpartno = @partno and inonhd.fpartrev = @rev
		AND inloca.fcfacility=@fac and inloca.fcInspect ='Y' and inonhd.flocation = inloca.flocation )
		,0.00000)
	
		return @returnval
		
	end
GO
/****** Object:  UserDefinedFunction [dbo].[GetItemLastIssueDate]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ************************************************************************
	--
	-- Author: 		Brian Boyd
	-- Date:		06/08/07
	-- Function name:	GetItemLastIssueDate
	--
	-- Purpose:		Returns the last issue date for the 
	--			passed in fac, part, and rev.
	--
	-- Parameters:		@fac - Facility of the item for which we're 
	--			retrieving the last issue date.
	--
	--			@partno - Part Number of the item for which we're 
	--			retrieving the last issue date.
	--
	--			@rev - Revision number of the item for which we're 
	--			retrieving the last issue date.
	--
	-- ************************************************************************
	
	CREATE FUNCTION [dbo].[GetItemLastIssueDate] 
	(@fac char(20), @partno char(25), @rev char(3))
	returns datetime
	as
	
	begin
		declare @returnval as datetime
	
		set @returnval =
		isnull(
		(SELECT max(fdate) 
	FROM intran 
	--Begin CR-196800 03/05/2012 by meena
	--WHERE ftype in ('I', 'T')
	WHERE ftype in ('I')
	--End CR-196800 03/05/2012 by meena
	and fac = @fac
	and fpartno = @partno
	and fcpartrev = @rev)
		,'1900-01-01')
		
		return @returnval
	end
GO
/****** Object:  UserDefinedFunction [dbo].[GetItemLastReceiptDate]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
-- ************************************************************************
	--
	-- Author: 		Brian Boyd
	-- Date:		06/08/07
	-- Function name:	GetItemLastReceiptDate
	--
	-- Purpose:		Returns the last receipt date for the 
	--			passed in fac, part, and rev.
	--
	-- Parameters:		@fac - Facility of the item for which we're 
	--			retrieving the last receipt date.
	--
	--			@partno - Part Number of the item for which we're 
	--			retrieving the last receipt date.
	--
	--			@rev - Revision number of the item for which we're 
	--			retrieving the last receipt date.
	--
	-- ************************************************************************
	
	CREATE FUNCTION [dbo].[GetItemLastReceiptDate] 
	(@fac char(20), @partno char(25), @rev char(3))
	returns datetime
	as
	
	begin
		declare @returnval as datetime
	
		set @returnval =
		isnull(
		(SELECT max(fdate) 
	FROM intran 
	WHERE ftype in ('M', 'R')
	and fac = @fac
	and fpartno = @partno
	and fcpartrev = @rev)
		,'1900-01-01')
		
		return @returnval
	end
GO
/****** Object:  UserDefinedFunction [dbo].[GetItemMTDIssues]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
-- ************************************************************************
	--
	-- Author: 		Brian Boyd
	-- Date:		06/08/07
	-- Function name:	GetItemMTDIssues
	--
	-- Purpose:		Returns the MTD issue amount for the item defined by 
	--			the passed in fac, partno, and rev.
	--
	-- Parameters:		@fac - Facility of the item for which we're 
	--			retrieving the MTD issue quantity.
	--
	--			@partno - Part Number of the item for which we're 
	--			retrieving the MTD issue quantity.
	--
	--			@rev - Revision number of the item for which we're 
	--			retrieving the MTD issue quantity.
	--
	--			@currentdate - Today's date.
	--
	-- ************************************************************************
	
	CREATE FUNCTION [dbo].[GetItemMTDIssues]
	(@fac char(20), @partno char(25), @rev char(3), @currentdate datetime)
	returns numeric (15,5)
	as
	
	begin
		declare @returnval as numeric (15,5)
	
		set @returnval =
		isnull(
		(select sum(fQty) 
				from intran 
				where ftype = 'I'
				and month(fdate) = month(@currentdate)
				and year(fdate) = year(@currentdate)
				and fac = @fac
				and fpartno = @partno
				and fcpartrev = @rev)
		,0.0) * -1
		
		return @returnval
	end
GO
/****** Object:  UserDefinedFunction [dbo].[GetItemMTDReceipts]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
-- ************************************************************************
	--
	-- Author: 		Brian Boyd
	-- Date:		06/08/07
	-- Function name:	GetItemMTDReceipts
	--
	-- Purpose:		Returns the MTD receipt amount for the item defined by 
	--			the passed in fac, partno, and rev.
	--
	-- Parameters:		@fac - Facility of the item for which we're 
	--			retrieving the MTD receipt amount.
	--
	--			@partno - Part Number of the item for which we're 
	--			retrieving the MTD receipt amount.
	--
	--			@rev - Revision number of the item for which we're 
	--			retrieving the MTD receipt amount.
	--
	--			@currentdate - Today's date.
	--
	-- ************************************************************************
	
	CREATE FUNCTION [dbo].[GetItemMTDReceipts]
	(@fac char(20), @partno char(25), @rev char(3), @currentdate datetime)
	returns numeric (15,5)
	as
	
	begin
		declare @returnval as numeric (15,5)
	
	-- 	where intran.fdate >= " + IntlSqlCharDate(ldStartNextMonth)
	
		set @returnval =
		isnull(
		(select sum(fQty) 
				from intran 
				where ftype in ('R', 'M')
				and month(fdate) = month(@currentdate)
				and year(fdate) = year(@currentdate)
				and fac = @fac
				and fpartno = @partno
				and fcpartrev = @rev)
		,0.0)
		
		return @returnval
	end
GO
/****** Object:  UserDefinedFunction [dbo].[GetItemNonNetQuantity]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
-- ************************************************************************
	--
	-- Author: 		Brian Boyd
	-- Date:		06/08/07
	-- Function name:	GetItemNonNetQuantity
	--
	-- Purpose:		Returns the non nettable quantity for the  
	--			passed in fac, part, and rev.
	--
	-- Parameters:		@fac - Facility of the item for which we're 
	--			retrieving the non net quantity.
	--
	--			@partno - Part Number of the item for which we're 
	--			retrieving the non net quantity.
	--
	--			@rev - Revision number of the item for which we're 
	--			retrieving the non net quantity.
	--
	-- ************************************************************************
	
	CREATE FUNCTION [dbo].[GetItemNonNetQuantity]
	(@fac char(20), @partno char(25), @rev char(3))
	returns numeric (15,5)
	as
	
	begin
	
		declare @returnval as numeric (15,5)
		set @returnval =
		isnull(
		(select sum(inonhd.fonhand)
		from inonhd inner join location inloca
		on inonhd.fac = @fac and inonhd.fpartno = @partno and inonhd.fpartrev = @rev
		AND inloca.fcfacility = @fac and inloca.fcmrpexcl = 'Y' and inonhd.flocation = inloca.flocation )
		,0.00000)
	
		return @returnval
		
	end
GO
/****** Object:  UserDefinedFunction [dbo].[GetItemOnHandQuantity]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
-- ************************************************************************
	--
	-- Author: 		Brian Boyd
	-- Date:		06/08/07
	-- Function name:	GetItemOnHandQuantity
	--
	-- Purpose:		Returns the On Hand amount for the  
	--			passed in fac, part, and rev.
	--
	-- Parameters:		@fac - Facility of the item for which we're 
	--			retrieving the on hand amount.
	--
	--			@partno - Part Number of the item for which we're 
	--			retrieving the on hand amount.
	--
	--			@rev - Revision number of the item for which we're 
	--			retrieving the on hand amount.
	--
	-- ************************************************************************
	
	CREATE FUNCTION [dbo].[GetItemOnHandQuantity]
	(@fac char(20), @partno char(25), @rev char(3))
	returns numeric (15,5)
	as
	
	begin
	
		declare @returnval as numeric (15,5)
		set @returnval =
		isnull(
		(select sum(inonhd.fonhand)
		from inonhd inner join location inloca
		on inonhd.fac = @fac and inonhd.fpartno = @partno and inonhd.fpartrev = @rev
		AND inloca.fcfacility = @fac and inloca.fcInspect <> 'Y' and inonhd.flocation = inloca.flocation )
		,0.00000)
	
		return @returnval
		
	end
GO
/****** Object:  UserDefinedFunction [dbo].[GetItemOnOrderQuantity]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
-- ************************************************************************
	--
	-- Author: 		Brian Boyd
	-- Date:		06/08/07
	-- Function name:	GetItemOnOrderQuantity
	--
	-- Purpose:		Returns the quantity on order for the 
	--			passed in facility, part, and rev.
	--
	-- Parameters:		@fac - Facility of the item for which we're 
	--			retrieving the on order quantity.
	--
	--			@partno - Part Number of the item for which we're 
	--			retrieving the on order quantity.
	--
	--			@rev - Revision number of the item for which we're 
	--			retrieving the on order quantity.
	--
	-- ************************************************************************
	
	CREATE FUNCTION [dbo].[GetItemOnOrderQuantity]
        (@fac char(20), @partno char(25), @rev char(3))  
        returns numeric (15,5)  
        as  
   
        begin  
   
        declare @returnval as numeric (15,5)  
        Set @returnval = IsNull((Select sum(poitem.fordqty - poitem.frcpqty)  
            from poitem inner join pomast  
            on poitem.fac = @fac and poitem.fpartno = @partno and poitem.frev = @rev
	      and poitem.fcategory = 'INV'
	      and pomast.fstatus = 'OPEN' and poitem.fpono = pomast.fpono 
            where poitem.fordqty  > poitem.frcpqty   
              and (poitem.fmultirls <> 'Y' or (poitem.fmultirls = 'Y' and poitem.frelsno <> '  0'))),0.0)
	    
        return @returnval  
        end
GO
/****** Object:  UserDefinedFunction [dbo].[GetItemYTDIssues]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
-- ************************************************************************
	--
	-- Author: 		Brian Boyd
	-- Date:		06/08/07
	-- Function name:	GetItemYTDIssues
	--
	-- Purpose:		Returns the YTD issue amount for the item defined by 
	--			the passed in fac, partno, and rev.
	--
	-- Parameters:		@fac - Facility of the item for which we're 
	--			retrieving the YTD issue amount.
	--
	--			@partno - Part Number of the item for which we're 
	--			retrieving the YTD issue amount.
	--
	--			@rev - Revision number of the item for which we're 
	--			retrieving the YTD issue amount.
	--
	--			@currentdate - Today's date.
	--
	-- ************************************************************************
	
	CREATE FUNCTION [dbo].[GetItemYTDIssues]
	(@fac char(20), @partno char(25), @rev char(3), @currentdate datetime)
	returns numeric (15,5)
	as
	
	begin
		declare @returnval as numeric (15,5)
	
		set @returnval =
		isnull(
		(select sum(fQty) 
				from intran 
				where ftype = 'I'
				and year(fdate) = year(@currentdate)
				and fac = @fac
				and fpartno = @partno
				and fcpartrev = @rev)
		,0.0) * -1
		
		return @returnval
	end
GO
/****** Object:  UserDefinedFunction [dbo].[GetItemYTDReceipts]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
-- ************************************************************************
	--
	-- Author: 		Brian Boyd
	-- Date:		06/08/07
	-- Function name:	GetItemYTDReceipts
	--
	-- Purpose:		Returns the YTD receipt amount for the item defined by 
	--			the passed in fac, partno, and rev.
	--
	-- Parameters:		@fac - Facility of the item for which we're 
	--			retrieving the YTD receipt amount.
	--
	--			@partno - Part Number of the item for which we're 
	--			retrieving the YTD receipt amount.
	--
	--			@rev - Revision number of the item for which we're 
	--			retrieving the YTD receipt amount.
	--
	--			@currentdate - Today's date.
	--
	-- ************************************************************************
	
	CREATE FUNCTION [dbo].[GetItemYTDReceipts]
	(@fac char(20), @partno char(25), @rev char(3), @currentdate datetime)
	returns numeric (15,5)
	as
	
	begin
		declare @returnval as numeric (15,5)
	
		set @returnval =
		isnull(
		(select sum(fQty) 
				from intran 
				where ftype in ('R', 'M')
				and year(fdate) = year(@currentdate)
				and fac = @fac
				and fpartno = @partno
				and fcpartrev = @rev)
		,0.0)
		
		return @returnval
	end
GO
/****** Object:  UserDefinedFunction [dbo].[GetJobProdClass]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[GetJobProdClass]
	(@Jobno AS M2MDocNumberJobOrder)
RETURNS varchar(50)
AS
BEGIN

   DECLARE	@IType AS CHAR(1),
		@GlAcct AS M2MGLAccount,
		@Fac AS M2MFacility,
		@PRODCL AS M2MProductClass,
		@Return AS varchar(50),
		@ItemsFound AS INTEGER

   SELECT 	@IType = fIType,
		@GlAcct = fGlAcct,
		@Fac = Fac,
		@PRODCL = FPRODCL
   FROM JOMast WHERE fJobNo = @Jobno

   IF @IType = '2'
	BEGIN
	  /** Internal job for internal use, acct number is in the job **/
	  SET @Return = 'GL-' + @GlAcct
	END
   ELSE
	BEGIN
	  SELECT @ItemsFound = COUNT(*) FROM INProd
	  WHERE Inprod.Fac = @Fac AND fpc_Number = @PRODCL

	  IF @ItemsFound > 0
	    BEGIN	
		/** Job Product Class found in INPROD table **/
		SET @Return = @PRODCL
	    END
	  ELSE
	    BEGIN
		/** Return Error Account if product class not found in INPROD table **/
		SELECT @Return = 'GL-' + fcerAcct FROM CSGENL		
	    END
        END

   RETURN @Return
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetOperExtQty]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
-- BEB - CRs 105512 and 105515 - 05/08/03
-- Added the @ItemNum parameter.
-- Sandip Kumar - CR 151599 Added parameter @BomInum 
-- CR 159664 By Abhishek on 23-Dec-08, Replaced the REAL type with DECIMAL(20,6)


CREATE  FUNCTION [dbo].[GetOperExtQty] 
 (@PartNo char(25), 
  @Rev char(3),
  @Fac char(20),
  @ItemNum char(3),
  @SONo char(6),
  @OperNo int,
  @JOMastQty DECIMAL(20,6),
  @OrigQty DECIMAL(20,6),
  @RtgType nvarchar(3),
  @BomInum char(4))
RETURNS DECIMAL(20,6)
AS
BEGIN

Declare @ReturnVal As DECIMAL(20,6),
@OperQty As DECIMAL(20,6),
@SPQ as DECIMAL(20,6)

SET @OperQty = @OrigQty
-- BEB - Function was returning NULL if no routing existed.
--       Added this SET statement to initialize the return value 
SET @ReturnVal = @OrigQty

	IF @RtgType = 'STD'
	   begin
		-- BEB - Function was returning NULL if no routing existed.
		--       Added this if statement to process only if a routing exists. 
		if EXISTS (SELECT FSPQ FROM INRTGC 
             		   WHERE fac = @Fac 
             		   AND fpartno = @PartNo 
             		   AND fcpartrev = @Rev)
		begin
		     SET @SPQ = (SELECT FSPQ FROM INRTGC 
	             		 WHERE fac = @Fac 
	             		 AND fpartno = @PartNo 
	             		 AND fcpartrev = @Rev)
	
		     IF @OperNo = 0
	
			  SET @OperQty = ROUND((SELECT TOP 1 foperqty from inrtgs 
					 WHERE fpartno = @PartNo
				         AND fcpartrev = @Rev
					 AND fac = @Fac
					 ORDER BY foperno) / @SPQ * @JOMastQty,5)  			
		     ELSE			
			  SET @OperQty = ROUND((SELECT foperqty from inrtgs 
					 WHERE fpartno = @PartNo
				         AND fcpartrev = @Rev
					 AND fac = @Fac
					 AND foperno = @OperNo) / @SPQ * @JOMastQty,5)
	  			
			  SET @ReturnVal = (@OperQty / @JOMastQty) * @OrigQty
		end 
	   end	
	ELSE
	   begin
		-- BEB - Function was returning NULL if no routing existed.
		--       Added this if statement to process only if a routing exists. 
		if EXISTS (SELECT TOP 1 foperqty from sodrtg 
			   WHERE fsono = @SONo and finumber = @ItemNum)
		begin
		     IF @OperNo = 0
			  -- BEB - CRs 105512 and 105515 - 05/08/03
			  -- Added the 'and finumber = @ItemNum' to the where clause
			  -- for these 2 select statements.
			  SET @OperQty = (SELECT TOP 1 foperqty from sodrtg 
					 WHERE fsono = @SONo and finumber = @ItemNum and fbominum=@BomInum
					 ORDER BY foperno) * @JOMastQty  			
		     ELSE			
			  SET @OperQty = (SELECT foperqty from sodrtg 
					 WHERE fsono = @SONo and finumber = @ItemNum and fbominum=@BomInum
					 AND foperno = @OperNo) * @JOMastQty
	
	  		  -- BEB - CR 105073 - 05/01/03 - Formula was incorrect.
			  -- SET @ReturnVal = @OperQty * @OrigQty 
			  SET @ReturnVal = (@OperQty / @JOMastQty) * @OrigQty 
		end
	   end	

Return @ReturnVal

END
GO
/****** Object:  UserDefinedFunction [dbo].[GetVendLastPayDate]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
-- ************************************************************************
	--
	-- Author: 		Brian Boyd
	-- Date:		06/08/07
	-- Function name:	GetVendLastPayDate
	--
	-- Purpose:		Returns the last payment date for the 
	--			passed in vendor.
	--
	-- Parameters:		@vendno - Number of the vendor for whom we're 
	--			retrieving the last payment date.
	--
	-- ************************************************************************
	
	CREATE FUNCTION [dbo].[GetVendLastPayDate] 
	(@vendno char(6))
	returns datetime
	as
	
	begin
		declare @returnval as datetime
	
		set @returnval =
		isnull(
		(SELECT max(fdPaidDate) 
	FROM GlcShm 
	WHERE fcPayClass = 'P' AND fcStatus = 'P'
	and fcnameid = @vendno)
		,'1900-01-01')
		
		return @returnval
	end
GO
/****** Object:  UserDefinedFunction [dbo].[GetVendLastPayment]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
-- ************************************************************************
	--
	-- Author: 		Brian Boyd
	-- Date:		06/08/07
	-- Function name:	GetVendLastPayment
	--
	-- Purpose:		Returns the last payment amount for the 
	--			passed in vendor.
	--
	-- Parameters:		@vendno - Number of the vendor for whom we're 
	--			retrieving the last payment amount.
	--
	-- ************************************************************************
	
	CREATE FUNCTION [dbo].[GetVendLastPayment]
	(@vendno char(6))
	returns money
	as
	
	begin
		declare @returnval as money
	
		set @returnval =
		isnull(
		(SELECT top 1 fnamount 
	FROM GlcShm 
	WHERE fcPayClass = 'P' AND fcStatus = 'P'
	and fcnameid = @vendno
	order by fdpaiddate desc)
		,0.0)
		
		return @returnval
	end
GO
/****** Object:  UserDefinedFunction [dbo].[GetVendorBalance]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
-- ************************************************************************
	--
	-- Author: 		Brian Boyd
	-- Date:		06/08/07
	-- Function name:	GetVendorBalance
	--
	-- Purpose:		Returns the balance due for the 
	--			passed in vendor.
	--
	-- Parameters:		@vendno - Number of the vendor for whom we're 
	--			retrieving the balance due.
	--
	-- ************************************************************************
	
CREATE FUNCTION [dbo].[GetVendorBalance]
	(@vendno char(6))
	returns money
	as
	
	begin
		declare @returnval as money

		set @returnval = (SELECT SUM(i.fnAmount - i.fnAdjCashAmt) as fbal FROM 
				(SELECT apmast.fcInvoice, MAX(apmast.fnAmount) as fnAmount, SUM(ISNULL(glcshi.fnDiscount,0.0000) + ISNULL(glcshi.fnCashAmt,0.0000) + ISNULL(glcshi.fnAdjAmt,0.0000)) as fnAdjCashAmt 
					FROM APMAST 
					LEFT JOIN glcshi ON apmast.fcInvoice = glcshi.fcInvoice AND glcshi.fcNameID = @vendno AND glcshi.fcType NOT IN ('C', 'M') 
					LEFT JOIN glcshm ON glcshm.fcCashNum = glcshi.fcCashNum AND glcshm.fcStatus <>'S' AND glcshm.fcPayClass = 'P'
        					WHERE APMAST.fVendNo = @vendno
					AND APMAST.fcStatus not in ('F', 'S', 'N', 'H', 'V')
					GROUP BY apmast.fcInvoice) as i)
	
		return ISNULL(@returnval, 0.0000)
	end
GO
/****** Object:  UserDefinedFunction [dbo].[GetVendYTDPurchases]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
-- ************************************************************************
	--
	-- Author: 		Brian Boyd
	-- Date:		06/08/07
	-- Function name:	GetVendYTDPurchases
	--
	-- Purpose:		Returns the YTD purchase order amount for the 
	--			passed in vendor.
	--
	-- Parameters:		@vendno - Number of the vendor for whom we're 
	--			retrieving the YTD purchase order amount.
	--
	--			@currentdate - Today's date.
	--
	-- ************************************************************************
	
CREATE FUNCTION [dbo].[GetVendYTDPurchases]
	(@vendno char(6), @currentdate datetime)
	returns money
	as
	
	begin
		declare @returnval as money
	
		set @returnval =
		isnull(
		(select sum(((poitem.fordqty - poitem.fretqty) * poitem.fucost) - 
				   ((poitem.fordqty - poitem.fretqty) * poitem.fucost) * (poitem.fdiscount / 100))
				from poitem JOIN pomast ON poitem.fpono = pomast.fpono
				where (poitem.fmultirls = 'N' or poitem.frelsno <> '000') 
				and pomast.fstatus not in ('CANCELLED', 'STARTED')
				and pomast.fmethod <> '3' 
				and pomast.fvendno = @vendno
				and year(pomast.forddate) = year(@currentdate))
		,0.0)
		
	-- Add misc invoice amounts
	
		set @returnval = @returnval + 
		isnull(
		(select sum(fnamount) 
				from apmast 
				where fvendno = @vendno
				and fcsource in ('V', 'I', 'A')
				and fcstatus not in ('V', 'N', 'H')
				and year(finvdate) = year(@currentdate))
		,0.0)
		return @returnval
	end
GO
/****** Object:  UserDefinedFunction [dbo].[IndexExists]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[IndexExists](@TableName sysname, @IndexName sysname)
RETURNS bit
AS
BEGIN
        DECLARE @Exists bit

        SET @Exists = (SELECT COUNT(*) from dbo.sysindexes where name = @IndexName and id = object_id('dbo.' + @TableName) AND indid > 0 AND indid < 255)

        RETURN @Exists
END
GO
/****** Object:  UserDefinedFunction [dbo].[m2mAddrOrder]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[m2mAddrOrder]
 (@Country nvarchar(30) = NULL) 
RETURNS nvarchar(30) 
AS
BEGIN
 DECLARE @RetVal nvarchar(30)
 SELECT @Country = dbo.GetCountryCode(@Country)
 SELECT @RetVal = (SELECT fcforder
                   FROM UTCURR
                   WHERE fccurid = @Country)
 RETURN @RetVal    
END
GO
/****** Object:  UserDefinedFunction [dbo].[m2mDecCurrency]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[m2mDecCurrency] 
 (@Country nvarchar(30) = NULL) 
RETURNS int 
AS
BEGIN
 DECLARE @RetVal int
 SELECT @Country = dbo.GetCountryCode(@Country)
         SELECT @RetVal = (SELECT fnnumdec
                   FROM UTCURR
                   WHERE fccurid = @Country)
 RETURN @RetVal    
END
GO
/****** Object:  UserDefinedFunction [dbo].[m2mDecPrice]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[m2mDecPrice]
 (@Country nvarchar(30) = NULL) 
RETURNS int 
AS
BEGIN
 DECLARE @RetVal int
 SELECT @Country = dbo.GetCountryCode(@Country)
         SELECT @RetVal = (SELECT fdecimals
                   FROM UTCOMP
                   WHERE fcsqldb = DB_NAME())
 RETURN @RetVal    
END
GO
/****** Object:  UserDefinedFunction [dbo].[m2mDecQuantity]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[m2mDecQuantity]
 (@Country nvarchar(30) = NULL) 
RETURNS int 
AS
BEGIN
 DECLARE @RetVal int
 SELECT @Country = dbo.GetCountryCode(@Country)
         SELECT @RetVal = (SELECT fnqtydec
                   FROM UTCOMP
                   WHERE fcsqldb = DB_NAME())
 RETURN @RetVal    
END
GO
/****** Object:  UserDefinedFunction [dbo].[m2mParensAmount]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[m2mParensAmount]
 (@Country nvarchar(30) = NULL) 
RETURNS int 
AS
BEGIN
 DECLARE @RetVal int
 SELECT @Country = dbo.GetCountryCode(@Country)
         SELECT @RetVal = (SELECT fnnegamt
                   FROM UTCURR
                   WHERE fccurid = @Country)
 RETURN @RetVal    
END
GO
/****** Object:  UserDefinedFunction [dbo].[m2mParensNumber]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[m2mParensNumber] 
 (@Country nvarchar(30) = NULL) 
RETURNS int 
AS
BEGIN
 DECLARE @RetVal int
 SELECT @Country = dbo.GetCountryCode(@Country)
         SELECT @RetVal = (SELECT fnnegnum
                   FROM UTCURR
                   WHERE fccurid = @Country)
 RETURN @RetVal    
END
GO
/****** Object:  UserDefinedFunction [dbo].[m2mPictAmount]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[m2mPictAmount] 
 (@Country nvarchar(30) = NULL) 
RETURNS nvarchar(30) 
AS
BEGIN
 DECLARE @RetVal nvarchar(30)
 DECLARE @Sep char(1)             
 SELECT @Country = dbo.GetCountryCode(@Country)
 SELECT @Sep = dbo.m2mSymbolSeparator(@Country) 
 SELECT @RetVal = '@R 9' + @Sep + '999' + @Sep + '999' + @Sep + '999' + 
                          dbo.m2mSymbolPoint(@Country) + 
                   REPLICATE('9', dbo.m2mDecCurrency(@Country))
 RETURN @RetVal    
END
GO
/****** Object:  UserDefinedFunction [dbo].[m2mPictAmountMillions]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[m2mPictAmountMillions]
 (@Country nvarchar(30) = NULL) 
RETURNS nvarchar(30) 
AS
BEGIN
 DECLARE @RetVal nvarchar(30)
 DECLARE @Sep char(1)             
 SELECT @Country = dbo.GetCountryCode(@Country)
 SELECT @Sep = dbo.m2mSymbolSeparator(@Country) 
 --THIS.cPictAmountMillions = "@R 9" + THIS.cSymbolSeparator + "999"
 SELECT @RetVal = '@R 9' + @Sep + '999' 
 RETURN @RetVal    
END
GO
/****** Object:  UserDefinedFunction [dbo].[m2mPictAmountThousands]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[m2mPictAmountThousands]
 (@Country nvarchar(30) = NULL) 
RETURNS nvarchar(30) 
AS
BEGIN
 DECLARE @RetVal nvarchar(30)
 DECLARE @Sep char(1)             
 SELECT @Country = dbo.GetCountryCode(@Country)
 SELECT @Sep = dbo.m2mSymbolSeparator(@Country) 
 --THIS.cPictAmountThousands = THIS.cPictAmountMillions + THIS.cSymbolSeparator + "999"
 SELECT @RetVal = dbo.m2mPictAmountMillions(@Country) + @Sep + '999' 
 RETURN @RetVal    
END
GO
/****** Object:  UserDefinedFunction [dbo].[m2mPictAmountTotal]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[m2mPictAmountTotal]
 (@Country nvarchar(30) = NULL) 
RETURNS nvarchar(30) 
AS
BEGIN
 DECLARE @RetVal nvarchar(30)
 SELECT @RetVal = dbo.m2mPictAmount(@Country)
 RETURN @RetVal    
END
GO
/****** Object:  UserDefinedFunction [dbo].[m2mPictAmountUnits]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[m2mPictAmountUnits]
 (@Country nvarchar(30) = NULL) 
RETURNS nvarchar(30) 
AS
BEGIN
 DECLARE @RetVal nvarchar(30)
 DECLARE @Sep char(1)             
 SELECT @Country = dbo.GetCountryCode(@Country)
 SELECT @Sep = dbo.m2mSymbolSeparator(@Country) 
 --THIS.cPictAmountUnits = THIS.cPictAmountThousands + THIS.cSymbolSeparator + "999"
 SELECT @RetVal = dbo.m2mPictAmountThousands(@Country) + @Sep + '999' 
 RETURN @RetVal    
END
GO
/****** Object:  UserDefinedFunction [dbo].[m2mPictDate]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[m2mPictDate]
 (@Country nvarchar(30) = NULL) 
RETURNS nvarchar(30) 
AS
BEGIN
 DECLARE @RetVal nvarchar(30)
 SELECT @Country = dbo.GetCountryCode(@Country)
 SELECT @RetVal = (SELECT fcdatefor
                   FROM UTCURR
                   WHERE fccurid = @Country)
 RETURN @RetVal    
END
GO
/****** Object:  UserDefinedFunction [dbo].[m2mPictGL]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[m2mPictGL]
 (@Country nvarchar(30) = NULL) 
RETURNS nvarchar(30) 
AS
BEGIN
 DECLARE @RetVal nvarchar(30)
 SELECT @Country = dbo.GetCountryCode(@Country)
 SELECT @RetVal = '@R ' + (SELECT fcglmask
                           FROM CSGENL)
 RETURN @RetVal    
END
GO
/****** Object:  UserDefinedFunction [dbo].[m2mPictNumeric]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[m2mPictNumeric]
 (@Country nvarchar(30) = NULL) 
RETURNS nvarchar(30)
AS
BEGIN
 DECLARE @RetVal nvarchar(30)
 SELECT @Country = dbo.GetCountryCode(@Country)
 SELECT @RetVal = '@R 9999999999' + dbo.m2mSymbolPoint(@Country) + 
                   REPLICATE('9', dbo.m2mDecQuantity(@Country))
 RETURN @RetVal    
END
GO
/****** Object:  UserDefinedFunction [dbo].[m2mPictNumericTotal]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[m2mPictNumericTotal]
 (@Country nvarchar(30) = NULL) 
RETURNS nvarchar(30) 
AS
BEGIN
 DECLARE @RetVal nvarchar(30)
 DECLARE @Sep char(1)             
 SELECT @Country = dbo.GetCountryCode(@Country)
 SELECT @Sep = dbo.m2mSymbolSeparator(@Country) 
 SELECT @RetVal = '@R 99' + @Sep + '999' + @Sep + '999' + @Sep + '999' + 
                          dbo.m2mSymbolPoint(@Country) + 
                   REPLICATE('9', dbo.m2mDecCurrency(@Country))
 RETURN @RetVal    
END
GO
/****** Object:  UserDefinedFunction [dbo].[m2mPictPhone]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[m2mPictPhone]
 (@Country nvarchar(30) = NULL) 
RETURNS nvarchar(30) 
AS
BEGIN
 DECLARE @RetVal nvarchar(30)
 SELECT @Country = dbo.GetCountryCode(@Country)
 SELECT @RetVal = '@R ' + (SELECT fcfphone
                           FROM UTCURR
                           WHERE fccurid = @Country)
 RETURN @RetVal    
END
GO
/****** Object:  UserDefinedFunction [dbo].[m2mPictSSN]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[m2mPictSSN]
 (@Country nvarchar(30) = NULL) 
RETURNS nvarchar(30) 
AS
BEGIN
 DECLARE @RetVal nvarchar(30)
 SELECT @Country = dbo.GetCountryCode(@Country)
 SELECT @RetVal = '@R ' + (SELECT fcssn
                           FROM UTCURR
                           WHERE fccurid = @Country)
 RETURN @RetVal    
END
GO
/****** Object:  UserDefinedFunction [dbo].[m2mPictState]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[m2mPictState]
 (@Country nvarchar(30) = NULL) 
RETURNS nvarchar(30) 
AS
BEGIN
 DECLARE @RetVal nvarchar(30)
 SELECT @Country = dbo.GetCountryCode(@Country)
 SELECT @RetVal = '@R ' + (SELECT fcfstate
                           FROM UTCURR
                           WHERE fccurid = @Country)
 RETURN @RetVal    
END
GO
/****** Object:  UserDefinedFunction [dbo].[m2mPictUnits]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[m2mPictUnits]
 (@Country nvarchar(30) = NULL) 
RETURNS nvarchar(30) 
AS
BEGIN
 DECLARE @RetVal nvarchar(30)
 SELECT @Country = dbo.GetCountryCode(@Country)
 SELECT @RetVal = '@R ' + (SELECT fcfcostpr
                           FROM UTCURR
                           WHERE fccurid = @Country)
 RETURN @RetVal    
END
GO
/****** Object:  UserDefinedFunction [dbo].[m2mPictUnitsRounded]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[m2mPictUnitsRounded]
 (@Country nvarchar(30) = NULL) 
RETURNS nvarchar(30) 
AS
BEGIN
 DECLARE @RetVal nvarchar(30)
 DECLARE @Sep char(1)             
 SELECT @Country = dbo.GetCountryCode(@Country)
 SELECT @Sep = dbo.m2mSymbolSeparator(@Country) 
 SELECT @RetVal = '@R 9' + @Sep + '999' + @Sep + '999' + @Sep + '999' + 
                          dbo.m2mSymbolPoint(@Country) + 
                   REPLICATE('9', dbo.m2mDecPrice(@Country))
 RETURN @RetVal    
END
GO
/****** Object:  UserDefinedFunction [dbo].[m2mPictZip]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[m2mPictZip]
 (@Country nvarchar(30) = NULL) 
RETURNS nvarchar(30) 
AS
BEGIN
 DECLARE @RetVal nvarchar(30)
 SELECT @Country = dbo.GetCountryCode(@Country)
 SELECT @RetVal = '@R ' + (SELECT fcfzip
                           FROM UTCURR
                           WHERE fccurid = @Country)
 RETURN @RetVal    
END
GO
/****** Object:  UserDefinedFunction [dbo].[m2mSetCentury]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[m2mSetCentury]
 (@Country nvarchar(30) = NULL) 
RETURNS nvarchar(30) 
AS
BEGIN
 DECLARE @RetVal nvarchar(30)
 SELECT @Country = dbo.GetCountryCode(@Country)
 SELECT @RetVal = (SELECT fcsetcent
                   FROM UTCURR
                   WHERE fccurid = @Country)
 RETURN @RetVal    
END
GO
/****** Object:  UserDefinedFunction [dbo].[m2mSymbolCurrency]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[m2mSymbolCurrency]
 (@Country nvarchar(30) = NULL) 
RETURNS char(6) 
AS
BEGIN
 DECLARE @RetVal char(6)
 SELECT @Country = dbo.GetCountryCode(@Country)
         SELECT @RetVal = (SELECT fcsymbol
                   FROM UTCURR
                   WHERE fccurid = @Country)
 RETURN @RetVal    
END
GO
/****** Object:  UserDefinedFunction [dbo].[m2mSymbolDate]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[m2mSymbolDate]
 (@Country nvarchar(30) = NULL) 
RETURNS nvarchar(30) 
AS
BEGIN
 DECLARE @RetVal nvarchar(30)
 SELECT @Country = dbo.GetCountryCode(@Country)
 SELECT @RetVal = (SELECT fcdatemar
                   FROM UTCURR
                   WHERE fccurid = @Country)
 RETURN @RetVal    
END
GO
/****** Object:  UserDefinedFunction [dbo].[m2mSymbolPoint]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[m2mSymbolPoint]
 (@Country nvarchar(30) = NULL) 
RETURNS char(1) 
AS
BEGIN
 DECLARE @RetVal char(1)
 SELECT @Country = dbo.GetCountryCode(@Country)
         SELECT @RetVal = (SELECT fcdsep
                   FROM UTCURR
                   WHERE fccurid = @Country)
 RETURN @RetVal    
END
GO
/****** Object:  UserDefinedFunction [dbo].[m2mSymbolPos]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[m2mSymbolPos] 
 (@Country nvarchar(30) = NULL) 
RETURNS int 
AS
BEGIN
 DECLARE @RetVal int
 SELECT @Country = dbo.GetCountryCode(@Country)
         SELECT @RetVal = (SELECT fnsymbol
                   FROM UTCURR
                   WHERE fccurid = @Country)
 RETURN @RetVal    
END
GO
/****** Object:  UserDefinedFunction [dbo].[m2mSymbolSeparator]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[m2mSymbolSeparator] 
 (@Country nvarchar(30) = NULL) 
RETURNS char(1) 
AS
BEGIN
 DECLARE @RetVal char(1)
 SELECT @Country = dbo.GetCountryCode(@Country)
         SELECT @RetVal = (SELECT fctsep
                   FROM UTCURR
                   WHERE fccurid = @Country)
 RETURN @RetVal    
END
GO
/****** Object:  UserDefinedFunction [dbo].[m2mTransform]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[m2mTransform] 
 (@Exp sql_variant,
  @Codes sql_variant,
  @tType int,
  @DatePict nvarchar(30) = '') 
RETURNS nvarchar(100)
AS
BEGIN
 -- tType should be one of 4 values depending on
 -- the type of data you're trying to transform:
         -- Numeric - 1
         -- Character data - 2
         -- Currency - 3
         -- Dates - 4

 DECLARE @oXForm int
 DECLARE @hr int
 DECLARE @src varchar(255), @desc varchar(255)
 DECLARE @RetVal nvarchar(100)
 DECLARE @ErrorMessage varchar(255)
 --EXEC @hr = sp_OACreate 'm2mfoxxform.clsfoxxform', @oXForm OUT
 EXEC @hr = sp_OACreate 'm2mdvxform.clsxform', @oXForm OUT, 4 -- Out of process exe so it can't mess with SQL Server's process.
 IF @hr <> 0
 BEGIN
    EXEC sp_OAGetErrorInfo @oXForm, @src OUT, @desc OUT 
    SELECT @ErrorMessage = convert(varchar(4),@hr) + RTRIM(LTRIM(@src)) + RTRIM(LTRIM(@desc))
    --RAISERROR (@ErrorMessage, 16, 1)
 END
 EXEC @hr = sp_OAMethod @oXForm, 'doxform', @RetVal OUTPUT, @Exp, @Codes, @tType, @DatePict
 IF @hr <> 0
 BEGIN
    EXEC sp_OAGetErrorInfo @oXForm, @src OUT, @desc OUT
    SELECT @ErrorMessage = convert(varchar(4),@hr) + RTRIM(LTRIM(@src)) + RTRIM(LTRIM(@desc))
    --RAISERROR (@ErrorMessage, 16, 1)
 END
 RETURN RTRIM(LTRIM(@RetVal))    
END
GO
/****** Object:  UserDefinedFunction [dbo].[MA_GetPartAverageSalesOrderReleasePrice]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

----------------------------------------------------------------------------------------------
-- MA_GetPartAverageSalesOrderReleasePrice is a scalar function which returns the average sorels Unit NetPrice for the specified item around specified due date
-- Sample usage:  select dbo.MA_GetPartAverageSalesOrderReleasePrice('ES120100', '000', '2008-10-31' )
----------------------------------------------------------------------------------------------
create function [dbo].[MA_GetPartAverageSalesOrderReleasePrice](@partNo varchar(25), @partRev varchar(3), @priorToDueDate datetime) returns decimal(17,5)
as
begin
	declare @return decimal(17,5)
	select @return = CONVERT(DECIMAL(17,5), sum(fnetprice) / sum(forderqty))
	from (
		select top 3 fnetprice, forderqty 
		from SORELS 
		where forderqty <> 0 and fpartno=@partNo and fpartrev=@partRev and fduedate <=@priorToDueDate 
		order by fduedate desc, frelease desc) soRels
	return @return
end					


GO
/****** Object:  UserDefinedFunction [dbo].[ProcExists]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[ProcExists](@ProcName as sysname)
RETURNS bit
AS
BEGIN
        DECLARE @Exists bit

        SET @Exists = (SELECT COUNT(*) FROM sysobjects WHERE name = @ProcName AND type = 'P')

        RETURN @Exists
END
GO
/****** Object:  UserDefinedFunction [dbo].[ROUNDCURR]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[ROUNDCURR]
 (@ROUNDVAR AS M2MGenericQuantity, @CURID AS nvarchar(6))
RETURNS M2MGenericQuantity
AS
BEGIN

   DECLARE @RETURN AS M2MGenericQuantity,
	   @ROUNDNUM AS INTEGER

/** Take the currency id, find the appropriate UtCurr Record and fnNumDec for that
    currency -- lnRoundNum will be the number of decimal places for that currency **/
  IF EXISTS(SELECT FNNUMDEC FROM UTCURR WHERE fccurid = @CURID)
	BEGIN
	  SELECT @ROUNDNUM = FNNUMDEC FROM UTCURR WHERE fccurid = @CURID
	END

  SET @RETURN = ROUND(@ROUNDVAR,@ROUNDNUM)

  RETURN @RETURN

END
GO
/****** Object:  UserDefinedFunction [dbo].[ROUNDQTY]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE   FUNCTION [dbo].[ROUNDQTY]
 (	@ROUNDVAR AS M2MGenericQuantity)
RETURNS M2MGenericQuantity
AS
BEGIN

   DECLARE @ReturnVal AS M2MGenericQuantity,
	   @DecQty AS INTEGER

   SELECT @DecQty = FNQTYDEC FROM UTCOMP

   SELECT @ReturnVal =  CASE WHEN @DecQty = 5 THEN CAST(ROUND(@ROUNDVAR,@DecQty) AS DECIMAL(16,5)) ELSE
			CASE WHEN @DecQty = 4 THEN CAST(ROUND(@ROUNDVAR,@DecQty) AS DECIMAL(16,4)) ELSE
			CASE WHEN @DecQty = 3 THEN CAST(ROUND(@ROUNDVAR,@DecQty) AS DECIMAL(16,3)) ELSE
			CASE WHEN @DecQty = 2 THEN CAST(ROUND(@ROUNDVAR,@DecQty) AS DECIMAL(16,2)) ELSE
			CASE WHEN @DecQty = 1 THEN CAST(ROUND(@ROUNDVAR,@DecQty) AS DECIMAL(16,1)) ELSE
			CASE WHEN @DecQty = 0 THEN CAST(ROUND(@ROUNDVAR,@DecQty) AS DECIMAL(16,0)) END END END END END END

   RETURN @ReturnVal

END
GO
/****** Object:  UserDefinedFunction [dbo].[TableExists]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[TableExists](@TableName sysname)
RETURNS bit
AS
BEGIN
        DECLARE @Exists bit

        SET @Exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @TableName)

        RETURN @Exists
END
GO
/****** Object:  UserDefinedFunction [dbo].[udf_GetEmpNo]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[udf_GetEmpNo]
(@comment text)
RETURNS CHAR(9)
AS
BEGIN
DECLARE @empNumber char(9);
DECLARE @empPortion VARCHAR(255);
SET @empPortion = SUBSTRING(
   @comment,
   PATINDEX('%[Emp]%',@comment),
   999); 
set @empNumber = SUBSTRING(
   @empPortion,--put the default on the end
   PATINDEX('%[0-9]%',@empPortion),
   999); --three characters
--select @empNumber
RETURN ISNULL(@empNumber,0)
END

GO
/****** Object:  UserDefinedFunction [dbo].[udf_GetNumeric]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[udf_GetNumeric]
(@strAlphaNumeric VARCHAR(256))
RETURNS VARCHAR(256)
AS
BEGIN
DECLARE @intAlpha INT
SET @intAlpha = PATINDEX('%[^0-9]%', @strAlphaNumeric)
BEGIN
WHILE @intAlpha > 0
BEGIN
SET @strAlphaNumeric = STUFF(@strAlphaNumeric, @intAlpha, 1, '' )
SET @intAlpha = PATINDEX('%[^0-9]%', @strAlphaNumeric )
END
END
RETURN ISNULL(@strAlphaNumeric,0)
END

GO
/****** Object:  UserDefinedFunction [dbo].[bfToolCostSummaryLv6]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[bfToolCostSummaryLv6] (@startDateParam DATETIME,@endDateParam DATETIME) 
  RETURNS Table 
AS 
RETURN
	select jobNumber, partNumber, partRev, description, pcsProduced,  
	valueAddedSales,totalValueAdd, budgetedToolAllowance, budgetedToolCost, 
	sum(toolItemIssueTotCost) as actualToolCost 
	from
	(
		select * from  bfToolCostSummaryLv5(@startDateParam,@endDateParam)
	) as lv5
	GROUP BY jobNumber, partNumber, partRev,description, pcsProduced,  valueAddedSales, totalValueAdd,
	budgetedToolAllowance, budgetedToolCost

GO
/****** Object:  UserDefinedFunction [dbo].[bfToolCostSummaryLv7]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[bfToolCostSummaryLv7](@startDateParam DATETIME,@endDateParam DATETIME) 
  RETURNS Table 
AS 
RETURN
select jobNumber, partNumber, partRev, description,pcsProduced, 
valueAddedSales, totalValueAdd, budgetedToolAllowance, 
budgetedToolCost,
case 
when pcsProduced = 0 then cast(0.0 as decimal(18,2))
else cast((actualToolCost / pcsProduced) as decimal(18,2)) 
end as actualToolAllowance, 
actualToolCost, 
case 
when (budgetedToolCost = 0) then cast(0.00 as decimal(18,2))
else cast((actualToolCost / budgetedToolCost * 100) as decimal(18,2)) 
end 
as budgetedVrsActualPct 
 from
(
	select * from  bfToolCostSummaryLv6(@startDateParam,@endDateParam)
) as lv6


GO
/****** Object:  UserDefinedFunction [dbo].[bfWorkSumLv2]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[bfWorkSumLv2]
(  
@startDateParam DATETIME,
@endDateParam DATETIME
)
RETURNS TABLE 
AS
RETURN
-- use this function to sum all parts made in a specified time period
select partNumber, partRev, maxJobNumber,maxOperNo,fpro_id,fdept,
m2mDescription, tlDescription as descript, valueAddedSales,budgetedToolAllowance,
NTLFlag,PartRevInItemMaster,
sum(fcompqty) as pcsProduced  
from bfWorkSumLv1(@startDateParam,@endDateParam)
group by partNumber, partRev, maxJobNumber,maxOperNo,fpro_id,fdept,
	m2mDescription,tldescription,valueAddedSales,budgetedToolAllowance,NTLFlag, 
	PartRevInItemMaster

GO
/****** Object:  UserDefinedFunction [dbo].[bfNoValueAddSalesOrToolAllowance]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[bfNoValueAddSalesOrToolAllowance] (@startDateParam DATETIME,@endDateParam DATETIME) 
  RETURNS Table 
AS 
RETURN
select ws.jobNumber, ws.partNumber, ws.partRev, ws.description, 
ws.pcsProduced,ws.valueAddedSales, ws.budgetedToolAllowance
from
(
	select maxJobNumber jobNumber, partNumber, partRev,m2mDescription description, pcsProduced,valueAddedSales, budgetedToolAllowance
	from bfWorkSumLv2(@startDateParam,@endDateParam)
		where valueAddedSales = 0 or budgetedToolAllowance = 0
) ws
inner join
(
	select distinct PartNumber from toolingtranslog 
	where (TranStartDateTime >= @startDateParam) and (TranStartDateTime <= @endDateParam)
) ttl
on ws.partNumber = ttl.partNumber



GO
/****** Object:  UserDefinedFunction [dbo].[bfWorkSumLv3]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[bfWorkSumLv3] (@startDateParam DATETIME,@endDateParam DATETIME) 
  RETURNS Table 
AS 
RETURN
	-- add totalValueAdd and budgetedToolCost
	select partNumber, partRev, maxJobNumber,maxOperNo, fpro_id, fdept,
	m2mDescription,	descript, pcsProduced,  
	valueAddedSales,
	cast(pcsProduced*valueAddedSales as decimal(18,2)) as totalValueAdd,
	budgetedToolAllowance, 
	cast(pcsProduced*budgetedToolAllowance as decimal(18,2)) as budgetedToolCost, 
	NTLFlag, 
	PartRevInItemMaster
	from
	(

		select * from  bfWorkSumLv2(@startDateParam,@endDateParam)
	)lv3
	--283



GO
/****** Object:  UserDefinedFunction [dbo].[bfWorkSumLv4IJ]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[bfWorkSumLv4IJ] (@startDateParam DATETIME,@endDateParam DATETIME) 
  RETURNS Table 
AS 
RETURN
select partNumber, partRev, maxJobNumber,maxOperNo, fpro_id, fdept,
m2mDescription,descript, 
pcsProduced,
valueAddedSales,totalValueAdd,budgetedToolAllowance, 
budgetedToolCost,NTLFlag,PartRevInItemMaster,
Plant,username,transTime,itemNumber,toolItemIssueQty,unitCost, 
cast(toolItemIssueQty*unitCost as decimal(18,2)) as toolItemIssueTotCost  
from
(
	select lv3.partNumber, partRev, maxJobNumber,maxOperNo, fpro_id, fdept,
	m2mDescription,descript,
	pcsProduced,valueAddedSales,totalValueAdd,budgetedToolAllowance, 
	budgetedToolCost,NTLFlag,PartRevInItemMaster,
	Plant,username,TranStartDateTime as transTime,
	itemNumber,
	case 
		when ToolLog.qty is null then cast(0.0 as decimal(18,2)) 
		else ToolLog.qty
	end 
	as toolItemIssueQty, 
	case 
		when ToolLog.unitCost is null then cast(0.0 as decimal(18,2)) 
		else ToolLog.unitCost
	end 
	as unitCost 
	from bfWorkSumLv3(@startDateParam,@endDateParam) lv3
	inner join			
	(
		select * from dbo.ToolingTransLog
		where dbo.ToolingTransLog.[TranStartDateTime] >= @startDateParam 
		and dbo.ToolingTransLog.[TranStartDateTime] <= @endDateParam 
	) ToolLog
	on lv3.partNumber = ToolLog.partNumber
) lv4
--12765


GO
/****** Object:  UserDefinedFunction [dbo].[bfWorkSumLv4IJC]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--/////////////////////////////////////////////////////////////////////
-- Sum of partNumber / itemNumber tool costs
-- Part/Item total cost has been calculated
-- BudgetPartItemTotCost has also been calculated for
-- consumable items
-- and part item records have been marked as consumable or not
-- ConsPartItemTotCost is a sum of all consumable toollog entries
-- ConsPartItemTotCost can be compared to BudgetPartItemTotCost
-- and PartItemTotCost is the total actual toolcost
--/////////////////////////////////////////////////////////////////////
create FUNCTION [dbo].[bfWorkSumLv4IJC] (@startDateParam DATETIME,@endDateParam DATETIME) 
  RETURNS Table 
AS 
RETURN

select lv4ijc.*, 
	case 
	when (ConsPartItemTotCost = 0) then 0.0
	else ((BudgetPartItemTotCost / ConsPartItemTotCost) * 100)  
	end budgetedVrsActualCost,
	case 
	when (BudgetPartItemTotCost = 0) then 0.0
	else ((ConsPartItemTotCost / BudgetPartItemTotCost ) * 100)  
	end ActualVrsBudgetedCost
from
(
	-- Use this query on the main report which will drop jobs with no tool cost
	select lv4ij.partNumber,lv4ij.itemNumber, partRev, maxJobNumber,maxOperNo, fpro_id, fdept,
	m2mDescription,descript,unitcost, 
	pcsProduced,
	valueAddedSales,totalValueAdd,budgetedToolAllowance, 
	budgetedToolCost,NTLFlag,PartRevInItemMaster,
	partItemTotQty, partItemTotCost, 
	-- identify items as consumable or not
	case 
		when itemsPerPart is null then 0 
		-- The toollist probably needs updated on these parts
		when itemsPerPart = 0 then 0 
		else 1 
	end
	as consumable,
	case 
		when toolDescript is null then 'No Desciption' 
		else toolDescript 
	end
	as toolDescript,
	case 
		when itemsPerPart is null then 0.0 
		else itemsPerPart 
	end
	as itemsPerPart,
	case 
		when toolOps is null then 'Not Found' 
		else toolOps 
	end
	as toolOps,
	case 
		when itemsPerPart is null then 0 
		else pcsProduced*itemsPerPart 
	end
	as bdgItemCnt,
	case
		when itemsPerPart is null then 0.0
		else (pcsProduced*itemsPerPart * unitCost)
	end
	as BudgetPartItemTotCost,
	case 
		-- if it is not consumable then
		-- we want to set this partItem 
		-- to $0
		when itemsPerPart is null then 0.0 
		when itemsPerPart = 0 then 0.0 
		else partItemTotQty 
	end
	as ConsPartItemTotQty,
	case 
		-- if it is not consumable then
		-- we want to set this partItem 
		-- to $0
		when itemsPerPart is null then 0.0 
		when itemsPerPart = 0 then 0.0 
		else partItemTotCost 
	end
	as ConsPartItemTotCost
	from 
	(
		select partNumber,lv4.itemNumber, partRev, maxJobNumber,maxOperNo, fpro_id, fdept,
		m2mDescription,descript,unitCost,description1 toolDescript,
		pcsProduced,
		valueAddedSales,totalValueAdd,budgetedToolAllowance, 
		budgetedToolCost,NTLFlag,PartRevInItemMaster,
		partItemTotQty,
		partItemTotCost 
		from
		(
			select partNumber,itemNumber, partRev, maxJobNumber,maxOperNo, fpro_id, fdept,
			m2mDescription,descript,unitCost,
			pcsProduced,
			valueAddedSales,totalValueAdd,budgetedToolAllowance, 
			budgetedToolCost,NTLFlag,PartRevInItemMaster,
			sum(toolItemIssueQty) partItemTotQty,
			sum(toolItemIssueTotCost) partItemTotCost 
			from bfWorkSumLv4IJ(@startDateParam,@endDateParam) 
			group by 
				partNumber, itemNumber,partRev, maxJobNumber,maxOperNo, fpro_id, fdept,
				m2mDescription,descript,unitCost, 
				pcsProduced,
				valueAddedSales,totalValueAdd,budgetedToolAllowance, 
				budgetedToolCost,NTLFlag,PartRevInItemMaster
				--2379
		)lv4
		inner join
		toolitems ti
		on lv4.itemnumber= ti.itemnumber
		--2379
	)lv4IJ
	left outer join
	(
		-- All these items are marked as consumable on ToolList
		select partNumber,ipp.itemNumber,
		itemsPerPart,toolOps
		from btToolListPartItems ipp
		--7076
	)ip
	on lv4IJ.partNumber=ip.partNumber
	and lv4IJ.itemNumber=ip.itemNumber
	--2194
)lv4IJC


GO
/****** Object:  UserDefinedFunction [dbo].[bfWorkSumLv1NTL]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[bfWorkSumLv1NTL]
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
	left outer join 
	(
		select partNumber,max(custPartFamily) maxPartFamily from btDistinctToolLists
		group by partNumber
		--529
	) q
	on p.partNumber=q.partNumber
	where q.partNumber is null
	-- we want labor details for part numbers with no tool list.
	--125483
	--14928
) r
--> delete duplicate records. Don't know why there are a few duplicates, but there are
group by 
partNumber, partRev, maxJobNumber,maxOperNo,fpro_id,fdept,
m2mDescription,tlDescription, valueAddedSales,budgetedToolAllowance,
NTLFlag,PartRevInItemMaster,fdate,fedatetime,fempno,fcompqty,fstatus 

GO
/****** Object:  UserDefinedFunction [dbo].[bfWorkSumLv2NTL]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[bfWorkSumLv2NTL]
(  
@startDateParam DATETIME,
@endDateParam DATETIME
)
RETURNS TABLE 
AS
RETURN
-- use this function to sum all parts made in a specified time period
select partNumber, partRev, maxJobNumber,maxOperNo,fpro_id,fdept,
m2mDescription, tlDescription as descript, valueAddedSales,budgetedToolAllowance,
NTLFlag,PartRevInItemMaster,
sum(fcompqty) as pcsProduced  
from bfWorkSumLv1NTL(@startDateParam,@endDateParam)
group by partNumber, partRev, maxJobNumber,maxOperNo,fpro_id,fdept,
	m2mDescription,tldescription,valueAddedSales,budgetedToolAllowance,NTLFlag, 
	PartRevInItemMaster

GO
/****** Object:  UserDefinedFunction [dbo].[bfActiveJobNoToolList]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[bfActiveJobNoToolList](
@startDateParam DATETIME, 
@endDateParam DATETIME 
)
RETURNS table
AS
return
	select maxJobNumber as jobNumber, partNumber,m2mDescription, pcsProduced 
	from bfWorkSumLv2NTL(@startDateParam,@endDateParam)

GO
/****** Object:  UserDefinedFunction [dbo].[bfNoValueAddSales]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[bfNoValueAddSales] (@startDateParam DATETIME,@endDateParam DATETIME) 
  RETURNS Table 
AS 
RETURN
select lv3.jobNumber, lv3.partNumber, lv3.partRev, lv3.Description, 
lv3.pcsProduced,lv3.valueAddedSales 
from
(
	select maxJobNumber jobNumber, partNumber, partRev, left(Descript,40) description, cast(pcsProduced as int) pcsProduced,valueAddedSales
	from bfWorkSumLv2(@startDateParam,@endDateParam)
		where valueAddedSales = 0
) lv3
inner join
(
	select distinct PartNumber from toolingtranslog 
	where (TranStartDateTime >= @startDateParam) and (TranStartDateTime <= @endDateParam)
) ttl
on lv3.partNumber = ttl.partNumber


GO
/****** Object:  UserDefinedFunction [dbo].[bfToolCostSummaryLv8]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[bfToolCostSummaryLv8](@startDateParam DATETIME,@endDateParam DATETIME) 
  RETURNS Table 
AS 
RETURN

select jobNumber, fdept, partNumber, partRev, description,pcsProduced, 
valueAddedSales, totalValueAdd, budgetedToolAllowance, 
budgetedToolCost,
actualToolAllowance, 
actualToolCost, 
budgetedVrsActualPct 
 from
(
	select * from  bfToolCostSummaryLv7(@startDateParam,@endDateParam)
) as tcs
inner join (
	--> fpro_id subpnt does not have a dept
	select distinct fjobno,fdept from jodrtg
	inner join inwork on jodrtg.fpro_id=inwork.fcpro_id 
	where fdept <> ''
) as dpt
on tcs.jobNumber=dpt.fjobno 

GO
/****** Object:  UserDefinedFunction [dbo].[bfWorkSumLv5IJ]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--/////////////////////////////////////////////////////////////////////
-- Sum of partNumber / itemNumber tool costs
-- Part/Item total cost has been calculated
-- BudgetPartItemTotCost has also been calculated for
-- consumable items
-- and part item records have been marked as consumable or not
-- partItemTotCost can be compared to BudgetPartItemTotCost
--/////////////////////////////////////////////////////////////////////
create FUNCTION [dbo].[bfWorkSumLv5IJ] (@startDateParam DATETIME,@endDateParam DATETIME) 
  RETURNS Table 
AS 
RETURN
	-- Use this query on the main report which will drop jobs with no tool cost
	-- summing the tool costs
	select partNumber, partRev, maxJobNumber,maxOperNo, fpro_id, fdept,
	m2mDescription,descript, 
	pcsProduced,valueAddedSales,totalValueAdd,budgetedToolAllowance, 
	budgetedToolCost,NTLFlag,PartRevInItemMaster,
	case 
	when (pcsProduced = 0) then 0.0
	else sum(budgetPartItemTotCost) / pcsProduced
	end
	as EngToolAllowance,
	sum(budgetPartItemTotCost) as engToolCost, 

	case 
	when (pcsProduced = 0) then 0.0
	else sum(ConsPartItemTotCost) / pcsProduced
	end
	as ConsToolAllowance,
	sum(ConsPartItemTotCost) as ConsToolCost, 

	case
	when (pcsProduced = 0) then 0.0
	else sum(partItemTotCost) / pcsProduced
	end
	as ActualToolAllowance,
	sum(partItemTotCost) as actualToolCost 
	from
	(
		select * from  bfWorkSumLv4IJC(@startDateParam,@endDateParam)
	) as lv5
	GROUP BY 
	partNumber, partRev, maxJobNumber,maxOperNo, fpro_id, fdept,
	m2mDescription,descript,
	pcsProduced,valueAddedSales,totalValueAdd,budgetedToolAllowance, 
	budgetedToolCost,NTLFlag,PartRevInItemMaster
	--231

GO
/****** Object:  UserDefinedFunction [dbo].[bfWorkSumLv6IJ]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--/////////////////////////////////////////////////////////////////////////
-- Use this query on the main report which will drop jobs with no tool cost
--////////////////////////////////////////////////////////////////////////
create FUNCTION [dbo].[bfWorkSumLv6IJ] (@startDateParam DATETIME,@endDateParam DATETIME) 
  RETURNS Table 
AS 
RETURN
	-- summing the tool costs
	select partNumber, partRev, maxJobNumber,maxOperNo, fpro_id, fdept,
	m2mDescription,descript,
	pcsProduced,valueAddedSales,totalValueAdd,budgetedToolAllowance, 
	budgetedToolCost,NTLFlag,PartRevInItemMaster,
	EngToolAllowance,
	engToolCost, 
	ConsToolAllowance,
	ConsToolCost, 
	ActualToolAllowance, 
	actualToolCost, 
	case 
	when (actualToolCost = 0) then 0.0
	else ((ConsToolCost / actualToolCost) * 100)  
	end 
	as consumableVrsActualPct, 
	case 
	when (EngToolCost = 0) then 0.0
	else ((ConsToolCost / EngToolCost) * 100)  
	end 
	as actualVrsBudgetedPct, 
	case 
	when (valueAddedSales = 0) then 0.0
	else ((actualToolCost / totalValueAdd) * 100)  
	end 
	as actualVrsVaSalesPct 
	from
	(
		select * from  bfWorkSumLv5IJ(@startDateParam,@endDateParam)
		--12223
	) as lv5



GO
/****** Object:  UserDefinedFunction [dbo].[bfWorkSumLv4OJ]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[bfWorkSumLv4OJ] (@startDateParam DATETIME,@endDateParam DATETIME) 
  RETURNS Table 
AS 
RETURN
	-- Use this if you want to include records with no tool cost
	select partNumber, partRev, maxJobNumber,maxOperNo, fpro_id, fdept,
	m2mDescription,descript,dailyToolCost, 
	pcsProduced,valueAddedSales,totalValueAdd,budgetedToolAllowance, 
	budgetedToolCost,NTLFlag,PartRevInItemMaster,
	Plant,username,transTime,itemNumber,toolItemIssueQty,unitCost, 
	cast(toolItemIssueQty*unitCost as decimal(18,2)) as toolItemIssueTotCost  
	from
	(
		select lv3.partNumber, partRev, maxJobNumber,maxOperNo, fpro_id, fdept,
		m2mDescription,descript,dailyToolCost, 
		pcsProduced,valueAddedSales,totalValueAdd,budgetedToolAllowance, 
		budgetedToolCost,NTLFlag,PartRevInItemMaster,
		case 
			when ToolLog.Plant is null then 'none' 
			else ToolLog.Plant
		end 
		as Plant,
		case 
			when ToolLog.username is null then 'none' 
			else ToolLog.username
		end 
		as username,
		case 
			when ToolLog.TranStartDateTime is null then '2008-01-01' 
			else ToolLog.TranStartDateTime
		end 
		as transTime,
		case 
			when ToolLog.itemNumber is null then 'none' 
			else ToolLog.itemNumber
		end 
		as itemNumber,
		case 
			when ToolLog.qty is null then cast(0.0 as decimal(18,2)) 
			else ToolLog.qty
		end 
		as toolItemIssueQty, 
		case 
			when ToolLog.unitCost is null then cast(0.0 as decimal(18,2)) 
			else ToolLog.unitCost
		end 
		as unitCost 
		from bfWorkSumLv3(@startDateParam,@endDateParam) lv3
		left outer join			
		(
			select * from dbo.ToolingTransLog
			where dbo.ToolingTransLog.[TranStartDateTime] >= @startDateParam 
			and dbo.ToolingTransLog.[TranStartDateTime] <= @endDateParam 
		) ToolLog
		on lv3.partNumber = ToolLog.partNumber
	) lv4OJ 
	--12296


GO
/****** Object:  UserDefinedFunction [dbo].[bfWorkSumLv5OJ]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[bfWorkSumLv5OJ] (@startDateParam DATETIME,@endDateParam DATETIME) 
  RETURNS Table 
AS 
RETURN
	-- Use this if you want to include records with no tool cost
	-- summing the tool costs
	select partNumber, partRev, maxJobNumber,maxOperNo, fpro_id, fdept,
	m2mDescription,descript, dailyToolCost, 
	pcsProduced,valueAddedSales,totalValueAdd,budgetedToolAllowance, 
	budgetedToolCost,NTLFlag,PartRevInItemMaster,
	case 
	when (pcsProduced = 0) then 0.0
	else sum(toolItemIssueTotCost) / pcsProduced
	end
	as ActualToolAllowance,
	sum(toolItemIssueTotCost) as actualToolCost 
	from
	(
		select * from  bfWorkSumLv4OJ(@startDateParam,@endDateParam)
		--12296
	) as lv5
	GROUP BY 
	partNumber, partRev, maxJobNumber,maxOperNo, fpro_id, fdept,
	m2mDescription,descript,dailyToolCost,
	pcsProduced,valueAddedSales,totalValueAdd,budgetedToolAllowance, 
	budgetedToolCost,NTLFlag,PartRevInItemMaster
	-- 283

GO
/****** Object:  UserDefinedFunction [dbo].[bfWorkSumLv4NTC]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create FUNCTION [dbo].[bfWorkSumLv4NTC] (@startDateParam DATETIME,@endDateParam DATETIME) 
  RETURNS Table 
AS 
RETURN
	-- Use this if you want only records with no tool cost
	select partNumber, partRev, maxJobNumber,maxOperNo, fpro_id, fdept,
	m2mDescription,descript,dailyToolCost, 
	pcsProduced,valueAddedSales,totalValueAdd,budgetedToolAllowance, 
	budgetedToolCost,NTLFlag,PartRevInItemMaster,
	Plant,username,transTime,itemNumber,toolItemIssueQty,unitCost, 
	cast(toolItemIssueQty*unitCost as decimal(18,2)) as toolItemIssueTotCost  
	from
	(
		select lv3.partNumber, partRev, maxJobNumber,maxOperNo, fpro_id, fdept,
		m2mDescription,descript,dailyToolCost, 
		pcsProduced,valueAddedSales,totalValueAdd,budgetedToolAllowance, 
		budgetedToolCost,NTLFlag,PartRevInItemMaster,
		case 
			when ToolLog.Plant is null then 'none' 
			else ToolLog.Plant
		end 
		as Plant,
		case 
			when ToolLog.username is null then 'none' 
			else ToolLog.username
		end 
		as username,
		case 
			when ToolLog.TranStartDateTime is null then '2008-01-01' 
			else ToolLog.TranStartDateTime
		end 
		as transTime,
		case 
			when ToolLog.itemNumber is null then 'none' 
			else ToolLog.itemNumber
		end 
		as itemNumber,
		case 
			when ToolLog.qty is null then cast(0.0 as decimal(18,2)) 
			else ToolLog.qty
		end 
		as toolItemIssueQty, 
		case 
			when ToolLog.unitCost is null then cast(0.0 as decimal(18,2)) 
			else ToolLog.unitCost
		end 
		as unitCost 
		from bfWorkSumLv3(@startDateParam,@endDateParam) lv3
		left outer join			
		(
			select * from dbo.ToolingTransLog
			where dbo.ToolingTransLog.[TranStartDateTime] >= @startDateParam 
			and dbo.ToolingTransLog.[TranStartDateTime] <= @endDateParam 
		) ToolLog
		on lv3.partNumber = ToolLog.partNumber
		where ToolLog.PartNumber is null
		--73
	) lv4NTC 
	inner join jomast
	on 
	lv4NTC.maxJobNumber = jomast.fjobno
	--73


GO
/****** Object:  UserDefinedFunction [dbo].[bfWorkSumLv5NTC]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[bfWorkSumLv5NTC] (@startDateParam DATETIME,@endDateParam DATETIME) 
  RETURNS Table 
AS 
RETURN
	-- Use this if you want only records with no tool cost
	select partNumber, partRev, maxJobNumber,maxOperNo, fpro_id, fdept,
	m2mDescription,descript,dailyToolCost, 
	pcsProduced,valueAddedSales,totalValueAdd,budgetedToolAllowance, 
	budgetedToolCost,NTLFlag,PartRevInItemMaster,
	case 
	when (pcsProduced = 0) then 0.0
	else sum(toolItemIssueTotCost) / pcsProduced
	end
	as ActualToolAllowance,
	sum(toolItemIssueTotCost) as actualToolCost 
	from
	(
		select * from  bfWorkSumLv4NTC(@startDateParam,@endDateParam)
	) as lv5
	GROUP BY 
	partNumber, partRev, maxJobNumber,maxOperNo, fpro_id, fdept,
	m2mDescription,descript,dailyToolCost,
	pcsProduced,valueAddedSales,totalValueAdd,budgetedToolAllowance, 
	budgetedToolCost,NTLFlag,PartRevInItemMaster


GO
/****** Object:  UserDefinedFunction [dbo].[bfToolCostSummaryLv2]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[bfToolCostSummaryLv2]
(  
@startDateParam DATETIME,
@endDateParam DATETIME
)
RETURNS TABLE 
AS
RETURN
	--query lv 3 
	-- added the current rev for all part numbers
	select jobNumber, partNumber, dbo.invcur.fcpartrev as partRev,pcsProduced from (
		-- query lv 2 
		-- there should be only 1 job with status released but
		-- just to make sure use the max(jomast.fjobno) function
		select max(jomast.fjobno) as jobNumber, partNumber,pcsProduced from (
			-- query lv 1  
			select fpartno as partNumber,sum(fcompqty) as pcsProduced
			from ( 
				select *
				from bfToolCostSummaryLv1(@startDateParam,@endDateParam)
			) a
			group by fpartno
			-- end query lv 1
		) as TotPartQty
		-- outer join to ensure we see the part even if no jobs have been released 
		left outer join jomast
		on TotPartQty.partNumber = jomast.fpartno
		group by partNumber, pcsProduced 
		-- there should be only 1 job per part with status released
		-- but even if they are not released now they were when these
		-- pieces where produced so they need to be on the report
		-- end query lv 2
	) as TotPartQty left outer join dbo.invcur 
		ON TotPartQty.partNumber = dbo.invcur.fcpartno
		--  this will show nulls on report when there is not a current rev
	-- end query lv 3


GO
/****** Object:  UserDefinedFunction [dbo].[bfToolCostSummaryLv3]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[bfToolCostSummaryLv3] (@startDateParam DATETIME,@endDateParam DATETIME) 
  RETURNS Table 
AS 
RETURN
	select jobNumber, partNumber, partRev, description, 
	pcsProduced,valueAddedSales, budgetedToolAllowance
	from
	(
		--query lv 4 
		-- add value added sales and tooling allowance
		select jobNumber, partNumber,partRev, 
		dbo.INMASTX.FCUSRCHR2 as description,pcsProduced, 
			case 
				when dbo.INMASTX.FCUSRCHR1 is null then 0.00
				when Len(dbo.INMASTX.FCUSRCHR1) <= 0 then 0.0
				when REPLACE(dbo.INMASTX.FCUSRCHR1, ' ', '') = '.' then 0.0
				else cast(dbo.INMASTX.FCUSRCHR1 as decimal(18,2))
			end
			as valueAddedSales,
			case
				when dbo.INMASTX.FNUSRCUR1 is null then 0.00
				else cast(dbo.INMASTX.FNUSRCUR1 as decimal(18,2)) 
			end
			as budgetedToolAllowance
		from
		(
			select * 
			from bfToolCostSummaryLv2(@startDateParam,@endDateParam) 
		) as PartRevAdded left outer JOIN 
				dbo.INMASTX ON PartRevAdded.partNumber = dbo.INMASTX.fpartno AND PartRevAdded.partRev = dbo.INMASTX.frev 
		-- end query lv 4
	) lv5


GO
/****** Object:  UserDefinedFunction [dbo].[bfItemQtyIssued]    Script Date: 4/24/2018 7:56:09 AM ******/
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
/****** Object:  UserDefinedFunction [dbo].[bfNoVendorCost]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[bfNoVendorCost](
@startDateParam DATETIME, 
@endDateParam DATETIME 
)
RETURNS table
AS
return
select ttl.itemnumber,description1
from 
(
select distinct itemnumber 
from toolingtranslog 
where unitcost = 0 
and (transtartdatetime >= @startDateParam) and (transtartdatetime <= @endDateParam)
) ttl
left outer join
toolitems ti
on ttl.itemnumber=ti.itemnumber

GO
/****** Object:  UserDefinedFunction [dbo].[bfToolCostSummaryLv1]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[bfToolCostSummaryLv1]
(  
@startDateParam DATETIME,
@endDateParam DATETIME
)
RETURNS TABLE 
AS
RETURN
select * from
(
	select lv6.fdate,lv6.fedatetime,lv6.fempno,lv6.fcompqty,lv6.fstatus,
	lv6.fpartno,lv6.fjob_name,lv6.fjobno,
	lv6.foperno,
	inw.fcpro_id,inw.fdept
	from
	(
		select lv5.fjobno,lv5.foperno,jom.fpartno,jom.fjob_name,
		lv5.fpro_id,lv5.fdate,lv5.fedatetime,lv5.fempno,lv5.fcompqty,lv5.fstatus
		from
		(
			select lv3.fjobno,lv3.foperno,fpro_id,fdate,fedatetime,fempno,fcompqty,fstatus
			from
			(
				--> This is a list of job/operation numbers which we need to tally 
				--> pieces produced. If a labor detail has an operation besides these
				--> ones that means it was for a secondary operation.  We should only 
				--> total the max operation quantities to arrive at the pieces produced.
				--> It has been verified that lower operation ladetail records can have
				--> fcompqty > 0 so this step is needed.
				select lv1.fjobno,lv1.foperno,lv2.fpro_id 
				from jodrtg lv2 
				inner join (
					-->Get rid of lower operation numbers
					select fjobno, max(foperno) as foperno 
					from jodrtg 
					group by fjobno
					having fjobno <> ''
					-- 19383
				) lv1 
				on lv1.fjobno = lv2.fjobno and lv1.foperno = lv2.foperno
				-- 19383
			) lv3
			inner join
			( 
				select fjobno,foperno,DATEADD(dd, 0 , DATEDIFF(DD, 0,  fedatetime)) as fdate,fedatetime,fempno,fcompqty,fstatus
				from ladetail 
				-- status = P is posted H is Hold
				where fstatus = 'P' 
				and fedatetime >= @startDateParam and fedatetime <= @endDateParam 
				and fcompqty <> 0.0 
				--3371
			) lv4
			--> Select only ladetail records of max operation numbers.  We should only 
			--> total the max operation quantities to arrive at the pieces produced.
			on (lv3.fjobno = lv4.fjobno)
			and (lv3.foperno = lv4.foperno)
			--3166  The labor records for lower operation have been removed
		) lv5
		inner join jomast jom 
		on lv5.fjobno = jom.fjobno
	) lv6
	inner join inwork inw 
	on lv6.fpro_id = inw.fcpro_id
	where fdept <> 45 
) lv7
--> delete duplicate records. Don't know why there are a few duplicates, but there are
group by fdate,fedatetime,fempno,fcompqty,fstatus,
fpartno,fjob_name,fjobno,
foperno,fcpro_id,fdept

GO
/****** Object:  UserDefinedFunction [dbo].[bfToolCostSummaryLv4]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[bfToolCostSummaryLv4] (@startDateParam DATETIME,@endDateParam DATETIME) 
  RETURNS Table 
AS 
RETURN
	-- add totalValueAdd and budgetedToolCost
	select jobNumber, partNumber, partRev, description, pcsProduced,  valueAddedSales,
	cast(pcsProduced*valueAddedSales as decimal(18,2)) as totalValueAdd,
	budgetedToolAllowance, cast(pcsProduced*budgetedToolAllowance as decimal(18,2)) as budgetedToolCost 
	from
	(
		select * from  bfToolCostSummaryLv3(@startDateParam,@endDateParam)
	)lv4
GO
/****** Object:  UserDefinedFunction [dbo].[bfToolCostSummaryLv5]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[bfToolCostSummaryLv5] (@startDateParam DATETIME,@endDateParam DATETIME) 
  RETURNS Table 
AS 
RETURN

	select jobNumber, partNumber, partRev, description, pcsProduced, 
	valueAddedSales, totalValueAdd, budgetedToolAllowance, budgetedToolCost, 
	toolItemIssueQty, unitCost,
	cast(toolItemIssueQty*unitCost as decimal(18,2)) as toolItemIssueTotCost  
	from
	(
		-- add tooling records 
		select lv4.jobNumber, lv4.partNumber, lv4.partRev, lv4.description, lv4.pcsProduced, 
		lv4.valueAddedSales, lv4.totalValueAdd, lv4.budgetedToolAllowance, lv4.budgetedToolCost, 
		case 
			when ToolTransLog.qty is null then cast(0.0 as decimal(18,2)) 
			else ToolTransLog.qty
		end 
		as toolItemIssueQty, 
		case 
			when ToolTransLog.unitCost is null then cast(0.0 as decimal(18,2)) 
			else ToolTransLog.unitCost
		end 
		as unitCost 
		from
		(
			select * from  bfToolCostSummaryLv4(@startDateParam,@endDateParam)
		)lv4
		inner join 
		--left outer JOIN
		(select * from dbo.ToolingTransLog
			where dbo.ToolingTransLog.[TranStartDateTime] >= @startDateParam 
			and dbo.ToolingTransLog.[TranStartDateTime] <= @endDateParam ) as ToolTransLog
		ON lv4.partNumber = ToolTransLog.PartNumber 
	)lv5

GO
/****** Object:  UserDefinedFunction [dbo].[bfWorkSumLv1]    Script Date: 4/24/2018 7:56:09 AM ******/
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
/****** Object:  UserDefinedFunction [dbo].[bfWorkSumLv4NLBTC]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--////////////////////////////////////////////////////////
-- bfWorkSumLv4NLBTC
--////////////////////////////////////////////////////////
create FUNCTION [dbo].[bfWorkSumLv4NLBTC]
(  
@startDateParam DATETIME,
@endDateParam DATETIME
)
RETURNS TABLE 
AS
RETURN
	-- ToolLists with no labor or tooling costs
select pd.*
from
(
	select lv1.partNumber
	from
	(
		select tl.partNumber
		from 
		(
			select 	* from bvDistinctPartNumbers
			--530
		) tl
		left outer join
		(
			select partNumber 
			from
			bfWorkSumLv3(@startDateParam,@endDateParam) 
			-- 34 secs
			--622
		) ws
		-- Part Numbers with no labor details records
		on tl.partNumber= ws.partNumber
		where ws.partNumber is null
		--99
		-- 50 seconds 
		-- No Labor 
	) lv1
	inner join 
	(
		select tl.partNumber
		from
		(
			select 	* from bvDistinctPartNumbers
			--530
		) tl
		left outer join
		(
			-- partNumbers with tooling costs
			select distinct partNumber from
			toolingtranslog
			where (tranStartDateTime >= @startDateParam)
			and (tranStartDateTime <= @endDateParam)
			--523
		) ttl
		on
		tl.partNumber=ttl.partNumber
		where ttl.partNumber is null
		-- 25 PartNumbers with no tooling cost
	) lv2
	on lv1.partNumber = lv2.partNumber
	-- 13 Part Numbers with no labor or tooling costs in past 3 years
	-- 50 Part Numbers with no labor or tooling costs in the past year
	-- 1min 10 secs
) lv3
-- add description
inner join
bvPartDescr pd
on lv3.partNumber = pd.partNumber
-- 50 Part Numbers with no labor or tooling costs in the past year



GO
/****** Object:  UserDefinedFunction [dbo].[bfWorkSumLv5NLBTC]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--////////////////////////////////////////////////////////
-- bfWorkSumLv5NLBTC
-- tooling items that have not been issued and no parts have 
-- been produced for there associated partnumbers in specified time
-- period
--////////////////////////////////////////////////////////
create FUNCTION [dbo].[bfWorkSumLv5NLBTC]
(  
@startDateParam DATETIME,
@endDateParam DATETIME
)
RETURNS TABLE 
AS
RETURN
select lv5.*,
case 
	when pni.toolops is null then 'none'
	else pni.toolops
end toolops
from
(
	select lv4.partNumber,lv4.itemNumber,
	case
		when ti.description1 is null then 'none'
		else ti.description1
	end
	as description1,
	case
		when ti.itemclass is null then 'none'
		else ti.itemclass
	end
	as itemclass,
	lv4.plant,
	lv4.binloclist,
	lv4.totqty,
	case
		when ti.cost is null then 0
		else ti.cost
	end
	as unitcost,
	case
		when ti.cost is null then 0
		else lv4.totqty*ti.cost
	end
	as totcost
	from
	(

		select lv3.PartNumber,
		lv3.itemNumber,
		case
			when totqty is null then 0
			else totqty
		end
		as totqty,
		case
			when plant is null then 999
			else plant
		end
		as plant,
		case
			when binloclist is null then 'none'
			else binloclist
		end
		as binloclist
		from
		(
			select lv1.*
			from
			(
				-- part number tooling for parts with no labor or tooling cost
				select otl.partNumber,pni.itemNumber 
				from PnNoLaborToolCost otl
				inner join
				btToolListPartItems pni
				on otl.partNumber=pni.partNumber
				--156
			) lv1
			-- have the tool list items to be deleted
			-- been issued under any other tool list
			left outer join
			(
				-- all tooling items with tooling costs
				select distinct itemNumber from
				toolingtranslog
				where (tranStartDateTime >= @startDateParam)
				and (tranStartDateTime <= @endDateParam)
				--1178
			) lv2
			-- list only those part number tooling items which have
			-- not been issued to any part Number
			on lv1.itemNumber=lv2.itemNumber
			where lv2.itemNumber is null
			--187
		)lv3
		-- list tooling items even if we don't have any in the crib or toolbosses
		left outer join
		-- 1 to many relationship (toolinv items in crib and toolbosses)
		toolinv inv
		on lv3.itemNumber=inv.itemNumber
		-- all tooling items not issued in the crib or toolbosses
		--7636
		--where inv.itemnumber is null
		--10
	)lv4
	-- tooling items that have not been issued and no parts have 
	-- been produced for there associated partnumbers in specified time
	-- period
	left outer join toolitems ti
	on lv4.itemnumber=ti.itemnumber
	--198
	--where ti.itemnumber is null
	--0
)lv5
left outer join 
btToolListPartItems pni
on
lv5.partNumber=pni.partNumber
and lv5.itemNumber=pni.itemNumber


GO
/****** Object:  UserDefinedFunction [dbo].[bfWorkSumLv6NLBTC]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--////////////////////////////////////////////////////////
-- bfWorkSumLv6NLBTC
-- a summary of partnumbers whose tooling items that have 
-- not been issued and no parts have been produced for there 
-- associated partnumbers in specified time period
--////////////////////////////////////////////////////////
create FUNCTION [dbo].[bfWorkSumLv6NLBTC]
(  
@startDateParam DATETIME,
@endDateParam DATETIME
)
RETURNS TABLE 
AS
RETURN
	select pd.*, totcost
	from
	(
		select lv4.partNumber,
		case
			when ws5.totcost is null then 0
			else ws5.totcost
		end as totcost 
		from 
		PnNoLaborToolCost lv4
		left outer join
		(
			select partNumber, sum(totcost) totcost
			from
			bfWorkSumLv5NLBTC(@startDateParam,@endDateParam) 
			group by partNumber
		) ws5
		on lv4.partNumber=ws5.partNumber
	) ws
	inner join
	bvPartDescr pd
	on ws.partNumber=pd.partNumber

GO
/****** Object:  UserDefinedFunction [dbo].[MA_GetMainJobAnalysisByShipDate]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


----------------------------------------------------------------------------------------------
-- MA_GetMainJobAnalysisByShipDate is a tabular function which returns data from the MA_Main_JobAnalysis view
-- based on the passed in from / to ship dates.
-- Sample usage:  select * from dbo.MA_GetMainJobAnalysisByShipDate('2000-01-01', '2020-01-01')
--                select * from dbo.MA_GetMainJobAnalysisByShipDate('2008-01-01', '2008-06-01') where GroupCode = 'Plast'
----------------------------------------------------------------------------------------------
CREATE function [dbo].[MA_GetMainJobAnalysisByShipDate](@fromDate datetime, @toDate datetime) returns table
as
return
	select * 
	from MA_Main_JobAnalysis
	where JobNo in (select substring(shsrce.loc,1,10) -- We are taking the first 10 chars of loc field because it sometimes also stores additional reference information after the job number.
					from shmast 
					join shsrce on fshipno = fcshipno 
					where  shsrce.source = 'JO' and 
						   shsrce.fnshipqty >0 and
						   shmast.ftype = 'SO' and
						   shmast.fshipdate>=@fromDate and shmast.fshipDate<=@toDate) 

GO
/****** Object:  UserDefinedFunction [dbo].[ToolCostSummaryReturnTable]    Script Date: 4/24/2018 7:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ToolCostSummaryReturnTable]
(  
@startDateParam DATETIME,
@endDateParam DATETIME
)
RETURNS TABLE 
AS
RETURN
select top 100 percent jobNumber, partNumber, description,cast(qty as decimal(18,0)) as pcsProduced, 
valueAddedSales, totalValueAdd, toolingAllowance as budgetedToolAllowance, 
budgetedToolCost,
  case 
	when qty = 0 then cast(0.0 as decimal(18,2))
	when totalToolItemIssueCost is null then cast(0.0 as decimal(18,2)) 
    else cast((totalToolItemIssueCost / qty) as decimal(18,2)) 
  end as actualToolAllowance, 
  case
	when totalToolItemIssueCost is null then cast(0.0 as decimal(18,2))
	else totalToolItemIssueCost
-- when actualToolCost = 0 this may mean that the tool boss transactions
-- have not been added to the toolingtranslog in m2m
  end as actualToolCost, 
  case 
	when totalToolItemIssueCost is null then cast(0.0 as decimal(18,2)) 
-- when a budgetedToolCost=0 on this may means that m2m's inventory
-- record, INMASTX.FNUSRCUR1 field, needs updated with the correct tooling allowance
	when (budgetedToolCost = 0) then cast(0.00 as decimal(18,2))
    else cast((totalToolItemIssueCost / budgetedToolCost * 100) as decimal(18,2)) 
  end 
  as budgetedVrsActualPct 
 from
(
	--query lv 7 
	select jobNumber, partNumber, description, qty, partRev, 
	valueAddedSales,totalValueAdd, toolingAllowance, budgetedToolCost, 
	sum(toolItemIssueTotCost) as totalToolItemIssueCost 
	from
	(
		--query lv 6 
		-- add tooling records 
		select totva.jobNumber, totva.partNumber, totva.description, totva.qty, 
		partRev, valueAddedSales, totalValueAdd, toolingAllowance, budgetedToolCost, 
		ToolTransLog.qty as toolItemIssueQty,ToolTransLog.unitCost, 
		cast(ToolTransLog.qty*unitCost as decimal(18,2)) as toolItemIssueTotCost  
		from
		(
			--query lv 5 
			-- add totalValueAdd and budgetedToolCost
			select jobNumber, partNumber, description, qty, partRev, valueAddedSales,
			cast(qty*valueAddedSales as decimal(18,2)) as totalValueAdd,
			toolingAllowance, cast(qty*toolingAllowance as decimal(18,2)) as budgetedToolCost 
			from
			(
				--query lv 4 
				-- add value added sales and tooling allowance
				select jobNumber, partNumber, dbo.INMASTX.FCUSRCHR2 as description, qty, partRev,
				  case 
					when Len(dbo.INMASTX.FCUSRCHR1) <= 0 then 0.0
					else cast(dbo.INMASTX.FCUSRCHR1 as decimal(18,2))
				  end
					as valueAddedSales,
					cast(dbo.INMASTX.FNUSRCUR1 as decimal(18,2))as toolingAllowance
				from
				(
					--query lv 3 
					-- added the current rev for all part numbers
					select jobNumber, partNumber, qty, dbo.invcur.fcpartrev as partRev from (
						-- query lv 2 
						-- there should be only 1 job with status released but
						-- just to make sure use the max(jomast.fjobno) function
						select max(jomast.fjobno) as jobNumber, partNumber,qty from (
							-- query lv 1  
							-- The total parts produced per part stripped off the job number
							select partNumber, sum(hiOpQty) as qty
							from
							(
								-- there is a different job number for each month so
								-- we just lost the job number info at this point
								select jomast.fpartno as partNumber, hiOpQty 
								from 
								(
									-- sum ladetail quantities for hi ops only
									select fjobno, cast(sum(fcompqty) as decimal(18,2)) as hiOpQty
									from 
									(
										-- get hi op ladetail records only
										select ladetail.fjobno,foperno, fcompqty
										from
										(
											--Get rid of lower operation numbers
											select fjobno,max(foperno) as hiop
											from ladetail
											group by fjobno
										) as PartHiOp INNER JOIN ladetail ON PartHiOp.fjobno = ladetail.fjobno and PartHiOp.hiop = ladetail.foperno
										where (ladetail.fdate >= @startDateParam) AND (ladetail.fdate <= @endDateParam) 
									) as HiOpLaDet
									group by fjobno
								) as LaDetJobSum INNER JOIN jomast ON LaDetJobSum.fjobno = jomast.fjobno
							) as TotPartQty
							group by TotPartQty.partNumber
							-- end query lv 1
						) as TotPartQty
						-- outer join to ensure we see the part even if no jobs have been released 
						left outer join jomast
						on TotPartQty.partNumber = jomast.fpartno
						group by partNumber, qty,fstatus,fitype 
						-- there should be only 1 job per part with status released
						having jomast.fstatus = 'RELEASED'
						AND (jomast.fitype = '1') 
						-- end query lv 2
					) as TotPartQty left outer join dbo.invcur 
						ON TotPartQty.partNumber = dbo.invcur.fcpartno
						--  this will show nulls on report when there is not a current rev
					-- end query lv 3
				) as PartRevAdded left outer JOIN 
					 dbo.INMASTX ON PartRevAdded.partNumber = dbo.INMASTX.fpartno AND PartRevAdded.partRev = dbo.INMASTX.frev 
					-- end query lv 4
			) as vasales
			-- end query lv 5
		) as totva left outer JOIN
			(select * from dbo.ToolingTransLog
				where dbo.ToolingTransLog.[TranStartDateTime] >= @startDateParam 
				and dbo.ToolingTransLog.[TranStartDateTime] <= @endDateParam ) as ToolTransLog
			ON totva.partNumber = ToolTransLog.PartNumber 
		-- end query lv 6
	) as translog
	GROUP BY jobNumber, partNumber, description, qty, partRev, valueAddedSales, totalValueAdd,
	toolingAllowance, budgetedToolCost
	-- end query lv 7
) as GroupTransLog
order by partnumber
-- end query lv 8



GO
