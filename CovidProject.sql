Select *
FROM CovidDeaths
Where continent is not null
order by 3,4

--Select *
--FROM CovidVaccinations
--order by 3,4

--SELEct Data to be used


Select Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying of covid
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE Location = 'Canada'
order by 1,2

--Total Cases vs Population
--Shows what percentage of canadian population got covid
Select Location, date,population, total_cases,  (total_cases/population)*100 as CasePercentage
FROM CovidDeaths
WHERE Location = 'Canada'
order by 1,2

--Countries with highest infection rate compared to population
Select Location, population, MAX(total_cases) as highestInfectionCount,  MAX((total_cases/population))*100 as PercentofPopulationInfected
FROM CovidDeaths
--WHERE Location = 'Canada'
Where continent is not null
GROUP BY location, population
order by PercentofPopulationInfected DESC


--Showing countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE Location = 'Canada'
Where continent is not null
GROUP BY location
order by TotalDeathCount DESC


--Broken down by continent
-- Showing continent with the hgihest death count
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE Location = 'Canada'
Where continent is not null 
group by continent
order by TotalDeathCount DESC


--Global Numbers
Select date, SUM(new_cases) as TotalCases,SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
Where continent is not null
Group by date
order by 1,2

--World Total
Select  SUM(new_cases) as TotalCases,SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
Where continent is not null
--Group by date
order by 1,2


--total population vs vaccinations

SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by  dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
FROM CovidDeaths as dea
Join CovidVaccinations  as vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
Order By 2,3


--Use CTE

With PopvsVac (Continent, Location, Date, Population,New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by  dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
FROM CovidDeaths as dea
Join CovidVaccinations  as vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--Order By 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--USE Tempt Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)


Insert into #PercentPopulationVaccinated
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by  dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
FROM CovidDeaths as dea
Join CovidVaccinations  as vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
Order By 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE View PercentPopulationVaccinated as
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by  dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
FROM CovidDeaths as dea
Join CovidVaccinations  as vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--Order By 2,3
