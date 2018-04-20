bpOpenGenPO.sql
USE [m2mdata01]
GO

/****** Object:  StoredProcedure [dbo].[bpOpenGenPO]    Script Date: 4/20/2018 8:35:08 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--/////////////////////////////////////////////////////////////////////////
-- Generates the btOpenGenPO table
-- contains open po created by Ashley Cribmaster PO program
-- GOES IN M2M
--////////////////////////////////////////////////////////////////////////
create PROCEDURE [dbo].[bpOpenGenPO] 
AS
BEGIN
IF
OBJECT_ID('btOpenGenPO') IS NOT NULL
	DROP TABLE btOpenGenPO
SELECT [fcompany]
      ,[fpono]
      ,[fstatus]
      ,[fvendno]
      ,[fbuyer]
      ,[fchangeby]
	  ,[forddate]
      ,[fcngdate]
into btOpenGenPO
  FROM [dbo].[pomast]
  where fbuyer = 'CM'
  and fstatus = 'OPEN'
and forddate > '2017-01-01'
END

GO