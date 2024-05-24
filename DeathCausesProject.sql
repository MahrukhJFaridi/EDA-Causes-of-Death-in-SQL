
--Analyzing countries with highest deaths by a certain disease

--Analyzing the country with the highest deaths by Cardiovascular diseases from 1990-2019
--Result = China has had the most deaths by CVDs

SELECT [Entity],
	   Highest_Death_Count_By_CVD= SUM([Deaths - Cardiovascular diseases - Sex: Both - Age: All Ages (Nu])
      
  FROM [DeathCauses].[dbo].[AnnualCausesofDeath]
  GROUP BY Entity 
  ORDER BY Highest_Death_Count_By_CVD DESC

  --Analyzing the country with the highest deaths by HIV/AIDS from 1990-2019
--Result = South Africa has had the most deaths by HIV/AIDS

SELECT [Entity],
	   Highest_Death_Count_By_AIDS= SUM([Deaths - HIV/AIDS - Sex: Both - Age: All Ages (Number)])
      
  FROM [DeathCauses].[dbo].[AnnualCausesofDeath]
  GROUP BY Entity
  ORDER BY Highest_Death_Count_By_AIDS DESC

  --Analyzing the country with the highest deaths by Drug Abuse from 1990-2019
--Result = United States has had the most deaths by Drug Abuse

SELECT [Entity],
	   Highest_Death_Count_By_DrugAbuse= SUM([Deaths - Drug use disorders - Sex: Both - Age: All Ages (Number)])
      
  FROM [DeathCauses].[dbo].[AnnualCausesofDeath]
  GROUP BY Entity
  ORDER BY Highest_Death_Count_By_DrugAbuse DESC


  --Analyzing the country with the highest deaths by HIV/AIDS from 1990-2019
--Result = China has had the most deaths by Road Accidents

SELECT [Entity],
	   Highest_Death_Count_By_RoadAccidents= SUM([Deaths - Road injuries - Sex: Both - Age: All Ages (Number)])
      
  FROM [DeathCauses].[dbo].[AnnualCausesofDeath]
  GROUP BY Entity
  ORDER BY Highest_Death_Count_By_RoadAccidents DESC
--------------------------------------------------------------------------------------------------------------------------------------------------------------
--Cardiovascular Diseases is the number one cause of death in the United States
-- Utilizing a CTE to explore how much the chances to die from a cardiovascular disease have increased from 1990 to 2019
--Result = Theres an almost 17% increased chance to die from a cardiovascular disease
WITH DeathsByCVD (Entity, min_deaths_by_cvd, max_deaths_by_cvd)
AS

(SELECT Entity,
min_deaths_by_cvd = MIN([Deaths - Cardiovascular diseases - Sex: Both - Age: All Ages (Nu]),
max_deaths_by_cvd= MAX([Deaths - Cardiovascular diseases - Sex: Both - Age: All Ages (Nu]) 

  FROM [DeathCauses].[dbo].[AnnualCausesofDeath]
  WHERE Entity= 'United States'
  GROUP BY Entity)

  SELECT *,
  absolute_change = max_deaths_by_cvd-min_deaths_by_cvd,
  relative_change = FORMAT(((max_deaths_by_cvd-min_deaths_by_cvd)/min_deaths_by_cvd), 'p')
  FROM DeathsByCVD
  
  --Analyzing out of all deaths caused by cardiovascular diseases in the United States, how many deaths were of elderly people (50 to 69)
--Result = Almost 20% people that die of cardiovascular diseases are elderly.
SELECT
entirepopdeaths.Entity,
--entirepopdeaths.Year,
entirepopdeathsSUM = SUM(entirepopdeaths.[Deaths - Cardiovascular diseases - Sex: Both - Age: All Ages (Nu]),
elederlypopdeathsSUM = SUM(elderlypopdeaths.[Deaths - Cardiovascular diseases - Sex: Both - Age: 50-69 years ]),
perc_elderly_died_by_cdv = FORMAT(SUM(elderlypopdeaths.[Deaths - Cardiovascular diseases - Sex: Both - Age: 50-69 years ])/SUM(entirepopdeaths.[Deaths - Cardiovascular diseases - Sex: Both - Age: All Ages (Nu]), 'p')

FROM DeathCauses..AnnualCausesofDeath as entirepopdeaths
JOIN DeathCauses..Death50to69 as elderlypopdeaths
ON entirepopdeaths.Entity=elderlypopdeaths.Entity AND entirepopdeaths.Year = elderlypopdeaths.Year
WHERE entirepopdeaths.Entity='United States'
GROUP BY entirepopdeaths.Entity
---------------------------------------------------------------------------------------------------------------------------------------------------------
--Analyzing youth/adult (15 to 49) deaths caused by road accidents in the United States.
--Result = Almost 60% people that die in road accidents are youth/adults.
SELECT
entirepopdeaths.Entity,
--entirepopdeaths.Year,
entirepopdeathsSUM = SUM(entirepopdeaths.[Deaths - Road injuries - Sex: Both - Age: All Ages (Number)]),
adultpopdeathsSUM = SUM(adultpopdeaths.[Deaths - Road injuries - Sex: Both - Age: 15-49 years (Number)]),
perc_adults_died_by_accidents = FORMAT(SUM(adultpopdeaths.[Deaths - Road injuries - Sex: Both - Age: 15-49 years (Number)])/SUM(entirepopdeaths.[Deaths - Road injuries - Sex: Both - Age: All Ages (Number)]), 'p')

FROM DeathCauses..AnnualCausesofDeath as entirepopdeaths
JOIN DeathCauses..Death15to49 as adultpopdeaths
ON entirepopdeaths.Entity=adultpopdeaths.Entity AND entirepopdeaths.Year = adultpopdeaths.Year
WHERE entirepopdeaths.Entity='United States'
GROUP BY entirepopdeaths.Entity
-------------------------------------------------------------------------------------------------------------------------------------------------------------
--Analyzing child deaths caused by nutritional deficiencies around the World
--Utilizing a Temp Table
--Result = Syria has the highest child death rate by nutritional deficiencies.

DROP IF EXISTS #ChildDeathsByNutritionalDeficiencies
CREATE TABLE #ChildDeathsByNutritionalDeficiencies
( entity nvarchar(255),
entirepopdeaths numeric,
childpopdeaths numeric)
INSERT INTO #ChildDeathsByNutritionalDeficiencies 
SELECT
entirepopdeaths.Entity,
entirepopdeathsSUM = SUM(entirepopdeaths.[Deaths - Nutritional deficiencies - Sex: Both - Age: All Ages (N]),
childpopdeathsSUM = SUM(childpopdeaths.[Deaths - Nutritional deficiencies - Sex: Both - Age: 5-14 years ])

FROM DeathCauses..AnnualCausesofDeath as entirepopdeaths
JOIN DeathCauses..Death5to14 as childpopdeaths
ON entirepopdeaths.Entity=childpopdeaths.Entity AND entirepopdeaths.Year = childpopdeaths.Year
GROUP BY entirepopdeaths.Entity
HAVING SUM(entirepopdeaths.[Deaths - Nutritional deficiencies - Sex: Both - Age: All Ages (N]) <> 0 
AND SUM(childpopdeaths.[Deaths - Nutritional deficiencies - Sex: Both - Age: 5-14 years ]) <> 0

SELECT *,
perc_children_died_by_nd= FORMAT((childpopdeaths/entirepopdeaths),'p')
FROM #ChildDeathsByNutritionalDeficiencies
ORDER BY perc_children_died_by_nd DESC
------------------------------------------------------------------------------------------------------------------------------------------------------------
--Analyzing infant deaths caused by malaria around the World
--Utilizing a Temp Table
--Result = Ethiopia has the highest infant death rate by malaria at 91.16%.

DROP IF EXISTS #InfantDeathsByMalaria
CREATE TABLE #InfantDeathsByMalaria
( entity nvarchar(255),
entirepopdeaths numeric,
infantpopdeaths numeric)
INSERT INTO #InfantDeathsByMalaria 
SELECT
entirepopdeaths.Entity,
entirepopdeathsSUM = SUM(entirepopdeaths.[Deaths - Malaria - Sex: Both - Age: All Ages (Number)]),
infantpopdeathsSUM = SUM(infantpopdeaths.[Deaths - Malaria - Sex: Both - Age: Under 5 (Number)])

FROM DeathCauses..AnnualCausesofDeath as entirepopdeaths
JOIN DeathCauses..DeathUnder5 as infantpopdeaths
ON entirepopdeaths.Entity=infantpopdeaths.Entity AND entirepopdeaths.Year = infantpopdeaths.Year
GROUP BY entirepopdeaths.Entity
HAVING SUM(entirepopdeaths.[Deaths - Malaria - Sex: Both - Age: All Ages (Number)]) <> 0 
AND SUM(infantpopdeaths.[Deaths - Malaria - Sex: Both - Age: Under 5 (Number)]) <> 0

SELECT *,
perc_infants_died_by_malaria= FORMAT((infantpopdeaths/entirepopdeaths),'p')
FROM #InfantDeathsByMalaria
ORDER BY perc_infants_died_by_malaria DESC
-------------------------------------------------------------------------------------------------------------------------------------------------------
--Creating Views for Visualizations in Tableau
--View for Countries with deaths by Cardiovascular diseases
CREATE VIEW CountryWithHighestDeathsByCVDs AS

SELECT [Entity],
	   Highest_Death_Count_By_CVD= SUM([Deaths - Cardiovascular diseases - Sex: Both - Age: All Ages (Nu])
      
  FROM [DeathCauses].[dbo].[AnnualCausesofDeath]
  GROUP BY Entity 

SELECT *
FROM CountryWithHighestDeathsByCVDs
  ORDER BY Highest_Death_Count_By_CVD DESC


--View for Countries with deaths by Drug Abuse
CREATE VIEW CountryWithHighestDeathsByDrugAbuse AS

SELECT [Entity],
	   Highest_Death_Count_By_DrugAbuse= SUM([Deaths - Drug use disorders - Sex: Both - Age: All Ages (Number)])
      
  FROM [DeathCauses].[dbo].[AnnualCausesofDeath]
  GROUP BY Entity
  

SELECT *
FROM CountryWithHighestDeathsByDrugAbuse
ORDER BY Highest_Death_Count_By_DrugAbuse DESC

--View for Countries with highest deaths by HIV
CREATE VIEW CountryWithHighestDeathsByHIV AS

SELECT [Entity],
	   Highest_Death_Count_By_AIDS= SUM([Deaths - HIV/AIDS - Sex: Both - Age: All Ages (Number)])
      
  FROM [DeathCauses].[dbo].[AnnualCausesofDeath]
  GROUP BY Entity
  
SELECT *
FROM CountryWithHighestDeathsByHIV
ORDER BY Highest_Death_Count_By_AIDS DESC


--View for Highest Youth Deaths by Road Accidents around the World
CREATE VIEW YouthDeathsByRoadAccidents AS

SELECT
entirepopdeaths.Entity,
--entirepopdeaths.Year,
entirepopdeathsSUM = SUM(entirepopdeaths.[Deaths - Road injuries - Sex: Both - Age: All Ages (Number)]),
adultpopdeathsSUM = SUM(adultpopdeaths.[Deaths - Road injuries - Sex: Both - Age: 15-49 years (Number)]),
perc_adults_died_by_accidents = FORMAT(SUM(adultpopdeaths.[Deaths - Road injuries - Sex: Both - Age: 15-49 years (Number)])/SUM(entirepopdeaths.[Deaths - Road injuries - Sex: Both - Age: All Ages (Number)]), 'p')

FROM DeathCauses..AnnualCausesofDeath as entirepopdeaths
JOIN DeathCauses..Death15to49 as adultpopdeaths
ON entirepopdeaths.Entity=adultpopdeaths.Entity AND entirepopdeaths.Year = adultpopdeaths.Year
GROUP BY entirepopdeaths.Entity
HAVING SUM(adultpopdeaths.[Deaths - Road injuries - Sex: Both - Age: 15-49 years (Number)]) <> 0
AND SUM(entirepopdeaths.[Deaths - Road injuries - Sex: Both - Age: All Ages (Number)]) <> 0

SELECT *
FROM YouthDeathsByRoadAccidents

--View for Child Deaths by Nutritional Deficiencies around the World
CREATE VIEW ChildDeathsByNutritionalDeficiencies AS

SELECT
entirepopdeaths.Entity,
entirepopdeathsSUM = SUM(entirepopdeaths.[Deaths - Nutritional deficiencies - Sex: Both - Age: All Ages (N]),
childpopdeathsSUM = SUM(childpopdeaths.[Deaths - Nutritional deficiencies - Sex: Both - Age: 5-14 years ])

FROM DeathCauses..AnnualCausesofDeath as entirepopdeaths
JOIN DeathCauses..Death5to14 as childpopdeaths
ON entirepopdeaths.Entity=childpopdeaths.Entity AND entirepopdeaths.Year = childpopdeaths.Year
GROUP BY entirepopdeaths.Entity
HAVING SUM(entirepopdeaths.[Deaths - Nutritional deficiencies - Sex: Both - Age: All Ages (N]) <> 0 
AND SUM(childpopdeaths.[Deaths - Nutritional deficiencies - Sex: Both - Age: 5-14 years ]) <> 0

SELECT *,
perc_children_died_by_nd= FORMAT((childpopdeathsSUM/entirepopdeathsSUM),'p')
FROM ChildDeathsByNutritionalDeficiencies
ORDER BY perc_children_died_by_nd DESC


