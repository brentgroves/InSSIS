btDistinctToolLists.sql
USE [Busche ToolList]
GO

/****** Object:  Table [dbo].[btDistinctToolLists]    Script Date: 4/19/2018 12:55:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[btDistinctToolLists](
	[OriginalProcessId] [int] NULL,
	[ProcessId] [int] NULL,
	[Customer] [nvarchar](50) NULL,
	[PartFamily] [nvarchar](50) NULL,
	[OperationDescription] [nvarchar](250) NULL,
	[PartNumber] [nvarchar](50) NULL,
	[Description] [nvarchar](356) NULL,
	[CustPartFamily] [nvarchar](103) NULL
) ON [PRIMARY]

GO
