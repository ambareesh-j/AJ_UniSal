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

-- Time Series Analysis 
/* How many floods happened over the past years & months? */  
SELECT EOMONTH([ReportedDateTime]) as 'As of Date',
        COUNT([FloodID]) as 'Number of Floods'
  FROM [DDMS].[FloodIncident]
  WHERE CAST([ReportedDateTime] as DATE) <= GETDATE()     -- 2022 - 6 outlier floods were filtered out
  GROUP BY EOMONTH([ReportedDateTime])
  ORDER BY EOMONTH([ReportedDateTime])  ASC


/* How many floods based on Max effect endured? */  
SELECT EOMONTH([ReportedDateTime]) as 'As of Date',
        [MaxEffect],
        COUNT([FloodID]) as 'Number of Floods'
  FROM [DDMS].[FloodIncident]
  WHERE CAST([ReportedDateTime] as DATE) <= GETDATE()     -- 2022 - 6 outlier floods were filtered out
  GROUP BY EOMONTH([ReportedDateTime]), [MaxEffect]
  ORDER BY EOMONTH([ReportedDateTime]), [MaxEffect]  ASC


/* How many floods based on the type of Carriage Way? */  
SELECT EOMONTH([ReportedDateTime]) as 'As of Date',
        [CarriagewayType],
        COUNT([FloodID]) as 'Number of Floods'
  FROM [DDMS].[FloodIncident]
  WHERE CAST([ReportedDateTime] as DATE) <= GETDATE()     -- 2022 - 6 outlier floods were filtered out
  GROUP BY EOMONTH([ReportedDateTime]), [CarriagewayType]
  ORDER BY EOMONTH([ReportedDateTime]), [CarriagewayType]  ASC


/* How many floods based on the current flood status? */  
SELECT EOMONTH([ReportedDateTime]) as 'As of Date',
        [FloodStatus],
        COUNT([FloodID]) as 'Number of Floods'
  FROM [DDMS].[FloodIncident]
  WHERE CAST([ReportedDateTime] as DATE) <= GETDATE()     -- 2022 - 6 outlier floods were filtered out
  GROUP BY EOMONTH([ReportedDateTime]), [FloodStatus]
  ORDER BY EOMONTH([ReportedDateTime]), [FloodStatus]  ASC

/* How many floods based on the preventability? */  
SELECT EOMONTH([ReportedDateTime]) as 'As of Date',
        [IsPreventable],
        COUNT([FloodID]) as 'Number of Floods'
  FROM [DDMS].[FloodIncident]
  WHERE CAST([ReportedDateTime] as DATE) <= GETDATE()     -- 2022 - 6 outlier floods were filtered out
  GROUP BY EOMONTH([ReportedDateTime]), [IsPreventable]
  ORDER BY EOMONTH([ReportedDateTime]), [IsPreventable]  ASC


/* How many preventable floods have affected the assets? */  
SELECT EOMONTH([ReportedDateTime]) as 'As of Date',
        [IsAssetAffected],
        COUNT([FloodID]) as 'Number of Floods',
        AVG([FloodSeverityIndex]) as 'Mean Flood Severity Index'
  FROM [DDMS].[FloodIncident]
  WHERE CAST([ReportedDateTime] as DATE) <= GETDATE()     -- 2022 - 6 outlier floods were filtered out
    AND [IsPreventable] = 'Yes'
  GROUP BY EOMONTH([ReportedDateTime]), [IsAssetAffected]
  ORDER BY EOMONTH([ReportedDateTime]), [IsAssetAffected]  ASC

/* How many floods based on the Regularity on the road? */  
SELECT EOMONTH([ReportedDateTime]) as 'As of Date',
        [Regularity],
        [Road],
        COUNT([FloodID]) as 'Number of Floods'
  FROM [DDMS].[FloodIncident]
  WHERE CAST([ReportedDateTime] as DATE) <= GETDATE()     -- 2022 - 6 outlier floods were filtered out
  GROUP BY EOMONTH([ReportedDateTime]), [Regularity], [Road]
  ORDER BY EOMONTH([ReportedDateTime]), [Regularity], [Road]  ASC


/* Flood Severity Index by Road & Dates */  
SELECT EOMONTH([ReportedDateTime]) as 'As of Date',
        [Road],
        ROUND(AVG([FloodSeverityIndex]), 2) as 'Mean Flood Severity Index'
  FROM [DDMS].[FloodIncident]
  WHERE CAST([ReportedDateTime] as DATE) <= GETDATE()     -- 2022 - 6 outlier floods were filtered out
  GROUP BY EOMONTH([ReportedDateTime]) , [Road]
  ORDER BY EOMONTH([ReportedDateTime]), Road  ASC


/* Average Processing Times of a flood incident */  
SELECT EOMONTH([ReportedDateTime]) as 'As of Date',
        Road,
        AVG([Processing Time]) as 'Mean Processing Time'
FROM
(SELECT  [FloodID],
         [Road],
        [ReportedDateTime],      
        CASE 
            WHEN [IsCurrentFlag] = 0 THEN DATEDIFF(DAY, [ValidFromDateTime], [ValidToDateTime])
            WHEN [IsCurrentFlag] = 1 THEN DATEDIFF(DAY, [ValidFromDateTime], GETDATE())
        END  as 'Processing Time'
  FROM [DDMS].[FloodIncident]
  WHERE CAST([ReportedDateTime] as DATE) <= GETDATE()     -- 2022 - 6 outlier floods were filtered out
) as T1
  GROUP BY EOMONTH([ReportedDateTime]), Road
  ORDER BY EOMONTH([ReportedDateTime]), Road  ASC







/*CONFIRM*/
/*Problem queries */
SELECT TOP 1000 * FROM CONFIRM.AssetSorCost   -- No Asset costs
SELECT TOP 1000 * FROM CONFIRM.Asset
SELECT TOP 1000 * FROM CONFIRM.CostCode
SELECT TOP 1000 * FROM CONFIRM.FailureType
SELECT TOP 1000 * FROM CONFIRM.MaintenanceRegime

/*Asset Types*/
SELECT [AssetGroupID],
       [AssetTypeID],
       [Name] as [Asset Name]
  FROM [CONFIRM].[AssetType]
  WHERE [IsCurrentFlag] = 1

/*Asset Groups*/
SELECT [AssetGroupID]
      ,[Name] as [Asset Group Name]
      ,[GroupClass]
  FROM [CONFIRM].[AssetGroup]
  WHERE [IsCurrentFlag] = 1



/*Floods all*/

SELECT a.[FloodID]
      ,a.[Road]
      ,a.[Area]
      ,a.[Latitude]
      ,a.[Longitude]
      ,a.[CarriagewayDirection]
      ,a.[CarriagewayType]
      ,a.[SectionID]
      ,a.[FloodStatus]
      ,a.[MaxEffect]
      ,a.[ReportedDateTime]
      ,a.[AffectedLength]
      ,a.[FloodSeverityIndex]
      ,a.[IsDeletedFlag]
      ,a.[IsCurrentFlag]
      ,b.[FloodHotspotID]
      ,b.[BaselineID]
      ,b.[BaselineRiskLevel]
      ,b.[IsFloodRiskAreaID]
      ,b.[ActionStatus]
      ,b.[OverallStatus]
  FROM [DDMS].[FloodIncident] as a
  LEFT JOIN [DDMS].[FloodHotspot] as b
  ON a.Road = b.Road AND a.Area = b.Area AND a.CarriagewayDirection = b.Direction