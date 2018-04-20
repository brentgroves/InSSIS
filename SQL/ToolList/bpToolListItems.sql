bpToolListItems.sql
USE [Busche ToolList]
GO

/****** Object:  StoredProcedure [dbo].[bpToolListItems]    Script Date: 4/19/2018 2:12:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-------------------------------------------------
-- Active ToolList items,misc,and fixture detail
-- grouped by item number 
-------------------------------------------------
create PROCEDURE [dbo].[bpToolListItems] 
AS
BEGIN
	SET NOCOUNT ON
IF
OBJECT_ID('dbo.btToolListItems') IS NOT NULL
	DROP TABLE btToolListItems
IF
OBJECT_ID('tempdb.dbo.#btOpDesc') IS NOT NULL
	DROP TABLE #btOpDesc

DECLARE
      @opDescList VARCHAR(max)

select 
	itemNumber,tlDescription,
	opDescription,tooldescription
    , RowNum = ROW_NUMBER() OVER (PARTITION BY itemNumber ORDER BY 1/0)
    , opDescList = CAST(NULL AS VARCHAR(max))
into #btOpDesc
from bvToolListItemsLv1
--12 sec


UPDATE #btOpDesc
SET 
      @opDescList = opDescList =
        CASE WHEN RowNum = 1 
            THEN tlDescription + ', ' + opDescription + ', '  + toolDescription
            ELSE @opDescList + '<br>' + tlDescription + ', ' + opDescription + ', '  + toolDescription 
        END

-- 14 sec

select 
      itemNumber
    , opDescList = MAX(opDescList) 
into btToolListItems
from #btOpDesc
GROUP BY itemNumber 
end

GO