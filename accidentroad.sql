select * from [dbo].[Data];
------------------------------
--Primary KPI - Total Casualties and Total Accident values for Current Year and YoY growth. 
select count (Accident_Index) as CurrentTotalAccident,
sum([Number_of_Casualties]) as CurrentTotalCasualties
from [dbo].[Data]
WHERE YEAR(CAST([Accident Date] AS DATE)) = 2022

SELECT count(Accident_Index) as YOY_ACCIDENT_GROWTH,
SUM([Number_of_Casualties]) AS YOY_Casualties_GROWTH
from [dbo].[Data]
WHERE YEAR(CAST([Accident Date] AS DATE)) = 2021;

SELECT * from [dbo].[Data]

-------------
/* SELECT ROW_NUMBER() OVER (ORDER BY CurrentTotalAccident DESC) AS RowNumber,
       CurrentTotalAccident,
       CurrentTotalCasualties
FROM (
    SELECT COUNT(Accident_Index) as CurrentTotalAccident,
           SUM([Number_of_Casualties]) as CurrentTotalCasualties
    FROM [dbo].[Data]
    WHERE YEAR(CAST([Accident Date] AS DATE)) = 2022
) AS Subquery;*/
---------------------------------------------------
/* SELECT ROW_NUMBER() OVER (ORDER BY YOY_ACCIDENT_GROWTH DESC) AS RowNumber,
       YOY_ACCIDENT_GROWTH,
       YOY_Casualties_GROWTH
FROM (
    SELECT COUNT(Accident_Index) as YOY_ACCIDENT_GROWTH,
           SUM([Number_of_Casualties]) AS YOY_Casualties_GROWTH
    FROM [dbo].[Data]
    WHERE YEAR(CAST([Accident Date] AS DATE)) = 2021
) AS FirstQuery */

------------------------
-- Join the two queries using INNER JOIN on RowNumber
SELECT A.RowNumber,
       A.CurrentTotalAccident,
       A.CurrentTotalCasualties,
       B.YOY_ACCIDENT_GROWTH,
       B.YOY_Casualties_GROWTH
FROM (
    SELECT ROW_NUMBER() OVER (ORDER BY CurrentTotalAccident DESC) AS RowNumber,
           CurrentTotalAccident,
           CurrentTotalCasualties
    FROM (
        SELECT COUNT(Accident_Index) as CurrentTotalAccident,
               SUM([Number_of_Casualties]) as CurrentTotalCasualties
        FROM [dbo].[Data]
        WHERE YEAR(CAST([Accident Date] AS DATE)) = 2022
    ) AS Subquery
) AS A
INNER JOIN (
    SELECT ROW_NUMBER() OVER (ORDER BY YOY_ACCIDENT_GROWTH DESC) AS RowNumber,
           YOY_ACCIDENT_GROWTH,
           YOY_Casualties_GROWTH
    FROM (
        SELECT COUNT(Accident_Index) as YOY_ACCIDENT_GROWTH,
               SUM([Number_of_Casualties]) AS YOY_Casualties_GROWTH
        FROM [dbo].[Data]
        WHERE YEAR(CAST([Accident Date] AS DATE)) = 2021
    ) AS FirstQuery
) AS B ON A.RowNumber = B.RowNumber;
---------
/*Categorize Van and goods are the same.
* You can consider Pedal Cycle / Ridden Horse as Other.
* Taxi / Private Car as Car.
* Minibus – Coach or Bus as Bus. */
SELECT [Vehicle_Type],    
    CASE 
        WHEN [Vehicle_Type] IN ('Taxi/Private hire car', 'car') THEN 'car'
        WHEN [Vehicle_Type] IN ('Van / Goods 3.5 tonnes mgw or under', 'cycle') THEN 'VAN AND Goods'
		WHEN [Vehicle_Type] IN ('Pedal cycle', 'Ridden horse') THEN 'Other'
		WHEN [Vehicle_Type] IN ('Bus or coach (17 or more pass seats)', 'Minibus (8 - 16 passenger seats)') THEN 'Other'
        ELSE 'unknown'  -- If needed, handle other cases
    END AS vehicle_category
