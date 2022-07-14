


select * 
from PortfolioProject..CovidDeaths
order by 2,3

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases Vs Total Deaths
-- Shows Likelihood of dying if you contract covid in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from PortfolioProject..CovidDeaths
where location like '%state%' and continent is not null
order by 1,2

--Looking at Total Cases Vs Total Deaths
-- Shows what percentage of population got Covid

select Location, date, Population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected 
from PortfolioProject..CovidDeaths
where location like '%state%' and continent is not null
order by 1,2

-- Looking at countries with Highest Infection Rate compared to Population

select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as  PercentagePopulationInfected 
from PortfolioProject..CovidDeaths
--where location like '%state%'
where continent is not null
group by location, population
order by PercentagePopulationInfected desc


-- Showing Countries with Highest Death Count per Population


select Location, MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
--where location like '%state%'
where continent is not null
group by location
order by TotalDeathCount  desc

--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing Continents with the highest death count per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
--where location like '%state%'
where continent is  not null 
group by continent
order by TotalDeathCount  desc


--GLOBAL NUMBERS

--Showing total cases , total deaths and death percentage per day globally

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

--Showing total cases , total deaths and death percentage globally

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null

--Looking at Total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations )) over(partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- USE CTE

with PopvsVac(Continent,location,Date,Population,new_vaccinations, RollingPeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations )) over(partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)

select *, (RollingPeoplevaccinated/population)*100
from PopvsVac


--TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeoplevaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations )) over(partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select *, (RollingPeoplevaccinated/population)*100
from #PercentPopulationVaccinated


--Creating view to store data for later visualisations

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations )) over(partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select *
from PercentPopulationVaccinated