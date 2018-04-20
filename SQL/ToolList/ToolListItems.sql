ToolListItems.sql
USE [Busche ToolList]
GO

/****** Object:  Table [dbo].[ToolListItems]    Script Date: 4/19/2018 2:13:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[ToolListItems](
	[originalprocessid] [int] NULL,
	[processid] [int] NULL,
	[partNumber] [nvarchar](50) NULL,
	[itemNumber] [nvarchar](50) NULL,
	[allToolOps] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO
