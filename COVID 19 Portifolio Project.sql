
--Showing CovidDeaths table
SELECT * 
FROM PortifolioProject..CovidDeaths
ORDER BY 3, 4



--Showing CovidVaccination table
SELECT *
FROM PortifolioProject..CovidVaccinations
ORDER BY 3, 4



--Selecting data that i will be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortifolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1, 2



--Looking at total cases vs total deaths
--Likelihood of dying if contract Covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM PortifolioProject..CovidDeaths
WHERE Location LIKE '%china%' 
AND continent is NOT NULL
ORDER BY 1, 2



--Looking at Total cases vs Population
--What percentage of the population got Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS Case_Percentage
FROM PortifolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1, 2




--Looking at countries with highest infection rate

SELECT Location, population, MAX(total_cases) AS Highest_Infection_Count, 
MAX(total_cases/population)*100 AS Percentage_Population_Infected
FROM PortifolioProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY Location, population
ORDER BY Percentage_Population_Infected DESC



--Showing countries with highest death count

SELECT Location, MAX(cast (total_deaths as int)) AS Total_Death_Count
FROM PortifolioProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY Location
ORDER BY Total_Death_Count DESC




--Showing the continent with Highest deaths count per population

SELECT continent, MAX(cast (total_deaths as int)) AS Total_Death_Count
FROM PortifolioProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC




--Global numbers by dates

SELECT date, SUM(new_cases) AS Total_cases, SUM(cast(new_deaths as int)) AS Total_deaths, 
SUM(cast(new_deaths as int))/ SUM(new_cases)*100 AS DeathPercentage
FROM PortifolioProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1, 2




--Global numbers 

SELECT SUM(new_cases) AS Total_cases, SUM(cast(new_deaths as int)) AS Total_deaths, 
SUM(cast(new_deaths as int))/ SUM(new_cases)*100 AS DeathPercentage
FROM PortifolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1, 2




--USE CTE
--Looking at total population vs vaccinations

WITH Pop_vs_Vac (Continent, Location, Date, Population, New_vaccinations, Rolling_people_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations))  OVER (partition by dea.location ORDER BY dea.location, 
dea.date) AS Rolling_people_vaccinated
--(Rolling_people_vaccinated/population)*100
FROM PortifolioProject..CovidDeaths dea
JOIN PortifolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 1, 2, 3
)
SELECT *, (Rolling_people_vaccinated/population)*100 AS Rolling_people_vaccinated_percetage
FROM Pop_vs_Vac





--TEMP TABLES
--Looking at total population vs vaccinations

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_people_vaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations))  OVER (partition by dea.location ORDER BY dea.location, 
dea.date) AS Rolling_people_vaccinated
--(Rolling_people_vaccinated/population)*100
FROM PortifolioProject..CovidDeaths dea
JOIN PortifolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 1, 2, 3
SELECT *, (Rolling_people_vaccinated/Population)*100 AS Rolling_people_vaccinated_percetage
FROM #PercentPopulationVaccinated





--Creating a view to store data for later visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations))  OVER (partition by dea.location ORDER BY dea.location, 
dea.date) AS Rolling_people_vaccinated
--(Rolling_people_vaccinated/population)*100
FROM PortifolioProject..CovidDeaths dea
JOIN PortifolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 1, 2, 3

SELECT * 
FROM PercentPopulationVaccinated