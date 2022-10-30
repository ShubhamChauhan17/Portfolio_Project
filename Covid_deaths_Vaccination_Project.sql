SELECT *  FROM `kagglefirst-step1717.CovidProject.CovidDeaths` 
ORDER BY 3,4

SELECT Location,date,total_cases,new_cases,total_deaths, population
FROM `kagglefirst-step1717.CovidProject.CovidDeaths`
ORDER BY 1,2

-- Looking at total cases vs Total deaths
-- Percentage of people dying if exposed to the virus in India

SELECT Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM `kagglefirst-step1717.CovidProject.CovidDeaths`
WHERE location like '%India%'
ORDER BY 1,2

-- Total cases vs Population
-- Percentage of people who got covid

SELECT Location,date,population, total_cases, (total_cases/ population)*100 AS PercentPopulationInfected
FROM `kagglefirst-step1717.CovidProject.CovidDeaths`
-- WHERE location like '%India%'
ORDER BY 1,2


-- Looking at countries with highest infection rate

SELECT Location,population, MAX(total_cases) AS HighestInfecCount, MAX((total_cases/ population))*100 AS PercentPopulationInfected
FROM `kagglefirst-step1717.CovidProject.CovidDeaths`
-- WHERE location like '%India%'
GROUP BY  Location,population
ORDER BY PercentPopulationInfected DESC

-- Countries with highest death.

SELECT Location,MAX(total_deaths) AS TotalDeathCount
FROM `kagglefirst-step1717.CovidProject.CovidDeaths`
-- Data cleaning required to show only countries and not continent
WHERE continent IS NOT NULL
GROUP BY  Location,population
ORDER BY TotalDeathCount DESC

-- Data exploration of Covid through Continents

SELECT continent,MAX(total_deaths) AS TotalDeathCount
FROM `kagglefirst-step1717.CovidProject.CovidDeaths`
WHERE continent IS NOT NULL
GROUP BY  continent
ORDER BY TotalDeathCount DESC


-- Global numbers

SELECT date,SUM(new_cases) AS sum_new_cases,SUM(new_deaths) AS sum_new_deaths, SUM(new_deaths)/SUM(new_cases)* 100 AS DeathPercentage
FROM `kagglefirst-step1717.CovidProject.CovidDeaths`
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Percentage of world population effected

SELECT SUM(new_cases) AS sum_new_cases,SUM(new_deaths) AS sum_new_deaths, SUM(new_deaths)/SUM(new_cases)* 100 AS DeathPercentage
FROM `kagglefirst-step1717.CovidProject.CovidDeaths`
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Over to Vaccination Table
-- Total population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, SUM(vacc.new_vaccinations) OVER (PARTITION BY dea.location ORDER  BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM `kagglefirst-step1717.CovidProject.CovidDeaths` AS dea
JOIN `kagglefirst-step1717.CovidProject.CovidVaccinations` AS vacc 
   ON dea.location = vacc.location AND dea.date = vacc.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- Using CTE

WITH PopvsVac (continent, location,date, population, new_vaccinations,RollingPeopleVaccinated )
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, SUM(vacc.new_vaccinations) OVER (PARTITION BY dea.location ORDER  BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM `kagglefirst-step1717.CovidProject.CovidDeaths` AS dea
JOIN `kagglefirst-step1717.CovidProject.CovidVaccinations` AS vacc 
   ON dea.location = vacc.location AND dea.date = vacc.date
WHERE dea.continent IS NOT NULL
)
SELECT * 
FROM PopvsVac

-- Temp Tables

DROP TABLE IF EXISTS PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated
(
  continent varchar(255)
  location varchar(255)
  date datetime,
  population int,
  new_vaccinations int,
  RollingPeopleVaccinated int,
)
INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, SUM(vacc.new_vaccinations) OVER (PARTITION BY dea.location ORDER  BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM `kagglefirst-step1717.CovidProject.CovidDeaths` AS dea
JOIN `kagglefirst-step1717.CovidProject.CovidVaccinations` AS vacc 
   ON dea.location = vacc.location AND dea.date = vacc.date


SELECT  *, (RollingPeopleVaccinated/population)*100
FROM PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
