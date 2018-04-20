btNoValueAddSalesWeek.sql

USE [m2mdata01]
GO

/****** Object:  Table [dbo].[btNoValueAddSalesWeek]    Script Date: 4/20/2018 7:28:39 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[btNoValueAddSalesWeek](
	[jobNumber] [char](10) NULL,
	[partNumber] [char](25) NULL,
	[partRev] [char](3) NULL,
	[description] [varchar](40) NULL,
	[pcsProduced] [int] NULL,
	[valueAddedSales] [decimal](18, 2) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

