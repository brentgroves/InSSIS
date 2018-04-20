btDistinctToolLists.sql
USE [m2mdata01]
GO

/****** Object:  Table [dbo].[btDistinctToolLists]    Script Date: 4/19/2018 12:39:10 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[btDistinctToolLists](
	[OriginalProcessId] [int] NOT NULL,
	[ProcessId] [int] NOT NULL,
	[Customer] [nvarchar](50) NULL,
	[PartFamily] [nvarchar](50) NULL,
	[OperationDescription] [nvarchar](250) NULL,
	[PartNumber] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](50) NOT NULL,
	[CustPartFamily] [nvarchar](50) NOT NULL
) ON [PRIMARY]

GO