FROM [dbo].[Data] ;
-------------------------------------
/*Categorize Weather Condition:
1. Fine
2. Other
3. Rain
4. Snow/ Fog */

SELECT [Weather_Conditions],    
    CASE 
        WHEN [Weather_Conditions] IN ('Fine no high winds', 'Fine + high winds') THEN 'fine'
		WHEN [Weather_Conditions] IN ('Raining no high winds', 'Raining + high winds') THEN 'rain'
		WHEN [Weather_Conditions] IN ('Fog or mist', 'Snowing + high winds','Snowing no high winds') THEN 'Snow/ Fog'
        ELSE 'other'  -- If needed, handle other cases
    END AS weather_category
FROM [dbo].[Data] ;
----------------------------
ALTER TABLE [dbo].[Data]
ADD   RowNumber INT,
    Severity NVARCHAR(50),
    TotalCasualties2021 INT,
    TotalCasualties2022 INT;

--------------------------------

-- Total Casualties by Accident Severity for the Current Year and prevoius year. 

SELECT 
    a.rowNumber,
    a.AccidentSeverity AS Severity,
    a.TotalNumberOfCasualtiesPV AS TotalCasualties2021,
    b.TotalNumberOfCasualtiesCY AS TotalCasualties2022
FROM (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY TotalNumberOfCasualtiesPV) AS rowNumber,
        AccidentSeverity,
        TotalNumberOfCasualtiesPV
    FROM (
        SELECT 
            [Accident_Severity] AS AccidentSeverity,
            SUM([Number_of_Casualties]) AS TotalNumberOfCasualtiesPV
        FROM 
            [dbo].[Data]
        WHERE 
            YEAR(CAST([Accident Date] AS DATE)) = 2021
        GROUP BY 
            [Accident_Severity]
    ) AS subquery1
) AS a
JOIN (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY TotalNumberOfCasualtiesCY) AS rowNumber,
        TotalNumberOfCasualtiesCY
    FROM (
        SELECT 
            [Accident_Severity] AS AccidentSeverity,
            SUM([Number_of_Casualties]) AS TotalNumberOfCasualtiesCY
        FROM 
            [dbo].[Data]
        WHERE 
            YEAR(CAST([Accident Date] AS DATE)) = 2022
        GROUP BY 
            [Accident_Severity]
    ) AS subquery2
) AS b ON a.rowNumber = b.rowNumber;
---------------------------------------------------------------------
CREATE TABLE NewTable (
    RowNumber INT,
    Severity NVARCHAR(50),
    TotalCasualties2021 INT,
    TotalCasualties2022 INT
);

INSERT INTO NewTable (RowNumber, Severity, TotalCasualties2021, TotalCasualties2022)
SELECT 
    a.rowNumber,
    a.AccidentSeverity AS Severity,
    a.TotalNumberOfCasualtiesPV AS TotalCasualties2021,
    b.TotalNumberOfCasualtiesCY AS TotalCasualties2022
FROM (
SELECT 
        ROW_NUMBER() OVER (ORDER BY TotalNumberOfCasualtiesPV) AS rowNumber,
        AccidentSeverity,
        TotalNumberOfCasualtiesPV
    FROM (
        SELECT 
            [Accident_Severity] AS AccidentSeverity,
            SUM([Number_of_Casualties]) AS TotalNumberOfCasualtiesPV
        FROM 
            [dbo].[Data]
        WHERE 
            YEAR(CAST([Accident Date] AS DATE)) = 2021
        GROUP BY 
            [Accident_Severity]
    ) AS subquery1) AS a
