btToolListPartItems.sql
USE [Busche ToolList]
GO

/****** Object:  Table [dbo].[btToolListPartItems]    Script Date: 4/19/2018 2:30:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[btToolListPartItems](
	[partNumber] [nvarchar](50) NULL,
	[itemNumber] [nvarchar](50) NULL,
	[itemsPerPart] [numeric](38, 27) NULL,
	[toolOps] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO
