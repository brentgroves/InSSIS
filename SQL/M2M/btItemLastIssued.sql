btItemLastIssued.sql
USE [m2mdata01]
GO

/****** Object:  Table [dbo].[btItemLastIssued]    Script Date: 4/19/2018 2:38:28 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[btItemLastIssued](
	[itemNumber] [nvarchar](32) NULL,
	[lastIssued] [smalldatetime] NULL
) ON [PRIMARY]

GO