JOIN (
  SELECT 
        ROW_NUMBER() OVER (ORDER BY TotalNumberOfCasualtiesCY) AS rowNumber,
        TotalNumberOfCasualtiesCY
    FROM (
        SELECT 
            [Accident_Severity] AS AccidentSeverity,
            SUM([Number_of_Casualties]) AS TotalNumberOfCasualtiesCY
        FROM 
            [dbo].[Data]
        WHERE 
            YEAR(CAST([Accident Date] AS DATE)) = 2022
        GROUP BY 
            [Accident_Severity]
    ) AS subquery2
) AS b ON a.rowNumber = b.rowNumber;


select * from [dbo].[NewTable];


---------------------
--Total Casualties with respect to vehicle type for the Current Year
SELECT 
    CASE 
        WHEN [Vehicle_Type] IN ('Taxi/Private hire car', 'car') THEN 'car'
        WHEN [Vehicle_Type] IN ('Van / Goods 3.5 tonnes mgw or under', 'cycle') THEN 'VAN AND Goods'
        WHEN [Vehicle_Type] IN ('Pedal cycle', 'Ridden horse') THEN 'Other'
        WHEN [Vehicle_Type] IN ('Bus or coach (17 or more pass seats)', 'Minibus (8 - 16 passenger seats)') THEN 'Other'
        ELSE 'unknown'
    END AS vehicle_category,
    SUM([Number_of_Casualties]) AS TotalCasualties
FROM 
    [dbo].[Data]
WHERE 
    YEAR(CAST([Accident Date] AS DATE)) = 2022
GROUP BY 
    CASE 
        WHEN [Vehicle_Type] IN ('Taxi/Private hire car', 'car') THEN 'car'
        WHEN [Vehicle_Type] IN ('Van / Goods 3.5 tonnes mgw or under', 'cycle') THEN 'VAN AND Goods'
        WHEN [Vehicle_Type] IN ('Pedal cycle', 'Ridden horse') THEN 'Other'
        WHEN [Vehicle_Type] IN ('Bus or coach (17 or more pass seats)', 'Minibus (8 - 16 passenger seats)') THEN 'Other'
        ELSE 'unknown'
    END;
-------------------------------
--Total Casualties per road type and Road_Surface_Conditions

/*select distinct Road_Type,
NULLIF([Dry],0),
NULLIF([Snow],0),
NULLIF([Frost or ice],0),
NULLIF([Wet or damp],0)
from [dbo].[Data]
PIVOT(
sum([Number_of_Casualties])
for Road_Surface_Conditions in (
[Dry],
[Snow],
[Frost or ice],
[Wet or damp])
) as pivottable
WHERE 
    YEAR(CAST([Accident Date] AS DATE)) = 2022 */
---------------------
----Total Casualties per road type and Road_Surface_Conditions
WITH RoadTypeCasualties AS (
    SELECT
        Road_Type,
        [Dry], [Snow], [Frost or ice], [Wet or damp],
        ROW_NUMBER() OVER (PARTITION BY Road_Type ORDER BY [Dry] + [Snow] + [Frost or ice] + [Wet or damp] DESC) AS RowRank
    FROM (
        SELECT
            Road_Type,
            SUM(CASE WHEN Road_Surface_Conditions = 'Dry' THEN Number_of_Casualties ELSE 0 END) AS [Dry],
            SUM(CASE WHEN Road_Surface_Conditions = 'Snow' THEN Number_of_Casualties ELSE 0 END) AS [Snow],
            SUM(CASE WHEN Road_Surface_Conditions = 'Frost or ice' THEN Number_of_Casualties ELSE 0 END) AS [Frost or ice],
            SUM(CASE WHEN Road_Surface_Conditions = 'Wet or damp' THEN Number_of_Casualties ELSE 0 END) AS [Wet or damp]
        FROM [dbo].[Data]
        WHERE YEAR(CAST([Accident Date] AS DATE)) = 2022
        GROUP BY Road_Type
    ) AS PivotData
)
SELECT Road_Type, [Dry], [Snow], [Frost or ice], [Wet or damp]
FROM RoadTypeCasualties
WHERE RowRank = 1;
