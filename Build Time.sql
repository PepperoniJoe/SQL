PRINT 'Documentation
-----------------------------------------------------------------
--	Build Time table
--	Description: Run this if the Time table needs to be recreated.
--
--  Created by:  M.Vernon   |  2/22/2005
--  Modified by: M.Vernon   |  5/11/2005 Add Indexes
--  Modified by: M.Vernon   |  7/22/2005 Added AMPM field
--  Modified by: M.Vernon   |  7/22/2005 Added SQLTime field
--  Modified by: M.Vernon   | 10/14/2005 Added Seq for time diff calculations
-----------------------------------------------------------------'

PRINT 'Recreate DEVL_LMOS table to build new table'

IF EXISTS(SELECT name 
	        FROM DEVL_LMOS.dbo.sysobjects 
	       WHERE name = N'Time' 
	         AND type = 'U')
BEGIN
    DROP TABLE DEVL_LMOS.dbo.Time
END

CREATE TABLE DEVL_LMOS.dbo.Time (
       [AS400 Time]    decimal (6,0) NOT NULL, 
       [HH:MM]         char    (5)   NULL, 
       [HH:MM:SS]      char    (8)   NULL, 
       [HH:MM AMPM]    char    (8)   NULL, 
       [HH:MM:SS AMPM] char    (11)  NULL, 
       [This Hour]     varchar (2)   NULL, 
       [This Minute]   varchar (2)   NULL, 
       [This Second]   varchar (2)   NULL,
       [AMPM]          char    (2)   NULL,
       [SQLTime]       char    (7)   NULL,
       [Seq]           int           NOT NULL
        )

-----------------------------------------------------------------
PRINT 'Build "AS400 Time" field'

    DECLARE @ss     AS INT
    DECLARE @mm     AS int
    DECLARE @hh     AS int
    DECLARE @time   AS varchar(6)
    DECLARE @seq    AS INT

    SET     @ss     = 0
    SET     @ss     = 0
    SET     @mm     = 0
    SET     @hh     = 0
    SET     @seq    = 0

WHILE @hh <24
BEGIN
	WHILE @mm < 60
	BEGIN
		WHILE @ss < 60
		BEGIN
		SET @time = (@hh * 10000) + (@mm * 100) + @ss
		SET @seq  = @seq + 1
		INSERT INTO DEVL_LMOS.dbo.[Time]
			VALUES (@time, null, null, null, null, null, null, null, null, null, @seq)
		SET @ss = @ss + 1
		END
	SET @mm = @mm + 1
	SET @ss = 0
	END
SET @hh = @hh + 1
SET @mm = 0
END
-----------------------------------------------------------------
PRINT 'Build [This Second] field'

    UPDATE DEVL_LMOS.dbo.time
	   SET DEVL_LMOS.dbo.time.[This Second] = RIGHT(CONVERT(varchar(6),[as400 time]),2)

-----------------------------------------------------------------
PRINT 'Build [This Minute] field'

    UPDATE DEVL_LMOS.dbo.time
	   SET DEVL_LMOS.dbo.time.[This Minute] = left(right(([as400 Time]),4),2)
	 WHERE len([as400 time])> 3

    UPDATE DEVL_LMOS.dbo.time
	   SET DEVL_LMOS.dbo.time.[This Minute] = left(right(([as400 Time]),3),1)
	 WHERE len([as400 time]) = 3

    UPDATE DEVL_LMOS.dbo.time
	   SET DEVL_LMOS.dbo.time.[This Minute] = 0
	 WHERE [This Minute] is null

-----------------------------------------------------------------
PRINT 'Build [This Hour] field'

    UPDATE DEVL_LMOS.dbo.time
	   SET DEVL_LMOS.dbo.time.[This Hour] = left([as400 Time],2)
	 WHERE len([as400 time])> 5

    UPDATE DEVL_LMOS.dbo.time
	   SET DEVL_LMOS.dbo.time.[This Hour] = left([as400 Time],1)
	 WHERE len([as400 time]) = 5

    UPDATE DEVL_LMOS.dbo.time
	   SET DEVL_LMOS.dbo.time.[This Hour] = 0
	 WHERE [This Hour] is null

-----------------------------------------------------------------
PRINT 'Build [HH:MM] field'

    UPDATE DEVL_LMOS.dbo.time
	   SET DEVL_LMOS.dbo.time.[HH:MM] = [This Hour] + ':0' + [This Minute]
	 WHERE len([This Minute])=1

    UPDATE DEVL_LMOS.dbo.time
	   SET DEVL_LMOS.dbo.time.[HH:MM] = [This Hour] + ':' + [This Minute]
	 WHERE len([This Minute])=2

