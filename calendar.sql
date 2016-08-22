
-------------------------------------------------------------
--	Determine the Current Report Month
--
DECLARE @reportmonth varchar(15)
SET @reportmonth = (Select distinct ReportMonth
	from lmread.dbo.calendar
	where 	thismonth = datepart(mm,getdate()-1)
		and thisyear = datepart(yyyy,getdate()-1))

--	select @reportmonth reportmonth

----------------------------------------------------------
-- Assign Date Variables
--

Declare @MonthBeginDate 	as int
--Declare @MonthEndDate		as int
Declare @MonthBeginDateSQL 	as smalldatetime
--Declare @MonthEndDateSQL	as smalldatetime

Set @monthbegindate = (datepart(yyyy,getdate()-1) * 10000)
			+ (datepart(mm,getdate()-1)* 100) + 01
select @monthbegindate begindate
Set @monthenddate = (datepart(yyyy,getdate()-1) * 10000)
		+ (datepart(mm,getdate()-1)* 100) + 99
select @monthenddate enddate
Set @monthbegindatesql = '20040901'
--Set @monthenddatesql = '20041101'

declare @calcdate as varchar
set @calcdate = 2004 + '-' + thismonth + '-01'
select @calcdate calcdate
----------------------------------------------------------
--Create begin month date
															
UPDATE lmread.dbo.calendar 
	SET lmread.dbo.calendar.reportmonthbegin = 
	convert(varchar(4),thisyear) + '-' 
	+ convert (varchar(4),thismonth) + '-01'
	
----------------------------------------------------------
--Create end month date
select thisyear, thismonth, max(YYYYMMDD) as maxdate 
	into #tempdate
	from lmread.dbo.calendar
	group by thisyear, thismonth
select * from #tempdate

