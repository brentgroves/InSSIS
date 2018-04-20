bfToolBossItemsInPlant.sql
USE [Busche ToolList]
GO

/****** Object:  UserDefinedFunction [dbo].[bfToolBossItemsInPlant]    Script Date: 4/19/2018 12:51:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create function [dbo].[bfToolBossItemsInPlant]
(  
 @plant int
)
RETURNS TABLE 
AS
RETURN
select * from bvToolBossItemsInPlants
where plant = @plant

GO
