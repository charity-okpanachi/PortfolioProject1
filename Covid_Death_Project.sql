--CHECKING DATA
SELECT *
FROM CovidDeaths
ORDER BY 3,4


SELECT *
FROM CovidVaccinations
ORDER BY 3,4


--SELECTING DATA TO BE USED
SELECT location, date, total_cases, new_cases, total_deaths, population_density
FROM CovidDeaths
ORDER BY 1,2


--LOOKING AT TOTAL CASES VS TOTAL DEATHS 
SELECT location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float)) as DeathPercentage
FROM CovidDeaths
ORDER BY 1,2


--LIKELIHOOD OF DYEING IF YOU CONTRACT COVID IN NIGERIA 
SELECT location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
FROM CovidDeaths
WHERE  location like '%Nigeria%'
ORDER BY 1,2


--LOOKING AT TOTAL CASES VS POPULATION 
--SHOWS WHAT PERCENTAGE GOT COVID 
SELECT location, date, population, total_cases, 
	(cast(total_cases as float)/cast(population as float))*100 as PopulationInfectedPercentage
FROM CovidDeaths
WHERE  location like '%Nigeria%'
and continent is not null
ORDER BY 1,2


-- COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION 
SELECT location, population, Max(total_cases) as HigestInfectionCount, 
       Max((cast(total_cases as float)/cast(population as float)))*100 as PopulationInfectedPercentage
FROM CovidDeaths
--WHERE  location like '%Nigeria%'
GROUP BY location, population
ORDER BY PopulationInfectedPercentage desc


--COUNTRIES WITH HIGEST DEATH COUNT PER POPULATION 
SELECT location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE  location like '%Nigeria%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc


--BREAKING DOWN BY CONTINENT 
SELECT continent, Max(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc



--GLOBAL NUMBERS 
SELECT date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2


SELECT date, SUM(new_cases) as NewCases, SUM(new_deaths) as NewDeaths
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


SELECT *
FROM CovidDeaths AS DEA
JOIN CovidVaccinations as VAC
    ON DEA.location = VAC.location
	AND DEA.date = VAC.date


--LOOKING AT TOTAL POPULATION VS VACINATION 
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
       SUM(cast(VAC.new_vaccinations as float)) 
	   OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS DEA
JOIN CovidVaccinations as VAC
    ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY 2,3


-- USE CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
       SUM(cast(VAC.new_vaccinations as float)) 
	   OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS DEA
JOIN CovidVaccinations as VAC
    ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population) * 100
FROM PopvsVac


--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
       SUM(cast(VAC.new_vaccinations as float)) 
	   OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS DEA
JOIN CovidVaccinations as VAC
    ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population) * 100
FROM #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALISATION 
Create view PercentPopulationVaccinated as
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
       SUM(cast(VAC.new_vaccinations as float)) 
	   OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS DEA
JOIN CovidVaccinations as VAC
    ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL