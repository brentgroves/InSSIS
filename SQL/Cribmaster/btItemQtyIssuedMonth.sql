btItemQtyIssuedMonth.sql

USE [m2mdata01]
GO

/****** Object:  Table [dbo].[btItemQtyIssuedMonth]    Script Date: 4/19/2018 2:47:14 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[btItemQtyIssuedMonth](
	[itemNumber] [nvarchar](32) NULL,
	[lQtyIssued] [int] NULL,
	[rQtyIssued] [int] NULL,
	[qtyIssued] [int] NULL
) ON [PRIMARY]

GO
