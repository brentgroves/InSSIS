btItemIssued.sql
USE [m2mdata01]
GO

/****** Object:  Table [dbo].[btItemIssued]    Script Date: 4/19/2018 2:40:52 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[btItemIssued](
	[newItemNumber] [nvarchar](32) NULL,
	[rwkItemNumber] [nvarchar](33) NULL,
	[newIssuedTotQty] [int] NULL,
	[newIssuedTotCost] [numeric](38, 4) NULL,
	[rwkIssuedTotQty] [int] NULL,
	[rwkIssuedTotCost] [numeric](38, 4) NULL,
	[issuedTotQty] [int] NULL,
	[issuedTotCost] [numeric](38, 4) NULL,
	[itemPartIssuedList] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO
