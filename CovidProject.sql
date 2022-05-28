
Select *
From MyPortfolioProject..CovidDeath$
Where continent is not null
order by 3,4

Select *
From MyPortfolioProject ..CovidVaccinations$
order by 3,4

----Select Data that we are going to be using


Select Location, date , total_cases, new_cases , total_deaths, population
From MyPortfolioProject..CovidDeath$

order by 1,2

--Looking at Total Cases vs Deaths
--Shows likehood of dying if you contract cocid in your Country

Select Location, date , total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From MyPortfolioProject..CovidDeath$

Where location like '%Kenya%'

order by 1,2


--Loooking for Total Cases vs Population

---Show what % of population got Covid


Select Location, date , total_cases,  population, (total_cases/population)*100 as DeathPercentage
From MyPortfolioProject..CovidDeath$

Where location like '%Kenya%'

order by 1,2

--Looking ata Countries with the Highest infection rate compared with populations


Select Location,population, MAX(total_cases) as HighestInfecionCount,MAX( (total_cases/population))*100 as PercentagePopolationInfected
From MyPortfolioProject..CovidDeath$

----Where location like '%Kenya%'
Group by location,population
order by PercentagePopolationInfected DESC


--Showing Countries with the Highest Death Count Per Population
Select Location,MAX(cast(total_deaths as int)) as TotalDeathCount
From MyPortfolioProject..CovidDeath$

----Where location like '%Kenya%'
Where continent is not null
Group by location
order by TotalDeathCount DESC

--Wrong using location is not null
Select Location,MAX(cast(total_deaths as int)) as TotalDeathCount
From MyPortfolioProject..CovidDeath$

----Where location like '%Kenya%'
Where location is not null
Group by location
order by TotalDeathCount DESC



----LET'S BREAK DOWN BY CONTINENT



--Showing the Continent with highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From MyPortfolioProject..CovidDeath$

----Where location like '%Kenya%'
Where continent is not null
Group by continent
order by TotalDeathCount DESC


---GLOBAL NUMBERS

Select  date , sum(new_cases), sum(cast(new_deaths as int))   --total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From MyPortfolioProject..CovidDeath$

--Where location like '%Kenya%'
Where continent is not null
Group by date
order by 1,2


Select  date , sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths , sum(cast(new_deaths as int))/SUM(new_cases)*100 as   DeathPercentage
From MyPortfolioProject..CovidDeath$

--Where location like '%Kenya%'
Where continent is not null
Group by date
order by 1,2


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths , SUM(cast(new_deaths as int))/SUM(new_cases)*100 as   DeathPercentage
From MyPortfolioProject..CovidDeath$

--Where location like '%Kenya%'
Where continent is not null
--Group by date
order by 1,2

--Looking total population vs vaccinations

Select *
From MyPortfolioProject..CovidDeath$  dea
Join MyPortfolioProject..CovidVaccinations$ vac
    ON dea.location = vac.location
	and dea.date = vac.date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location)
From MyPortfolioProject..CovidDeath$  dea
JOIN MyPortfolioProject..CovidVaccinations$ vac
    ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-----
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.Date )
as RollingPeopeleVaccinated
From MyPortfolioProject..CovidDeath$  dea
JOIN MyPortfolioProject..CovidVaccinations$ vac
    ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
 
order by 2,3


--USE CTE

With PopvsVac(Continet, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.Date )
as RollingPeopeleVaccinated
From MyPortfolioProject..CovidDeath$  dea
JOIN MyPortfolioProject..CovidVaccinations$ vac
    ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
 
--order by 2,3


)

select *

From PopvsVac

With PopvsVac(Continet, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.Date )
as RollingPeopeleVaccinated
From MyPortfolioProject..CovidDeath$  dea
JOIN MyPortfolioProject..CovidVaccinations$ vac
    ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
 
--order by 2,3


)

select *, (RollingPeopleVaccinated/Population)*100

From PopvsVac



With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From MyPortfolioProject..CovidDeath$ dea
Join MyPortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


----Temp Table

Drop Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated(

Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,

New_vaccinations numeric,
RollingPeopleVaccinated numeric



)

Insert into  #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From MyPortfolioProject..CovidDeath$ dea
Join MyPortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From  #PercentPopulationVaccinated


---Create View to store data for visualisations

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From MyPortfolioProject..CovidDeath$ dea
Join MyPortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3


select *
From PercentPopulationVaccinated