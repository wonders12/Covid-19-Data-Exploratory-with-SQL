

--- Checking the tables imported to the database named PortforfolioProject
SELECT *
FROM [PortfolioProject].dbo.CovidDeath
--- because whenever countinent is found under location, the continent col would be null
WHERE location NOT IN ('Asia', 'Europe', 'Africa', 'North America', 'South America', 'Oceanic', 'Antarctia', 'World')
ORDER BY 3,4
;

SELECT *
FROM [PortfolioProject].[dbo].CovidVaccinations
WHERE location NOT IN ('Asia', 'Europe', 'Africa', 'North America', 'South America', 'Oceanic', 'Antarctia', 'World')--- because whenever countinent is found under location, the continent col would be null
ORDER BY 3,4
;


--- Getting location, date, total case, new case, total deaths
--- and population
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [PortfolioProject]..CovidDeath 
--- because whenever countinent is found under location, the continent col would be null
WHERE location NOT IN ('Asia', 'Europe', 'Africa', 'North America', 'South America', 'Oceanic', 'Antarctia', 'World')
ORDER BY 1,2
;

--- Calculation total cases vs total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 Death_rate
FROM [PortfolioProject]..CovidDeath
 --- because whenever countinent is found under location, the continent col would be null
WHERE location NOT IN ('Asia', 'Europe', 'Africa', 'North America', 'South America', 'Oceanic', 'Antarctia', 'World')
ORDER BY 1,2
;

--- Calculate the death rate against total cases in United State and Nigeria
--- and leave the death rate in 1 decimal place.
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,1) Death_rate
FROM [PortfolioProject]..CovidDeath
WHERE location IN ('United States', 'Nigeria')
    AND location NOT IN ('Asia', 'Europe', 'Africa', 'North America', 'South America', 'Oceanic', 'Antarctia', 'World') --- because whenever countinent is found under location, the continent col would be null
ORDER BY 1,2
;

--- Calculate the case rate against population and leave the result in 1 dp in United States
SELECT location, date, total_cases, population, ROUND((total_cases/population)*100,1) Case_rate
FROM [PortfolioProject]..CovidDeath
WHERE location LIKE '%States%'
    AND location NOT IN ('Asia', 'Europe', 'Africa', 'North America', 'South America', 'Oceanic', 'Antarctia', 'World') --- because whenever countinent is found under location, the continent col would be null
ORDER BY 1,2
;

--- Total cases of covid in the world
SELECT location, date, population, total_cases, ROUND((total_cases/population)*100,1) Case_rate
FROM [PortfolioProject]..CovidDeath
--- because whenever countinent is found under location, the continent col would be null
WHERE location NOT IN ('Asia', 'Europe', 'Africa', 'North America', 'South America', 'Oceanic', 'Antarctia', 'World')
ORDER BY 1,2

--- Countries with highest Infection rate against population
SELECT continent, location, population, MAX(total_cases) highest_infection,
        ROUND((MAX(total_cases)/population)*100,1) highest_infection_rate
FROM [PortfolioProject]..CovidDeath
WHERE location NOT IN ('Asia', 'Europe', 'Africa', 'North America', 'South America', 'Oceanic', 'Antarctia', 'World')
GROUP BY continent, location, population
ORDER BY highest_infection_rate DESC
;

--- Showing the highest death rate against population by location
SELECT location, MAX(CAST(total_deaths AS int)) total_deaths_count
FROM [PortfolioProject]..CovidDeath
WHERE location NOT IN ('Asia', 'Europe', 'Africa', 'North America', 'South America', 
                        'Oceanic', 'Antarctia', 'World', 'Upper middle income',
                        'Lower middle income', 'European Union', 'High income',
                        'Low income')
GROUP BY location, population
ORDER BY total_deaths_count DESC
;


