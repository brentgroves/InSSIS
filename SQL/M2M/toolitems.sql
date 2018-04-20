toolitems.sql
USE [m2mdata01]
GO

/****** Object:  Table [dbo].[toolitems]    Script Date: 4/19/2018 11:45:16 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[toolitems](
	[itemnumber] [varchar](12) NOT NULL,
	[description1] [varchar](50) NULL,
	[itemclass] [varchar](15) NOT NULL,
	[UDFGLOBALTOOL] [varchar](20) NOT NULL,
	[cost] [numeric](19, 4) NOT NULL
) ON [PRIMARY]

GO