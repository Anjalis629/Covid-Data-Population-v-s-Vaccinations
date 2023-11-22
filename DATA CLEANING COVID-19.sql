SELECT * FROM [dbo].[covid_vaccine_statewise$]
SELECT * FROM [dbo].[covid_19_india$]

---------------DATA CLEANING

DELETE FROM covid_19_india$ WHERE [State/UnionTerritory] = 'Cases being reassigned to states'

DELETE FROM covid_19_india$ WHERE [State/UnionTerritory] = 'Daman & Diu'

DELETE FROM covid_19_india$ WHERE [State/UnionTerritory] = 'Unassigned'

UPDATE covid_19_india$
SET [State/UnionTerritory] = 'Dadra and Nagar Haveli and Daman and Diu'
WHERE [State/UnionTerritory] = 'Dadra and Nagar Haveli'

UPDATE covid_19_india$
SET [State/UnionTerritory] = 'Telangana'
WHERE [State/UnionTerritory] = 'Telengana'



SELECT CAST([Date] AS DATE) AS DATE FROM [dbo].[covid_19_india$]

UPDATE covid_19_india$
SET [Date] = REPLACE( Date, '-', '/')--------------REPLACING ONE SPECIAL CHARACTER WITH ANOTHER

UPDATE [dbo].[covid_vaccine_statewise$]
SET [Updated On] = REPLACE([Updated On],'/', '-')

ALTER TABLE [dbo].[covid_19_india$]
ALTER COLUMN [Date] VARCHAR(60)--------------------CONVERTED THE DATATYPE ONE COLUMN TO ANOTHER


UPDATE [dbo].[covid_19_india$]
SET [Date] = REPLACE([Date],'12:00AM', ' ')--------REMOVED SOME VALUES FROM COLUMN

SELECT CONVERT(VARCHAR, CAST([Date] AS DATE), 105)  FROM [dbo].[covid_19_india$]-------CONVERTED THE FORMAT STYLE OF DATE

UPDATE [dbo].[covid_19_india$]
SET [Date] = CONVERT(VARCHAR, CAST(Date AS DATE), 105);


--------------ADDING A NEW COLUMN OF ACTIVE CASES

ALTER TABLE [dbo].[covid_19_india$]
ADD ACTIVE_CASES INT

UPDATE [dbo].[covid_19_india$]
SET ACTIVE_CASES = (Confirmed-Deaths-Cured)

---------------------------------------------------------------------------------ANALYSIS

--------------LOOKING AT TOTAL CONFIRMED CASES, CURED CASES AND DEATHS 

SELECT [State/UnionTerritory], SUM([Deaths]) AS TOTAL_DEATHS, SUM([Confirmed]) AS CONFIRMED_CASES, SUM([Cured]) AS CURED_CASES
FROM [dbo].[covid_19_india$]
GROUP BY [State/UnionTerritory]
ORDER BY 1,2

-------------LOOKING AT STATES WITH MAX CONFIRMED CASES AND DEATHS

SELECT [State/UnionTerritory], MAX([Confirmed]) AS HIGHEST_CASES, MAX([Deaths]) AS MAX_DEATHS
FROM [dbo].[covid_19_india$]
GROUP BY [State/UnionTerritory]
ORDER BY HIGHEST_CASES DESC

-------------LOOKING AT STATES WITH MAX ACTIVE CASES

SELECT [State/UnionTerritory], MAX([ACTIVE_CASES]) AS ACTIVE
FROM [dbo].[covid_19_india$]
WHERE [ACTIVE_CASES] IS NOT NULL
GROUP BY [State/UnionTerritory]
ORDER BY ACTIVE DESC

------------LOOKING AT TOP 10 STATES WITH MAX ACTIVE CASES

SELECT TOP 10([State/UnionTerritory]), COUNT([ACTIVE_CASES]) AS ACTIVE FROM [dbo].[covid_19_india$]
GROUP BY [State/UnionTerritory]
ORDER BY ACTIVE DESC

------------LOOKING AT TOP 10 STATES WITH MAX CONFIRMED CASES

SELECT TOP 10([State/UnionTerritory]), SUM([Confirmed]) AS TOTAL_CASES FROM [dbo].[covid_19_india$]
GROUP BY [State/UnionTerritory]
ORDER BY TOTAL_CASES DESC

------------------------------------------------------------------------------------------------------------------------------
-------------VACCINATED STATES

SELECT [State], MAX([Total Individuals Vaccinated]) AS TOTAL_VACCINATIONS FROM [dbo].[covid_vaccine_statewise$]
GROUP BY [State]
ORDER BY TOTAL_VACCINATIONS DESC