--- Showing the death rate by continent
SELECT continent, MAX(CAST(total_deaths AS int)) total_deaths_count
FROM   [PortfolioProject]..CovidDeath
WHERE location NOT IN ('Asia', 'Europe', 'Africa', 'North America', 'South America', 
                        'Oceanic', 'Antarctia', 'World', 'Upper middle income',
                        'Lower middle income', 'European Union', 'High income',
                        'Low income')
GROUP BY continent
ORDER BY total_deaths_count DESC
;

--- Joining the two tables
SELECT *
FROM [PortfolioProject]..CovidDeath dea
JOIN [PortfolioProject]..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
;

--- Showing rate of people took vaccinate against population everyday
SELECT dea.continent, dea.location, dea.date, dea.population,
        vac.new_vaccinations, ROUND((vac.new_vaccinations/dea.population)*100,1) vaccination_rate
FROM [PortfolioProject]..CovidDeath dea
JOIN [PortfolioProject]..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3
;

--- Showing the total number of  vaccaination for each day by location
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        SUM(CONVERT(int,vac.new_vaccinations)) 
        OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) Rolling_vaccinated
FROM [PortfolioProject]..CovidDeath dea
JOIN [PortfolioProject]..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.location NOT IN ('Asia', 'Europe', 'Africa', 'North America', 'South America', 
                        'Oceanic', 'Antarctia', 'World', 'Upper middle income',
                        'Lower middle income', 'European Union', 'High income',
                        'Low income')
ORDER BY 2,3
;

--- Showing number of the rate of people vaccinated from population by location
--- Using CTE
WITH vac_vs_pop (continent, location, date, population, Rolling_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, SUM(CONVERT(int,vac.new_vaccinations))
        OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) Rolling_vaccinated
FROM [PortfolioProject]..CovidDeath dea
JOIN [PortfolioProject]..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.location NOT IN ('Asia', 'Europe', 'Africa', 'North America', 'South America', 
                        'Oceanic', 'Antarctia', 'World', 'Upper middle income',
                        'Lower middle income', 'European Union', 'High income',
                        'Low income')
---ORDER BY 2,3
)
SELECT continent, location, ((Rolling_vaccinated)/population)*100 vaccination_rate
FROM vac_vs_pop
---GROUP BY continent, location
---ORDER BY 1,2
;

--- Creating temp table for % of people vaccinated from population
USE [PortfolioProject];
DROP TABLE #percentpopnvaccinated ;
CREATE TABLE #percentpopnvaccinated
(
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population NUMERIC,
    New_vaccinations NUMERIC,
    Rolling_vaccinated NUMERIC
)

INSERT INTO #percentpopnvaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
        SUM(CONVERT(bigint,vac.new_vaccinations))
        OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) Rolling_vaccinated
FROM [PortfolioProject]..CovidDeath dea
JOIN [PortfolioProject]..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.location NOT IN ('Asia', 'Europe', 'Africa', 'North America', 'South America', 
                        'Oceanic', 'Antarctia', 'World', 'Upper middle income',
                        'Lower middle income', 'European Union', 'High income',
                        'Low income')
---ORDER BY 2,3
;

SELECT *
FROM #percentpopnvaccinated


--- create a table to be used for vizualization with Power BI
USE PortfolioProject;
DROP TABLE covideda
CREATE TABLE covideda
    (
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population NUMERIC,
    New_vaccinations NUMERIC,
    Rolling_vaccinated NUMERIC
)

INSERT INTO covideda
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
        SUM(CONVERT(bigint,vac.new_vaccinations))
        OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) Rolling_vaccinated
FROM [PortfolioProject]..CovidDeath dea
JOIN [PortfolioProject]..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.location NOT IN ('Asia', 'Europe', 'Africa', 'North America', 'South America', 
                        'Oceanic', 'Antarctia', 'World', 'Upper middle income',
                        'Lower middle income', 'European Union', 'High income',
                        'Low income')
---ORDER BY 2,3
;

SELECT *
FROM PortfolioProject.dbo.covideda
;




