bfActiveJobNoToolListWeek.sql
USE [m2mdata01]
GO

/****** Object:  UserDefinedFunction [dbo].[bfActiveJobNoToolListWeek]    Script Date: 4/20/2018 7:18:54 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create function [dbo].[bfActiveJobNoToolListWeek](
)
  RETURNS @ActiveJobNoToolList Table 
    (jobNumber char(10), 
     partNumber char(25), 
     description varchar(40),
	 qty numeric(15,5)
	  )  
AS 
begin
	Declare @startDateParam DATETIME 
	Declare @endDateParam DATETIME 
	set @startDateParam = DateAdd(week, -1, GetDate())
	set @endDateParam = GetDate()
	insert into @ActiveJobNoToolList select * from bfActiveJobNoToolList(@startDateParam,@endDateParam) 
	RETURN 
end

GO