-----------------------------------------------------------------
PRINT 'Build [HH:MM:SS] field'

    UPDATE DEVL_LMOS.dbo.time
	   SET DEVL_LMOS.dbo.time.[HH:MM:SS] = rtrim([HH:MM]) + ':0' + [This Second]
	 WHERE len([This Second])=1

    UPDATE DEVL_LMOS.dbo.time
	   SET DEVL_LMOS.dbo.time.[HH:MM:SS] = rtrim([HH:MM]) + ':' + [This Second]
	 WHERE len([This Second])=2

-----------------------------------------------------------------
PRINT 'Build [HH:MM AMPM] field'

    UPDATE DEVL_LMOS.dbo.time
	   SET DEVL_LMOS.dbo.time.[HH:MM AMPM] = rtrim([HH:MM]) + ' AM'
	 WHERE [as400 time] < 120000

    UPDATE DEVL_LMOS.dbo.time
	   SET DEVL_LMOS.dbo.time.[HH:MM AMPM] = '12:'+ [This Minute] + ' AM'
	 WHERE [This Hour] = 0 and len([this minute]) = 2

    UPDATE DEVL_LMOS.dbo.time
	   SET DEVL_LMOS.dbo.time.[HH:MM AMPM] = '12:0'+ [This Minute] + ' AM'
	 WHERE [This Hour] = 0 and len([this minute]) = 1

    UPDATE DEVL_LMOS.dbo.time
	   SET DEVL_LMOS.dbo.time.[HH:MM AMPM] = rtrim([HH:MM]) + ' PM'
	 WHERE [as400 time] >= 120000 and [as400 time] <= 125959

    UPDATE DEVL_LMOS.dbo.time
	   SET DEVL_LMOS.dbo.time.[HH:MM AMPM] = convert(varchar(2),rtrim([This Hour])-12) + ':' + [This Minute] + ' PM'
	 WHERE [as400 time] >= 130000

-----------------------------------------------------------------
PRINT 'Build [HH:MM:SS AMPM] field'

    UPDATE DEVL_LMOS.dbo.time
	   SET DEVL_LMOS.dbo.time.[HH:MM:SS AMPM] = rtrim([HH:MM]) + ':0'+ [This second] + ' AM'
	 WHERE [as400 time] < 120000 and len([this second])=1

    UPDATE DEVL_LMOS.dbo.time
	   SET DEVL_LMOS.dbo.time.[HH:MM:SS AMPM] = rtrim([HH:MM]) + ':'+ [This second] + ' AM'
	 WHERE [as400 time] < 120000 and len([this second])=2

    UPDATE DEVL_LMOS.dbo.time
	   SET DEVL_LMOS.dbo.time.[HH:MM:SS AMPM] = '12:'+ [This Minute]+ ':0'+ [This second]  + ' AM'  
	 WHERE [This Hour] = 0 and len([this minute]) = 2 and len([this second])=1

    UPDATE DEVL_LMOS.dbo.time
	   SET DEVL_LMOS.dbo.time.[HH:MM:SS AMPM] = '12:0'+ [This Minute]+ ':0'+ [This second]  + ' AM'  
	 WHERE [This Hour] = 0 and len([this minute]) = 1 and len([this second])=1

    UPDATE DEVL_LMOS.dbo.time
	   SET DEVL_LMOS.dbo.time.[HH:MM:SS AMPM] = '12:'+ [This Minute]+ ':'+ [This second]  + ' AM'  
	 WHERE [This Hour] = 0 and len([this minute]) = 2 and len([this second])=2

    UPDATE DEVL_LMOS.dbo.time
	   SET DEVL_LMOS.dbo.time.[HH:MM:SS AMPM] = '12:0'+ [This Minute]+ ':'+ [This second]  + ' AM'  
	 WHERE [This Hour] = 0 and len([this minute]) = 1 and len([this second])=2

    UPDATE DEVL_LMOS.dbo.time
	   SET DEVL_LMOS.dbo.time.[HH:MM:SS AMPM] = rtrim([HH:MM]) + ':0'+ [This Second] + ' PM'
	 WHERE [as400 time] >= 120000 and [as400 time] <= 125959 and len([This Second]) = 1

    UPDATE DEVL_LMOS.dbo.time
	   SET DEVL_LMOS.dbo.time.[HH:MM:SS AMPM] = rtrim([HH:MM]) + ':'+ [This Second] + ' PM'
	 WHERE [as400 time] >= 120000 and [as400 time] <= 125959 and len([This Second]) = 2

    UPDATE DEVL_LMOS.dbo.time
	   SET DEVL_LMOS.dbo.time.[HH:MM:SS AMPM] = convert(varchar(2),rtrim([This Hour])-12) + ':' + [This Minute] + ':0'+ [This Second]  + ' PM'
	 WHERE [as400 time] >= 130000 and len([This Second]) = 1

    UPDATE DEVL_LMOS.dbo.time
	   SET DEVL_LMOS.dbo.time.[HH:MM:SS AMPM] = convert(varchar(2),rtrim([This Hour])-12) + ':' + [This Minute] + ':'+ [This Second]  + ' PM'
	 WHERE [as400 time] >= 130000 and len([This Second]) = 2

