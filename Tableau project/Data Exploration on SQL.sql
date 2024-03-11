-- Viewing Data

Select *
From PortfolioProject2..CovidDeaths
Where continent is not null
Order by 3,4


--Select *
--From PortfolioProject2..CovidVaccination
--Order by 3,4

Select location, date,total_cases, new_cases, total_deaths, population
From PortfolioProject2..CovidDeaths
Where continent is not null
Order by 1,2

-- Looking at Total Cases vs Total Deaths

Select  location, date,total_cases, new_cases, total_deaths,(cast (total_cases as float) / cast(total_deaths as float))*100 as DeathPercentage
From PortfolioProject2..CovidDeaths
Where location like '%Nigeria%'
Order by 1,2

-- Looking at Total Cases vs Population

Select  location, date,total_cases, population,(cast (total_cases as float) / cast(population as float))*100 as DeathPercentage
From PortfolioProject2..CovidDeaths
Where location like '%Nigeria%'
Order by 1,2


--Looking at countries with highest infection rate

Select  location, population,MAX(total_cases) as HighestInfectionCount, MAX(cast (total_cases as float) / cast(population as float))*100 as PercentPopulationInfected
From PortfolioProject2..CovidDeaths
--Where location like '%Nigeria%'
Where continent is not null
Group by location, population
Order by PercentPopulationInfected desc

-- Countries showing the highest death count per population

Select  continent,MAX (cast(total_deaths as int)) as TotalDeathsCount
From PortfolioProject2..CovidDeaths
--Where location like '%Nigeria%'
Where continent is not null
Group by continent
Order by TotalDeathsCount desc

-- BREAKING IT DOWN BY CONTINENT

Select  continent,MAX (cast(total_deaths as int)) as TotalDeathsCount
From PortfolioProject2..CovidDeaths
--Where location like '%Nigeria%'
Where continent is not null
Group by continent
Order by TotalDeathsCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject2..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Joining codvicDeaths Table and CodvicVaccine Table
-- Looking at Total Population vs Vaccination


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
	dea.Date) 
From PortfolioProject2..CovidDeaths dea
Join PortfolioProject2..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 1,2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
	dea.Date) as RollingPeopleVaccinations
From PortfolioProject2..CovidDeaths dea
Join PortfolioProject2..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 1,2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Temporal Table

--DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
	dea.Date) 
From PortfolioProject2..CovidDeaths dea
Join PortfolioProject2..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 1,2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating view to store data for visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
	dea.Date) as RollingPeopleVaccinations
From PortfolioProject2..CovidDeaths dea
Join PortfolioProject2..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 1,2,3

