bpToolItems.sql
USE [Cribmaster]
GO

/****** Object:  StoredProcedure [dbo].[bpToolItems]    Script Date: 4/19/2018 2:05:20 PM ******/
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