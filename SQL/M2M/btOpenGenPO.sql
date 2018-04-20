btOpenGenPO.sql
USE [m2mdata01]
GO

/****** Object:  Table [dbo].[btOpenGenPO]    Script Date: 4/20/2018 8:36:21 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[btOpenGenPO](
	[fcompany] [varchar](35) NOT NULL,
	[fpono] [char](6) NOT NULL,
	[fstatus] [char](20) NOT NULL,
	[fvendno] [char](6) NOT NULL,
	[fbuyer] [char](3) NOT NULL,
	[fchangeby] [char](25) NOT NULL,
	[forddate] [datetime] NOT NULL,
	[fcngdate] [datetime] NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

