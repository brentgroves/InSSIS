toolinv.sql

USE [Cribmaster]
GO

/****** Object:  Table [dbo].[toolinv]    Script Date: 4/19/2018 11:42:35 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[toolinv](
	[itemNumber] [nvarchar](12) NOT NULL,
	[binlocList] [nvarchar](max) NULL,
	[totqty] [int] NULL,
	[plant] [nvarchar](5) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
