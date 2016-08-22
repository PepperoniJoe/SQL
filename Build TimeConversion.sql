Print 'Documentation
-----------------------------------------------------------------
--	Build Time Conversion table
--	Description: Run this if the Time Conversion table needs to be recreated.
--
--  Created by:  M.Vernon	|  10/14/2005
--  Modified by:
--
-----------------------------------------------------------------'

PRINT 'Recreate DEVL_LMOS table to build new table'

IF EXISTS(SELECT name 
	        FROM DEVL_LMOS.dbo.sysobjects 
	       WHERE name = N'TimeConversion' 
	         AND type = 'U')
BEGIN
    DROP TABLE DEVL_LMOS.dbo.TimeConversion
END

CREATE TABLE DEVL_LMOS.dbo.TimeConversion (
       [TotalSeconds]  int           NOT NULL, 
       [HH:MM]         char    (5)   NULL, 
       [HH:MM:SS]      char    (8)   NULL, 
       [Hours]         varchar (2)   NULL, 
       [Minutes]       varchar (2)   NULL, 
       [Seconds]       varchar (2)   NULL
        )

-----------------------------------------------------------------
PRINT 'Build "AS400 Time" field'

    DECLARE @ss     AS INT
    DECLARE @mm     AS int
    DECLARE @hh     AS int
    DECLARE @time   AS varchar(6)
    DECLARE @totalsecs    AS INT
    DECLARE @HHMM   AS char (5)
    DECLARE @HHMMSS AS char (8)

    SET     @ss     = 0
    SET     @mm     = 0
    SET     @hh     = 0
    SET     @totalsecs    = 0

WHILE @hh <24
BEGIN
	WHILE @mm < 60
	BEGIN
		WHILE @ss < 60
		BEGIN
		IF len(@mm)=1
			SET @HHMM = rtrim(convert(varchar(2),@hh)) + ':0' + rtrim(convert(varchar(2),@mm))
                ELSE
			SET @HHMM = rtrim(convert(char(2),@hh)) + ':' + rtrim(convert(varchar(2),@mm))
		IF len(@ss)=1
			SET @HHMMSS = rtrim(convert(varchar(5),@hhmm)) + ':0' + rtrim(convert(varchar(2),@ss))
                ELSE
			SET @HHMMSS = rtrim(convert(varchar(5),@hhmm)) + ':' + rtrim(convert(varchar(2),@ss))

		INSERT INTO DEVL_LMOS.dbo.[TimeConversion]
			VALUES (@totalsecs, @hhmm, @hhmmss, @hh, @mm, @ss)
		SET @totalsecs  = @totalsecs + 1
		SET @ss = @ss + 1
		END
	SET @mm = @mm + 1
	SET @ss = 0
	END
SET @hh = @hh + 1
SET @mm = 0
END

-----------------------------------------------------------------
PRINT 'Build LMREAD.dbo.TimeConversion'

	IF EXISTS(SELECT name 
	            FROM LMREAD.dbo.sysobjects 
	           WHERE name = N'TimeConversion' 
	             AND type = 'U')
        BEGIN
   		 DROP TABLE LMREAD.dbo.TimeConversion
	END
		
	SELECT * INTO lmread.dbo.TimeConversion FROM DEVL_LMOS.dbo.TimeConversion
	ORDER BY TotalSeconds 

    CREATE INDEX [Index_TotalSeconds]
        ON lmread.dbo.TimeConversion ([TotalSeconds])

    CREATE INDEX [Index_HH:MM]
        ON lmread.dbo.timeconversion ([HH:MM])

    CREATE INDEX [Index_HH:MM:SS]
        ON lmread.dbo.timeconversion ([HH:MM:SS])

    CREATE INDEX [Index_Hours]
        ON lmread.dbo.timeConversion ([Hours])

    CREATE INDEX [Index_Minutes]
        ON lmread.dbo.timeconversion ([Minutes])

    CREATE INDEX [Index_Seconds]
        ON lmread.dbo.timeconversion ([Seconds])

 --		select * from devl_lmos.dbo.timeconversion order by [TotalSeconds]
--	SELECT * into plalmsql01.devl.dbo.TimeConversion from simsql112.devl_lmos.dbo.timeconversion
