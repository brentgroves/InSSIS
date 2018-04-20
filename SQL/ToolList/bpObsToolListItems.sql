bpObsToolListItems.sql
USE [Busche ToolList]
GO

/****** Object:  StoredProcedure [dbo].[bpObsToolListItems]    Script Date: 4/19/2018 2:18:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-------------------------------------------------
-- Obsolete ToolList items,misc,and fixture detail
-- grouped by item number 
-------------------------------------------------
create PROCEDURE [dbo].[bpObsToolListItems] 
AS
BEGIN
	SET NOCOUNT ON
IF
OBJECT_ID('dbo.btObsToolListItems') IS NOT NULL
	DROP TABLE btObsToolListItems
IF
OBJECT_ID('tempdb.dbo.#btObsOpDesc') IS NOT NULL
	DROP TABLE #btObsOpDesc

DECLARE
      @opDescList VARCHAR(max)

select 
	itemNumber,tlDescription,
	opDescription,tooldescription
    , RowNum = ROW_NUMBER() OVER (PARTITION BY itemNumber ORDER BY 1/0)
    , opDescList = CAST(NULL AS VARCHAR(max))
into #btObsOpDesc
from bvObsToolListItemsLv1
--12 sec



UPDATE #btObsOpDesc
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
into btObsToolListItems
from #btObsOpDesc
GROUP BY itemNumber 
end


GO