-----------------------------------------------------------------
PRINT 'Build [AMPM] field'

    UPDATE DEVL_LMOS.dbo.time
	   SET DEVL_LMOS.dbo.time.[AMPM] = right(rtrim([HH:MM AMPM]),2)

-----------------------------------------------------------------
PRINT 'Build [SQLTime] field'

    UPDATE DEVL_LMOS.dbo.time
	   SET DEVL_LMOS.dbo.time.[SQLTime] = rtrim(left([HH:MM AMPM],5)) + [AMPM]

-----------------------------------------------------------------
PRINT 'Build LMREAD.dbo.Time'

	IF EXISTS(SELECT name 
	            FROM LMREAD.dbo.sysobjects 
	           WHERE name = N'Time' 
	             AND type = 'U')
    BEGIN
   		 DROP TABLE LMREAD.dbo.Time
	END
		
	SELECT * INTO lmread.dbo.Time FROM DEVL_LMOS.dbo.Time

IF NOT EXISTS(SELECT name 
	            FROM  sysobjects 
	           WHERE  name = N'Time' 
	             AND  type = 'U'
                 AND id = (SELECT sysindexes.id 
                             FROM sysindexes
                            WHERE name='Index_AS400 Time'))
    CREATE INDEX [Index_AS400 Time]
        ON dbo.time ([AS400 Time])
GO

IF NOT EXISTS(SELECT name 
	            FROM  sysobjects 
	           WHERE  name = N'Time' 
	             AND  type = 'U'
                 AND id = (SELECT sysindexes.id 
                             FROM sysindexes
                            WHERE name='Index_HH:MM'))
    CREATE INDEX [Index_HH:MM]
        ON lmread.dbo.time ([HH:MM])
GO

IF NOT EXISTS(SELECT name 
	            FROM  sysobjects 
	           WHERE  name = N'Time' 
	             AND  type = 'U'
                 AND id = (SELECT sysindexes.id 
                             FROM sysindexes
                            WHERE name='Index_HH:MM:SS'))
    CREATE INDEX [Index_HH:MM:SS]
        ON lmread.dbo.time ([HH:MM:SS])
GO

IF NOT EXISTS(SELECT name 
	            FROM  sysobjects 
	           WHERE  name = N'Time' 
	             AND  type = 'U'
                 AND id = (SELECT sysindexes.id 
                             FROM sysindexes
                            WHERE name='Index_This Hour'))
    CREATE INDEX [Index_This Hour]
        ON lmread.dbo.time ([This Hour])
GO

IF NOT EXISTS(SELECT name 
	            FROM  sysobjects 
	           WHERE  name = N'Time' 
	             AND  type = 'U'
                 AND id = (SELECT sysindexes.id 
                             FROM sysindexes
                            WHERE name='Index_This Minute'))
    CREATE INDEX [Index_This Minute]
        ON lmread.dbo.time ([This Minute])
GO

IF NOT EXISTS(SELECT name 
	            FROM  sysobjects 
	           WHERE  name = N'Time' 
	             AND  type = 'U'
                 AND id = (SELECT sysindexes.id 
                             FROM sysindexes
                            WHERE name='Index_This Second'))
    CREATE INDEX [Index_This Second]
        ON lmread.dbo.time ([This Second])
GO

IF NOT EXISTS(SELECT name 
	            FROM  sysobjects 
	           WHERE  name = N'Time' 
	             AND  type = 'U'
                 AND id = (SELECT sysindexes.id 
                             FROM sysindexes
                            WHERE name='Index_AMPM'))
    CREATE INDEX [Index_AMPM]
        ON lmread.dbo.time ([AMPM])
GO

IF NOT EXISTS(SELECT name 
	            FROM  sysobjects 
	           WHERE  name = N'Time' 
	             AND  type = 'U'
                 AND id = (SELECT sysindexes.id 
                             FROM sysindexes
                            WHERE name='Index_SQLTime'))
    CREATE INDEX [Index_SQLTime]
        ON lmread.dbo.time ([SQLTime])
GO

IF NOT EXISTS(SELECT name 
	            FROM  sysobjects 
	           WHERE  name = N'Time' 
	             AND  type = 'U'
                 AND id = (SELECT sysindexes.id 
                             FROM sysindexes
                            WHERE name='Index_Seq'))
    CREATE INDEX [Index_Seq]
        ON lmread.dbo.time ([Seq])
GO

--		select * from devl_lmos.dbo.time order by [as400 time]

