/*

        LMREAD.dbo.Calendar on PLALMSQL01 and SIMSQL112
 
The Calendar table was set up as an alternative to user-defined
date functions.  Using the calendar table has many advantages in 
that it can be used for a wide variety of date calculations (some examples below), 
handles bad dates without aborting the code, takes holidays into 
consideration, allows for a wide variety of date formats, and has good
performance. The Calendar table contains one record for each day from Jan 1, 1985
to Dec 31, 2039.
*/

----------------------------------------------------------------
--    Format a date to/from any of these formats.
--    The date format can be easily changed by just changing the field name.
--
--        FIELD NAME       EXAMPLE FORMAT
--        StandardDate     01/04/1985
--        CommonDate       Jan 4, 1985
--        CompactDate      1/4/1985
--        LongDate         January 4, 1985
--        YYYYMMDD         19850104
--        JulianYYYY999    1985004
--        BusJulianYYYY999 1985003
--        SQLDate          1985-01-04 00:00:00

--    This converts an AS400 date into a SQL Date. Example given AS400 date is 19850104.

    SELECT SQLDate          FROM lmread.dbo.calendar WHERE YYYYMMDD = 19850104

--    Change the format of the result easily by changing the field name.            RESULT

    SELECT StandardDate     FROM lmread.dbo.calendar WHERE YYYYMMDD = 19850104 -- 01/04/1985 
    SELECT CommonDate       FROM lmread.dbo.calendar WHERE YYYYMMDD = 19850104 -- Jan 4, 1985
    SELECT LongDate         FROM lmread.dbo.calendar WHERE YYYYMMDD = 19850104 -- January 4, 1985
    SELECT CompactDate      FROM lmread.dbo.calendar WHERE YYYYMMDD = 19850104 -- 1/4/1985
    SELECT JulianYYYY999    FROM lmread.dbo.calendar WHERE YYYYMMDD = 19850104 -- 1985004
    SELECT BusJulianYYYY999 FROM lmread.dbo.calendar WHERE YYYYMMDD = 19850104 -- 1985003

--    Change any date format to any other date format.  These are a few examples:
    SELECT LongDate         FROM lmread.dbo.calendar WHERE CommonDate   = 'Jan 4, 1985'         -- January 4, 1985  
    SELECT YYYYMMDD         FROM lmread.dbo.calendar WHERE SQLDate      = '2005-08-04 00:00:00' -- 19850104
    SELECT BusJulianYYYY999 FROM lmread.dbo.calendar WHERE CompactDate  = '1/4/1985'            -- 1985003
    SELECT SQLDate          FROM lmread.dbo.calendar WHERE StandardDate = '01/04/1985'          -- 1985-01-04 00:00:00
    SELECT StandardDate     FROM lmread.dbo.calendar WHERE SQLDate      = '2005-08-04 00:00:00' -- 01/04/1985

----------------------------------------------------------------
--	The Year, Month, Day of the Month, Day of the Week, Year, ReportMonth 
--  and Day Type (Business, Weekend, Holiday) can be 
--  determined for a given date of any format.  The example is in Compact Date 
--  format but the date can be in any of the provided formats including 
--  SQL Date, AS400, Long Date, Standard Date, Julian Date, etc.
--
--  FIELD NAME       EXAMPLE FORMAT
--  NameOfDay        FRIDAY
--  AbbrNameOfDay    FRI
--  ThisYear         1985
--  ThisMonth        1
--  ThisDay          4
--  DayType          BUS      (BUS= Business, W/E= Weekend, HOL=CHL Holiday)
--  MonthName        January
--  MonthShortName   JAN
--  ReportMonth      January 1985
    
--  Some examples:                                                                              
    SELECT NameofDay      FROM lmread.dbo.calendar WHERE CompactDate = '1/4/1985' -- FRIDAY    
    SELECT AbbrNameofDay  FROM lmread.dbo.calendar WHERE CompactDate = '1/4/1985' -- FRI
    SELECT ThisYear       FROM lmread.dbo.calendar WHERE CompactDate = '1/4/1985' -- 1985
    SELECT ThisMonth      FROM lmread.dbo.calendar WHERE CompactDate = '1/4/1985' -- 1
    SELECT ThisDay        FROM lmread.dbo.calendar WHERE CompactDate = '1/4/1985' -- 4
    SELECT DayType        FROM lmread.dbo.calendar WHERE CompactDate = '1/4/1985' -- BUS 
    SELECT MonthName      FROM lmread.dbo.calendar WHERE CompactDate = '1/4/1985' -- January
    SELECT MonthShortName FROM lmread.dbo.calendar WHERE CompactDate = '1/4/1985' -- JAN 
    SELECT ReportMonth    FROM lmread.dbo.calendar WHERE CompactDate = '1/4/1985' -- January 1985

