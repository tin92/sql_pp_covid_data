
-- Checking data 
/*
SELECT *
FROM PortfolioProject..covid_death;


SELECT TOP 2000 * 
FROM PortfolioProject..covid_death
ORDER BY 3,4;

SELECT TOP 2000 * 
FROM PortfolioProject..covid_vaccination
ORDER BY 3,4; */

/*
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM dbo.covid_death
ORDER BY 1,2;
*/

/*
SELECT 
TABLE_CATALOG,
TABLE_SCHEMA,
TABLE_NAME, 
COLUMN_NAME, 
DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'covid_death' 
*/



--UPDATE PortfolioProject..covid_death SET total_deaths=0 WHERE total_deaths IS NULL;

--UPDATE PortfolioProject..covid_death SET total_cases=0 WHERE total_cases IS NULL;

/*
SELECT  total_deaths, ISNUMERIC(total_deaths), total_cases, ISNUMERIC(total_cases)
FROM PortfolioProject..covid_death;
*/

-- Checking the presence of non-numeric characters 

/*
SELECT DISTINCT(ISNUMERIC(total_cases))
FROM PortfolioProject..covid_death;
*/

-- Total deaths vs Total cases
-- Likelihood of death if you contract covid in your country

/*
SELECT TOP 10 location, date, total_cases, total_deaths, NULLIF((total_deaths/NULLIF(total_cases,0))*100,0) AS "Death Percentage"
FROM PortfolioProject..covid_death
ORDER BY 1,2;
*/

/*
SELECT location, date, total_cases, total_deaths, NULLIF((total_deaths/NULLIF(total_cases,0))*100,0) AS "Death Percentage"
FROM PortfolioProject..covid_death
WHERE location LIKE '%states%'
ORDER BY 1,2;
*/


-- Total cases vs population
-- Percentage of population that got Covid


/*
SELECT location, population
FROM PortfolioProject..covid_death
WHERE ISNUMERIC(population) = 0;
*/

/*
DELETE FROM PortfolioProject..covid_death 
WHERE ISNUMERIC(population) = 0;
*/

/*
SELECT location, date, population, total_cases, NULLIF((total_cases/NULLIF(population,0))*100,0) AS "Percentage of population with Covid"
FROM PortfolioProject..covid_death
WHERE location LIKE '%states%'
ORDER BY 1,2;
*/

-- Countries with highest infection rate ratios

/*
SELECT location, population, MAX(total_cases) AS 'Highest infection count', NULLIF(MAX((total_cases/NULLIF(population,0))*100),0) AS "Maximum percentage of population with Covid"
FROM PortfolioProject..covid_death
GROUP BY location, population  
--WHERE location LIKE '%states%'
ORDER BY 4 DESC
*/

-- Countries with the highest death rates


/*

SELECT location, MAX(total_deaths) AS "Total Deaths"
FROM PortfolioProject..covid_death
WHERE continent != ''
GROUP BY location 
ORDER BY 2 DESC

*/

-- Continents with the highest death count 

/*
SELECT continent, MAX(total_deaths) AS "Total Deaths of continent"
FROM PortfolioProject..covid_death
WHERE continent != ''
GROUP BY continent
ORDER BY 2 DESC
*/

-- A bit more accurate 

/*
SELECT location, MAX(total_deaths) AS "Total Deaths of continent"
FROM PortfolioProject..covid_death
WHERE continent = ''
GROUP BY location
ORDER BY 2 DESC
*/

-- Global Numbers 

/*
UPDATE PortfolioProject..covid_death 
SET new_cases=0 
WHERE new_cases= '';


SELECT DISTINCT(ISNUMERIC(new_cases))
FROM PortfolioProject..covid_death;
*/

/*
SELECT DISTINCT(ISNUMERIC(new_deaths))
FROM PortfolioProject..covid_death;

SELECT TOP 10 *
FROM PortfolioProject..covid_death
WHERE ISNUMERIC(new_deaths)=0
*/

/*
UPDATE PortfolioProject..covid_death 
SET new_deaths=0 
WHERE new_deaths= '';

SELECT DISTINCT(ISNUMERIC(new_deaths))
FROM PortfolioProject..covid_death;
*/

/*
SELECT date, SUM(new_cases), SUM(new_deaths), NULLIF((SUM(new_deaths)/NULLIF(SUM(new_cases),0))*100,0) AS 'Global Death Percenatage'
FROM PortfolioProject..covid_death
WHERE continent != ''
GROUP BY date
ORDER BY 1,2
*/

-- Global Total 

/*
SELECT SUM(new_cases), SUM(new_deaths), NULLIF((SUM(new_deaths)/NULLIF(SUM(new_cases),0))*100,0) AS 'Global Death Percenatage'
FROM PortfolioProject..covid_death
WHERE continent != ''
--GROUP BY date
ORDER BY 1,2
*/


-- Join and observe tables 

/*
SELECT *
FROM PortfolioProject..covid_death AS dea
JOIN PortfolioProject..covid_vaccination AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
*/

-- Total Population vs Vaccination 

/*
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..covid_death AS dea
JOIN PortfolioProject..covid_vaccination AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent != ''
ORDER BY 2,3,4
*/

/*
UPDATE PortfolioProject..covid_vaccination 
SET new_vaccinations=0 
WHERE new_vaccinations= '';
*/


/*
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY vac.location ORDER BY dea.location,dea.date) AS 'New vaccinations over time/Rolling count' -- Only partition over location and seperate it out over date
FROM PortfolioProject..covid_death AS dea
JOIN PortfolioProject..covid_vaccination AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent != ''
ORDER BY 2,3
*/

-- Using CTE (Can also use temp table)

/*
WITH popvsvac(continent, date, location, population, new_vaccinations, rollingpeoplevaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY vac.location ORDER BY dea.location,dea.date) AS 'New vaccinations over time/Rolling count' -- Only partition over location and seperate it out over date
FROM PortfolioProject..covid_death AS dea
JOIN PortfolioProject..covid_vaccination AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent != ''
--ORDER BY 2,3
)

SELECT *, (rollingpeoplevaccinated/population)*100 AS '% of population vaccinated over time'
FROM popvsvac
-- Can now use it to do further calculations 
*/

-- Temp table 

-- In case of alteration 
DROP TABLE IF EXISTS #percentpopulationvaccinated

CREATE TABLE #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric 
)


INSERT INTO #percentpopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY vac.location ORDER BY dea.location,dea.date) AS rollingpeoplevaccinated -- Only partition over location and seperate it out over date
FROM PortfolioProject..covid_death AS dea
JOIN PortfolioProject..covid_vaccination AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent != ''


SELECT *, (rollingpeoplevaccinated/population)*100 '% of population vaccinated over time'
FROM #percentpopulationvaccinated


-- Creating View to store data for later visualizations

CREATE VIEW percentpopulationvaccinatedview1 AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY vac.location ORDER BY dea.location,dea.date) AS rollingpeoplevaccinated -- Only partition over location and seperate it out over date
FROM PortfolioProject..covid_death AS dea
JOIN PortfolioProject..covid_vaccination AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent != ''
-- ORDER BY 2,3
-- Ss



