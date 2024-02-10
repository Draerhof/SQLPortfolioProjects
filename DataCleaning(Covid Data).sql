SELECT *
FROM SQLPortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM SQLPortfolioProject.dbo.CovidVaccinations$
--ORDER BY 3,4

SELECT  Location, date, total_cases, new_cases, total_deaths, population
FROM SQLPortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
ORDER BY 1,2


-- Looking at Total Cases VS Total Deaths
--Shows likelihood of dying if you contract covid in your country

SELECT  Location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases*100),2) as percentage_of_deaths
FROM SQLPortfolioProject.dbo.CovidDeaths$
--WHERE ROUND((total_deaths/total_cases*100),2) is NOT NULL
WHERE location like '%Ukraine%'
and continent is not null
ORDER BY 1,2


-- Looking at total_cases VS Population
-- Shows what percentage of population got Covid

SELECT  Location, date, population, total_cases, ROUND((total_cases/population*100),2) as Percent_of_population_infected
FROM SQLPortfolioProject.dbo.CovidDeaths$
WHERE location like '%Ukraine%' and continent is not null
ORDER BY 1,2


-- Looking at Countries with Highest infection rate compared to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX(ROUND((total_cases/population*100),2)) as Percent_of_population_infected
FROM SQLPortfolioProject.dbo.CovidDeaths$
--WHERE location like '%Ukraine%'
WHERE continent is not null
GROUP BY Location, population
ORDER BY Percent_of_population_infected DESC


-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths as int)) as Total_death_count
FROM SQLPortfolioProject.dbo.CovidDeaths$
--WHERE location like '%Ukraine%'
WHERE continent is not null
GROUP BY Location
ORDER BY Total_death_count DESC




-- Let's break things down by continent

SELECT continent, MAX(cast(total_deaths as int)) as Total_death_count
FROM SQLPortfolioProject.dbo.CovidDeaths$
--WHERE location like '%Ukraine%'
WHERE continent is not null
GROUP BY continent
ORDER BY Total_death_count DESC


-- Breaking global numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,  SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as Death_Percentage
FROM SQLPortfolioProject..CovidDeaths$
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2



-- Looking at Total population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	   SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location ORDER by dea.location, dea.Date) as RollingPeopleVaccinated
	   , (RollingPeopleVaccinated/population) * 100
FROM SQLPortfolioProject..CovidDeaths$ dea
JOIN SQLPortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- USE CTE

WITH PopulationVsVaccination (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	   SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location ORDER by dea.location, dea.Date) as RollingPeopleVaccinated
	  -- , (RollingPeopleVaccinated/population) * 100
FROM SQLPortfolioProject..CovidDeaths$ dea
JOIN SQLPortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population) * 100 as RollingPeopleVaccinatedPercentage
FROM PopulationVsVaccination




-- Use of the temp table

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	   SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location ORDER by dea.location, dea.Date) as RollingPeopleVaccinated
	  -- , (RollingPeopleVaccinated/population) * 100
FROM SQLPortfolioProject..CovidDeaths$ dea
JOIN SQLPortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population) * 100 as RollingPeopleVaccinatedPercentage
FROM #PercentPopulationVaccinated



-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	   SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location ORDER by dea.location, dea.Date) as RollingPeopleVaccinated
	  -- , (RollingPeopleVaccinated/population) * 100
FROM SQLPortfolioProject..CovidDeaths$ dea
JOIN SQLPortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated
