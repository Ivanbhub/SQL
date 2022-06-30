----------------------------------------------------------------------------------------------------------------------------------
The 
----------------------------------------------------------------------------------------------------------------------------------
-- 1
SELECT *
FROM Covid..deaths
WHERE continent IS NOT NULL 

----------------------------------------------------------------------------------------------------------------------------------
-- 2
-- Total cases vs Total deaths over time
    -- likelihood of dying of covid in your country (US)

SELECT location, date, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Covid..deaths
WHERE LOCATION like '%states' AND total_deaths > 0 AND continent IS NOT NULL
----------------------------------------------------------------------------------------------------------------------------------
-- 3
-- Total cases vs Population 
-- likelihood of contracting covid in your country (US)

SELECT  location, date,population,total_cases, (total_cases/population)*100 AS ConfirmedCasesPercentage
FROM Covid..deaths
WHERE LOCATION like '%states' AND total_deaths > 0
ORDER BY total_cases


----------------------------------------------------------------------------------------------------------------------------------
-- 4
-- Countries with the highest infection rate compared to population  

SELECT location, population, max(total_cases)AS TotalInfectionCount, max((total_cases/population)*100) AS ConfirmedCasesPercentage
FROM Covid..deaths
GROUP BY location,population
ORDER BY ConfirmedCasesPercentage
DESC


----------------------------------------------------------------------------------------------------------------------------------
-- 5
-- Countries with the highest COVID Death rate compared to population 

SELECT location, population, MAX(total_deaths) AS total_deaths , max((total_deaths/population)*100 )AS DeathPercentage
FROM Covid..deaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY total_deaths
DESC
----------------------------------------------------------------------------------------------------------------------------------
-- 6
-- Breaking it down by continent 

SELECT continent,MAX(total_deaths) AS total_deaths, MAX((total_deaths/population)*100 )AS DeathPercentage
FROM Covid..deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_deaths 
DESC
----------------------------------------------------------------------------------------------------------------------------------
-- 7
-- Location count
    -- using GROUP BY

Select top 5 location , COUNT(location)
 FROM Covid..deaths
  WHERE continent IS NOT NULL
 GROUP BY location
 ORDER by 2 
 DESC

----------------------------------------------------------------------------------------------------------------------------------

--8


-- Most new infection cases in one day (top 5)

SELECT max(new_cases) as "highest_infection_rate",location, MAX(population) population, (max(new_cases)/MAX(population))*100 as percentage_of_infected
FROM Covid..deaths
WHERE continent IS NOT NULL and new_cases IS NOT NULL
GROUP BY location 

-- order by New_Cases
-- DESC

----------------------------------------------------------------------------------------------------------------------------------
-- 9 
-- Covid infections over time (Worldwide)

SELECT date, SUM(new_cases) infectionPerDay, SUM(new_deaths) AS deathsPerDay , SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM Covid..deaths
WHERE continent IS NOT NULL
GROUP BY date 


-- 10
-- Totals 

SELECT  SUM(new_cases) Totalinfections, SUM(new_deaths) AS Totaldeaths , SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM Covid..deaths
WHERE continent IS NOT NULL

-- Or

SELECT  SUM(total_cases) as total_worldwide_case FROM( SELECT date, SUM(new_cases) AS total_cases
FROM Covid..deaths
WHERE continent IS NOT NULL
GROUP BY date
) AS total



----------------------------------------------------------------------------------------------------------------------------------
-- Adding the vaccination's table in the picture 
----------------------------------------------------------------------------------------------------------------------------------
-- 11
-- Vaccinations vs Population 
    -- Cummulative vaccinations count per country 

SELECT deaths.date, vaccs.population, deaths.location, deaths.new_cases , vaccs.new_vaccinations,
SUM(vaccs.new_vaccinations) OVER (PARTITION BY deaths.location ORDER BY deaths.location,deaths.date ) AS Rolling_vaccinations

FROM Covid..deaths deaths
JOIN Covid..vaccinations vaccs
ON deaths.location = vaccs.location
    AND deaths.date = vaccs.date
      WHERE continent IS NOT NULL AND new_vaccinations IS NOT NULL
   




----------------------------------------------------------------------------------------------------------------------------------

-- 12
-- Using Common Table Expression (CTE)

    -- When did vaccinations start for each country ? 


 WITH CTE_Vaccs_count AS (


SELECT deaths.date, vaccs.population, deaths.location, deaths.new_cases , vaccs.new_vaccinations,
SUM(vaccs.new_vaccinations) OVER (PARTITION BY deaths.location ORDER BY deaths.location,deaths.date ) AS Rolling_vaccinations

FROM Covid..deaths deaths
JOIN Covid..vaccinations vaccs
ON deaths.location = vaccs.location
    AND deaths.date = vaccs.date
      WHERE continent IS NOT NULL


)
SELECT location AS Country ,MIN(date) AS First_day_of_Vaccinations,MIN(Rolling_vaccinations) as Vaccinated
FROM CTE_Vaccs_count
WHERE Rolling_vaccinations IS NOT NULL
GROUP BY location
ORDER BY First_day_of_Vaccinations



----------------------------------------------------------------------------------------------------------------------------------

-- 13

-- using Temp table

    -- Percentage of people vaccinated over time

DROP TABLE IF EXISTS #PercentageVaccinated

CREATE TABLE #PercentageVaccinated
    (
continent NVARCHAR(50),
location NVARCHAR(50),
date DATETIME,
population BIGINT,
new_vaccinations FLOAT,
Rolling_vaccinations FLOAT,

    )
INSERT INTO #PercentageVaccinated


SELECT deaths.continent, deaths.location, deaths.date, vaccs.population, vaccs.new_vaccinations,
SUM(vaccs.new_vaccinations) OVER (PARTITION BY deaths.location ORDER BY deaths.location,deaths.date ) AS Rolling_vaccinations

FROM Covid..deaths deaths
JOIN Covid..vaccinations vaccs
ON deaths.location = vaccs.location
    AND deaths.date = vaccs.date
      WHERE continent IS NOT NULL


SELECT *, (Rolling_vaccinations/population)*100 AS percentage_of_vaccinated_population
 FROM #PercentageVaccinated

 WHERE new_vaccinations IS NOT NULL
 ORDER BY date








-- END of QUERIES
----------------------------------------------------------------------------------------------------------------------------------
-- creating views
----------------------------------------------------------------------------------------------------------------------------------