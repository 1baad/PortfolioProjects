Select *  
From PortfolioProject..CovidDeaths
order by 3,4 

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2


--Total cases vs Total Deaths. Likelihood of dying after having Covid
Select Location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast (total_cases as float))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location = 'United States'
order by 1,2

-- Total Cases vs Population
-- Percentage of population that got Covid
Select Location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast (total_cases as float))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location = 'United States'
order by 1,2

-- Countries with Highest Infection rate by population
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Countries with Highest Death Rate by Population
Select Location, Population, MAX(cast(total_deaths as int)) as DeathCount,  Max((total_deaths/population))*100 as PercentPopulationDied
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location, Population
order by PercentPopulationDied desc

-- Showing continents with the highest death count
Select DISTINCT continent, Population, MAX(cast(total_deaths as int)) as DeathCount,  Max((total_deaths/population))*100 as PercentPopulationDied
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent, Population
order by DeathCount desc


-- GLOBAL Numbers
Select DISTINCT continent
From PortfolioProject..CovidDeaths
Where continent is not null



-- USE CTE to perform calculation 
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 1,2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
-- Total Population vs Vaccinations
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 1,2,3

Select *, (RollingPeopleVaccinated/population) *100
From #PercentPopulationVaccinated

--Creating a view to store data
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *
From PercentPopulationVaccinated