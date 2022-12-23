select *
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4


--selecting only required columns
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--where location like '%state%'
where continent is not null
order by 1,2

-- Countries with Highest Infection Rate compared to Population

select location, population, max(total_cases) as HighestInfectionCount, (max(total_cases)/population)*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths$
--where location like '%state%'
where continent is not null
group by location, population
order by PercentagePopulationInfected desc

-- Countries with Highest Death Count per Population

select location,  max(convert(int, total_deaths)) as HighestDeaths
from PortfolioProject..CovidDeaths$
--where location like '%state%'
where continent is not null
group by location
order by HighestDeaths desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

select continent, sum(convert(int,total_deaths)) as TotalDeathsContinent
from PortfolioProject..CovidDeaths$
where continent is not null
--where location like '%state%'
group by continent
order by TotalDeathsContinent desc

-- GLOBAL NUMBERS of TotalCases vs TotalDeaths

select sum(new_cases) as TotalCases, sum(convert(int,new_deaths)) as TotalDeaths, (sum(convert(int,new_deaths)))/sum(new_cases)*100 as PercentageGlobalDeaths
from PortfolioProject..CovidDeaths$
where continent is not null


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date)as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
  on dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null
order by 2,3

--or

select dea.continent, dea.location, population, sum(convert(int,vac.new_vaccinations)) as TotalVaccinations
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
group by dea.continent, dea.location, population
order by 1,2


-- Using CTE to perform Calculation on Partition By in previous query

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinations)
as
(
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date)as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
  on dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinations/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location Nvarchar(255),
Data datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinations numeric,
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date)as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
  on dea.location=vac.location
  and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinations/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
