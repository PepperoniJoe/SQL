    SELECT * INTO #mvtemp FROM lmread.dbo.calendar

--    drop table #mvtemp2
     SELECT #mvtemp.busseq
         , Count(#mvtemp.busseq) AS NumberOfDups
      INTO #mvtemp2
      FROM #mvtemp
  GROUP BY #mvtemp.busseq
    HAVING Count(#mvtemp.busseq)>1

--    select * from #mvtemp2

SELECT * into #mvas400 FROM OPENQUERY( AS400PL , 'Select * From MTGLIBP1.CALENDAR where cadtyp = ''HOL'' order by cadate')
--select CAdate, cabusj, busjulianYYYY999, diff= busjulianyyyy999 - cabusj from #mvas400 join lmread.dbo.calendar on cadate = yyyymmdd

--------------------Start here
drop table #mvcalendarold
SELECT * into #mvcalendarold FROM lmread.dbo.calendar
/*
update lmread.dbo.calendar
    set daytype = 'BUS'
from lmread.dbo.calendar
    where YYYYMMDD=20041223 */

drop table #mvcalendar
SELECT * into #mvcalendar FROM lmread.dbo.calendar
select * from #mvcalendar
 
    UPDATE #mvcalendar 
       SET busseq = 0
      FROM #mvcalendar

drop table #mvsub1
select YYYYMMDD, busseq into #mvsub1
    from #mvcalendar where daytype = 'BUS'

    drop table #mvsub2

    SELECT YYYYMMDD, IDENTITY(int, 50001,1) AS Seq#
      INTO #mvsub2
      FROM #mvsub1
  ORDER BY YYYYMMDD

-- select * from #mvsub2

    UPDATE #mvcalendar 
       SET busseq = seq#
      FROM #mvcalendar
    join #mvsub2 on #mvcalendar.YYYYMMDD = #mvsub2.YYYYMMDD

-- select YYYYMMDD, Busseq, daytype from #mvcalendar
    drop table #mvcalendargood
select * into #mvcalendargood from #mvcalendar

    UPDATE #mvcalendar 
       SET busseq = (select max(busseq) from #mvcalendargood 
                        where daytype='BUS' and #mvcalendargood.YYYYMMDD < #mvcalendar.YYYYMMDD)
      FROM #mvcalendar 
    WHERE daytype <> 'BUS'

     update #mvcalendar
        SET busseq = 50000
    from #mvcalendar
    where YYYYMMDD = 19850101

    select a.YYYYMMDD, a.Busseq, b.busseq, dif=a.busseq - b.busseq from #mvcalendar  a
    join lmread.dbo.calendar b
    on a.YYYYMMDD = b.YYYYMMDD
    where a.busseq <> b.busseq
    order by a.YYYYMMDD

    select * from lmread.dbo.calendar where   YYYYMM = 200501
       select YYYYMMDD, busseq, daytype, abbrnameofday from #mvcalendar where daytype = 'HOL' YYYYMM = 200501
    
    select * from lmread.dbo.calendar where daytype='HOL' order by YYYYMMDD

    Update #mvcalendar
       SET busjulianYYYY999 = 0
    where daytype <> 'BUS'

select * from #mvcalendar 

drop table lmread.dbo.calendar
select * into lmread.dbo.calendar from #mvcalendar 

    select YYYYMMDD, busseq, daytype from #mvcalendar where daytype = 'BUS' and  busjulianYYYY999=0

select YYYYMMDD, busseq, daytype, abbrnameofday from lmread.dbo.calendar

 