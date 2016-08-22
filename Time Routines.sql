/*

        LMREAD.dbo.Time on PLALMSQL01 and SIMSQL112
 
The Time table was set up as an alternative to user-defined
time functions.  
*/

----------------------------------------------------------------
--    Format a time to/from any of these formats.
--    The time format can be easily changed by just changing the field name.
--
--        FIELD NAME       EXAMPLE FORMAT
--        [AS400 Time]     150841
--        [HH:MM]          15:08
--        [HH:MM:SS]       15:08:41
--        [HH:MM AMPM]     3:08 PM 
--        [HH:MM:SS AMPM]  3:08:41 PM 
--        [This Hour]      15
--        [This Minute]    08
--        [This Second]    41
--        [AMPM]           PM
--        SQLTime          3:08PM

--    This converts an AS400 time into a easy-to-read format ([HH:MM AMPM]). 
--    Example AS400 time is 150841.

    SELECT [HH:MM AMPM]    FROM lmread.dbo.[Time] WHERE [AS400 Time] = 150841 -- 3:08 PM 

--    Change the format of the result easily by changing the field name.       RESULT

    SELECT SQLTime         FROM lmread.dbo.[Time] WHERE [AS400 Time] = 150841 -- 3:08PM 
    SELECT [HH:MM]         FROM lmread.dbo.[Time] WHERE [AS400 Time] = 150841 -- 15:08 
    SELECT [HH:MM:SS]      FROM lmread.dbo.[Time] WHERE [AS400 Time] = 150841 -- 15:08:41
    SELECT [HH:MM:SS AMPM] FROM lmread.dbo.[Time] WHERE [AS400 Time] = 150841 -- 3:08:41 PM 