DELETE FROM [dbo].[covid_vaccine_statewise$]
WHERE [State] = 'India'

----------PROPORTION OF COVAXIN, COVISHIELD, SPUTNIK DOSES

SELECT State, CAST(ROUND((MAX([CoviShield (Doses Administered)]/[Total Doses Administered]))*100,2) AS VARCHAR(40)) +'%' AS PERCENT_COVISHIELD, 
CAST(ROUND((MAX([ Covaxin (Doses Administered)]/[Total Doses Administered]))*100,2) AS VARCHAR(40)) + '%' AS PERCENT_COVAXIN,
CAST(ROUND((MAX([Sputnik V (Doses Administered)]/[Total Doses Administered]))*100,2) AS VARCHAR(40)) +'%' AS PERCENT_SPUTNIK 
FROM [dbo].[covid_vaccine_statewise$]
GROUP BY State;

-----------PROPORTION OF VACCINATION AMONG AGE GROUPS

SELECT State, CAST(ROUND((MAX([18-44 Years(Individuals Vaccinated)]/[Total Individuals Vaccinated]))*100,2) AS VARCHAR(40)) +'%' AS YOUNG_VACCINATED, 
CAST(ROUND((MAX([45-60 Years(Individuals Vaccinated)]/[Total Individuals Vaccinated]))*100,2) AS VARCHAR(40)) + '%' AS MIIDDLEAGE_VACCINATED,
CAST(ROUND((MAX([60+ Years(Individuals Vaccinated)]/[Total Individuals Vaccinated]))*100,2) AS VARCHAR(40)) +'%' AS OLDAGE_VACCINATED 
FROM [dbo].[covid_vaccine_statewise$]
GROUP BY State;

----------PERCENT OF PEOPLE WHO TOOK BOTH DOSES OF VACCINE 

SELECT [State], CAST(ROUND((MAX([Second Dose Administered]/[First Dose Administered]))*100,2) AS VARCHAR(20)) + '%' AS TOTAL_DOSES
FROM [dbo].[covid_vaccine_statewise$]
GROUP BY [State]
ORDER BY TOTAL_DOSES DESC

---------COUNT OF MALE AND FEMALE AND TRANSGENDER DOSES

SELECT [State], MAX([Male (Doses Administered)]) AS MALE, MAX([Female (Doses Administered)]) AS FEMALE, MAX([Transgender (Doses Administered)]) AS TRANS
FROM [dbo].[covid_vaccine_statewise$]
GROUP BY [State]

---------COUNT OF AEFI(ADVERSE EVENT FOLLOWING IMMUNIZATION)

SELECT [State], MAX([AEFI]) AS AEFI_COUNT
FROM [dbo].[covid_vaccine_statewise$]
WHERE [AEFI] IS NOT NULL
GROUP BY [State]
ORDER BY AEFI_COUNT DESC

----------COUNT OF TOTAL DOSES ADMINISTERED STATE WISE

SELECT [State], SUM([Total Doses Administered]) AS DOSES
FROM [dbo].[covid_vaccine_statewise$]
WHERE [Total Doses Administered] IS NOT NULL
GROUP BY [State]
ORDER BY DOSES ASC

-------------------------------------------------------------JOINING TWO TABLES BASED ON STATES AND DATES

SELECT * FROM [dbo].[covid_19_india$] AS COVID
INNER JOIN [dbo].[covid_vaccine_statewise$] AS VACCINATION
ON COVID.[State/UnionTerritory] = VACCINATION.[State]
AND COVID.[Date] = VACCINATION.[Updated On]

SELECT * FROM [dbo].[covid_19_india$] AS COVID
LEFT JOIN [dbo].[covid_vaccine_statewise$] AS VACCINATION
ON COVID.[State/UnionTerritory] = VACCINATION.[State]
AND COVID.[Date] = VACCINATION.[Updated On]


SELECT * FROM [dbo].[covid_19_india$] AS COVID
RIGHT JOIN [dbo].[covid_vaccine_statewise$] AS VACCINATION
ON COVID.[State/UnionTerritory] = VACCINATION.[State]
AND COVID.[Date] = VACCINATION.[Updated On]

-----------LOOKING AT TOTAL POPULATION VACCINATED DATE WISE

SELECT [State], [Updated On], [Total Individuals Vaccinated]
FROM [dbo].[covid_vaccine_statewise$] AS VACCINATION
INNER JOIN [dbo].[covid_19_india$] AS COVID
ON VACCINATION.State = COVID.[State/UnionTerritory]
AND VACCINATION.[Updated On]  =COVID.[Date]
WHERE [Total Individuals Vaccinated] IS NOT NULL
ORDER BY 1,2













