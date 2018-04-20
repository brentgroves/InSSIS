btObsToolListItems.sql

USE [Busche ToolList]
GO

/****** Object:  Table [dbo].[btObsToolListItems]    Script Date: 4/19/2018 2:21:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[btObsToolListItems](
	[itemNumber] [nvarchar](50) NULL,
	[opDescList] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

