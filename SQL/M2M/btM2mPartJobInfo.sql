btM2mPartJobInfo.sql

USE [m2mdata01]
GO

/****** Object:  Table [dbo].[btM2mPartJobInfo]    Script Date: 4/20/2018 7:23:57 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[btM2mPartJobInfo](
	[partNumber] [char](25) NOT NULL,
	[partRev] [char](3) NULL,
	[maxJobNumber] [char](10) NULL,
	[maxOperNo] [int] NULL,
	[fpro_id] [char](7) NOT NULL,
	[fdept] [char](2) NOT NULL,
	[description] [varchar](40) NULL,
	[valueAddedSales] [numeric](18, 2) NULL,
	[budgetedToolAllowance] [numeric](18, 2) NULL,
	[NTLFlag] [numeric](15, 5) NULL,
	[PartRevInItemMaster] [int] NOT NULL,
	[fstatus] [char](10) NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


