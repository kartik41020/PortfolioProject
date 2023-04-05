-- ctrl + space to autocomplete

--Covid 19 Data Exploration 
SELECT * 
FROM public."CovidDeaths"
WHERE continent IS NOT NULL -- removes all the rows having continents in location
ORDER BY 3,4

SELECT * 
FROM public."CovidVaccinations"
WHERE continent IS NOT NULL 
ORDER BY 3,4


-- Select Data that we are going to be starting with
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM public."CovidDeaths"
WHERE continent IS NOT NULL 
ORDER BY 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths,
(total_deaths/total_cases)*100 as Death_Percentage
FROM public."CovidDeaths"
WHERE continent IS NOT NULL 
ORDER BY 1,2

SELECT Location, date, total_cases, total_deaths,
(total_deaths/total_cases)*100 as DeathPercentage
FROM public."CovidDeaths"
WHERE continent = 'Africa' AND continent IS NOT NULL 
ORDER BY 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
SELECT Location, date, Population, total_cases,
(total_cases/population)*100 as InfectedPopulation_Percentage
FROM public."CovidDeaths"
WHERE continent IS NOT NULL 
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount,
Max((total_cases/population))*100 as HighestInfectedPopulation_Percentage
FROM public."CovidDeaths"
WHERE continent IS NOT NULL
GROUP BY Location, Population
ORDER BY 4 DESC NULLS LAST 
--PostgreSQL treat NULL values as very large and put them at the beginning of a descending sort order.


-- Countries with Highest Death Count per Population
SELECT Location, population, MAX(Total_deaths) AS TotalDeathCount,
(MAX(Total_deaths)/population)*100 AS DeathPerPopulation_percentage
FROM public."CovidDeaths"
WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY 3 DESC NULLS LAST 
LIMIT 5

SELECT Location, population, SUM(new_deaths) AS TotalDeathCount,
(SUM(new_deaths)/population)*100 AS DeathPerPopulation_percentage
FROM public."CovidDeaths"
WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY 3 DESC NULLS LAST 
LIMIT 5
				 
-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population
SELECT continent, MAX(Total_deaths) AS TotalDeathCount
-- , population, (MAX(Total_deaths)/population)*100 AS DeathPerPopulation_percentage
FROM public."CovidDeaths"
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC NULLS LAST 

SELECT continent, SUM(new_deaths) AS TotalDeathCount
-- , population, (SUM(new_deaths)/population)*100 AS DeathPerPopulation_percentage
FROM public."CovidDeaths"
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC NULLS LAST

-- GLOBAL NUMBERS
--Total cases and deaths per day
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths,
(SUM(new_deaths)/SUM(new_cases))*100 AS death_percentage
FROM public."CovidDeaths"
WHERE continent IS NOT NULL 
GROUP BY 1
ORDER BY 1

--Total cases and deaths
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths,
(SUM(new_deaths)/SUM(new_cases))*100 AS death_percentage
FROM public."CovidDeaths"
WHERE continent IS NOT NULL 


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS total_vaccinations
-- , (daily_vaccinations/population)*100
-- We can't use an alias table name for other operations. It will show error.
FROM public."CovidDeaths" AS dea JOIN public."CovidVaccinations" AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2, 3 

SELECT dea.location, dea.date, MAX(vac.new_vaccinations) AS daily_vaccinations,
MAX(vac.total_vaccinations) AS total_vaccinations
FROM public."CovidDeaths" AS dea JOIN public."CovidVaccinations" AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
GROUP BY dea.date, dea.location
ORDER BY 1, 2

-- Using CTE to perform Calculation on Partition By in previous query
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, total_vaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS total_vaccinations
-- , (daily_vaccinations/population)*100
-- We can't use an alias table name for other operations. It will show error.
FROM public."CovidDeaths" AS dea JOIN public."CovidVaccinations" AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2, 3
)
SELECT *, (total_vaccinations/Population)*100 AS VaccinationsPerPopulation
FROM PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query
DROP Table if exists #PercentPopulationVaccinated 
--if we want to make any changes to our table, DROP table will delete the existing table so that
CREATE TEMP TABLE PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *
, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated

-- Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM public."CovidDeaths" AS dea
JOIN public."CovidVaccinations" AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * FROM PercentPopulationVaccinated
