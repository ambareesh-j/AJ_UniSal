/* Ongoing Research and Query Analysis */

/* How many floods happened? */  
SELECT DISTINCT COUNT([FloodID]) as 'Number of Floods'
  FROM [DDMS].[FloodIncident]

-- Ans: 59632

/* How many floods happened over the past years? */  
SELECT  YEAR([ReportedDateTime]) as 'Reported Year',
        COUNT([FloodID]) as 'Number of Floods'
  FROM [DDMS].[FloodIncident]
  GROUP BY YEAR([ReportedDateTime])
  ORDER BY YEAR([ReportedDateTime]) ASC

-- Ans: 2020 - 9293 (Highest recorded) and 2021 - 6678

