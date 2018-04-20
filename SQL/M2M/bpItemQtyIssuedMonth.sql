bpItemQtyIssuedMonth.sql
USE [m2mdata01]
GO

/****** Object:  StoredProcedure [dbo].[bpItemQtyIssuedMonth]    Script Date: 4/19/2018 2:45:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--///////////////////////////////////////////////////////////////////////////////////
-- Determines item quantities issued within the last month
--///////////////////////////////////////////////////////////////////////////////////
create PROCEDURE [dbo].[bpItemQtyIssuedMonth] 
AS
BEGIN
	SET NOCOUNT ON
	Declare @startDateParam DATETIME
	Declare @endDateParam DATETIME
	set @startDateParam = DATEADD (month ,-1, GETDATE())
	set @endDateParam = GETDATE()
	IF
	OBJECT_ID('btItemQtyIssuedMonth') IS NOT NULL
		DROP TABLE btItemQtyIssuedMonth

	select * 
	into btItemQtyIssuedMonth 
	from 
	bfItemQtyIssued(@startDateParam,@endDateParam)
end

GO