----------------------------------------------------------------
--	A variety of Day calculations can be done easily using 
--  the calendar table.  Another advantage is that Countrywide Holidays are taken
--  into consideration when using the table for Business Day calcuations.
--
--  Some of the types of information that can be determined using the calendar table: 
--    The prior business day for any given date
--    The number of days between two dates 
--    The number of business days between two dates excluding CHL holidays
--    The next holiday
--    A date that is X number of business days from a given date excluding any holidays
--    The type of day (weekend, holiday or business day) for a given date
--    The 1st Tuesday, 2nd Monday, 1st Saturday, 3rd Wed, etc. of a month
--    The first business day of a year
--
--    A few examples are provided below. 

--	Determine the Previous business day based on a date. Notice that this example uses the
--  Tuesday after Labor Day and the result returns the prior business day which was Friday.

    Select PreviousBusDay FROM lmread.dbo.calendar WHERE YYYYMMDD = 20050906  -- 20050902


--  Determine the number of days for any two given dates. Notice that the two given dates 
--  do not have to be in the same date format.

    SELECT COUNT(*) FROM lmread.dbo.calendar WHERE YYYYMMDD >= 19850104 AND SQLDate < getdate()


--  Determine the number of BUSINESS days for any two given dates. Holidays are excluded.

    SELECT COUNT(*) FROM lmread.dbo.calendar WHERE YYYYMMDD >= 19850104 AND SQLDate < getdate()
    AND DayType = 'BUS'


--  Determine the first BUSINESS day for the month of a given date. This can be written several
--  ways.  Example given date = 19850104.

    SELECT MIN(SQLDate) FROM lmread.dbo.calendar
    WHERE    DayType = 'BUS'
    AND      ReportMonth = (SELECT ReportMonth FROM lmread.dbo.calendar WHERE YYYYMMDD=19850104)
                            -- 1985-01-02 00:00:00


--  Determine the first Monday for the month of a given date that is a business day
--  and not a holiday. This can be written several ways.  

    SELECT MIN(SQLDate) FROM lmread.dbo.calendar
    WHERE    DayType = 'BUS' and AbbrNameofDay = 'MON'
    AND      ReportMonth = (SELECT ReportMonth FROM lmread.dbo.calendar WHERE YYYYMMDD=19850104)
                            -- 1985-01-07 00:00:00

--  Determine the 2nd Tuesday for a given month. This can be written several ways. 
--  Example given month = 'January 1985'  

    SELECT TOP 2 SQLDate INTO #temp FROM lmread.dbo.calendar
                WHERE    AbbrNameofDay = 'TUE'
                AND      ReportMonth   = 'January 1985'
    SELECT MAX(SQLDate) FROM #temp        -- 1985-01-08 00:00:00


----------------------------------------------------------------
--	For any given date, the first day of the month,
--  the last day of the month, the first day of the prior month and the
--  last day of the prior month can be determined. The Time on the month-end
--  dates are at the end of the day so that date ranges can be done easily.
--
--    FIELD NAME               FORMAT
--    ReportMonth              January 1985
--    ReportMonthBegin         1985-01-01 00:00:00
--    ReportMonthEnd           1985-01-31 23:59:00
--    PreviousReportMonthBegin 1984-12-01 00:00:00
--    PreviousReportMonthEnd   1984-12-31 23:59:00

--  The example uses a given date in standard date format.
    SELECT ReportMonth              FROM lmread.dbo.calendar WHERE StandardDate = '01/04/1985' -- January 1985     
    SELECT ReportMonthBegin         FROM lmread.dbo.calendar WHERE StandardDate = '01/04/1985' -- 1985-01-01 00:00:00 
    SELECT ReportMonthEnd           FROM lmread.dbo.calendar WHERE StandardDate = '01/04/1985' -- 1985-01-31 23:59:00
    SELECT PreviousReportMonthBegin FROM lmread.dbo.calendar WHERE StandardDate = '01/04/1985' -- 1984-12-01 00:00:00
    SELECT PreviousReportMonthEnd   FROM lmread.dbo.calendar WHERE StandardDate = '01/04/1985' -- 1984-12-31 23:59:00