UPDATE lmread.dbo.calendar
	SET lmread.dbo.calendar.reportmonthend = 
	convert(varchar(4),lmread.dbo.calendar.thisyear) + '-' 
	+ convert (varchar(2),lmread.dbo.calendar.thismonth) + '-' 
	+ convert(varchar(2),right(#tempdate.maxdate,2))
	+ ' 23:59:00'
	FROM lmread.dbo.calendar JOIN #tempdate
	on (lmread.dbo.calendar.thisyear = #tempdate.thisyear)
	and (lmread.dbo.calendar.thismonth = #tempdate.thismonth)
	
select * from devl.dbo.calendar2

insert into devl.dbo.calendar
	select cadate 			as YYYYMMDD,
		caJULI 			as JulianYYYY999,
		cabusj			as busjulianyyyy999,
		caname			as nameofday,
		caday			as abbrnameofday,
		cadtyp			as daytype,
		left(cadate,4)		as thisyear,
		left(right(cadate,4),2) as thismonth,
		right(cadate,2)		as thisday,
		left(right(cadate,4),2) 
			+ '/' 
			+ right(cadate,2)
			+ '/'
			+ left(cadate,4)as standarddate,
		'          '		as monthname,
		'   '			as monthshortname,
		'                    ' 	as reportmonth,
		caiso			as sqldate,
		caiso			as reportmonthbegin,
		caiso			as reportmonthend
		from devl.dbo.calendar2
		where cadate < 20030101
--			select * from devl.dbo.calendar	order by yyyymmdd	

UPDATE devl.dbo.calendar
	SET devl.dbo.calendar.monthname = lmread.dbo.calendar.monthname
	FROM lmread.dbo.calendar 
	where devl.dbo.calendar.thismonth = lmread.dbo.calendar.thismonth

UPDATE devl.dbo.calendar
	SET devl.dbo.calendar.monthshortname = lmread.dbo.calendar.monthshortname
	FROM lmread.dbo.calendar 
	where devl.dbo.calendar.thismonth = lmread.dbo.calendar.thismonth

UPDATE devl.dbo.calendar
	SET devl.dbo.calendar.reportmonth = devl.dbo.calendar.monthname + ' ' +
					convert(varchar(4),devl.dbo.calendar.thisyear)
UPDATE devl.dbo.calendar 
	SET devl.dbo.calendar.reportmonthbegin = 
	convert(varchar(4),thisyear) + '-' 
	+ convert (varchar(4),thismonth) + '-01'

select * from devl.dbo.calendar order by YYYYMMDD

--Create end month date
select thisyear, thismonth, max(YYYYMMDD) as maxdate 
	into #tempdate
	from devl.dbo.calendar
	group by thisyear, thismonth
select * from #tempdate

UPDATE devl.dbo.calendar
	SET devl.dbo.calendar.reportmonthend = 
	convert(varchar(4),devl.dbo.calendar.thisyear) + '-' 
	+ convert (varchar(2),devl.dbo.calendar.thismonth) + '-' 
	+ convert(varchar(2),right(#tempdate.maxdate,2))
	+ ' 23:59:00'
	FROM devl.dbo.calendar JOIN #tempdate
	on (devl.dbo.calendar.thisyear = #tempdate.thisyear)
	and (devl.dbo.calendar.thismonth = #tempdate.thismonth)

--drop table lmread.dbo.calendar

--select * into lmread.dbo.calendar from devl.dbo.calendar

select * from lmread.dbo.calendar order by YYYYMMDD

-- compact date

UPDATE lmread.dbo.calendar
	SET CompactDate = 
 	convert(varchar(2),thismonth) 
	+ '/' 
	+ Convert(varchar(2),thisday)
	+ '/' 
	+ convert(varchar(4),thisyear) 
	
select compactdate as "M/D/YYYY" into #temp001 from lmread.dbo.calendar
select [m/d/yyyy] from #temp001
select * from #temp001

---------------------------------------------------------------------------------
PRINT ' Create Previous Business Day'

    SELECT *
         , PreviousBusDay = (Select max(sqldate) as sqldate 
                             from lmread.dbo.calendar as b
                            where daytype = 'BUS' 
                              and b.sqldate < a.sqldate)
      INTO #mvtemp01
      FROM lmread.dbo.calendar as a

-------------------------------------------------------------------------------
PRINT '  Create DD, MM and YY fields '
 
    UPDATE devl.dbo.calendar        -- YY
       SET YY = right(thisyear,2)
      FROM devl.dbo.calendar

    UPDATE devl.dbo.calendar        -- MM
       SET MM = left(standarddate,2)
      FROM devl.dbo.calendar

    UPDATE devl.dbo.calendar        -- DD
       SET DD = substring(standarddate,4,2)
      FROM devl.dbo.calendar

-------------------------------------------------------------------------------
PRINT '  Create YYYY-MM-DD date'
 
    UPDATE devl.dbo.calendar        -- YYYY-MM-DD
       SET [YYYY-MM-DD] = left(thisyear,4) + '-' + MM + '-' + DD
      FROM devl.dbo.calendar
 
--            select * from devl.dbo.calendar
-------------------------------------------------------------------------------
PRINT '  Get Day of Year'
 
   UPDATE devl.dbo.calendar
      SET DayOfYear = datepart(dy,sqldate) 
     FROM devl.dbo.calendar
 
-------------------------------------------------------------------------------
PRINT '  Get Weekday'
 
   UPDATE devl.dbo.calendar
      SET WeekDay = datepart(dw,sqldate) 
     FROM devl.dbo.calendar  

--            select * from devl.dbo.calendar
-------------------------------------------------------------------------------
PRINT '  Get Week'
 
   UPDATE devl.dbo.calendar
      SET Week = datepart(ww,sqldate) 
     FROM devl.dbo.calendar  

--            select * from devl.dbo.calendar

-------------------------------------------------------------------------------
PRINT '  Get Quarter'
 
   UPDATE devl.dbo.calendar
      SET Quarter = datepart(qq,sqldate) 
     FROM devl.dbo.calendar  

--            select * from devl.dbo.calendar

-------------------------------------------------------------------------------
PRINT '  Get YYYYMM'
 
   UPDATE devl.dbo.calendar
      SET YYYYMM = left(YYYYMMDD, 6) 
     FROM devl.dbo.calendar  

--            select * from devl.dbo.Calendar order by yyyymmdd

--    Creates a seq# 
drop table devl.[CFC\MVERNON].NEWTABLE
SELECT *, IDENTITY(int, 1,1) AS ID_Num
INTO NEWTABLE
FROM lmread.dbo.calendar
order by YYYYMMDD

--        select * into Seq from devl.dbo.seq

-------------------------------------------------------------------------------
PRINT '  Update MonthBegin_YYYYMMDD'

   UPDATE devl.dbo.calendar
      SET MonthBegin_YYYYMMDD = (SELECT a.YYYYMMDD 
                                   FROM LMRead.dbo.Calendar a
                                  WHERE a.sqldate = b.reportmonthbegin) 
     FROM devl.dbo.calendar b 
/*
drop table devl.dbo.calendar
select * into devl.dbo.calendar from lmread.dbo.calendar*/
--        select * from devl.dbo.calendar
-------------------------------------------------------------------------------
PRINT '  Update MonthEnd_YYYYMMDD'
   UPDATE devl.dbo.calendar
      SET MonthEnd_YYYYMMDD   = (SELECT a.YYYYMMDD 
                                   FROM LMRead.dbo.Calendar a
                                  WHERE left(a.sqldate,11) = left(b.reportmonthend,11)) 
     FROM devl.dbo.calendar b 
-------------------------------------------------------------------------------
PRINT '  Update PreviousMonthBegin_YYYYMMDD'

   UPDATE devl.dbo.calendar
      SET PreviousMonthBegin_YYYYMMDD   = (SELECT a.YYYYMMDD 
                                   FROM LMRead.dbo.Calendar a
                                  WHERE left(a.sqldate,11) = left(b.previousreportmonthbegin,11)) 
     FROM devl.dbo.calendar b 

 UPDATE lmread.dbo.calendar
      SET PreviousMonthBegin_YYYYMMDD   = 19841201
     FROM lmread.dbo.calendar
    where PreviousMonthBegin_YYYYMMDD is null
-------------------------------------------------------------------------------
PRINT '  Update PreviousMonthEnd_YYYYMMDD'

   UPDATE devl.dbo.calendar
      SET PreviousMonthEnd_YYYYMMDD   = (SELECT a.YYYYMMDD 
                                           FROM LMRead.dbo.Calendar a
                                          WHERE left(a.sqldate,11) = left(b.previousreportmonthend,11)) 
     FROM devl.dbo.calendar b 

 UPDATE lmread.dbo.calendar
      SET PreviousMonthEnd_YYYYMMDD   = 19841231
     FROM lmread.dbo.calendar
    where PreviousMonthEnd_YYYYMMDD is null
