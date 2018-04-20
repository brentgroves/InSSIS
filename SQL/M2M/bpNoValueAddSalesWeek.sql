bpNoValueAddSalesWeek.sql

USE [m2mdata01]
GO

/****** Object:  StoredProcedure [dbo].[bpNoValueAddSalesWeek]    Script Date: 4/20/2018 7:27:33 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[bpNoValueAddSalesWeek] 
AS
BEGIN
	SET NOCOUNT ON
	IF
	OBJECT_ID('btNoValueAddSalesWeek') IS NOT NULL
		DROP TABLE btNoValueAddSalesWeek

	select * 
	into btNoValueAddSalesWeek
	from 
	bfNoValueAddSalesWeek() 

end

GO
