bvToolListsAssignedPN.sql
USE [Busche ToolList]
GO

/****** Object:  View [dbo].[bvToolListsAssignedPN]    Script Date: 4/19/2018 12:33:15 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create VIEW [dbo].[bvToolListsAssignedPN]
AS
		-- Pick only one part number for each active and approved toollist
		select lv1.Originalprocessid,lv1.processid, 
			customer,partfamily,OperationDescription,descript,descr,subDescript,subDescr,partNumber 
		from
		(
			select * from bvListOfActiveApprovedToolLists
			-- 733  
		) lv1
		inner join
		(
			-- Engineering sometimes adds more than one part number on a tool list
			-- we must pick one and drop the rest.  Tool lists with multiple Part numbers
			-- will show up on the Multi PN Tool List report. 
			select  ProcessID, MAX(PartNumbers) AS PartNumber
			FROM   [ToolList PartNumbers]
			GROUP BY ProcessID
		) lv2
		on lv1.ProcessID = lv2.ProcessID
		-- tool lists with no part numbers assigned have been dropped
		--732

GO
