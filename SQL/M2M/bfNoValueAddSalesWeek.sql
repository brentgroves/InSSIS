bfNoValueAddSalesWeek.sql

USE [m2mdata01]
GO

/****** Object:  UserDefinedFunction [dbo].[bfNoValueAddSalesWeek]    Script Date: 4/20/2018 7:30:43 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create function [dbo].[bfNoValueAddSalesWeek]()
  RETURNS @RetTable Table 
    (jobNumber char(10), 
     partNumber char(25), 
	 partRev char(3),
     description varchar(40),
	 pcsProduced int,
	 valueAddedSales decimal(18,2)
	  )  
AS 
begin
Declare @startDateParam DATETIME 
Declare @endDateParam DATETIME 
set @startDateParam = DateAdd(week, -1, GetDate())
set @endDateParam = GetDate()

insert into @RetTable select * from bfNoValueAddSales (@startDateParam,@endDateParam) 
RETURN
end

GO

