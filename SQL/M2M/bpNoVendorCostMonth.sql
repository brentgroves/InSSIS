bpNoVendorCostMonth.sql

USE [m2mdata01]
GO

/****** Object:  StoredProcedure [dbo].[bpNoVendorCostMonth]    Script Date: 4/20/2018 7:42:39 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[bpNoVendorCostMonth]
AS
	SET NOCOUNT ON
	IF
	OBJECT_ID('btNoVendorCostMonth') IS NOT NULL
		DROP TABLE btNoVendorCostMonth

	Declare @startDateParam DATETIME
	Declare @endDateParam DATETIME
	set @startDateParam = DATEADD (month,-1, GETDATE())
	set @endDateParam = GETDATE()
	select * 
	into btNoVendorCostMonth
	from  
	bfNoVendorCost(@startDateParam,@endDateParam)
	order by itemNumber

GO

