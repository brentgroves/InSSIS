VToolInv.sql

USE [Cribmaster]
GO

/****** Object:  Table [dbo].[toolinv]    Script Date: 4/19/2018 11:42:35 AM ******/
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